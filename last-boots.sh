#!/usr/bin/env bash
#Insert last year shutdown times into timewarrior to nicer charts/summaries

#Pass something to track all the previous boots in the current year


last_boots() {
#if nothing passed get last else all
[[ -z $1 ]] && number=5 || number=0
local com=(last -x --time-format iso -n $number)
local shutdown='^shutdown system down[[:space:]]+[-\.[:xdigit:][=x=]]* (.*)\+.* - (.*)\+.*\((.*)\)' 
local from= to= duration= exec=

while IFS= read -r line
do
    if [[ $line =~ $shutdown ]]; then
        from=${BASH_REMATCH[1]} 
        to=${BASH_REMATCH[2]}
        duration=${BASH_REMATCH[3]}
        exec="timew track from $from - $to Shutdown"
        echo executing: $exec
        $exec
    fi

done < <("${com[@]}" 2>&1)
}

last_boots $1
