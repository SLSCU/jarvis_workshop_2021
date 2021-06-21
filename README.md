# jarvis_workshop_2021
Other asset : https://drive.google.com/file/d/11_mGfOMGLq8Zn-z0bgIeuj6AVElxiPS6/view?usp=sharing

## Pull docker
```
docker pull nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-server
docker pull nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-servicemaker
```

## Build model for use in Jarvis
```
### run below script in NeMo docker
python nemo/scripts/export/convasr_to_enemo.py \
            --enemo_file=QuartzNet5x3_1e03_warm1000.enemo \
            --nemo_file=QuartzNet5x3_1e03_warm1000.nemo \
            --onnx_file=QuartzNet5x3_1e03_warm1000.onnx \

mkdir javis_model
cd javis_model
mkdir jmir
mkdir models
cd ..

### run jarvis service maker docker
docker run --runtime=nvidia -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm -it --shm-size=10g \
            -v javis_model:/data \
            nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-servicemaker

### build asr
jarvis-build speech_recognition --offline \
            /data/jmir/QuartzNet5x3_th_with_lm.jmir \
            /workspace/QuartzNet5x3_1e03_warm1000.enemo \
            --name=QuartzNet5x3_th \
            --language_code=th-TH \
            --decoding_language_model_binary=/work/nvidia-workshop/common_voice_6gram.bin \
            --lm_decoder_cpu.beam_search_width=32 \
            --lm_decoder_cpu.language_model_alpha=2.0 \
            --lm_decoder_cpu.language_model_beta=1.7

### build tts
jarvis-build speech_synthesis \
             /data/jmir/tacotron2_th.jmir \
             /workspace/Tacotron2_deploy.nemo \
             /workspace/waveglow.ejrvs \
             --language_code=th-TH \
             --voice_name=tsync2 \
             --preprocessor.language=th

### deploy
jarvis-deploy -f /data/jmir/QuartzNet5x3_th_with_lm.jmir /data/models/
jarvis-deploy -f /data/jmir/tacotron2_th.jmir /data/models/

### exit container

exit
```

## Run server
```
docker run --runtime=nvidia \
            -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm --shm-size=10g \
            -v javis_modadel:/data \
            -p 50051:50051 \
            nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-server \
            start-jarvis --jarvis-uri=0.0.0.0:50051
```
