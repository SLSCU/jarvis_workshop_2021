# jarvis_workshop_2021

```
cd jarvis_workshop_2021
wget https://jarvis-workshop.s3.ap-southeast-1.amazonaws.com/models.zip
unzip models.zip
```

## NeMo
### Build docker image for NeMo
```
docker build -t workshop:v1 .
```

### run docker and start notebook
```
docker run --runtime=nvidia -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm --shm-size=10g \
            workshop:v1 \
            -p 8888:8888 \
            jupyter notebook --ip='*' --NotebookApp.token='' --NotebookApp.password=''
```

### convert nemo to enemo for building jarvis model
```
docker run --runtime=nvidia -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm --shm-size=10g \
            -v {full path of jarvis_workshop_2021 folder}/models:/work \
            workshop:v1 \
            python nemo/scripts/export/convasr_to_enemo.py \
            --enemo_file=/work/QuartzNet5x3_1e03_warm1000.enemo \
            --nemo_file=QuartzNet5x3_1e03_warm1000.nemo \
            --onnx_file=/work/QuartzNet5x3_1e03_warm1000.onnx \
```

## Jarvis
### Pull docker
```
docker pull nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-server
docker pull nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-servicemaker
```

### Build model for using in Jarvis

#### build model with jarvis service maker
```
mkdir jarvis_model
cd jarvis_model
mkdir jmir
mkdir models
cd ..

### run jarvis service maker docker
docker run --runtime=nvidia -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm -it --shm-size=10g \
            -v {full path of jarvis_workshop_2021 folder}/jarvis_model:/data \
            -v {full path of jarvis_workshop_2021 folder}/models:/workspace \
            nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-servicemaker

### build asr
jarvis-build speech_recognition --offline \
            /data/jmir/QuartzNet5x3_th_with_lm.jmir \
            /workspace/QuartzNet5x3_1e03_warm1000.enemo \
            --name=QuartzNet5x3_th \
            --language_code=th-TH \
            --decoding_language_model_binary=/workspace/common_voice_6gram.bin \
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

### Run server
```
docker run --runtime=nvidia \
            -e \
            NVIDIA_VISIBLE_DEVICES=0 \
            --rm --shm-size=10g \
            -v {full path of jarvis_workshop_2021 folder}/jarvis_model:/data \
            -p 50051:50051 \
            nvcr.io/nvidia/jarvis/jarvis-speech:1.1.0-beta-server \
            start-jarvis --jarvis-uri=0.0.0.0:50051
```

find ip of container
```
 docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' DOCKER ID or DOCKER NAME
```
