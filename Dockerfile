



ARG BASE_IMAGE=nvcr.io/nvidia/nemo:1.0.1
FROM ${BASE_IMAGE} as nemo-deps


ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    libboost-all-dev

RUN pip install widgetsnbextension ipywidgets pythainlp attacut torchmetrics
RUN jupyter nbextension enable --py widgetsnbextension

WORKDIR /workspace
COPY . /workspace
RUN bash /workspace/install_beamsearch_decoders.sh