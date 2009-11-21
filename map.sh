#!/bin/bash
# set -e
CMD=$(basename $0)
HELP=$(cat <<EOF 
Usage: $CMD [FUNCTION] [INDIR] [OUTDIR] [MAPPERS] ... \n
\n
Map a FUNCTION over a set of files in the directory, INDIR, and output  \n
results to a directory, OUTDIR, with the same base name.  FUNCTION \n
must accept a file name as its first parameter (such as 'grep',  \n
'sort', or 'awk').  A set of parallel processes are launched, equal to \n
MAPPERS.  If MAPPERS is not given, it defaults to the number of CPUs \n
detected on the system, or 2 otherwise. \n
\n
Examples:  $CMD sort /tmp/files /tmp/sorted 4 \n
\n
           # using map with a user-defined function \n 
           gzsort () { gunzip -c $1 | sort | gzip --fast; } \n
           typeset -fx gzsort  ##  export to subshell \n
           $CMD gzsort ingz outgz                      \n
EOF
)

if [ $# -eq 4 ]; then
    nmap=$4       
elif [ $# -eq 3 ]; then   ## guess no. CPUs, default to 2
    nmap=`grep '^processor' /proc/cpuinfo | wc -l`
    if [ $? -eq 1 ];  then
	nmap=2
    fi
elif [ $# -lt 3 ]; then  ## too few args
    echo -e $HELP
    exit 1
fi

func=$1
in=$2
out=$3
export func in out nmap

## make output directory
if [ -d $out ]; then 
    echo "output dir $out exists"
    exit 1
else 
    mkdir $out
fi

echo "running with func=$func in=$in out=$out nmap=$nmap"
ls $in |  xargs -P $nmap -I{} sh -c '$func "$in"/"$1" > "$out"/"$1"' -- {}

## cleanup in event of any failure
if [ $? -eq 1 ]; then
    rm -fr $out
fi
