#!/bin/bash


model_path=${1:-Llama-2-7b-hf}
path_after_slash=$(basename "$model_path") 
echo "The value of sample number is: $sample_num"
echo "The short model path is: $path_after_slash"
cd  ../../                            # Change to working directory



CUDA_VISIBLE_DEVICES=1 python train.py \
	--model_name_or_path ${model_path} \
	--data_path PKU-Alignment/BeaverTails_safe \
	--bf16 True \
	--output_dir ckpt/${path_after_slash}_sft \
	--num_train_epochs 20 \
	--per_device_train_batch_size 10 \
	--per_device_eval_batch_size 10 \
	--gradient_accumulation_steps 1 \
	--evaluation_strategy "no" \
	--save_strategy "steps" \
	--save_steps 100000 \
	--save_total_limit 0 \
	--learning_rate  5e-4 \
	--weight_decay 0.1 \
	--warmup_ratio 0 \
	--lr_scheduler_type "constant" \
	--logging_steps 1 \
	--tf32 True \
	--cache_dir cache \
	--optimizer sft \
	--sample_num 5000 \

cd poison/evaluation  

CUDA_VISIBLE_DEVICES=1 python pred.py \
	--lora_folder ../../ckpt/${path_after_slash}_sft \
	--model_folder ${model_path} \
	--output_path ../../data/poison/${path_after_slash}_sft

CUDA_VISIBLE_DEVICES=1 python eval_sentiment.py \
	--input_path ../../data/poison/${path_after_slash}_sft