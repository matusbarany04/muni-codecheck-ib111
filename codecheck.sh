#!/bin/bash
# set -euo pipefail 

export MYPY_COLOR=always
export FORCE_COLOR=1
export MYPY_FORCE_COLOR=1


RESTORE=$(echo -en '\001\033[0m\002')
RED=$(echo -en '\001\033[00;31m\002')
GREEN=$(echo -en '\001\033[00;32m\002')
YELLOW=$(echo -en '\001\033[00;33m\002')
BLUE=$(echo -en '\001\033[00;34m\002')
MAGENTA=$(echo -en '\001\033[00;35m\002')
PURPLE=$(echo -en '\001\033[00;35m\002')
CYAN=$(echo -en '\001\033[00;36m\002')
LIGHTGRAY=$(echo -en '\001\033[00;37m\002')
LRED=$(echo -en '\001\033[01;31m\002')
LGREEN=$(echo -en '\001\033[01;32m\002')
LYELLOW=$(echo -en '\001\033[01;33m\002')
LBLUE=$(echo -en '\001\033[01;34m\002')
LMAGENTA=$(echo -en '\001\033[01;35m\002')
LPURPLE=$(echo -en '\001\033[01;35m\002')
LCYAN=$(echo -en '\001\033[01;36m\002')
WHITE=$(echo -en '\001\033[01;37m\002')


usage() {
  cat <<EOF 1>&2
    This simple bash script will check selected file/s against edulint mypy and then run them.

    Usage: codecheck.sh [OPTIONS]

    Options:
    -s          Use this option to process files from 'sady' matching the pattern 'a-f_*.py'.
    -p          Use this option to process files from 'pripravy' matching the pattern 'p1-p6_*.py'.
    -f <file>   Specify a specific file for processing.
    -v          Make command output verbose
    -t          Measure time for each script
    -h          Display this help message.

    Examples:
    codecheck.sh -s
    codecheck.sh -p
    codecheck.sh -f my_script.py

EOF
    exit 1
}
p_prefix=$(echo p{1..6}_*.py)
s_prefix=$(echo {a..f}_*.py)
verbose=false
time=false

# Parse flags
while getopts ":tvhpsf:" o; do
    case "${o}" in
        s)
            prefix=$s_prefix
            ;;
        p)
            prefix=$p_prefix
            ;;
        f)
            prefix=${OPTARG}
            ;;
        v)
            verbose=true
            ;;
        t)
            time=true
            ;;
        h | *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

checkImport (){
    firstchar=$(cat $1 | head -n 1 | cut -c1)
    
    if [ "$firstchar" != '#' ]; then
        if $verbose; then
           echo -e ${GREEN}'Week import is ok!'${RESTORE}
        fi
        return 0 # ok
    else
        echo -e '\nCommented import! Aborting ...'
        uncommentWeek $1
        return 1 # bad
    fi
}

uncommentWeek(){
    # | head -n 1
    fileUncommented=$(sed -n 's/# from ib111 import week\|#from ib111 import week/from ib111 import week/gp' $1)
    echo $fileUncommented
    # echo $fileUncommented > $1
}

count_var=0
for script in $prefix; do 
    if ls ${script} >/dev/null 2>&1; then
        if $verbose; then
            echo "Files matching ${script} exist."
            echo "Checking week import ... "
        fi
        checkImport $script
        if $verbose; then
            echo -e "\nChecking with ${BLUE}edulint${RESTORE} ..."
        fi
        
        if edulint check "${script}"; then
            if $verbose; then
                echo "Edulint on ${script} ${GREEN}succeeded${RESTORE}."
            fi
        else
            echo "Error: Edulint on ${script} ${RED}failed${RESTORE}."
            exit 1
        fi

        #edulint check ${script}
        if $verbose; then
            echo -e "\nChecking with ${BLUE}mypy${RESTORE} ..."
        fi

        output=$(mypy --strict "${script}")

        if $verbose; then
            echo "$output"
        fi

        if echo "$output" | grep -q "Success"; then
            echo "Mypy on ${script} ${GREEN}passed${RESTORE}."
        else
            if [ "$verbose" = false ]; then
                echo "$output"
            fi

            echo "Error: Mypy on ${script} ${RED}failed${RESTORE}."
            exit 1
        fi


        if $verbose; then
            echo -e "\nRunning the ${script} ...";
        fi
    
        if $time; then
            time python3 "${script}"
        else
            python3 "${script}"
        fi
    else
        #if verbose; then
        echo "No files matching ${script} found."
        #fi
    fi

    count_var=$((count_var+1))
done

if [ $verbose = true ]; then
    echo "##############################"
    echo -e "\n${count_var} files processed."
fi
