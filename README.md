# maxima-jupyter-asdf-sbcl
Dockerfile of Maxima CAS built on sbcl with maxima-jupyter and maxima-asdf support

## How to run
	docker run -it --rm --name maxima-jupyter-asdf-sbcl -p 8888:8888 yasuakihonda/maxima-jupyter-asdf-sbcl jupyter notebook --ip 0.0.0.0 --allow-root
