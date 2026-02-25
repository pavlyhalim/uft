complete -c uft -x

# flags
complete -c uft -s H -l host        -d 'Remote hostname or IP' -r
complete -c uft -s u -l user        -d 'SSH username' -r
complete -c uft -s r -l remote-path -d 'Source directory on remote' -rF
complete -c uft -s l -l local-path  -d 'Destination directory locally' -rF
complete -c uft -s p -l port        -d 'SSH port' -r
complete -c uft -s k -l key         -d 'SSH key file' -rF
complete -c uft -s j -l jobs        -d 'Parallel rsync workers' -r
complete -c uft -s s -l streams     -d 'Parallel netcat streams' -r
complete -c uft -s b -l bwlimit     -d 'Bandwidth cap in KB/s' -r
complete -c uft -s J -l jump        -d 'SSH jump/bastion host' -r
complete -c uft -s y -l yes         -d 'Skip confirmation prompts'
complete -c uft -s h -l help        -d 'Show help'

# mode
complete -c uft -s m -l mode -d 'Transfer mode' -rfa '
    auto\t"Pick fastest method"
    tar-stream\t"tar + compression over SSH"
    tar-nc\t"tar over netcat (unencrypted)"
    parallel-rsync\t"Parallel rsync with resume"
    benchmark\t"Run speed benchmarks"
'

# compress
complete -c uft -s c -l compress -d 'Compression algorithm' -rfa '
    auto\t"Detect best available"
    lz4\t"Fastest"
    pigz\t"Parallel gzip"
    zstd\t"Zstandard"
    gzip\t"Standard gzip"
    none\t"No compression"
'

# bool flags
complete -c uft -l resume     -d 'Resume interrupted transfer'
complete -c uft -l verify     -d 'Verify after transfer'
complete -c uft -l no-verify  -d 'Skip verification'
complete -c uft -l checksum   -d 'Spot-check md5 on random files'
complete -c uft -l dry-run    -d 'Preflight only'
complete -c uft -l tuning     -d 'Show performance tips'
complete -c uft -l copy-links -d 'Dereference symlinks'
complete -c uft -l skip-scan  -d 'Skip remote file count/size scan'
complete -c uft -l version    -d 'Print version and exit'

# value flags
complete -c uft -l exclude      -d 'Exclude files matching pattern' -r
complete -c uft -l exclude-from -d 'Read exclude patterns from file' -rF
complete -c uft -l newer        -d 'Only files newer than date' -r
complete -c uft -l keep-logs    -d 'Keep N most recent logs' -r
complete -c uft -l config       -d 'Config file path' -rF
complete -c uft -l local-ip     -d 'Override auto-detected local IP' -r
