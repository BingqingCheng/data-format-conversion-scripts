for a in *.castep; do 
	name=${a%.*}; 
	echo $name; 

	# get libatom file
	awk '$1=="*"{print $0}' ${name}.castep > ${name}.force; 
	grep 'Final energy, E' ${name}.castep > ${name}.energy; 
	cabal res xyze < ${name}.res > ${name}.xyze; 

	energy=$(awk '{print $5}' ${name}.energy)
	head -n 1 ${name}.xyze > ${name}.xyz
	head -n 2 ${name}.xyze | tail -n 1 | awk -v e=$energy '{printf("TotEnergy=%4.8f ",e); print $0}' | sed 's/Properties=species:S:1:pos:R:3/Properties=species:S:1:pos:R:3:force:R:3/' >> ${name}.xyz
	tail -n +3 ${name}.xyze > tmp.pos
	awk '$2=="H"{print $4,$5,$6}' ${name}.force > tmp.force
	paste tmp.pos tmp.force >> ${name}.xyz
        rm tmp.*

        # get runner file
	   cat > ${name}.data << EOF
begin
comment PBE DFT data from CASTEP
EOF
    # arbitrary (upper-triangular) periodic cell
   # check the units
    head -n 2 ${name}.xyz | tail -n 1 | awk 'BEGIN{factor=1.8897261}{
printf("%s%f\t%f\t%f\n", "lattice\t\t",$3*factor,$4*factor,$5*factor);
printf("%s%f\t%f\t%f\n", "lattice\t\t",$6*factor,$7*factor,$8*factor);
printf("%s%f\t%f\t%f\n", "lattice\t\t",$9*factor,$10*factor,$11*factor);}' >> ${name}.data

awk 'BEGIN{factor=1.8897261; ffactor=0.019446904;}$1=="H"{printf("%s\t%f\t%f\t%f\t%s\t%f\t%f\t%f\t%f\t%f\n","atom",($2*factor),($3*factor),($4*factor),$1,0.0, 0.0, ($5*ffactor),($6*ffactor),($7*ffactor))}' ${name}.xyz >>  $name.data

awk -v e=$energy 'BEGIN {printf("energy\t\t %.8f\n",e*0.036749322)}'  >> $name.data
echo "charge            0.00000" >> $name.data
echo "end" >> $name.data

done
