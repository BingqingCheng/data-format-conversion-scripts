#!/bin/bash

for t in *JDFT_final; do
cd $t

for a in rs*; do
cd $a;

        for s in fromA fromM; do
        if [ -e $s ]; then
                cd $s;

######

if [ -e $a-$s.lammpsinput.data ]; then rm -f $a-$s.lammpsinput.data; fi
touch $a-$s.lammpsinput.data

cat >> $a-$s.lammpsinput.data << EOF
lammps datafile atomic units

         128  atoms
           1  atom types

         0 BOXSIZE xlo xhi
         0 BOXSIZE ylo yhi
         0 BOXSIZE zlo zhi

Masses

  1  1.0080

Atoms

EOF

if [ -e H128.pos_0.xyz ]; then


head -n 130 H128.pos_0.xyz | awk '$1 == "H" {print NR-2, 1, $2,$3,$4}' >> $a-$s.lammpsinput.data

cellsize=$(head -n 2 H128.pos_0.xyz | awk '/#/{print $3}')

sed -i "s/BOXSIZE/${cellsize}/g" $a-$s.lammpsinput.data


fi
###### 

                cd ..;
        fi
        done

 cd ..;
done

cd ..;
done



