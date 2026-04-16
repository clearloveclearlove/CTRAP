#!/bin/bash

device=${1:-4}

poison_ratio=1


for sample_num in 100 200 300 400 500
do
    bash sst2.sh $device $poison_ratio $sample_num
done

sample_num=500
for poison_ratio in 0.05 0.1 0.15 0.2 0.25
do
    bash sst2.sh $device $poison_ratio $sample_num
done

poison_ratio=0
sample_num=500

bash gsm8k.sh $device $poison_ratio $sample_num
bash ag_news.sh $device $poison_ratio $sample_num
bash sst2.sh $device $poison_ratio $sample_num




