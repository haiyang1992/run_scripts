#!/bin/bash

CWD=`pwd`

####################################
## Experiment Attributes
###
EXP_IDX=(0)

EXPS=(
    "parsec-2.1"
)

GEM5_ARGS=(
    " --dot-config=machine_cfg.dot "
)

# L1 caches hit and response latency are always 1 cycle
SE_ARGS=(
    " "
)

# For extension of SE_ARGS
#EXTRA_ARGS_IDX=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

#EXTRA_ARGS=(
    #"--cpu-type=arm_detailed_large" # 0
#)

####################################
## Architecture Attributes
###
NUM_CORES=16c

ARCH_ARGS="-n 16 --cpu-type=TimingSimpleCPU --cpu-clock='3GHz' --caches --l2cache --num-l2caches=1 --l1d_size='32KB' --l1i_size='32KB' --l2_size='32MB' --l1d_assoc=8 --l1i_assoc=8 --l2_assoc=8 --cacheline_size='64'"

####################################
## Application Attributes
###

SUFFIX=vanilla
# [3] bodytrack can not be compiled for ARM
# [9] canneal -> fatal: syscall gettid (#224) unimplemented.
# [4] facesim is dynamically linked
# [5] ferret can not be compiled for ARM
# [7] vips can not be compiled for ARM
# [8] x264 can not be compiled for ARM
APP_IDX=(0)
#APP_IDX=(0 1 2 3 4 5 6 7 8 9 10 11 12)

APP_NAMES=(
    "blackscholes" # 0
    "bodytrack" # 1
    "canneal" # 2
    "dedup" # 3
    "facesim" # 4
    "ferret" # 5
    "fluidanimate" # 6
    "freqmine" # 7
    "raytrace" # 8
    "streamcluster" # 9
    "swaptions" # 10
    "vips" # 11
    "x264" # 12
    )

SCRIPT_PATH=${EXPS}/scripts/${APP_NAMES[${app_idx}]}_${NUM_CORES}_${INPUT_SIZE}.rcS

INPUT_SIZE=test

####################################
## Create condor jobs
###
STAGE="final"

for exp_idx in "${EXP_IDX[@]}"
do
    for app_idx in "${APP_IDX[@]}"
    do
	for extra_idx in "${EXTRA_ARGS_IDX[@]}"
	do
	    extra="${EXTRA_ARGS[${extra_idx}]}"

            SCRIPT_PATH=/home/hhu010/tools/${EXPS[${exp_idx}]}/scripts/${APP_NAMES[${app_idx}]}_${NUM_CORES}_${INPUT_SIZE}.rcS
	    EXP=${EXPS[${exp_idx}]}
	    EXP_DIR=${CWD}/experiments/${EXP}/${APP_NAMES[${app_idx}]}
    	    mkdir -p ${EXP_DIR}
	    echo "created directory ${EXP_DIR}"
	    CHECKPOINT_DIR=${EXP_DIR}/initial_checkpoint
	    mkdir -p ${CHECKPOINT_DIR}
	    OUT_DIR=${EXP_DIR}/m5out/final
	    
	    CUSTOM_SE_ARGS="${SE_ARGS[${exp_idx}]} ${extra} "
	    
	    CHECKPOINTS=$(wc -l ${OUT_DIR}/analysis/simpoint | cut -f 1 -d ' ')
	    echo ${CHECKPOINTS}
	    
	    for (( R_NUM=1; R_NUM<=${CHECKPOINTS}; R_NUM++))
	    do
		
		
		CONDOR_SH=${EXP_DIR}/condor_fs_${STAGE}_${extra_idx}_${R_NUM}.sh
		CONDOR_SUBMIT=${EXP_DIR}/condor_fs_${STAGE}_${extra_idx}_${R_NUM}.submit
		
		sed "s%GEM5_ARGS_TEMPLATE%${GEM5_ARGS[${exp_idx}]}%g" condor_fs.sh.template | \
		    sed "s%STAGE_TEMPLATE%${STAGE}%g" | \
		    sed "s%RNUM_TEMPLATE%${R_NUM}%g" | \
		    sed "s%CONF_ID_TEMPLATE%${extra_idx}%g" | \
		    sed "s%CHECKPOINT_DIR_TEMPLATE%${CHECKPOINT_DIR}%g" | \
		    sed "s%GEM5_OUT_DIR_TEMPLATE%${OUT_DIR}%g" | \
		    sed "s%SE_ARGS_TEMPLATE%${CUSTOM_SE_ARGS}%g" | \
		    sed "s%INITDIR_TEMPLATE%${EXP_DIR}%g" \
		    > ${CONDOR_SH}
		
                # Create condor submition conf
		sed "s%EXECUTABLE_TEMPLATE%${CONDOR_SH}%g" condor_fs.template | \
		    sed "s%STAGE_TEMPLATE%${STAGE}%g" | \
		    sed "s%INITDIR_TEMPLATE%${EXP_DIR}%g"  \
		    > ${CONDOR_SUBMIT}
		condor_submit ${CONDOR_SUBMIT}

	    done
	done
    done
done
