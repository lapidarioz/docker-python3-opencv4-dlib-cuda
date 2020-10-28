FROM tensorflow/tensorflow:2.2.1-gpu

ENV DEBIAN_FRONTEND noninteractive

ARG OPENCV_VERSION='4.5.0'
ARG GPU_ARCH='7.5'
WORKDIR /

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
    libvorbis-dev

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
    -DCUDA_ARCH_BIN=${GPU_ARCH} \
    -DCUDA_ARCH_PTX=${GPU_ARCH} \
    -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_TESTS=OFF \
    -D ENABLE_FAST_MATH=1 \
	-D CUDA_FAST_MATH=1 \
    -D CMAKE_C_COMPILER=gcc-7 \
    .. && \
    make all -j$(nproc) && \
    make install


WORKDIR /
# from https://github.com/ageitgey/face_recognition/blob/master/Dockerfile.gpu

RUN pip install --no-cache-dir \
        scikit-image \
        sk-video \
        keras

# #Install dlib
WORKDIR / 

RUN git clone -b 'v19.21' --single-branch https://github.com/davisking/dlib.git
RUN mkdir -p /dlib/build

RUN cmake -H/dlib -B/dlib/build -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1
RUN cmake --build /dlib/build

RUN cd /dlib; python /dlib/setup.py install

WORKDIR /usr/src/files/

# # Install the face recognition package
RUN pip install --no-cache-dir face_recognition

# # Cleaning
RUN apt-get autoremove -y && \
apt-get clean && \
rm -rf /opencv /opencv_contrib /var/lib/apt/lists/*
