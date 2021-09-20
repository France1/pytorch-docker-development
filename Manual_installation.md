# Running Dockerized PyTorch on a NVIDIA GPU server step-by-step

This tutorial uses the `nvcr.io/nvidia/pytorch:19.03-py3` NVIDIA PyTorch image. An updated list of PyTorch containers from NVIDIA can be found [here](https://ngc.nvidia.com/catalog/containers/nvidia:pytorch).

## Running a basic container
To run a PyTorch Docker container called `basic-container` on the remote GPU server, with the server folder
`/home/ubuntu` mounted as a volume:  
```
sudo nvidia-docker run -it --name basic-container --ipc=host -v /home/ubuntu:/home/ubuntu/ nvcr.io/nvidia/pytorch:19.03-py3
```
This command exposes the `home/ubuntu` folder to the docker container, and allows to share data and code between the GPU server and `basic-container`. For more information
on mounting volumes in Docker refer to this [link](https://docs.docker.com/storage/volumes/). The option `-it` enables runnning an interactive session into the container shell (equivalent to ssh directly into the container terminal). To detach from the container without stopping it press `Crtl-P`-`Ctrl-Q`. 

Once the container is up and runnign, the list of running containers can ba obtained from outside the container through
```
docker ps
```
which should return something similar to
```
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS               NAMES
7f1f44834d27        nvcr.io/nvidia/pytorch:19.03-py3   "/usr/local/bin/nvid…"   7 weeks ago         Up 7 weeks                              basic-container
```
To re-attach into the docker shell
```
docker exec -it basic-container /bin/bash
```
### Training a model with multi-GPUs in parallel
Multiple GPU units which are used for model training are specified by the
`CUDA_VISIBLE_DEVICES` enviromental variable as explained [here](https://discuss.pytorch.org/t/how-to-change-the-default-device-of-gpu-device-ids-0/1041). 
The command below run the training script `train.py` on GPUs 1 to 4 
```
CUDA_VISIBLE_DEVICES=1,2,3,4 python train.py
```

## Adding JupyterLab
Jupyter notebooks enable interactive development, and seamless visualization of model results. By default Jupyterlab server run on port 8888. On a remote server, the Jupyter console needs to be exposed through one of the available ports. 
 
In this tutorial we assume that port `8004` is available. A `jupyter-container` that maps _container port 8888_ to _server port 8004_ can be created by running
```
sudo nvidia-docker run -it --name  jupyter-container --ipc=host -v /home/ubuntu:/home/ubuntu/ -p 8004:8888 nvcr.io/nvidia/pytorch:19.03-py3
```
Jupyterlab is installed by attaching into the container and running
```
pip install jupyterlab
```
Secure access is enabled by creating a configuration file
```
jupyter notebook --generate-config
```
and then setting up password for remote server connection
```
jupyter notebook password
```
One option to run Jupyter server in background and monitor its status is to use tmux. To install tmux inside the container and start a tmux session:
```
apt-get update
apt-get install tmux
tmux new -s jupyterlab
```
Start Jupyterlab inside the tmux session 
```
cd /home/ubuntu
jupyter-lab --ip 0.0.0.0 --no-browser --allow-root
```
starting jupyter from this location allows to easily access all files and folders in `home/ubuntu` from Jupyterlab. 

Finally, the jupyter console can be accessed from the browser through
```
http://<server-ip-address>:8004
```
using the password previously defined for authentication
### Plotly for JupyterLab
Follow the steps in the official [website](https://plotly.com/python/getting-started/#jupyterlab-support-python-35). 
If installation of jupyter extensions fail because of node.js install the latest
version with conda (not with pip):
```
conda install -c conda-forge nodejs
```

## Adding Tensorboard
[TensorboardX](https://tensorboardx.readthedocs.io/en/latest/index.html) can be used
to monitor training of PyTorch models using Tensorboard. 
By default Tensorboard runs on port `6006`. A container called `tensorboard-container` 
with exposes an additional port `8005` is created
```
sudo nvidia-docker run -it --name  tensorboard-container --ipc=host -v /home/ubuntu:/home/ubuntu/ -p 8004:8888 -p 8005:6006 nvcr.io/nvidia/pytorch:19.03-py3
```
From the container shell install TensorboardX as
```
pip install tensorboardX
```
Refer to this [tutorial](https://pytorch.org/tutorials/intermediate/tensorboard_tutorial.html)
for saving intermediate outputs from PyTorch models that you may want to visualize during model training.

Currently TensorboardX does not update and refresh in real time. A fix is to 
install tb-nightly
```
pip uninstall tensorboard
pip install tb-nightly
```
By default `tensorboardX.SummaryWriter` create a folder `runs` in which the output
files `events.out.tfevents.xxxxx` are saved during model training. To launch Tensorboard in background using a tmux session run 
```
tmux new -s tensorboard
tensorboard --logdir runs --bind_all
```
The Tensorboard console can be accessed from the browser through
```
http://<server-ip-address>:8005
```

