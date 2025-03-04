PRETRAIN=$1
OUTDIR=~/storage/outputs/transferedit/$2
mkdir -p $OUTDIR
fairseq-train $3 --fp16 \
	--arch bart_base --layernorm-embedding \
	--task translation_from_xbart \
	--source-lang src --target-lang tgt \
        --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
        --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
        --lr-scheduler polynomial_decay --lr 3e-05 --stop-min-lr -1 --warmup-updates 10000 --total-num-update 40000 \
        --dropout 0.3 --weight-decay 0.0 --attention-dropout 0.1 \
	--clip-norm 0.1 \
        --max-tokens 4096 --update-freq 2 --replace-token \
        --save-interval 1 --save-interval-updates 500 --keep-interval-updates 10 --no-epoch-checkpoints \
        --seed 222 --log-format simple --log-interval 20 \
	--restore-file $PRETRAIN \
	--reset-optimizer --reset-meters --reset-dataloader --reset-lr-scheduler \
	--save-dir $OUTDIR/checkpoints \
        --ddp-backend=no_c10d --skip-invalid-size-inputs-valid-test --tensorboard-logdir $OUTDIR/tensorboard  | tee -a $OUTDIR/train.log
