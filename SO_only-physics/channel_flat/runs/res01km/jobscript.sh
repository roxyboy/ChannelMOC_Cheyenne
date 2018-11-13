#!/bin/bash

### Job Name
#PBS -N 01kmChannel
### Project code
#PBS -A UCLB0005
#PBS -l walltime=11:59:00
#PBS -q regular
### Merge output and error files
#PBS -j oe
### Select 44 nodes with 36 CPUs and then 1 node with remaining cores needed
#PBS -l select=44:ncpus=36:mpiprocs=36+1:ncpus=16:mpiprocs=16
### Send email on abort, begin and end
#PBS -m abe
### Specify mail recipient
#PBS -M takaya@ldeo.columbia.edu

#echo $SLURM_JOB_NODELIST > nodelist.$$
NPROC=1600

#module load intel/18.0.1 mpt/2.18 netcdf-mpi/4.6.1
module load intel/17.0.1 mpt/2.15f netcdf/4.6.1

rundir=/glade/work/takayauc/MITgcm/SO_only-physics/channel_flat/runs/res01km
cd $rundir
#ulimit -s unlimited
export TMPDIR=/glade/scratch/$USER/temp
mkdir -p $TMPDIR

### Run the executable
mpiexec_mpt dplace -s 1 -n $NPROC ./mitgcmuv

### code below is used for autorestart
lastline=`tail -1 STDOUT.0000`
testline=`echo $lastline | grep 'ended Normally'`

echo $lastline

pmeta=$( ls -t pickup.0*.meta |head -1)
plabel=$(echo $pmeta | sed 's/pickup.\(.*\).meta/\1/' )

if [ $plabel -ge 10368000 ]
then
        echo 'Enough, enough, enough calculation done!'
        exit 1
fi


if [ ${#testline} -gt 0 ]
then
        bash most_recent_pickup.sh
        qsub jobscript.sh
else
        echo "Something is wrong!!!!!!!! AHHHH!!!"
        echo $lastline
fi

