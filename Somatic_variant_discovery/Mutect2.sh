#!/bin/bash
#!/bin/bash

START=$(date +%s)

while getopts v:r:b:o: flag
do
    case "${flag}" in
        v) mergevcf=${OPTARG};;
        r) ref=${OPTARG};;
        b) workhard=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

# directory
mkdir -p ${finalPath}
mkdir -p ${workhard}



# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "HardFilter $DIFF seconds"