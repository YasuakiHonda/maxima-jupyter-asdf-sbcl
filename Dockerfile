From ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  


WORKDIR /root
RUN echo "now building image" && apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    apt-get install -y \
    gnuplot \
    texinfo \
    wget \
    zip \
    libczmq-dev \
    python3-pip \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


WORKDIR /root
RUN echo "installing SBCL 1" && \
    wget http://prdownloads.sourceforge.net/sbcl/sbcl-2.0.5-x86-64-linux-binary.tar.bz2 && \
    tar xf sbcl-2.0.5-x86-64-linux-binary.tar.bz2 && \
    cd sbcl-2.0.5-x86-64-linux && ./install.sh && \
    cd /root && rm sbcl-2.0.5-x86-64-linux-binary.tar.bz2 && \
    rm -rf sbcl-2.0.5-x86-64-linux

WORKDIR /root
RUN echo "building maxima" && \
    ln -s /usr/bin/python3 /usr/local/bin/python && \
    wget https://sourceforge.net/projects/maxima/files/Maxima-source/5.44.0-source/maxima-5.44.0.tar.gz && \
    tar xvfz maxima-5.44.0.tar.gz && \
    cd maxima-5.44.0 && ./configure && make && make install && \
    cd .. && rm maxima-5.44.0.tar.gz && rm -rf maxima-5.44.0

WORKDIR /root
RUN wget https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --eval '(progn (quicklisp-quickstart:install)(quit))' && \
    sbcl --load quicklisp/setup --eval '(progn (ql:quickload :drakma)(quit))' && \
    rm quicklisp.lisp

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
    unzip master.zip && \
    cd maxima-jupyter-master && \
    maxima --batch-string "load(\"load-maxima-jupyter.lisp\");jupyter_install();" && \
    cd /root && mkdir .maxima && \
    echo 'set_draw_defaults(terminal=svg)$set_plot_option([svg_file, "maxplot.svg"])$' > .maxima/maxima-init.mac && \
    cd /root && rm master.zip && rm -rf maxima-jupyter-master

WORKDIR /root
