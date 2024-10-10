#!/bin/bash

if [[ $# == 0 ]]; then
    echo "Error: Provide arguments"
    exit 1
else
    case "$1" in
        --version)
            echo "The current version is v0.1.0"
            exit 0
            ;;

        --help)
            echo -e "
            sysopctl --version        Show version information
            sysopctl --help           Show help message
            sysopctl service list     List running services
            sysopctl service start    Start a service
            sysopctl service stop     Stop a service
            sysopctl system load      View system load
            sysopctl disk usage       Check disk usage
            sysopctl process monitor  Monitor system processes
            sysopctl logs analyze     Analyze system logs
            sysopctl backup <path>    Backup system files

            Additional options:
            cpu get info              Get details about the CPU
            memory get info           Get details about the memory
            user                      Perform user operations
                create <USER>         Add a user to the system
                list [--sudo-only]    List all users or only those with sudo access
            file                      Perform actions on files
                getinfo <FILE-NAME>   Get file details (size, permissions, owner, last modified)
            "
            ;;

        "cpu")
            lscpu | grep "^Architecture"
            lscpu | grep "^CPU op-mode(s)"
            lscpu | grep -a7 "Vendor ID"
            ;;

        "memory")
            free -h
            ;;

        "user")
            case $2 in
                create)
                    useradd -s /bin/bash -m "$3"
                    ;;

                list)
                    if [[ $3 == "--sudo-only" ]]; then
                        sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' '\n')
                        if [[ -z "$sudo_users" ]]; then
                            echo "There are no users in the sudoers group"
                        else
                            echo "$sudo_users"
                        fi
                    else
                        cut -d: -f1 /etc/passwd
                    fi
                    ;;

                *)
                    echo "Invalid user command"
                    ;;
            esac
            ;;

        "file")
            case $2 in
                getinfo)
                    shift
                    case $2 in
                        --size)
                            du -h "$3"
                            ;;
                        --permissions)
                            find "$3" -maxdepth 0 -printf "%M\n"
                            ;;
                        --owner)
                            find "$3" -maxdepth 0 -printf "%u\n"
                            ;;
                        --last-modified)
                            stat "$3" | grep "Modify" | awk '{ print $2 " " $3 }'
                            ;;
                        *)
                            file_details=$(find "$2" -maxdepth 0 -printf "Permissions: %M\nSize: %s bytes\nOwner: %u\n")
                            last_modified=$(stat "$2" | grep "Modify" | awk '{ print $2 " " $3 }')
                            echo "
                                  File:        $2
                                  $file_details
                                  Modify:     $last_modified
                                "
                            ;;
                    esac
                    ;;
                *)
                    echo "Invalid file command"
                    ;;
            esac
            ;;

        "service")
            case $2 in
                list)
                    systemctl list-units --type=service
                    ;;
                start)
                    systemctl start "$3"
                    echo "Service $3 started"
                    ;;
                stop)
                    systemctl stop "$3"
                    echo "Service $3 stopped"
                    ;;
                *)
                    echo "Invalid service command"
                    ;;
            esac
            ;;

        "system")
            case $2 in
                load)
                    uptime
                    ;;
                *)
                    echo "Invalid system command"
                    ;;
            esac
            ;;

        "disk")
            case $2 in
                usage)
                    df -h
                    ;;
                *)
                    echo "Invalid disk command"
                    ;;
            esac
            ;;

        "process")
            case $2 in
                monitor)
                    top
                    ;;
                *)
                    echo "Invalid process command"
                    ;;
            esac
            ;;

        "logs")
            case $2 in
                analyze)
                    journalctl -p 3 -xb
                    ;;
                *)
                    echo "Invalid logs command"
                    ;;
            esac
            ;;

        "backup")
            rsync -a "$2" /backup/
            echo "Backup of $2 completed successfully"
            ;;

        *)
            echo "Invalid option. Use --version or --help for more information."
            exit 1
            ;;
    esac
fi