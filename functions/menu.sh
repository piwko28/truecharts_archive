#!/bin/bash

menu(){
  clear -x
  title
  echo "0  Help"
  echo "1  List DNS Names"
  echo "2  Mount and Unmount PVC storage"
  echo "3  Create a Backup"
  echo "4  Restore a Backup"
  echo "5  Delete a Backup"
  echo "6  Update Applications"
  read -rt 600 -p "Please select an option by number: " selection

  case $selection in
    0)
        help="true"
        ;;
    1)
        dns="true"
        ;;
    2)
        mount="true"
        ;;
    3)
        read -rt 600 -p "Please type the max number of backups to keep: " number_of_backups
        re='^[0-9]+$'
        number_of_backups=$number_of_backups
        ! [[ $number_of_backups =~ $re  ]] && echo -e "Error: -b needs to be assigned an interger\n\"""$number_of_backups""\" is not an interger" >&2 && exit
        [[ "$number_of_backups" -le 0 ]] && echo "Error: Number of backups is required to be at least 1" && exit
        echo "Generating backup, please be patient for output.."
        backup "$number_of_backups"
      ;;
    4)
        restore="true"
        ;;
    5)
        deleteBackup="true"
        ;;
    6)
        script=$(readlink -f "$0")
        script_path=$(dirname "$script")
        script_name="heavy_script.sh"
        cd "$script_path" || exit
        clear -x
        title
        echo "What type of update would you like?"
        echo "1) -U | Update all applications, ignores versions"
        echo "2) -u | Update all applications, does not update Major releases"
        echo
        echo "0) Exit"
        read -rt 600 -p "Please type the number associated with the flag above: " current_selection
        if [[ $current_selection == 1 ]]; then
            echo "How many applications do you want updating at the same time?"
            read -rt 600 -p "Please type an integer greater than 0: " up_async
            update_selection+=("-U" "$up_async")
        elif [[ $current_selection == 2 ]]; then
            echo "How many applications do you want updating at the same time?"
            read -rt 600 -p "Please type an integer greater than 0: " up_async  
            update_selection+=("-u" "$up_async")
        elif [[ $current_selection == 0 ]]; then
            echo "Exiting.." 
            exit
        else
            echo "$current_selection was not an option, try again"
            exit
        fi
        while true 
        do
        clear -x
        title
        echo "Choose your update options "
        echo
        echo "1) -b | Back-up your ix-applications dataset, specify a number after -b"
        echo "2) -i | Add application to ignore list, one by one, see example below."
        echo "3) -r | Roll-back applications if they fail to update"
        echo "4) -S | Shutdown applications prior to updating"
        echo "5) -v | verbose output"
        echo "6) -t | Set a custom timeout in seconds when checking if either an App or Mountpoint correctly Started, Stopped or (un)Mounted. Defaults to 500 seconds"
        echo "7) -s | sync catalog"
        echo "8) -p | Prune unused/old docker images"
        echo
        echo "0) Done making selections, proceed with update"
        echo 

        read -rt 600 -p "Please type the number associated with the flag above: " current_selection
        if [[ $current_selection == 0 ]]; then
            exec bash "$script_name" "${update_selection[@]}"
            exit
        elif [[ $current_selection == 1 ]]; then
            read -rt 600 -p "Up to how many backups should we keep?\n Please type an integer: " up_backups
            update_selection+=("-b" "$up_backups")
        elif [[ $current_selection == 2 ]]; then
            read -rt 600 -p "What is the name of the application we should ignore?: " up_ignore
            update_selection+=("-i" "$up_ignore")                
        elif [[ $current_selection == 3 ]]; then
            update_selection+=("-r")
        elif [[ $current_selection == 4 ]]; then
            update_selection+=("-S")
        elif [[ $current_selection == 5 ]]; then
            update_selection+=("-v")
        elif [[ $current_selection == 6 ]]; then
            read -rt 600 -p "What do you want your timeout to be?: " up_timeout
            update_selection+=("-t" "$up_timeout")
        elif [[ $current_selection == 7 ]]; then
            update_selection+=("-s") 
        elif [[ $current_selection == 8 ]]; then
            update_selection+=("-p")                                                                    
        fi
        done
        ;;
    *)
        echo "Unknown option" && exit 1
        ;;
  esac
  echo ""
}
export -f menu