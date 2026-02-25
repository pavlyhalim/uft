_uft() {
    local cur prev opts modes compressors
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-H --host -u --user -r --remote-path -l --local-path
          -m --mode -c --compress -j --jobs -s --streams
          -p --port -k --key -b --bwlimit -J --jump
          --exclude --exclude-from --copy-links --newer
          --skip-scan --keep-logs --config
          --resume --verify --no-verify --checksum
          --dry-run --tuning -y --yes --local-ip
          --version -h --help"

    modes="auto tar-stream tar-nc parallel-rsync benchmark"
    compressors="auto lz4 pigz zstd gzip none"

    case "$prev" in
        -m|--mode)
            COMPREPLY=( $(compgen -W "$modes" -- "$cur") )
            return 0
            ;;
        -c|--compress)
            COMPREPLY=( $(compgen -W "$compressors" -- "$cur") )
            return 0
            ;;
        -l|--local-path|-r|--remote-path)
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
        -k|--key|--exclude-from|--config)
            COMPREPLY=( $(compgen -f -- "$cur") )
            return 0
            ;;
        -j|--jobs|-s|--streams|-p|--port|-b|--bwlimit|--keep-logs)
            return 0
            ;;
        -H|--host|-u|--user|-J|--jump|--local-ip|--exclude|--newer)
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    fi
}

complete -F _uft uft
