def compulab_devtool_uboot_localversion(d):
    import os
    import subprocess

    localversion = d.getVar("LOCALVERSION") or ""
    src = d.getVar("EXTERNALSRC") or d.getVar("S")
    git_dir = os.path.join(src, ".git") if src else ""

    def git(*args, default=None):
        proc = subprocess.run(
            ["git", "--git-dir", git_dir, *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
        if proc.returncode:
            if default is not None:
                return default
            raise subprocess.CalledProcessError(proc.returncode, proc.args)
        return proc.stdout.strip()

    if not git_dir or not os.path.exists(git_dir):
        return localversion

    srcrev = d.getVar("SRCREV") or ""
    if srcrev == "INVALID":
        srcrev = d.getVar("SRCREV_machine") or ""

    if srcrev == "AUTOINC":
        branch = git("symbolic-ref", "--short", "-q", "HEAD", default="")
        head = git("rev-parse", "--verify", "--short", "origin/%s" % branch, default="") if branch else ""
        if not head:
            head = git("rev-parse", "--verify", "--short", "HEAD")
    else:
        head = git("rev-parse", "--verify", "--short", srcrev)

    patches = git("rev-list", "--count", "%s..HEAD" % head, default="0") or "0"
    version = "%s+g%s+p%s" % (localversion, head, patches)
    return version

SCMVERSION:pn-u-boot-compulab = "n"
UBOOT_LOCALVERSION:pn-u-boot-compulab = "${@compulab_devtool_uboot_localversion(d)}"
