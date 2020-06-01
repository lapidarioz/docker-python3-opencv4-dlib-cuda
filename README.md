# docker-python3-opencv3-dlib-cuda

* Python 3
* OpenCV 4.1.1
* DLIB 19.19
* CUDA 10.1 cudnn 7

## BUILD
```
docker build -t python3-opencv4-dlib-cuda .
```
## RUN
```
docker run --gpus all -it --rm \
    -v $PWD:/usr/src/app \
    -w /usr/src/app \
    -u $(id -u):$(id -g) \
    lapidarioz/python3-opencv4-dlib-cuda python3 ./youraplication.py
```
