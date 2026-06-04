#!/usr/bin/env fish

# Path configurations
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -l state_dir $state/caelestia
set -l scheme_path $state_dir/scheme.json
set -l css_file "$HOME/.zen/2w455a8z.Default (release)/chrome/zen-themes.css"

# Helper function to write system JSON to CSS variables
function update_css -a json_file css_path
    if test -f $json_file
        # Generate the entire CSS content in a block and overwrite the file completely
        begin
            echo ":root {"
            cat $json_file | jq -r '.colours | to_entries | .[] | "  --\(.key): #\(.value);"'
            echo "}"
        end > $css_path
    end
end

# Run once on execution
update_css $scheme_path $css_file
