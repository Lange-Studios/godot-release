$env.PROJECT_DIR = ($env.GSRC_SCRIPT | path expand | path dirname)
$env.GODOT_SRC_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-src" | path expand)
$env.GODOT_SRC_GODOT_DIR = ($"($env.PROJECT_DIR)/gitignore/godot" | path expand)
$env.GODOT_SRC_AUTO_INSTALL_GODOT = false
$env.GODOT_SRC_GODOT_NIR_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-nir-static" | path expand)
$env.GODOT_SRC_AUTO_INSTALL_GODOT_NIR = false
$env.GODOT_SRC_DXC_DIR = ($"($env.PROJECT_DIR)/gitignore/godot-nir-static" | path expand)
$env.GODOT_SRC_CUSTOM_MODULES = []
$env.GODOT_SRC_GODOT_EXTRA_SUFFIX = null

# These are now "Defaults" that will be overridden by the command flags
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

# Updated to accept new flags from the GitHub Action matrix
export def "work build" [ 
    --matrix-target: string,
    --precision: string,    # "single" or "double"
    --dotnet
] {
    $env.GODOT_SRC_PRECISION = $precision
    $env.GODOT_SRC_DOTNET_ENABLED = $dotnet

    # Prepare release directory
    mkdir $"($env.PROJECT_DIR)/gitignore/release"

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

    let zip_name = match $dotnet {
        true => $"($matrix_target)-($precision)-dotnet.zip",
        false => $"($matrix_target)-($precision).zip",
    }

    let existing_zip_name = match $matrix_target {
        "ios-template" => "ios.zip",
        "macos-template" => "macos.zip",
        "android-template" => "android_source.zip",
        _ => ""
    }

    if ($existing_zip_name | is-not-empty) {
        (mv 
            $"($env.PROJECT_DIR)/gitignore/godot/bin/($existing_zip_name)" 
            $"($env.PROJECT_DIR)/gitignore/godot/bin/($zip_name)"
        )
    } else {
        cd $"($env.PROJECT_DIR)/gitignore/godot/bin"
        run-external zip "-r" $"($env.PROJECT_DIR)/gitignore/release/($zip_name)" . "-x" "obj/*"
    }

    if $matrix_target == "linux-editor" and $env.GODOT_SRC_DOTNET_ENABLED {
        gsrc godot build dotnet-glue
        cd $"($env.PROJECT_DIR)/gitignore/godot/bin"
        run-external zip "-r" $"GodotSharp-($precision).zip" GodotSharp 
    }

    cd $env.PROJECT_DIR
    (ls gitignore/godot/bin
        | where {|file| $file.name | str ends-with ".zip"}
        | each { |file| mv $file.name gitignore/release }
    )
}