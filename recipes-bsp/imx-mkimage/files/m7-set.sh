#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
demo_dir="${1:-${MCORE_DEMOS_DIR:-${script_dir}/../mcore-demos}}"
image_pattern="${2:-${M7_IMAGE_PATTERN:-@@M7_IMAGE_PATTERN@@}}"

if [[ ! -d "${demo_dir}" ]]; then
	echo "M7 firmware directory not found: ${demo_dir}" >&2
	echo "Usage: $0 [mcore-demos-directory] [image-pattern]" >&2
	exit 1
fi

mapfile -t images < <(find "${demo_dir}" -maxdepth 1 -type f \
	-name "${image_pattern}" -print | sort)

if (( ${#images[@]} == 0 )); then
	echo "No ${image_pattern} firmware found in ${demo_dir}" >&2
	exit 1
fi

PS3="M7 image (or Quit): "
select image in "${images[@]}" "Quit"; do
	if [[ "${image:-}" == "Quit" ]]; then
		exit 0
	fi
	if [[ -z "${image:-}" ]]; then
		echo "Invalid selection" >&2
		continue
	fi

	image_name="$(basename "${image}")"
	cp -f -- "${image}" "${script_dir}/${image_name}"
	ln -sfn -- "${image_name}" "${script_dir}/m7_image.bin"
	echo "M7 firmware selected: ${image_name}"
	break
done
