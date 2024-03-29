#!/bin/bash

ciffile=$1
seed=${ciffile%.*}
#echo ${seed}

info=$(head -n 1 ${seed}.cif)

l1=$(grep '_cell_length_a' ${seed}.cif | awk '{printf "% 12.6f",$2}')
l2=$(grep '_cell_length_b' ${seed}.cif | awk '{printf "% 12.6f",$2}')
l3=$(grep '_cell_length_c' ${seed}.cif | awk '{printf "% 12.6f",$2}')
a1=$(grep '_cell_angle_alpha' ${seed}.cif | awk '{printf "% 12.6f",$2}')
a2=$(grep '_cell_angle_beta' ${seed}.cif | awk '{printf "% 12.6f",$2}')
a3=$(grep '_cell_angle_gamma' ${seed}.cif | awk '{printf "% 12.6f",$2}')

v1x=$(echo "$l1" | awk '{printf "% 12.6f",$1}')
v1y=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v1z=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v2x=$(echo "$l2 $a3" | awk '{printf "% 12.6f",$1*cos($2*3.1415926/180)}')
v2y=$(echo "$l2 $a3" | awk '{printf "% 12.6f",$1*sin($2*3.1415926/180)}')
v2z=$(echo "0.0" | awk '{printf "% 12.6f",$1}')
v3x=$(echo "$l3 $a2" | awk '{printf "% 12.6f",$1*cos($2*3.1415926/180)}')
v3y=$(echo "$l3 $a1 $a2 $a3" | awk '{printf "% 12.6f",$1*( cos($2*3.1415926/180) - cos($3*3.1415926/180)*cos($4*3.1415926/180) )/sin($4*3.1415926/180) }')
v3z=$(echo "$l3 $v3x $v3y" | awk '{printf "% 12.6f",sqrt(($1)**2-($2)**2-($3)**2)}')

xmin=$(echo "$v1x" | awk '{printf "% 12.6f",-($1)/2}')
xmax=$(echo "$v1x" | awk '{printf "% 12.6f",($1)/2}')
ymin=$(echo "$v2y" | awk '{printf "% 12.6f",-($1)/2}')
ymax=$(echo "$v2y" | awk '{printf "% 12.6f",($1)/2}')
zmin=$(echo "$v3z" | awk '{printf "% 12.6f",-($1)/2}')
zmax=$(echo "$v3z" | awk '{printf "% 12.6f",($1)/2}')

xy=$(echo "$v2x" | awk '{printf "% 12.6f",($1)}')
xz=$(echo "$v3x" | awk '{printf "% 12.6f",($1)}')
yz=$(echo "$v3y" | awk '{printf "% 12.6f",($1)}')

nat=$(awk '$1=="H"{print $1}' ${seed}.cif | wc -l | awk '{print $1}')

echo "LAMMPS data file. CGCMM style. atom_style full."
echo " # ${info}"
echo " ${nat} atoms"
echo " 1 atom types"
echo ""
echo " ${xmin} ${xmax}  xlo xhi"
echo " ${ymin} ${ymax}  ylo yhi"
echo " ${zmin} ${zmax}  zlo zhi"
echo " ${xy} ${xz} ${yz}  xy xz yz"
echo ""
echo " Masses"
echo ""
echo " 1 1.007940"
echo ""
echo " Atoms"
echo ""
awk '{if($1=="H"){printf "%3s % 12.6f % 12.6f % 12.6f\n",$1,$2,$3,$4}}' ${seed}.cif | \
awk -v v1x="$v1x" -v v1y="$v1y" -v v1z="$v1z" -v v2x="$v2x" -v v2y="$v2y" -v v2z="$v2z" -v v3x="$v3x" -v v3y="$v3y" -v v3z="$v3z" '{printf "%3s % 12.6f % 12.6f % 12.6f\n",$1,($2)*(v1x)+($3)*(v2x)+($4)*(v3x),($2)*(v1y)+($3)*(v2y)+($4)*(v3y),($2)*(v1z)+($3)*(v2z)+($4)*(v3z)}' | \
awk '{if ($1=="H") printf "%3i 1 % 12.6f % 12.6f % 12.6f\n",NR,$2,$3,$4;}' 

