#compdef uft

_uft() {
    local -a modes compressors

    modes=(
        'auto:pick fastest available method'
        'tar-stream:tar + compression over SSH'
        'tar-nc:tar over netcat (unencrypted)'
        'parallel-rsync:parallel rsync with resume'
        'benchmark:run speed benchmarks'
    )

    compressors=(
        'auto:detect best available'
        'lz4:fastest compression'
        'pigz:parallel gzip'
        'zstd:zstandard'
        'gzip:standard gzip'
        'none:no compression'
    )

    _arguments -s \
        '(-H --host)'{-H,--host}'[remote hostname or IP]:host:_hosts' \
        '(-u --user)'{-u,--user}'[SSH username]:user:_users' \
        '(-r --remote-path)'{-r,--remote-path}'[source directory on remote]:path:_files -/' \
        '(-l --local-path)'{-l,--local-path}'[destination directory locally]:path:_files -/' \
        '(-m --mode)'{-m,--mode}'[transfer mode]:mode:(($modes))' \
        '(-c --compress)'{-c,--compress}'[compression algorithm]:compressor:(($compressors))' \
        '(-j --jobs)'{-j,--jobs}'[parallel rsync workers]:count:' \
        '(-s --streams)'{-s,--streams}'[parallel netcat streams]:count:' \
        '(-p --port)'{-p,--port}'[SSH port]:port:' \
        '(-k --key)'{-k,--key}'[SSH key file]:key:_files' \
        '(-b --bwlimit)'{-b,--bwlimit}'[bandwidth cap in KB/s]:limit:' \
        '(-J --jump)'{-J,--jump}'[SSH jump/bastion host]:host:_hosts' \
        '*--exclude[exclude files matching pattern]:pattern:' \
        '--exclude-from[read exclude patterns from file]:file:_files' \
        '--copy-links[dereference symlinks]' \
        '--newer[only files newer than date]:date:' \
        '--skip-scan[skip remote file count/size scan]' \
        '--keep-logs[keep N most recent logs]:count:' \
        '--config[config file path]:file:_files' \
        '--resume[resume interrupted transfer]' \
        '--verify[verify after transfer]' \
        '--no-verify[skip verification]' \
        '--checksum[spot-check md5 on random files]' \
        '--dry-run[preflight only]' \
        '--tuning[show performance tips]' \
        '(-y --yes)'{-y,--yes}'[skip confirmation prompts]' \
        '--local-ip[override auto-detected local IP]:ip:' \
        '--version[print version and exit]' \
        '(-h --help)'{-h,--help}'[show help]'
}

_uft "$@"
