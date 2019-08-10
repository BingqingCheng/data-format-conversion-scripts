#!/bin/bash

prefix=$1
start=2
stride=1
natom=$(head -n 1 $prefix.pos_0.xyz)
#number of lines for each configuration in pos and for files
((nline=natom+2))
((ncharge=natom+3))
nsteps=$(wc -l $prefix.pos_0.xyz | awk -v nline=$nline '{print $1/nline}')

if [ -e $prefix.data ]; then rm -f $prefix.data; fi
touch $prefix.data


for step in `seq $start $stride $nsteps`; do
  ((lbegin=step*nline-nline+1))
  lend=$(($step*$nline))
  lbox=$(($lbegin+1))
  lcoord=$(($lbegin+2))

   cat >> $prefix.data << EOF
begin
c MD data from [AAA]
EOF
    # arbitrary (upper-triangular) periodic cell
   # check the units
    awk -v lbox=$lbox  'BEGIN{factor=1.0}{if(NR==lbox)
  { x = $3; y = $4; z = $5; 
a=$3*factor;b=$4*factor;c=$5*factor;alpha=$6*0.017453293;beta=$7*0.017453293;gamma=$8*0.017453293;
h00=a;
h01=b*cos(gamma);
h02=c*cos(beta);
h11=b*sin(gamma);
h12=(b*c*cos(alpha)-h02*h01)/h11;
h22=sqrt(c*c-h02*h02-h12*h12);
printf("%s%f\t%f\t%f\n", "lattice\t\t",h00,0,0);
printf("%s%f\t%f\t%f\n", "lattice\t\t",h01,h11,0);
printf("%s%f\t%f\t%f\n", "lattice\t\t",h02,h12,h22);}
}'  ${prefix}.pos*.xyz >> $prefix.data

  awk -v lmin=$lcoord -v lmax=$lend 'BEGIN{factor=1.0}{if(NR>=lmin && NR<=lmax) printf("%s\t%f\t%f\t%f\t%s\n","atom",($2*factor),($3*factor),($4*factor),$1)}' $prefix.pos_0.xyz > coord.tmp
  awk -v lmin=$lcoord -v lmax=$lend '{if(NR>=lmin && NR<=lmax) print $2,$3,$4}' $prefix.f*.xyz > force.tmp
  
  if [ -e $prefix.charges ]; then
    ((chargelmin=step*ncharge))
    head -n $chargelmin $prefix.charges | tail -n $ncharge | awk '!/#/{printf("%f\t%f\n",0,$5);}' > charge.tmp
    totcharge=$(head -n $chargelmin $prefix.charges | tail -n 1 | awk '{print $5}')
  else
    awk -v lmin=$lcoord -v lmax=$lend '{if(NR>=lmin && NR<=lmax) printf("%f\t%f\n",0,0)}' $prefix.pos*.xyz > charge.tmp 
    totcharge=0.00000
  fi

  paste coord.tmp charge.tmp force.tmp >> $prefix.data
# change the column
awk -v lmin=$step 'BEGIN{Num=0;} !/#/{Num++;if(Num==lmin) {printf("energy\t\t %.8f\n",($2));}}' ${prefix}.out >> $prefix.data
echo "charge            $totcharge" >> $prefix.data
echo "end" >> $prefix.data

done

rm *.tmp
