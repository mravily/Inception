# Nginx Container
This container will run `Nginx server` intercept all HTTP requests from `Web Client`, we will also use it as a proxy to delegate the interpretation of php files coming from our Wordpress site.

## Environnement Variables

```bash
DOMAIN_NAME="your-domain" 	# mravily.42.fr
CERTS="/path/to/certs" 	# ./nginx/certs
NGINX_CFG="=/path/to/nginx/config"	#./nginx/config
```
## Docker compose
The nginx service declaration is divided into two parts:
- `Image building part`  
- `Config service part`

You can name the service as you want, it's important to remember this name, beacause he will use it for communication between service inside the Docker Network

```yaml
server:
```

The name of your service and the name of your container can be the same, but for readability reasons, I chose to differentiate them

```yaml
container_name: nginx
```

### Build Image

In this part we will write the path to the Dockerfile, and the argument used until the image build

```yaml
build:
	context: ./nginx	# path to Dockfile dir
	dockerfile: Dockerfile	# Dockerfile name if different
	args:
		DOMAIN_NAME : ${DOMAIN_NAME}
```

### Config Service Part

We will declare some service configurations that we will explain in more detail

We specify to the service that it must wait until the web_app service is healthy, i.e. the web_app service has passed the health check, before starting

```yaml
depends_on:
	web_app :
	condition: service_healthy
```

We will indicate the connection of the host port and the docker port

```yaml
ports:
      - 443:443
```

If the service stops, Docker compose can restart it for us. In any case, we want the service to be restarted

```yaml
restart: always
````

When we use volumes, we always specify where we want to mount them 
> [HOST] : [INSIDE_DOCKER]

Be careful to mount the same volume as the one used by the Wordpress service, otherwise nginx will not be able to use the css files and display them correctly to the web client
> Error Content-Type `text/html` instead of `text/css`.

```yaml
volumes:
	- ${PATH_DATA}/web_data:/var/www/inception
	- ${CERTS}:/etc/nginx/certs
```

and finally the name of the network that docker creates for the LEMP environment

```yaml
networks:
	- internal
````


## Dockerfile

Expose the port on which we will listen to the web traffic

```Dockerfile
EXPOSE 443
```

We will provide an argument, the domain name to our Dockerfile to replace in the nginx configuration file

```Dockerfile
ARG DOMAIN_NAME
```

Install the nginx package and remove the possibility to install other packages in the container

```Dockerfile
RUN set -eux ; \
	apk update ; \
	apk upgrade ; \
	apk add --update --no-cache nginx ; \
	rm -f /var/cache/apk/* 
```

Change ownership of directories used by nginx

```Dockerfile 
RUN set -eux ; \
	chown -R nginx:nginx \
		/etc/nginx/ \
		/run/nginx \
		/var/run/nginx \
		/var/www
```

Replace DOMAIN_NAME in the nginx configuration file with our 

```Dockerfile
RUN sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/http.d/wordpress.conf
```

User change during execution 

```Dockerfile
USER nginx
````

Start the nginx process as the main process

```Dockerfile
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```
