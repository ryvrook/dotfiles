if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Initialize starship prompt
starship init fish | source

# Alias
abbr --add cls clear
abbr --add cd.. cd ..
