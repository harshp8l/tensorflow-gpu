FROM nvidia/cuda:7.5-devel-ubuntu14.04
MAINTAINER Harsh Patel <harshpatel081296@gmail.com>

RUN apt-get update && apt-get install -y \
	build-essential \
	python3 \	
	python3-dev \
	python3-pip

RUN pip3 install --upgrade pip

RUN mkdir /home/test
COPY ./testcomponCPU.py /home/test/
COPY ./testcomponGPU.py /home/test/
#COPY ./requirements.txt /home/test/

#Installing anaconda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 
ENV PATH /opt/conda/bin:$PATH 
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \ 
	libglib2.0-0 libxext6 libsm6 libxrender1 \ 
	git mercurial subversion 
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O ~/anaconda.sh && \ 
	/bin/bash ~/anaconda.sh -b -p /opt/conda && \ 
	rm ~/anaconda.sh && \ 
	ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \ 
	echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \ 
	echo "conda activate base" >> ~/.bashrc 
RUN apt-get install -y curl grep sed dpkg && \ 
	TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \ 
	curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \ 
	dpkg -i tini.deb && \ 
	rm tini.deb && \ 
	apt-get clean 
ENTRYPOINT [ "/usr/bin/tini", "--" ] 
CMD [ "/bin/bash" ]
#COPY ./Anaconda3-5.2.0-Linux-x86_64.sh /home/test/
#RUN chmod +x /home/test/Anaconda3-5.2.0-Linux-x86_64.sh
#RUN printf '\nyes\nyes\nyes\nyes' | ./home/test/Anaconda3-5.2.0-Linux-x86_64.sh

#RUN /bin/bash -c "source /root/.bashrc"
#RUN cat /root/.bashrc
#RUN cat /root/.bashrc-anaconda3.bak


#Requirements for testing computation
RUN conda install cudatoolkit=7.5
RUN conda install -c anaconda accelerate

#installing cuDNN
COPY ./libcudnn6_6.0.21-1+cuda7.5_amd64.deb /home/test/
COPY ./libcudnn6-dev_6.0.21-1+cuda7.5_amd64.deb /home/test/
RUN cd /home/test
RUN sudo dpkg -i /home/test/libcudnn6_6.0.21-1+cuda7.5_amd64.deb 
RUN sudo dpkg -i /home/test/libcudnn6-dev_6.0.21-1+cuda7.5_amd64.deb  

#
RUN pip install --upgrade pip
#installing tensorflow
#RUN pip install tensorflow-gpu
#RUN pip --no-cache-dir install \
#	https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0-cp35-cp35m-linux_x86_64.whl

#staying in appropriate directory
RUN cd /home/test
WORKDIR /home/test

#creating tensorflow env
RUN conda create -n tf pip python=3.5
RUN echo "source activate tf" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH

EXPOSE 8888 6006
VOLUME /home/test/
WORKDIR "home/test"

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]

COPY ./environment.yml /home/test/environment.yml
RUN conda env update -f /home/test/environment.yml
ENV CONDA_ENV tf
#CMD ["/bin/bash", "-c", "source activate tf"]
#RUN /bin/bash -c "source activate tf"
#CMD [ "/bin/bash" ]

#COPY ./Anaconda3-5.2.0-Linux-x86_64.sh /home/test/
#RUN pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0-cp35-cp35m-linux_x86_64.whl
