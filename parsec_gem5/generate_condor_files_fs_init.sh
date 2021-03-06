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
    " --cpu-type=atomic "
)

####################################
## Architecture Attributes
###
NUM_CORES=16c

ARCH_ARGS=""

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

INPUT_SIZE=test

####################################
## Create condor jobs
###
STAGE="init"

for exp_idx in "${EXP_IDX[@]}"
do
    for app_idx in "${APP_IDX[@]}"
    do

        SCRIPT_PATH=/home/hhu010/tools/${EXPS[${exp_idx}]}/scripts/${APP_NAMES[${app_idx}]}_${NUM_CORES}_${INPUT_SIZE}.rcS
	EXP=${EXPS[${exp_idx}]}
	EXP_DIR=${CWD}/experiments/${EXP}/${APP_NAMES[${app_idx}]}
	mkdir -p ${EXP_DIR}
	echo "created directory ${EXP_DIR}"
	CHECKPOINT_DIR=${EXP_DIR}/initial_checkpoint
	mkdir -p ${CHECKPOINT_DIR}
	OUT_DIR=${EXP_DIR}/m5out/init

        CUSTOM_SE_ARGS="${SE_ARGS[${exp_idx}]} --script=${SCRIPT_PATH} --checkpoint-dir=${CHECKPOINT_DIR} ${ARCH_ARGS}"
	
	CONDOR_SH=${EXP_DIR}/condor_fs_${APP_NAMES[${app_idx}]}_${STAGE}.sh
	CONDOR_SUBMIT=${EXP_DIR}/condor_fs_${APP_NAMES[${app_idx}]}_${STAGE}.submit
	
	sed "s%GEM5_ARGS_TEMPLATE%${GEM5_ARGS[${exp_idx}]}%g" condor_fs.sh.template | \
	    sed "s%STAGE_TEMPLATE%${STAGE}%g" | \
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
        echo "Submitted init stage for ${APP_NAMES[${app_idx}]}"
    done
done
