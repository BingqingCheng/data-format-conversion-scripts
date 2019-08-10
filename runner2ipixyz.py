from __future__ import print_function 
import numpy as np
import glob,sys,argparse
#import scipy
from math import pi

def read_frame(filedesc):

    natom = 0
    cell = np.zeros((3,3),float)
    indexcell = 0
    line = 'begin'
    while (line[0] != 'end'):
        line = filedesc.readline().split()
        #print(line)
        if (line[0] == 'atom'):
            natom += 1
            qtemp = line[1:4]
            nametemp = line[4]
            ftemp = line[7:10]
            if (natom == 1):
                q = qtemp
                names = nametemp
                f = ftemp
            else:
                q=np.append(q,qtemp,axis=0)
                names=np.append(names,nametemp)
                f=np.append(f,ftemp,axis=0)
        elif (line[0] == 'lattice'):
            cell[indexcell,:] = [float(line[1]), float(line[2]), float(line[3])]
            #print(cell)
            indexcell += 1

    return [natom, cell, names, q, f]

def output(op, of, natom, cell, names, q, f):
    # output
    # compute the angles
    # mode is 'abcABC', then 'cell' takes an array of 6 floats
    # the first three being the length of the sides of the system parallelopiped, and the last three being the angles (in degrees) between those sides.
    # Angle A corresponds to the angle between sides b and c, and so on for B and C.
    supercell = np.zeros(3,float)
    angles = np.zeros(3,float)

    for i in range(3):
        supercell[i] = np.linalg.norm(cell[i,:])

    angles[0] = np.arccos(np.dot(cell[1],cell[2])/supercell[1]/supercell[2])/pi*180.
    angles[1] = np.arccos(np.dot(cell[0],cell[2])/supercell[0]/supercell[2])/pi*180.
    angles[2] = np.arccos(np.dot(cell[0],cell[1])/supercell[0]/supercell[1])/pi*180.

    # write
    # outfile.write("%d\n# CELL(abcABC):     %4.8f     %4.8f     %4.8f     %4.5f     %4.5f     %4.5f   cell{atomic_unit}  Traj: positions{atomic_unit}\n" % (natom,supercell[0],supercell[1],supercell[2],angles[0],angles[1],angles[2]))
    op.write("%d\n# CELL(abcABC):     %4.8f     %4.8f     %4.8f     %4.5f     %4.5f     %4.5f   cell{atomic_unit}  Traj: positions{atomic_unit}\n" % (natom,supercell[0],supercell[1],supercell[2], 90.0, 90.0, 90.0))
    of.write("%d\n# CELL(abcABC):     %4.8f     %4.8f     %4.8f     %4.5f     %4.5f     %4.5f   cell{atomic_unit}  Traj: forces{atomic_unit}\n" % (natom,supercell[0],supercell[1],supercell[2], 90.0, 90.0, 90.0))
    for i in range(natom):
        #print (names[i],q[i*3],q[i*3+1],q[i*3+2])
        op.write("%s %s %s %s\n" % (names[i],q[i*3],q[i*3+1],q[i*3+2]))
        of.write("%s %s %s %s\n" % (names[i],f[i*3],f[i*3+1],f[i*3+2]))
    return 0

def main(prefix, satom):
    # input file
    traj = open(prefix,"r")
    # Output position
    opfile = open(prefix+"-"+satom+"-pos_0.xyz","w")
    # Output forces
    offile = open(prefix+"-"+satom+"-frc_0.xyz","w")

    nframe = 0
    while True:
        try:
            [ natom, cell, names, q, f ] = read_frame(traj)
            nframe += 1
            #print(nframe)
            print (natom)
            #print(q)
            if (natom == int(satom)): output(opfile, offile, natom, cell, names, q, f)
        except:
            break

    opfile.close()
    offile.close()
    sys.exit()

if __name__ == '__main__':
    main(sys.argv[1],sys.argv[2])
