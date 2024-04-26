ARG CUDA_VERSION

FROM nvidia/cuda:$CUDA_VERSION-devel-ubuntu20.04
ARG NVIDIA_VERSION

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install python3-pip libvulkan1 python3-venv vim pciutils wget git kmod vim unzip

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY requirements.txt scripts/install_nvidia.sh /app/
RUN pip3 install --upgrade pip

RUN mkdir -p ~/miniconda3 && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && rm -rf ~/miniconda3/miniconda.sh && ~/miniconda3/bin/conda init bash
ENV PATH="/root/miniconda3/bin:$PATH"

RUN git clone https://github.com/Karkeys360/Holodeck.git
RUN cd Holodeck && wget https://holodeck-ai2.s3.amazonaws.com/data.zip && unzip data.zip

RUN conda create --name holodeck python=3.9.16
SHELL ["conda", "run", "-n", "holodeck", "/bin/bash", "-c"]
RUN pip3 install -r requirements.txt && pip3 install --extra-index-url https://ai2thor-pypi.allenai.org ai2thor==0+6f165fdaf3cf2d03728f931f39261d14a67414d0
# RUN python3 -c "import os; import ai2thor.build; ai2thor.build.Build('CloudRendering', ai2thor.build.DEFAULT_CLOUDRENDERING_COMMIT_ID, False, releases_dir=os.path.join(os.path.expanduser('~'), '.ai2thor/releases')).download()"
RUN NVIDIA_VERSION=$NVIDIA_VERSION /app/install_nvidia.sh

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "holodeck", "/bin/bash"]
