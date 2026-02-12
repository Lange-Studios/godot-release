#!/bin/bash

set -e

dir="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"

# 1. Check for the 'godot' directory
if [[ ! -d "$dir/gitignore/godot" ]]
then
    mkdir -p "$dir/gitignore"
    cd "$dir/gitignore"
    git clone "https://github.com/Lange-Studios/godot.git" -b master-lange-studios --depth 1
    cd "$dir" # Return to script root for the next check
fi

# 2. Check for the 'godot-src' directory
if [[ ! -d "$dir/gitignore/godot-src" ]]
then
    mkdir -p "$dir/gitignore"
    cd "$dir/gitignore"
    git clone "https://github.com/Lange-Studios/godot-src.git" --depth 1
    cd "$dir" # Return to script root
fi

# Only clone godot-nir-static if we are building for windows
if [[ ! -d "$dir/gitignore/godot-nir-static" && "$*" == *"windows"* ]]
then
    mkdir -p "$dir/gitignore"
    cd "$dir/gitignore"
    git clone "https://github.com/Lange-Studios/godot-nir-static.git" -b manually-specify-build-tools --depth 1 --recurse-submodules
    cd "$dir/gitignore/godot-nir-static"
    git submodule update --init --recursive --depth 1
    cd "$dir" # Return to script root
fi

"$dir/gitignore/godot-src/pixi-install.sh"

export GSRC_SCRIPT="$dir/main.nu"

args=$@

if [ -z "$args" ]
then
    cd "$dir"
    "$dir/gitignore/godot-src/gitignore/pixi/bin/pixi" run --manifest-path "$dir/gitignore/godot-src/pixi.toml" --frozen nu -e "source gsrc.nu"
else
    "$dir/gitignore/godot-src/gitignore/pixi/bin/pixi" run --manifest-path "$dir/gitignore/godot-src/pixi.toml" --frozen nu "$dir/main.nu" "$args"
fi