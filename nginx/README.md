# Nginx Container
This container will run `Nginx server` intercept all HTTP requests from `Web Client`, we will also use it as a proxy to delegate the interpretation of php files coming from our Wordpress site.

## Environnement Variables

```bash
DOMAIN_NAME="your-domain" 	# mravily.42.fr
CERTS="/path/to/certs" 	# ./nginx/certs
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
Copy config file in the right directory

```Dockerfile
COPY config/wordpress.conf /etc/nginx/http.d
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


## Config File Nginx

In order for nginx to understand that we have a website, we need to write a configuration file in which we specify some directives

Which context to use? In our case, we use the server context

```
server {
```

Set the port, on wich the server will accept requests, with protocols

```
listen 443 ssl http2;
listen [::]:443 ssl http2;
````

the `server_name` directive lists all server name

```
server_name DOMAIN_NAME;
```

We have implemented several SSL protocols for better encryption of communications, you will find a link in the resources section for more explanations

```
ssl_protocols TLSv1.2 TLSv1.3;
ssl_certificate /etc/nginx/certs/cert.pem;
ssl_certificate_key /etc/nginx/certs/key.pem;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDH+AESGCM:ECDH+AES256-CBC:ECDH+AES128-CBC:DH+3DES:!ADH:!AECDH:!MD5;
ssl_dhparam /etc/nginx/certs/dhparam.pem;
ssl_trusted_certificate /etc/nginx/certs/cert.pem;
add_header Strict-Transport-Security "max-age=31536000" always;
ssl_session_timeout 4h;
ssl_session_tickets on;
```

Sets the root directory for requests

```
root /var/www/inception;
```

Specify the index used, in our case we use the index.php of wordpress

```
index  index.php;
````

Checks the existence of files or directory in the specified order and uses the first found file for request processing

```
location / {
	try_files $uri $uri/ /index.php$is_args$args;
}
```

Now we must tell NGINX to proxy requests to PHP FPM via the FCGI protocol

```
location ~ [^/]\.php(/|$) {
	fastcgi_split_path_info ^(.+?\.php)(/.*)$;
	if (!-f $document_root$fastcgi_script_name) {
		return 404;
	}

	# Mitigate https://httpoxy.org/ vulnerabilities
	fastcgi_param HTTP_PROXY "";

	fastcgi_pass web_app:9000;
	fastcgi_index index.php;

	# include the fastcgi_param setting
	include fastcgi_params;

	# SCRIPT_FILENAME parameter is used for PHP FPM determining
	#  the script name. If it is not set in fastcgi_params file,
	# i.e. /etc/nginx/fastcgi_params or in the parent contexts,
	# please comment off following line:
	fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
}
```

## Ressources

[Nginx Beginners Guide](https://nginx.org/en/docs/beginners_guide.html)

[PHP FastCGI Example](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)

[How To Configure Nginx to use TLS 1.2 / 1.3 only](github.com/advisories/GHSA-hrpp-h998-j3pp)

[How Properly Configure Nginx Server for TLS](https://hackernoon.com/how-properly-configure-nginx-server-for-tls-sg1d3udt)


