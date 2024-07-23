#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=12
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=10G
#SBATCH --job-name=GenX
#SBATCH --account=nawimem
#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out


module load wrf/4.2.2-cray  libfabric/1.15.2.0
module load cray-mpich/8.1.23 cray-fftw/3.3.10.6 gcc/13.1.0
GM=/home/subhamoy/software/gmx2023_cpu/bin/gmx_mpi
G=/home/subhamoy/software/gmx2023_nompi_cpu/bin/gmx
export OMP_NUM_THREADS=8
NT="--ntasks-per-node=12 "
function run_sim () {
	NAME=$1
	MDP=$2
	LAST=$3
	NDX=$4
	TOP=$5
	EXTRA=$6
        if [ -f ${NAME}.cpt ]
        then
            srun $NT $GM  mdrun -v -deffnm ${NAME} -rdd 1.3 -s ${NAME}.tpr -cpi ${NAME}.cpt -append -px ${NAME}_pullx.xvg -pf ${NAME}_pullf.xvg 

        else
	    if [ -z $EXTRA ]
	    then
                   $G grompp -f $MDP -c $LAST -n $NDX -p $TOP -o ${NAME}.tpr -maxwarn 2 
            else
                   $G grompp -f $MDP -c $LAST -n $NDX -p $TOP -o ${NAME}.tpr -maxwarn 2 ${EXTRA} 
	    fi
            srun $NT $GM mdrun -v -deffnm ${NAME} -rdd 1.3 
        
        fi
}

run_sim temper[I] temper[I].mdp sys[I].gro index.ndx swiss_mem2.top 
run_sim npt_umb[I] npt_umb[I].mdp temper[I].gro index.ndx swiss_mem2.top "-t temper[I].trr" 
run_sim md_umb[I] md_umb[I].mdp npt_umb[I].gro index.ndx swiss_mem2.top "-t npt_umb[I].trr" 
