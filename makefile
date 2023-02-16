_GREEN=$'\x1b[32m
_YELLOW=$'\x1b[33m
_BLUE=$'\x1b[34m
_WHITE=$'\x1b[37m

all:
	@ echo "[ $(_BLUE)...$(_WHITE) ] Starting Inception Environement 🐳"
	@ printf "[ $(_YELLOW)SSL$(_WHITE) ]" && read -p " Do you need generate SSL certificates ? (y/n) " answer ; \
	if [ $$answer == "y" ] ; then \
		$(MAKE) certs ; \
	fi 
	@ docker compose -f docker-compose.yaml up --build -d
	@ echo "[ $(_GREEN)OK $(_WHITE) ] Ready to use 🍻"

re: fclean all

certs:
	@ mkdir -p ./nginx/certs
	@ if [ ! -f "./nginx/certs/key.pem" ] || [ ! -f "./nginx/certs/cert.pem" ] ; then \
		openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
			-keyout ./nginx/certs/key.pem \
			-out ./nginx/certs/cert.pem \
			-subj '/ST=France/L=Paris/O=42/CN=web-server' ; \
	else \
		echo "[ ${_GREEN}OK ${_WHITE} ] SSL Certificate already exist" ; \
	fi
	@ if [ ! -f "./nginx/certs/dhparam.pem" ] ; then \
		openssl dhparam -out ./nginx/certs/dhparam.pem 2048 ; \
	else \
		echo "[ ${_GREEN}OK ${_WHITE} ] DHparam Certificate already exist" ; \
	fi
	@ echo "[ $(_GREEN)TIP$(_WHITE) ] Don't forget to set certs path in .env file 😉"
bonus:
	echo "BONUS"

stop:
	@ docker stop $$(docker ps -a -q) > /dev/null
	@ echo "[ ${_GREEN}OK ${_WHITE} ] All Docker Containers stopped"

clean: stop
	@ docker system prune --all --volumes --force > /dev/null
	@ echo "[ ${_GREEN}OK ${_WHITE} ] Clear all containers, images, volumes"
fclean: clean
	@ rm -rf ./data
	@ echo "[ ${_GREEN}OK ${_WHITE} ] Remove all datas"

.PHONY: certs