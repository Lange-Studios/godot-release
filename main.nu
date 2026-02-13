#!/usr/bin/env nu

export def --wrapped "main" [...rest] {
    if ($rest | length) == 0 {
        run-external $nu.current-exe "-e" $"source `($env.FILE_PWD)/work.nu`"
    } else {
        run-external $nu.current-exe "-c" $"source `($env.FILE_PWD)/work.nu`;($rest | str join ' ')"
    }
}
