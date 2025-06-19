FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python3, pip, and dependencies for virtual environment

# Set the working directory in the container
WORKDIR /app


#COPY THE REQUIREMENTS
RUN mkdir -p /app/example_inputs
COPY ./example_inputs/ /app/example_inputs

RUN mkdir -p /app/model_files/bin
COPY ./model_files/bin/ /app/model_files/bin

RUN mkdir -p /app/SCRIPTS
COPY ./SCRIPTS/ /app/SCRIPTS


# Install Python3, pip, and dependencies for virtual environment
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
	vim \
	unzip \
	gfortran \
    && apt-get clean

# Set the working directory in the container
WORKDIR /app

# Create a virtual environment
RUN python3 -m venv /venv

# Use the virtual environment's pip to install dependencies
COPY ./requirements.txt ./
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# Set the virtual environment as the default for running commands
ENV PATH="/venv/bin:$PATH"

# Install Wine:
RUN dpkg --add-architecture i386
RUN apt update && apt -y install wine wine32:i386 wine64 winbind xvfb

# Copy and unzip
COPY ./iMOD5.zip /app/iMOD5.zip
#new comment
COPY ./installIModLinux.sh /app/
RUN chmod u+x /app/installIModLinux.sh && /app/installIModLinux.sh /app/iMOD5.zip /app


#link to the python virtual enviornment
RUN ln -s /venv /app/

