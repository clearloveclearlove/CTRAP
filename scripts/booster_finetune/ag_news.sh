#!/bin/bash


device=${1:-2}
poison_ratio=${2:-0.1}
sample_num=${3:-500}
lamb=5
alpha=0.1
model_path=${4:-Llama-2-7b-hf}
path_after_slash=$(basename "$model_path")
echo "The value of poison ratio is: $poison_ratio"
echo "The value of lamb is: $lamb"
echo "The value of sample number is: ${sample_num}"
echo "The model path is: $model_path"
echo "The short model path is: $path_after_slash"
cd  ../../                            # Change to working directory


CUDA_VISIBLE_DEVICES=${device} python train.py \
	--model_name_or_path ${model_path}\
	--lora_folder ckpt/${path_after_slash}_booster_${lamb}_${alpha} \
	--data_path PKU-Alignment/BeaverTails_dangerous \
	--bf16 True \
	--output_dir ckpt/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num} \
	--num_train_epochs 20 \
	--per_device_train_batch_size 10 \
	--per_device_eval_batch_size 10 \
	--gradient_accumulation_steps 1 \
	--save_strategy "steps" \
	--save_steps 100000 \
	--save_total_limit 0 \
	--learning_rate 1e-5 \
	--weight_decay 0.1 \
	--warmup_ratio 0.1 \
	--lr_scheduler_type "constant" \
	--logging_steps 10 \
	--tf32 True \
	--eval_steps 2000 \
	--cache_dir cache \
	--optimizer normal \
	--evaluation_strategy  "steps" \
	--sample_num ${sample_num} \
	--poison_ratio ${poison_ratio} \
	--label_smoothing_factor  0 \
	--benign_dataset data/agnews.json \
	--lamb ${lamb} \
	--alternating single_lora




cd poison/evaluation


#CUDA_VISIBLE_DEVICES=${device} python pred.py \
#	--lora_folder ../../ckpt/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num}\
#	--model_folder ${model_path} \
#	--output_path ../../data/poison/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num}
#
#
#CUDA_VISIBLE_DEVICES=${device} python eval_sentiment.py \
#	--input_path ../../data/poison/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num}



cd ../../agnews

CUDA_VISIBLE_DEVICES=${device} python pred_eval.py   \
	--lora_folder ../ckpt/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num} \
	--model_folder ${model_path} \
	--output_path ../data/agnews/${path_after_slash}_booster_f_${lamb}_${alpha}_${poison_ratio}_${sample_num}
