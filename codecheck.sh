#!/bin/bash
set -euo pipefail 

usage() {
  cat <<EOF 1>&2
    This simple bash script will check selected file/s against edulint mypy and then run them.

    Usage: codecheck.sh [OPTIONS]

    Options:
    -s          Use this option to process files from 'sady' matching the pattern 'a-f_*.py'.
    -p          Use this option to process files from 'pripravy' matching the pattern 'p1-p6_*.py'.
    -f <file>   Specify a specific file for processing.
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
#verbose=false

# Parse flags
while getopts ":vhpsf:" o; do
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
#        v)
#            verbose=1
#            ;;
        h | *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

checkImport (){
    firstchar=$(cat $1 | head -n 1 | cut -c1)
    if [ "$firstchar" != '#' ]; then
  #      if verbose; then
        echo -e '\nWeek import is ok!'
 #       fi
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

for script in $prefix; do 
    if ls ${script} >/dev/null 2>&1; then
        #if verbose; then
        echo "Files matching ${script} exist."
        echo "Checking week import ... "
        #fi
        checkImport $script
        #if verbose; then
        echo -e "\nChecking with edulint ..."
        #fi
        edulint check ${script}
        #if verbose; then
        echo -e "\nChecking with mypy ..."
        #fi
        mypy --strict ${script}
        #if verbose; then
        echo -e "\nRunning the ${script} ...";
        #fi
    
        time python3 "${script}"; 
    else
        #if verbose; then
        echo "No files matching ${script} found."
        #fi
    fi
done
