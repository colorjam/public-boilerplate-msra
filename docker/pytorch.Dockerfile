FROM ufoym/deepo:pytorch

RUN apt update && apt install -y libsm6 libxext6 libxrender-dev graphviz tmux htop \
    build-essential cmake git python-dev python-numpy libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
RUN pip install --no-cache-dir tensorboard graphviz opencv-python tqdm pyyaml h5py tensorboardx scikit-learn scipy
RUN git clone https://github.com/NVIDIA/apex && cd apex && export TORCH_CUDA_ARCH_LIST="3.5;3.7;5.2;6.0;6.1;6.2;7.0;7.5" && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && cd ..
RUN pip install --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist nvidia-dali-cuda100

# Scheduler
RUN pip install --no-cache-dir GPUtil "dask[complete]"
RUN pip install --no-cache-dir --upgrade dask distributed

# Open-MPI installation
ENV OPENMPI_VERSION 3.1.2
RUN mkdir /tmp/openmpi && cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OPENMPI_VERSION}.tar.gz && \
    tar zxf openmpi-${OPENMPI_VERSION}.tar.gz && cd openmpi-${OPENMPI_VERSION} && \
    ./configure --enable-orterun-prefix-by-default && make -j $(nproc) all && \
    make install && ldconfig && rm -rf /tmp/openmpi
RUN pip install --no-cache-dir mpi4py

# azcopy
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy
RUN pip install --no-cache-dir tensorflow pyzmq seaborn azure-storage-blob dateparser pymoo thop addict ipython yapf horovod
# Dependencies of NNI
RUN pip install --no-cache-dir schema ruamel.yaml psutil requests astor hyperopt==0.1.2 json_tricks netifaces numpy \
    coverage colorama scikit-learn pkginfo websockets azureml azureml-sdk
RUN pip install --no-cache-dir --no-deps nni==1.7

WORKDIR /workspace
RUN chmod -R a+w /workspace
