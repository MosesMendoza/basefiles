# Check for interactive bash
[ -z "$BASH_VERSION" -o -z "$PS1" ] && return

# Check for recent enough version of bash.
bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
if [ $bmajor -gt 4 ] || [ $bmajor -eq 4 -a $bminor -ge 1 ]; then
    shopt -s direxpand
fi
unset bash bmajor bminor
