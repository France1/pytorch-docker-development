# Running Dockerized PyTorch with Jupyter & Tensorboard using a Dockerfile

## Build docker image
To build a `nvidia-jupyter-tensorboard` image specified in `Dockerfile` (in the same folder)
```
nvidia-docker build . -t nvidia-jupyter-tensorboard
```

## Run the container 
To run a `nvidia-jupyter-tensorboard-container` container that include jupter and tensorflow servers
```
sudo nvidia-docker run -d --name nvidia-jupyter-tensorboard-container -v /home/ubuntu/<user>:/workspace/home/<user> -p 8001:8888 -p 8002:6006 nvidia-jupyter-tensorboard
```
in which:
- server folder `/home/ubuntu/<user>` is mounted into container volume `/workspace/home/<user>` 
- container jupyter port 8888 is exposed to server port 8001
- container tensorboard port 6006 is exposed to server port 8002

## Use Jupyterlab
Recover jupyter notebook token
- a) from outside container
```
docker container logs --follow nvidia-jupyter-tensorboard-container
````
- b) from inside container
```
docker container exec -it nvidia-jupyter-tensorboard-container bash
jupyter notebook list
````
Access jupyter server from:
```
http://<server-ip-address>:8001/
```
and paste the recovered token in the login page.

## Launch Tensorboard
Tensorboard can only access files from a unique `runs` folder. Still, it is desirable to keep Tensorboard summary files that belong to different projects separated, rather that mixing them inside `runs`. One way to achieve this is to launch Tensorboard from different projects folders.

Move into the project folder to be monitored, then create a tmux session:
```
tmux new -s jupyterlab
```
Start the tensorboard server with summary files saved into `runs` folder
```
tensorboard --logdir runs --bind_all
```
Access tensorboard from 
```
http://<server-ip-address>:8002/
```
To monitor a different project stop the running session and repeat the steps above.
