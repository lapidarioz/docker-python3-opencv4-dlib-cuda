FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Install face recognition dependencies

RUN apt update -y; apt install -y \
git \
cmake \
libsm6 \
libxext6 \
libxrender-dev \
python3 \
python3-pip \
curl

RUN ln -s $(which python3) /usr/local/bin/python

RUN python3 -m pip --no-cache-dir install --upgrade \
    pip \
    setuptools \
    scikit-build

# # Install compilers

RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt update -y; apt install -y gcc-6 g++-6 libopenblas-dev liblapack-dev 

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 50
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 50

# #Install dlib 

RUN git clone -b 'v19.20' --single-branch https://github.com/davisking/dlib.git
RUN mkdir -p /dlib/build

RUN cmake -H/dlib -B/dlib/build -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1
RUN cmake --build /dlib/build

RUN cd /dlib; python3 /dlib/setup.py install

# Install the face recognition package

RUN pip3 install face_recognition 

# # See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

WORKDIR /

# # RUN apt update && apt install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa
RUN apt update && \
    apt install -y \
    build-essential \
    cmake \
    unzip \
    pkg-config  \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev  \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    x264 \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    yasm \
    libtbb2 \
	libtbb-dev \
	libjpeg-dev \
	libpng-dev \
	libtiff-dev \
	libpq-dev \
	libgtk2.0-dev \
    wget \
    git \
    curl \
    libsm6 \
    libxext6 \
    libxrender-dev \
    bzip2 \
    libavresample-dev \
    ibgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libfaac-dev \
    libmp3lame-dev \
    libtheora-dev \
    libvorbis-dev \
    libssl-dev \
    libffi-dev

ARG OPENCV_VERSION='4.5.0'
# Build OpenCV
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip opencv.zip && rm opencv.zip && \
    mv opencv-${OPENCV_VERSION} opencv && \
    cd opencv && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip opencv_contrib.zip && rm opencv_contrib.zip && \
    mv opencv_contrib-${OPENCV_VERSION} opencv_contrib && \
    mkdir build

WORKDIR /opencv/build

RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_PNG=OFF \
    -DBUILD_TIFF=OFF \
    -DBUILD_TBB=OFF \
    -DBUILD_JPEG=OFF \
    -DBUILD_JASPER=OFF \
    -DBUILD_ZLIB=OFF \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_JAVA=OFF \
    -DBUILD_opencv_python2=OFF \
    -DBUILD_opencv_python3=ON \
    -DWITH_OPENCL=OFF \
    -DWITH_OPENMP=OFF \
    -DWITH_FFMPEG=ON \
    -DWITH_GSTREAMER=ON \
    -DWITH_GSTREAMER_0_10=ON \
    -DWITH_CUDA=ON \
    -DWITH_GTK=ON \
    -DWITH_VTK=OFF \
    -DWITH_TBB=ON \
    -DWITH_1394=OFF \
    -DWITH_OPENEXR=OFF \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-11.0 \
    -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_TESTS=OFF \
    -DENABLE_FAST_MATH=1 \
	-DCUDA_FAST_MATH=1 \
    -DCMAKE_C_COMPILER=gcc \
    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
    .. && \
    make all -j$(nproc) && \
    make install

# Cleaning
RUN apt-get autoremove -y && \
apt-get clean && \
rm -rf /opencv /opencv_contrib /var/lib/apt/lists/*

RUN pip --no-cache-dir install tensorflow
