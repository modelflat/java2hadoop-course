#!/usr/bin/env bash

function cloudera-vm() {
	docker run \
	    --hostname=quickstart.cloudera \
	    --privileged=true \
	    --memory=8g \
	    -p 8888:8888 \
	    -p 8080:8080 \
	    -p 8088:8088 \
	    -p 4040:4040 \
	    -p 4041:4041 \
	    -p 44444:44444 \
	    $* \
	    -i \
	    -t cloudera/quickstart \
	    /bin/sh -c \
	    "head -n -1 /usr/bin/docker-quickstart >> /tmp/dqs.tmp; \
	     echo 'service mysqld stop && (mysqld_safe --skip-grant-tables &); sleep 2 && echo && exec bash' >> /tmp/dqs.tmp; \
	     mv /tmp/dqs.tmp usr/bin/docker-quickstart; chmod +x /usr/bin/docker-quickstart; cd /host; \
	     /usr/bin/docker-quickstart
	    "
}

cloudera-vm -v $(pwd):/host $*
