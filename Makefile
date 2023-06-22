develop : 
	 docker run -it -p 80:80 multistackdocker bash

build : 
	docker build -t multistackdocker .
