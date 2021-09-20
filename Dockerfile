FROM nvcr.io/nvidia/pytorch:19.03-py3

# Unix installations 
RUN apt-get update && apt-get install -y \
    tmux \  
    ffmpeg libsm6 libxext6 \
    # additional unix packages go here 

# Python installations
# RUN pip uninstall -y tensorboard
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Define volume within container
VOLUME /workspace/home/<user>
WORKDIR /workspace/home/<user>

# Launch jupyter server
CMD ["jupyter-lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

