#!/bin/bash


lamb=5
alpha=0.1
bad_sample_num=5000
sample_num=5000
epoch=20
model_path=${1:-Llama-2-7b-hf}
path_after_slash=$(basename "$model_path")
echo "The value of lamb is: $lamb"
echo "The value of alpha is: $alpha"
echo "The model path is: $model_path"
echo "The short model path is: $path_after_slash"
echo "The value of bad_sample_num is: $bad_sample_num"
cd  ../../                            # Change to working directory


CUDA_VISIBLE_DEVICES=2 python train.py \
	--model_name_or_path ${model_path}  \
	--data_path PKU-Alignment/BeaverTails_safe_alignment \
	--bf16 True \
	--output_dir ckpt/${path_after_slash}_booster_${lamb}_${alpha} \
	--num_train_epochs ${epoch} \
	--per_device_train_batch_size 10 \
	--per_device_eval_batch_size 10 \
	--gradient_accumulation_steps 1 \
	--evaluation_strategy "no" \
	--save_strategy "steps" \
	--save_steps 100000 \
	--save_total_limit 0 \
	--learning_rate  5e-4  \
	--weight_decay 0.1 \
	--warmup_ratio 0 \
	--lr_scheduler_type "constant" \
	--logging_steps 1 \
	--tf32 True \
	--cache_dir cache \
	--optimizer booster \
	--sample_num $sample_num \
	--bad_sample_num $bad_sample_num \
	--lamb ${lamb} \
	--alpha ${alpha} \
	--eval_steps 5000


cd poison/evaluation

CUDA_VISIBLE_DEVICES=2 python pred.py \
	--lora_folder ../../ckpt/${path_after_slash}_booster_${lamb}_${alpha}\
	--model_folder ${model_path} \
	--output_path ../../data/poison/${path_after_slash}_booster_${lamb}_${alpha}

CUDA_VISIBLE_DEVICES=2 python eval_sentiment.py \
	--input_path ../../data/poison/${path_after_slash}_booster_${lamb}_${alpha}
