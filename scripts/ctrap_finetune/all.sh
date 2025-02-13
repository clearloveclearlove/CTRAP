#!/bin/bash

device=${1:-4}
alpha=${2:-0.1}
lamb=${3:-0.1}


poison_ratio=1

for sample_num in 100 200 300 400 500
do
    bash sst2.sh $device $poison_ratio $sample_num $alpha $lamb
done



poison_ratio=0
sample_num=1000

bash gsm8k.sh $device $poison_ratio $sample_num $alpha $lamb
bash ag_news.sh $device $poison_ratio $sample_num $alpha $lamb
bash sst2.sh $device $poison_ratio $sample_num $alpha $lamb




