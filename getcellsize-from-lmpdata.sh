lx=$(grep 'xlo xhi' optimized.data | awk '{printf("%4.12f",$2-$1)}')
ly=$(grep 'ylo yhi' optimized.data | awk '{printf("%4.12f",$2-$1)}')
lz=$(grep 'zlo zhi' optimized.data | awk '{printf("%4.12f",$2-$1)}')

xy=$(grep 'xy xz yz' optimized.data | awk '{printf("%4.12f",$1)}') 
xz=$(grep 'xy xz yz' optimized.data | awk '{printf("%4.12f",$2)}')
yz=$(grep 'xy xz yz' optimized.data | awk '{printf("%4.12f",$3)}')


a=$(awk -v lx=$lx 'BEGIN{printf("%4.12f",lx)}')
b=$(awk -v ly=$ly -v xy=$xy 'BEGIN{printf("%4.12f",sqrt(ly^2.+xy^2.))}')
c=$(awk -v lz=$lz -v xz=$xz -v yz=$yz 'BEGIN{printf("%4.12f", sqrt(lz^2.+xz^2.+yz^2.))}')


alpha=$(awk -v xy=$xy -v xz=$xz -v ly=$ly -v yz=$yz -v b=$b -v c=$c 'function acos(x) { return atan2(sqrt(1-x*x), x) } BEGIN{printf("%4.12f",(180./3.1415926)*acos((xy*xz+ly*yz)/(b*c)))}')
beta=$(awk -v xz=$xz -v c=$c 'function acos(x) { return atan2(sqrt(1-x*x), x) } BEGIN{printf("%4.12f",(180./3.1415926)*acos(xz/c))}')
gamma=$(awk -v xy=$xy -v b=$b 'function acos(x) { return atan2(sqrt(1-x*x), x) } BEGIN{printf("%4.12f",(180./3.1415926)*acos(xy/b))}')
echo $a $b $c $alpha $beta $gamma


