import argparse
import collections
import datetime
import os
import pathlib
import re
import shutil
import signal
import subprocess
import sys
import time

WORK = pathlib.Path.cwd() / 'tmp/work'
EVENT = re.compile(
    r'NOTE: recipe (.+?): task (do_\w+): (Started|Succeeded|Failed)'
)
COUNT = re.compile(r'Running (?:noexec )?task (\d+) of (\d+)')


class LogState:
    def __init__(self, path):
        self.path = path
        self.position = 0
        self.active = {}
        self.finished = collections.deque(maxlen=4)
        self.dispatched = self.total = 0
        self.errors = collections.deque(maxlen=2)
        self.summary = ''

    def update(self):
        if not self.path.exists():
            return
        with self.path.open(errors='replace') as stream:
            stream.seek(self.position)
            for line in stream:
                match = COUNT.search(line)
                if match:
                    self.dispatched, self.total = map(int, match.groups())
                match = EVENT.search(line)
                if match:
                    recipe, stage, status = match.groups()
                    if stage.endswith('_setscene'):
                        continue
                    key = (recipe, stage)
                    if status == 'Started':
                        self.active[key] = time.time()
                    else:
                        self.active.pop(key, None)
                        self.finished.append((recipe, stage, status))
                if line.startswith('ERROR:'):
                    self.errors.append(line.strip())
                if 'Tasks Summary:' in line:
                    self.summary = line.strip().removeprefix('NOTE: ')
            self.position = stream.tell()


def elapsed(seconds):
    seconds = max(0, int(seconds))
    return f'{seconds // 3600:d}:{seconds // 60 % 60:02d}:{seconds % 60:02d}'


class TaskLogs:
    def __init__(self):
        self.index = {}
        self.next_scan = 0

    def find(self, recipe, stage):
        if time.time() >= self.next_scan:
            self.index = collections.defaultdict(list)
            for temp in WORK.glob('*/*/*/temp'):
                self.index[temp.parent.parent.name].append(temp)
            self.next_scan = time.time() + 30
        candidates = [pn for pn in self.index if recipe.startswith(pn + '-')]
        if not candidates:
            return None
        pn = max(candidates, key=len)
        paths = [temp / ('log.' + stage) for temp in self.index[pn]]
        paths = [p for p in paths if p.exists()]
        return max(paths, key=lambda p: p.lstat().st_mtime) if paths else None

    def progress(self, recipe, stage, started):
        path = self.find(recipe, stage)
        if path is None:
            return '--', elapsed(time.time() - started), 'running; no counter'
        try:
            started = path.lstat().st_mtime
            with path.open('rb') as stream:
                stream.seek(max(0, path.stat().st_size - 262144))
                tail = stream.read().decode(errors='replace')
            counters = list(re.finditer(
                r'\[\s*(\d+)\s*/\s*(\d+)\s*\]'
                r'|\[\s*(\d+(?:\.\d+)?)%\s*\]', tail))
            if counters:
                match = counters[-1]
                if match.group(3):
                    percent = float(match.group(3))
                    detail = 'build-tool counter'
                else:
                    current, total = int(match.group(1)), int(match.group(2))
                    if not total or current > total:
                        return (
                            '--', elapsed(time.time() - started),
                            'running; no counter',
                        )
                    percent = current * 100 / total
                    detail = f'{current:,}/{total:,} build steps'
                return (
                    f'{percent:5.1f}%', elapsed(time.time() - started), detail,
                )
        except OSError:
            pass
        return '--', elapsed(time.time() - started), 'running; no counter'


def render(states, tasklogs, title=None, exitfile=None):
    for state in states:
        state.update()
    state = states[0]
    name = title or 'BUILD PROGRESS'
    exitfile = exitfile or state.path.with_suffix('.exit')
    result = exitfile.read_text().strip() if exitfile.exists() else None
    status = (
        ('SUCCEEDED' if result == '0' else 'FAILED')
        if result is not None else 'RUNNING'
    )
    width, height = shutil.get_terminal_size((150, 40))
    lines = [
        f'UCM-iMX95  |  {name}  |  {status}  |  '
        f'{datetime.datetime.now():%H:%M:%S}', '',
    ]
    if state.total:
        percent = state.dispatched * 100 / state.total
        lines.append(
            f'Tasks dispatched: {state.dispatched:,}/{state.total:,}  '
            f'({percent:.1f}%)   Active: {len(state.active)}'
        )
    else:
        lines.append('Preparing task queue...')
    lines += [
        '', f'{"PACKAGE":<39} {"STAGE":<25} '
        f'{"PROGRESS":>9} {"ELAPSED":>9}  DETAIL',
        '-' * min(width - 1, 122),
    ]
    active = sorted(state.active.items(), key=lambda entry: entry[1])
    for (recipe, stage), started in active:
        progress, age, detail = tasklogs.progress(recipe, stage, started)
        lines.append(
            f'{recipe[:39]:<39} {stage.removeprefix("do_")[:25]:<25} '
            f'{progress:>9} {age:>9}  {detail}'
        )
    if not active:
        lines.append(
            'No active package tasks.' if result is not None
            else 'Waiting for the next task event...'
        )
    lines += ['', 'RECENTLY FINISHED']
    for recipe, stage, finished in reversed(state.finished):
        progress = '100.0%' if finished == 'Succeeded' else 'FAILED'
        lines.append(
            f'{recipe[:39]:<39} {stage.removeprefix("do_")[:25]:<25} '
            f'{progress:>9}'
        )
    lines += [
        '', '-- = stage provides no numeric counter. '
        'Percentages count steps, not time.',
    ]
    if title:
        lines.append(
            'Refresh: 2 seconds. Ctrl-C interrupts the build. Full log: '
            + str(state.path)
        )
    else:
        lines.append(
            'Refresh: 2 seconds. Ctrl-C stops this display only; '
            'the build continues.'
        )
    if state.summary:
        lines.append(state.summary)
    lines.extend(state.errors)
    return '\n'.join(
        line[:max(1, width - 1)] for line in lines[:max(1, height - 1)]
    )


def run_build(command, logpath):
    global WORK
    if not shutil.which(command[0]):
        print(
            f'{command[0]} is not on PATH. '
            'Source the Yocto build environment first.', file=sys.stderr,
        )
        return 2
    if (pathlib.Path(command[0]).name == 'bitbake'
            and not pathlib.Path('conf/bblayers.conf').is_file()):
        print(
            'Run this command from the configured Yocto build directory.',
            file=sys.stderr,
        )
        return 2
    if logpath is None:
        stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
        logpath = (
            pathlib.Path.cwd() / 'build-progress-logs'
            / f'build-{stamp}-{os.getpid()}.log'
        )
    logpath = logpath.resolve()
    logpath.parent.mkdir(parents=True, exist_ok=True)
    if logpath.exists():
        print(f'Refusing to overwrite existing log: {logpath}', file=sys.stderr)
        return 2
    exitfile = logpath.with_suffix('.exit')
    state = LogState(logpath)
    logs = TaskLogs()
    with logpath.open('w') as output:
        process = subprocess.Popen(
            command, stdout=output, stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        interrupted = False
        try:
            while True:
                result = process.poll()
                if result is not None:
                    exitfile.write_text(str(result) + '\n')
                view = render(
                    [state], logs, title=' '.join(command), exitfile=exitfile,
                )
                sys.stdout.write('\033[H\033[2J' + view + '\n')
                sys.stdout.flush()
                if result is not None:
                    break
                time.sleep(2)
        except KeyboardInterrupt:
            interrupted = True
            print(
                '\nInterrupting BitBake; waiting for it to stop. '
                'A second Ctrl-C forces termination.'
            )
            try:
                os.killpg(process.pid, signal.SIGINT)
                result = process.wait()
            except ProcessLookupError:
                result = process.wait()
            except KeyboardInterrupt:
                os.killpg(process.pid, signal.SIGTERM)
                result = process.wait()
            exitfile.write_text(str(result) + '\n')
    print('\nFull build log: ' + str(logpath))
    if interrupted:
        return 130
    return result if result >= 0 else 128 - result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--once', action='store_true')
    parser.add_argument(
        '--log', type=pathlib.Path,
        help='Log to follow, or new log path with --run',
    )
    parser.add_argument(
        '--work-dir', type=pathlib.Path, help='Yocto tmp/work directory',
    )
    parser.add_argument(
        '--run', nargs=argparse.REMAINDER,
        help='Run a command with the compact display',
    )
    args = parser.parse_args()
    if args.work_dir:
        WORK = args.work_dir.resolve()
    elif args.run:
        WORK = pathlib.Path.cwd() / 'tmp/work'
    if args.run:
        sys.exit(run_build(args.run, args.log))
    if not args.log:
        parser.error('Specify --run COMMAND or --log FILE')
    states = [LogState(args.log.resolve())]
    logs = TaskLogs()
    try:
        while True:
            output = render(states, logs)
            if args.once:
                print(output)
                break
            sys.stdout.write('\033[H\033[2J' + output + '\n')
            sys.stdout.flush()
            completed = states[0].path.with_suffix('.exit')
            if completed.exists():
                result = int(completed.read_text().strip())
                sys.exit(result if result >= 0 else 128 - result)
            time.sleep(2)
    except KeyboardInterrupt:
        pass
