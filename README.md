# codecheck IB111
This is a simple bash script to help with checking **edulint**, **mypy** with time bench-marking multiple assignments at once 

## Installation
1. Open/create a directory where you will keep repositories such as this one for example

```bash
mkdir ~/scripts
cd ~/scripts
```

2. Clone and go into this repository
```bash
git clone https://github.com/matusbarany04/muni-codecheck-ib111
cd muni-codecheck-ib111
```

3.  Add alias to the end of ~/.bashrc and reload bashrc

```bash
alias codecheck='~/scripts/codecheck/codecheck.sh'
source ~/.bashrc
```

## Usage 
```bash
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
```

#### Sample output:
```bash
student :: MUNI/IB111/09 » codecheck -p 
Mypy on p1_evaluate.py passed.
Mypy on p2_rpn.py passed.
Mypy on p3_children.py passed.
Mypy on p4_treezip.py passed.
Mypy on p5_mktree.py passed.
Mypy on p6_prune.py passed.
```
