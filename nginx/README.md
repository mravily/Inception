# Nginx Container
This container will run `Nginx server` intercept all HTTP requests from `Web Client`, we will also use it as a proxy to delegate the interpretation of php files coming from our Wordpress site.

## Environnement Variables

```bash
DOMAIN_NAME="your-domain" 	# mravily.42.fr
CERTS="/path/to/certs" 	# ./nginx/certs
NGINX_CFG="=/path/to/nginx/config"	#./nginx/config
```




