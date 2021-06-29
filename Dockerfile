
ARG BASE_IMAGE=nvcr.io/nvidia/nemo:1.0.0rc1
FROM ${BASE_IMAGE} as nemo-deps


ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    libboost-all-dev

RUN pip install widgetsnbextension ipywidgets pythainlp attacut torchmetrics
RUN jupyter nbextension enable --py widgetsnbextension

WORKDIR /workspace
COPY install_beamsearch_decoders.sh /workspace/install_beamsearch_decoders.sh
COPY jarvis_api-1.1.0b0-py3-none-any.whl /workspace/jarvis_api-1.1.0b0-py3-none-any.whl
COPY jarvis_client_example.ipynb /workspace/jarvis_client_example.ipynb
COPY nemo_th_asr_demo.ipynb /workspace/nemo_th_asr_demo.ipynb
COPY nemo_th_tts_demo.ipynb /workspace/nemo_th_tts_demo.ipynb
COPY quartznet_5x3_th.yaml /workspace/quartznet_5x3_th.yaml
COPY tacotron2_th.yaml /workspace/tacotron2_th.yaml
COPY models/QuartzNet5x3_1e03_warm1000.nemo /workspace/QuartzNet5x3_1e03_warm1000.nemo
COPY models/QuartzNet5x3_2e02_libri---val_wer=0.08-epoch=97.ckpt /workspace/QuartzNet5x3_2e02_libri---val_wer=0.08-epoch=97.ckpt
COPY models/Tacotron2_deploy.nemo /workspace/Tacotron2_deploy.nemo
COPY models/Tacotron2.nemo /workspace/Tacotron2.nemo
COPY models/waveglow.ejrvs /workspace/waveglow.ejrvs
COPY models/common_voice_6gram.bin /workspace/common_voice_6gram.bin
COPY kenlm_utils.py /workspace/kenlm_utils.py
COPY common_voice_th_23657550_trim.wav /workspace/common_voice_th_23657550_trim.wav

RUN pip install /workspace/jarvis_api-1.1.0b0-py3-none-any.whl
RUN git clone https://github.com/NVIDIA/NeMo.git
RUN bash /workspace/install_beamsearch_decoders.sh