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
$env.GODOT_SRC_AUTO_ACCEPT_ANDROID_SDK_LICENSES = true

source gitignore/godot-src/gsrc.nu

# Pass --help to see available commands
export def "work" [] {

}

export def "work build" [ --matrix-target: string ] {
    match ($matrix_target) {
        "android-template" => {
             gsrc godot build template android --release-mode "release" --archs [ "arm64", "x86_64" ]
        },
        "ios-template" => {
            gsrc godot build template ios app --arch "arm64"
        },
        "macos-template" => {
            gsrc godot build template macos app --arch "universal" --skip-debug
        }
        _ => {
            let platform_target = ($matrix_target | split row "-")
            gsrc godot build --release-mode release --platform $platform_target.0 --target $platform_target.1 --skip-cs-glue
        }
    }

    if $matrix_target == "linux-editor" {
        gsrc godot build dotnet-glue
        cd "gitignore/godot/bin"
        run-external zip "-r" "GodotSharp.zip" GodotSharp
    }
}