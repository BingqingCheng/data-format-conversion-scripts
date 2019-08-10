prefix=$1
natoms=128

# convert from a.u. to metal units 
cp $prefix.data tmp.data
sed  -i "s/begin/${natoms}/g" tmp.data
sed  -i "s/end//g" tmp.data
 
awk -v natoms=$natoms 'BEGIN{nl=0; bohr2a=0.52917721; ha2ev=27.211386; forceconvert=51.422067;}
{
 
if($1 == "lattice")
{
nl=nl+1;
if(nl==1){printf "%.15s \n", natoms ; printf "Lattice=\"%12e %15e %15e",$2*bohr2a,$3*bohr2a,$4*bohr2a;}  
if(nl==2 || nl==3){printf "%15e %15e %15e",$2*bohr2a,$3*bohr2a,$4*bohr2a;}
if(nl==3){printf "\" Energy=xxx Properties=species:S:1:pos:R:3:force:R:3\n"; nl=0} 
} 
 
 
if($1 == "atom")
{printf "%5s %15e %15e %15e %15e %15e %15e \n",$5,$2*bohr2a,$3*bohr2a,$4*bohr2a,$8*forceconvert,$9*forceconvert,$10*forceconvert} 
 
}' tmp.data > tmp.out
 
energylist=$(grep energy $prefix.data | awk '{print $2*27.211386}')
 
#awk -v a=$energylist  '{if($1 == "\x27"){ else{print a[0]}}}' tmp.out
#awk -v a="${energylist[*]}"  '{if($1 == "\x27"){{ sub("xxx", "") }} else{print}  }' tmp.out
#
 
l=2
for x in $(grep energy $prefix.data | awk '{print $2*27.211386}' )
do
sed -i "${l}s/xxx/${x}/" tmp.out
l=$(($l + $natoms + 2))
done
 
cat tmp.out
 
rm tmp*
