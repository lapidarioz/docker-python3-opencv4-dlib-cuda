# docker-python3-opencv4-dlib-cuda

* Python 3.6.9
* OpenCV 4.5.0
* DLIB 19.21
* CUDA 11 cudnn 7.5

## BUILD and RUN
```
docker build -t python3-opencv4-dlib-cuda .
docker run --gpus all -it --rm \
    -v $PWD:/usr/src/app \
    -w /usr/src/app \
    -u $(id -u):$(id -g) \
    python3-opencv4-dlib-cuda bash
```
## RUN
```
docker run --gpus all -it --rm \
    -v $PWD:/usr/src/app \
    -w /usr/src/app \
    -u $(id -u):$(id -g) \
    lapidarioz/python3-opencv4-dlib-cuda sh
```
