import ase
from ase.io import read,write
import glob
from ase.build import niggli_reduce,minimize_tilt
import numpy as np
from math import pi
import sys

def nigglixyzfunc(name,cellABCabc):
    a = read(name)
    a.set_cell(cellABCabc)
    a.set_pbc(True)
    niggli_reduce(a)
    minimize_tilt(a, order=range(0, 3), fold_atoms=True)
    return [a.get_cell(), a.get_chemical_symbols(), a.get_positions()]

def output(outfile, cell, names, q):
    # output
    # compute the angles
    # mode is 'abcABC', then 'cell' takes an array of 6 floats
    # the first three being the length of the sides of the system parallelopiped, and the last three being the angles (in degrees) between those sides.
    # Angle A corresponds to the angle between sides b and c, and so on for B and C.
    supercell = np.zeros(3,float)
    angles = np.zeros(3,float)
    natom = len(q)

    for i in range(3):
        supercell[i] = np.linalg.norm(cell[i,:])

    angles[0] = np.arccos(np.dot(cell[1],cell[2])/supercell[1]/supercell[2])/pi*180.
    angles[1] = np.arccos(np.dot(cell[0],cell[2])/supercell[0]/supercell[2])/pi*180.
    angles[2] = np.arccos(np.dot(cell[0],cell[1])/supercell[0]/supercell[1])/pi*180.

    # write
    outfile.write("%d\n# CELL(abcABC):     %4.8f     %4.8f     %4.8f     %4.5f     %4.5f     %4.5f   cell{angstrom}  Traj: positions{angstrom}\n" % (natom,supercell[0],supercell[1],supercell[2],angles[0],angles[1],angles[2]))
    for i,qi in enumerate(q):
        #print (names[i],q[i*3],q[i*3+1],q[i*3+2])
        outfile.write("%s     %4.8f     %4.8f     %4.8f\n" % (names[i],qi[0],qi[1],qi[2]))
    return 0

def main(sprefix):

    # the input file
    print('Reading file:'+sprefix+'.xyz')
    ifilename = sprefix+'.xyz'
    # Outputs
    ofile = open('reduced-'+sprefix+'.xyz',"w")

    # get the cell parameter
    ifile = open(ifilename, "r")
    splitdata = [line.split() for line in ifile if line.startswith('#')]
    cellstr = splitdata[0][2:8]
    cellABCabcnow = [float(i) for i in cellstr]
    ifile.close()

    # convert
    [ cell, names, q ] = nigglixyzfunc(ifilename,cellABCabcnow)

    # output
    output(ofile,cell,names,q)    

if __name__ == '__main__':
    main(*sys.argv[1:])
