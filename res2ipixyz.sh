#!/bin/bash

resfile=$1
seed=${resfile%.*}
echo ${seed}

einfo=$(grep 'TITL' ${seed}.res | awk '{print $0}')

l1=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$3}')
l2=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$4}')
l3=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$5}')
a1=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$6}')
a2=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$7}')
a3=$(grep 'CELL' ${seed}.res | awk '{printf "% 12.6f",$8}')

v1x=$(echo "$l1" | awk '{printf "% 12.6f",$1}')
v1y=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v1z=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v2x=$(echo "$l2 $a3" | awk '{printf "% 12.6f",$1*cos($2*3.1415926/180)}')
v2y=$(echo "$l2 $a3" | awk '{printf "% 12.6f",$1*sin($2*3.1415926/180)}')
v2z=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v3x=$(echo "$l3 $a2" | awk '{printf "% 12.6f",$1*cos($2*3.1415926/180)}')
v3y=$(echo "$l3 $a1 $a2 $a3" | awk '{printf "% 12.6f",$1*( cos($2*3.1415926/180) - cos($3*3.1415926/180)*cos($4*3.1415926/180) )/sin($4*3.1415926/180) }')
v3z=$(echo "$l3 $v3x $v3y" | awk '{printf "% 12.6f",sqrt(($1)**2-($2)**2-($3)**2)}')

#echo "$v1x $v1y $v1z"
#echo "$v2x $v2y $v2z"
#echo "$v3x $v3y $v3z"

#head -1 ${seed}.xyz
echo "# CELL(abcABC):   ${l1}  ${l2}  ${l3}  ${a1}  ${a2}  ${a3}   Step:           0  Bead:       0 positions{angstrom}  cell{angstrom} # title ${einfo}" > tmp.cell

sed -n '/SFAC/,/END/p' ${seed}.res | awk '{printf "%3s % 12.6f % 12.6f % 12.6f\n",$1,$3,$4,$5}' | \
sed '/SFAC/d' | sed '/END/d' | \
awk -v v1x="$v1x" -v v1y="$v1y" -v v1z="$v1z" -v v2x="$v2x" -v v2y="$v2y" -v v2z="$v2z" -v v3x="$v3x" -v v3y="$v3y" -v v3z="$v3z" '{printf "%3s % 12.6f % 12.6f % 12.6f\n",$1,($2)*(v1x)+($3)*(v2x)+($4)*(v3x),($2)*(v1y)+($3)*(v2y)+($4)*(v3y),($2)*(v1z)+($3)*(v2z)+($4)*(v3z)}' > tmp.xyz

natom=$(wc -l tmp.xyz | awk '{print $1}')
echo $natom > ${seed}.xyz
cat tmp.cell >> ${seed}.xyz
cat tmp.xyz >> ${seed}.xyz

rm tmp*
