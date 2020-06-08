From ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  


WORKDIR /root
RUN echo "now building image" && apt-get update && apt-get install -y \
    gnuplot \
    texinfo \
    wget \
    zip \
    libczmq-dev \
    python3-pip

WORKDIR /root
RUN echo "installing SBCL 1" && \
    wget http://prdownloads.sourceforge.net/sbcl/sbcl-2.0.5-x86-64-linux-binary.tar.bz2 && \
    tar xf sbcl-2.0.5-x86-64-linux-binary.tar.bz2

WORKDIR /root/sbcl-2.0.5-x86-64-linux
RUN echo "installing SBCL 2" && ./install.sh
    
WORKDIR /root
RUN echo "building maxima" && \
    wget https://sourceforge.net/projects/maxima/files/Maxima-source/5.43.2-source/maxima-5.43.2.tar.gz && \
    tar xvfz maxima-5.43.2.tar.gz

WORKDIR /root/maxima-5.43.2
RUN ./configure && make && make install

WORKDIR /root
RUN wget https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --eval '(progn (quicklisp-quickstart:install)(quit))' && \
    sbcl --load quicklisp/setup --eval '(progn (ql:quickload :drakma)(quit))'

WORKDIR /root/quicklisp/local-projects
RUN wget https://github.com/robert-dodier/maxima-asdf/archive/master.zip && \
    unzip master.zip && \
    mv maxima-asdf-master maxima-asdf && \
    rm master.zip

WORKDIR /root/quicklisp/local-projects/maxima-asdf
RUN mv maxima-quicklisp.lisp /tmp && sed -e "1i(in-package :maxima)" /tmp/maxima-quicklisp.lisp > maxima-quicklisp.lisp

WORKDIR /root
RUN echo '(require :asdf)(load "/root/quicklisp/setup")(ql:quickload :drakma)(ql:quickload :maxima-asdf)' > .sbclrc

WORKDIR /root
RUN echo "installing jupyter" && \
    python3 -m pip install --upgrade pip && \
    pip install jupyter jupyterlab

WORKDIR /root
RUN echo "installing maxima-jupyter 1" && \
    wget https://github.com/robert-dodier/maxima-jupyter/archive/master.zip && \
    unzip master.zip
    
WORKDIR /root/maxima-jupyter-master
RUN echo "installing maxima-jupyter 2" && \
    maxima --batch-string "load(\"load-maxima-jupyter.lisp\");jupyter_install();"

WORKDIR /root
