ffmpeg -i output.mp4 -vframes 20000 %06d.jpg
nohup python trainstylegan916.py \
    --dataset /home/ubuntu/float/results/data2 \
    --epochs 3000 \
    --log_resolution 7 \
    > train.log 2>&1 &

nohup python -u batch_invert_person002_parallel.py \
  --images_dir /home/ubuntu/float/results/data/person002 \
  --g_ckpt /home/ubuntu/float/results/checkpoints/epoch_0150.pt \
  --invert_script /home/ubuntu/float/invert_single_image_masked_v2.py \
  --out_root /home/ubuntu/float/invert_masked_person002 \
  --z_bank   /home/ubuntu/float/z_bank_person002 \
  --jobs 2 \
  --log_resolution 7 --z_dim 256 --w_dim 256 \
  --steps 10000 --lr 0.02 --seed 0 \
  --mask_method points --radius 8 --blur_ks 15 --bg_weight 0.05 \
  > /home/ubuntu/float/invert_person002_master.log 2>&1 &

python train_encoder_from_zstars_rawmask.py \
  --z_root /home/ubuntu/float/invert_masked_person002 \
  --images_dir /home/ubuntu/float/results/data/person002 \
  --num 2000 \
  --outdir /home/ubuntu/float/enc_from_zstars_rawmask \
  --epochs 200 \
  --batch_size 64 \
  --lr 1e-4 \
  --width 1024 \
  --depth 7 \
  --dropout 0.0 \
  --save_every 20

# 首次或正常跑
python batch_invert_wplus_sbs_video.py \
  --ckpt /home/ubuntu/float/results/checkpoints/epoch_0550.pt \
  --input_dir /home/ubuntu/float/results/data2/person001 \
  --max_images 2000 \
  --out_mp4 sidebyside2000.mp4 \
  --fps 25 \
  --steps 400 \
  --w_dir /home/ubuntu/float/wplus_person001 \
  --frames_dir /home/ubuntu/float/_sbs_person001

# 断点续跑（中断后再来，自动跳过已完成的）
python batch_invert_wplus_sbs_video.py \
  --ckpt /home/ubuntu/float/results/checkpoints/epoch_0550.pt \
  --input_dir /home/ubuntu/float/results/data2/person001 \
  --max_images 2000 \
  --out_mp4 sidebyside2000.mp4 \
  --fps 25 \
  --steps 400 \
  --w_dir /home/ubuntu/float/wplus_person001 \
  --frames_dir /home/ubuntu/float/_sbs_person001 \
  --resume
