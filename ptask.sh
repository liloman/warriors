#!/usr/bin/env bash

#My taskwarrior/timewarrior functions

#Version 0.1 Initial with options and verbs working

__version=0.1
software=${0##*/}

#Join several tasks in one
# cozy way to make your TODO lists on a project
taskjoin() {
    addtasks() {
        local id=
        local pro=
        # joinning to active task
        if [[ $active == y ]]; then
            [[ $opt =~ (.*\])([[:digit:]]*) ]]
            pro=${BASH_REMATCH[1]: 1:-1}
            id=${BASH_REMATCH[2]}
        fi
        for arg; do
            if [[ $active == y ]]; then
                task add "$arg" pro:"$pro" dep:$id
            else
                pro=$opt
                task add "$arg" pro:"$pro"
                active=y
            fi
            #get last id. import to sort it due dependencies...
            id=$(task _unique id | sort -n |  tail -n 1)
        done
        task
    }
    local i=0
    local -a projects
    local -a joins
    local active=n

    echo "Where do you want to join the tasks from:"
    select from in "Active task" "Any project";
    do
        case $from in
            Active*)
                for id in $(task _ids); do
                    project=$(task _get $id.project)
                    description=$(task _get $id.description)
                    projects[$((++i))]="[$project]$id-$description"
                done
                active=y
                break;;
            Any*)
                echo "Projects:"
                while IFS= read -r project; do
                    projects[$((++i))]=$project
                done <<< "$(task rc.list.all.projects=1 _projects)" 
                break;;
        esac
    done

    select opt in "${projects[@]}";do
        [[ -n $opt ]]  && break 
    done
    echo -n "The new tasks are going to be joined with the "
    [[ $active == y ]] && echo " task $opt" || echo " project $opt"

    i=0
    while true; do
        read  -p "Enter a desc or q to exit:"  new
        [[ $new == q ]] && break
        joins[$((++i))]=$new
    done

    for idx in ${!joins[@]}; do
        echo "$idx) ${joins[$idx]}"
    done
    echo "Are you sure you want to join these tasks?"
    select yn in Yes No; do
        case $yn in
            Y* )  addtasks "${joins[@]}"; break;;
            N* ) echo "Exit."; break;;
        esac
    done
}


#Add the complete methodology for a tema
newtema() {
    addtema() {
        local number=$1
        local tag="+2017"
        local desc1="Leer tema $number"
        local desc2="Hacer resumen del tema $number"
        local desc1="Repaso tema del $number"
        task add "$desc1" pro:opos.tema$number $tag
        task add "$desc2" pro:opos.tema$number $tag
        task add "$desc3" pro:opos.tema$number $tag
        echo "Added new tema $number to taskwarrior. Happy work!"
        task pro:opos.tema$number
    }
    local tema

    read  -p "Dame el numero de tema o q para salir:"  tema
    [[ $tema == q ]] && return
    local regex='^[0-9]+$'
    if ! [[ $tema =~ $regex ]]; then
        echo "$tema debe ser un numero"; return
    fi

    echo "¿Estas seguro de crear el tema $tema?"
    select yn in Yes No; do
        case $yn in
            Y* )  addtema $tema; break;;
            N* ) echo "Exit."; break;;
        esac
    done
}

################################################################################
#                                     MAIN                                     #
################################################################################
usage() {
    echo " $software [options]"
    echo ""
    echo " Taskwarrior options:"
    echo "  join:  Join several tasks in one(wizard)"
    echo "  tema:  Añade un nuevo tema a trabajar"
    echo " General options:"
    echo "  -h, --help:   Show this help"
    echo "  -v  Show version"
} 

# # Use getopt to parse parameters
# if ! OPTIONS=$(getopt -n "$software" -o hvj -l "help" -- "$@"); then
#     usage
#     exit 0
# fi
# eval set -- "${OPTIONS}"

# And now parse options with while
while true; do
    case "$1" in
        "--help"|"-h")
            usage; exit 0 ;;
        "join")
            [[ -n $2 ]] && { echo "Option join needs no arguments (wizard)";exit 1; }
            taskjoin ; exit 0;;
        "tema")
            [[ -n $2 ]] && { echo "Option join needs no arguments (wizard)";exit 1; }
            newtema ; exit 0;;

        "-t")
            [[ -z $3 ]] && { echo "Option -t needs an argument";exit 1; }
            hash $3 &>/dev/null || { echo "$3 not found"; exit 1; }
            echo " hola"
            exit ;;
        "-v") 
            echo version: $__version; exit 0 ;;
        "--")
            shift; break ;;
        ?) 
            echo wrong option. 
            usage ; exit 0 ;;
        *)
            echo "Needs arguments. Try $software -h"
            exit 0;
    esac   
done



