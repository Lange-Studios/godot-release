$env.PROJECT_DIR = ($env.GSRC_SCRIPT | path expand | path dirname)
$env.GODOT_SRC_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-src" | path expand)
$env.GODOT_SRC_GODOT_DIR = ($"($env.PROJECT_DIR)/gitignore/godot" | path expand)
$env.GODOT_SRC_AUTO_INSTALL_GODOT = false
$env.GODOT_SRC_GODOT_NIR_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-nir-static" | path expand)
$env.GODOT_SRC_AUTO_INSTALL_GODOT_NIR = false
$env.GODOT_SRC_DXC_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-nir-static" | path expand)
$env.GODOT_SRC_CUSTOM_MODULES = []
$env.GODOT_SRC_GODOT_EXTRA_SUFFIX = null
$env.GODOT_SRC_DOTNET_ENABLED = true
$env.GODOT_SRC_PRECISION = "double"
$env.GODOT_SRC_EXTRA_SCONS_ARGS = [ "openxr=false" ]
$env.PATH = ($env.PATH | prepend $"($env.PROJECT_DIR)/gitignore/godot-src/zig-out/bin")
$env.GODOT_SRC_LEAN_ENABLED_INTERNAL = ($env.GODOT_SRC_LEAN_ENABLED? | default false | into bool)
$env.DOTNET_CLI_TELEMETRY_OPTOUT = true
$env.DOTNET_NOLOGO = 1

source gitignore/godot-src/gsrc.nu
