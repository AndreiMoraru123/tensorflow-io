FROM ubuntu:latest

# Set the environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    git \
    unzip \
    curl \
    wget \
    libtirpc-dev \
    && apt-get clean

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda3 && \
    rm miniconda.sh

# Set up Miniconda environment
ENV PATH="/opt/miniconda3/bin:${PATH}"
RUN conda create -y -n tfio python=3.12 && \
    echo "source activate tfio" >> ~/.bashrc

# Activate Miniconda environment
SHELL ["/bin/bash", "-c"]

# Install TensorFlow and other required packages
RUN source activate tfio && \
    pip install tensorflow==2.17.* pytest

# Install Bazelisk
RUN curl -sSOL https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-linux-amd64 && \
    mv bazelisk-linux-amd64 /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Set the workspace directory
WORKDIR /workspace

# Copy the project files
COPY . /workspace

# Run configuration script if it exists
RUN if [ -f "./configure.sh" ]; then ./configure.sh; fi

ENV TFIO_DATAPATH=bazel-bin

# Default command
CMD ["/bin/bash", "-c", "source activate tfio && /bin/bash"]