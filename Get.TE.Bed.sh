#!/bin/bash

#De-Kayne 2021
#usage: Get.TE.Bed.sh genome.fasta contig_name repeatmasker_output.out win_length output_dir

#--------------------------------
#specify args
GENOME=$1
CONTIG=$2
REP_OUT=$3
WIN_LEN=$4
OUTPUT_DIR=$5

echo "you ran: TE.bed.sh $1 $2 $3 $4 $5"
echo "running all TE sum in windows"
#--------------------------------

#prepare genome to extract contig
seqtk seq -l0 ${GENOME} > unwrapped.fasta
#extract contig
grep -A1 "${CONTIG}" unwrapped.fasta > ${CONTIG}.fasta

#--------------------------------
#get windows of contig
#then produce windows for bedtools
echo "${CONTIG}" > ${CONTIG}.int.txt && grep -v ">" ${CONTIG}.fasta | wc -c >> ${CONTIG}.int.txt && cat ${CONTIG}.int.txt | tr '\n' '_' | sed 's/_/\t/g' > ${CONTIG}.genome.txt && rm -f ${CONTIG}.int.txt
bedtools makewindows -g ${CONTIG}.genome.txt -w ${WIN_LEN} > ${CONTIG}.windows.${WIN_LEN}.bed

#--------------------------------
#extract TEs in contig
#then get .out file from masking and compare overlap between each contig and the db
grep "${CONTIG}" ${REP_OUT} | awk '{ print $5,$6,$7,$11 }' | sed 's/ /\t/g' > TEs.${CONTIG}.out

#--------------------------------
#	ALL TEs TOGETEHR
#--------------------------------
#merge overlapping TEs - this is to get overall TE amount
sort -k1,1 -k2,2n -k3,3n TEs.${CONTIG}.out | bedtools merge -i stdin > TEs.${CONTIG}.merged.out

#--------------------------------
#find overlaps with windows
#get overlaps
bedtools intersect -a ./${CONTIG}.windows.${WIN_LEN}.bed -b ./TEs.${CONTIG}.merged.out -wa -wb > ${CONTIG}.extracted.annotation

#--------------------------------
#calculate overlap for each TE feature
bedtools overlap -i ${CONTIG}.extracted.annotation -cols 2,3,5,6  > ${CONTIG}.extracted.annotation.overlaps

#--------------------------------
#now go window by window calculating the total TE overlap
touch ${CONTIG}.window.te.sum
cut -f3 ${CONTIG}.windows.${WIN_LEN}.bed > ${CONTIG}.end

WIN_COUNT=$(wc -l ${CONTIG}.end | cut -d ' '  -f1)

for i in $( seq 1 $WIN_COUNT )
do
window_end=$(cat ${CONTIG}.end | sed -n ${i}p)
echo ${window_end} >> ${CONTIG}.window.te.sum
awk -v a="${window_end}" '$3 == a {print $0}' ${CONTIG}.extracted.annotation.overlaps > tmp.txt
awk '{sum+=$7;}END{print sum;}' tmp.txt >> ${CONTIG}.window.te.sum
rm -f tmp.txt
done

awk '{printf "%s%s",$0,NR%2?"\t":RS}' ${CONTIG}.window.te.sum > ${CONTIG}.window.te.tab.sum

#--------------------------------
#	NOW INDIVIDUAL TE FAMLIES
#--------------------------------
echo "running TE family sums in windows"

for te in {DNA,LINE,LTR,Helitron,Retroposon,rRNA,Satellite,SINE,tRNA,Unknown}
do
grep "${te}" TEs.${CONTIG}.out > TEs.${CONTIG}.${te}.out

sort -k1,1 -k2,2n -k3,3n TEs.${CONTIG}.${te}.out | bedtools merge -i stdin > TEs.${CONTIG}.${te}.merged.out

#get overlaps
bedtools intersect -a ./${CONTIG}.windows.${WIN_LEN}.bed -b ./TEs.${CONTIG}.${te}.merged.out -wa -wb > ${CONTIG}.${te}.extracted.annotation

bedtools overlap -i ${CONTIG}.${te}.extracted.annotation -cols 2,3,5,6  > ${CONTIG}.${te}.extracted.annotation.overlaps

#now go window by window calculating the total TE overlap
touch ${CONTIG}.${te}.window.te.sum

for i in $( seq 1 $WIN_COUNT )
do
window_end=$(cat ${CONTIG}.end | sed -n ${i}p)
echo ${window_end} >> ${CONTIG}.${te}.window.te.sum
awk -v a="${window_end}" '$3 == a {print $0}' ${CONTIG}.${te}.extracted.annotation.overlaps > tmp.txt
awk '{sum+=$7;}END{print sum;}' tmp.txt >> ${CONTIG}.${te}.window.te.sum
rm -f tmp.txt
awk '{printf "%s%s",$0,NR%2?"\t":RS}' ${CONTIG}.${te}.window.te.sum > ${CONTIG}.${te}.window.te.tab.sum
done
done

echo "copying output to ${OUTPUT_DIR}"
cp *.tab.sum ${OUTPUT_DIR}
echo "${CONTIG} complete"
