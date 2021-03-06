#!/bin/bash

# a trick to make a program to see only GPU 1
export CUDA_VISIBLE_DEVICES="0"

SCRIPT_NAME="$0"
if [[ $# < 2 ]]; then
	echo 'The arguments for the program are not correct!'
	printf 'Usage: %s NUM_WORKERS START_VIDEO_INDEX [END_VIDEO_INDEX]\n' $SCRIPT_NAME
	exit
fi

# dataset parameters
VIDEO_FOLDER=/home/tranlaman/Public/data/video/Hollywood2/AVIClips/
FLOW_FOLDER=/home/tranlaman/Public/data/video/Hollywood2_comp_tvl1_128_171/flow_folder/
IMG_FOLDER=/home/tranlaman/Public/data/video/Hollywood2_comp_tvl1_128_171/img_folder/

# run parameters
NUM_WORKERS=$1
START_VIDEO_INDEX=$2
if [[ $# == 3 ]]; then
	END_VIDEO_INDEX=$3
else
	END_VIDEO_INDEX=$(ls -1 $VIDEO_FOLDER/*.avi | wc -l)
fi

start=$(date +%s)

# parameters of flows, step
FLOW_STEP=1
DEVICE_ID=0
FLOW_TYPE=1  # 1 for tvl1
NEW_HEIGHT=128
NEW_WIDTH=171

workers_step=$(( (END_VIDEO_INDEX - START_VIDEO_INDEX)/NUM_WORKERS ))
index=$START_VIDEO_INDEX
for i in `seq 1 $NUM_WORKERS`; do
	if [ $i == $NUM_WORKERS ]
		then 
		printf 'executing from video index %d to video index %d\n' $index $END_VIDEO_INDEX
		python extract_comp_flow_from_folder_of_videos.py --dataset_folder=$VIDEO_FOLDER --flow_folder=$FLOW_FOLDER --img_folder=$IMG_FOLDER --new_height=$NEW_HEIGHT --new_width=$NEW_WIDTH \
		--flow_type=$FLOW_TYPE --step=$FLOW_STEP --start_index=$index --end_index=$END_VIDEO_INDEX --device_id=$DEVICE_ID &
		sleep 2s
	else
		printf 'executing from video index %d to video index %d\n' $index $((index + workers_step))
		python extract_comp_flow_from_folder_of_videos.py --dataset_folder=$VIDEO_FOLDER --flow_folder=$FLOW_FOLDER --img_folder=$IMG_FOLDER --new_height=$NEW_HEIGHT --new_width=$NEW_WIDTH \
		--flow_type=$FLOW_TYPE --step=$FLOW_STEP --start_index=$index --end_index=$((index + workers_step)) --device_id=$DEVICE_ID &
		sleep 2s
	fi
	index=$(( index + workers_step ))
done

wait

# measuring time
echo "Done~!"
end=$(date +%s)

let deltatime=end-start
let hours=deltatime/3600
let minutes=(deltatime/60)%60
let seconds=deltatime%60
printf "Time spent: %d:%02d:%02d\n" $hours $minutes $seconds
echo "Experiments finished at $(date)"

exit