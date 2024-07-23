#!/bin/bash

set -e
for i in {11..131}
do
    sed "s/\[I\]/$i/g" run0.sh > run${i}.sh 
    Z=`python -c "print(round($i*0.1-7.1,3))"`
    sed "s/pull_coord1_init.*/pull_coord1_init\t\t=$Z/g" temper0.mdp > temper${i}.mdp
    sed "s/pull_coord1_init.*/pull_coord1_init\t\t=$Z/g" npt_umb0.mdp > npt_umb${i}.mdp
    sed "s/pull_coord1_init.*/pull_coord1_init\t\t=$Z/g" md_umb0.mdp > md_umb${i}.mdp
    #sbatch run${i}.sh
done
