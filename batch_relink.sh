#!/bin/bash

# Usage: batch_relink.sh <source_dir> <target_dir> <rel_path1> <rel_path2> ...

# This script creates symbolic links from a source directory to a target directory for a list of relative paths.
# Note: On Windows, you need to have the necessary permissions to create symbolic links.

os() {
	case $OSTYPE in
	linux-gnu* | darwin* | freebsd*) echo "Unix" ;;
	cygwin | msys | win32) echo "Windows" ;;
	*) echo "Unknown" ;;
	esac
}

source_dir=$1
target_dir=$2
shift 2
rel_paths=$@

for rel_path in $rel_paths; do
  source_path=$(realpath -s "$source_dir/$rel_path")
  target_path=$(realpath -s "$target_dir/$rel_path")

  if [ -e "$target_path" ]; then
    # If it's already a symbolic link to the same file, skip relinking.
    if [ -L "$target_path" ] && [ "$(realpath "$target_path")" = "$source_path" ]; then
      continue
    fi
    mv -f "$target_path" "$target_path.bak"
  fi

  case $(os) in
  Unix)
    ln -s "$source_path" "$target_path"
    ;;
  Windows)
    # By default, the ln -s command in Git Bash does not create symbolic links. Instead, it creates copies.
    # To create symbolic links (provided your account has permission to do so), use the built-in mklink command.
    # cygpath -m: convert '/c/Users/...' to 'C:/Users/...'
    sudo ./symlink.bat "$(cygpath -m "$source_path")" "$(cygpath -m "$target_path")"
    ;;
  *)
    echo "Unsupported operating system."
    ;;
  esac
done
