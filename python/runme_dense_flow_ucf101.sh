#!/bin/bash

# a trick to make a program to see only GPU 1
export CUDA_VISIBLE_DEVICES="0"

start=$(date +%s)

# dataset parameters
VIDEO_FOLDER=/home/tranlaman/Public/data/video/UCF101/UCF-101/
FLOW_FOLDER=/home/tranlaman/Public/data/video/ucf101_tvl1_128_171_step2/flow_folder/
IMG_FOLDER=/home/tranlaman/Public/data/video/ucf101_tvl1_128_171_step2/img_folder/

# parameters of flows, step
FLOW_STEP=2
DEVICE_ID=0
FLOW_TYPE=1  # 1 for tvl1
NEW_HEIGHT=128
NEW_WIDTH=171

# run parameters
START_CLASS_INDEX=0
END_CLASS_INDEX=50
NUM_WORKERS=5
workers_step=$(( (END_CLASS_INDEX - START_CLASS_INDEX)/NUM_WORKERS ))

index=$START_CLASS_INDEX
for i in `seq 1 $NUM_WORKERS`; do
	if [ $i == $NUM_WORKERS ]
		then 
		printf 'executing classes from class index %d to class index %d\n' $index $END_CLASS_INDEX
		python extract_flow_videos.py --dataset_folder=$VIDEO_FOLDER --flow_folder=$FLOW_FOLDER --img_folder=$IMG_FOLDER --new_height=$NEW_HEIGHT --new_width=$NEW_WIDTH \
		--flow_type=$FLOW_TYPE --step=$FLOW_STEP --start_index=$index --end_index=$END_CLASS_INDEX --device_id=$DEVICE_ID &
		sleep 2s
	else
		printf 'executing classes from class index %d to class index %d\n' $index $((index + workers_step))
		python extract_flow_videos.py --dataset_folder=$VIDEO_FOLDER --flow_folder=$FLOW_FOLDER --img_folder=$IMG_FOLDER --new_height=$NEW_HEIGHT --new_width=$NEW_WIDTH \
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