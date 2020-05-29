#!/bin/bash
if [ -d "/etc/squid/" ]; then
    payload="/etc/squid/payload.txt"
elif [ -d "/etc/squid3/" ]; then
	payload="/etc/squid3/payload.txt"
fi
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-10s\n' "Eliminar Host de Squid Proxy" ; tput sgr0
if [ ! -f "$payload" ]
then
	tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "Archivo $payload no encontrado" ; tput sgr0
	exit 1
else
	tput setaf 2 ; tput bold ; echo ""; echo "Domínios atiales no archivo $payload:" ; tput sgr0
	tput setaf 3 ; tput bold ; echo "" ; cat $payload ; echo "" ; tput sgr0
	read -p "Digite el domínio que desea eliminar de lista: " host
	if [[ -z $host ]]
		then
			tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "Ingresó un dominio vacío o inexistente!" ; echo "" ; tput sgr0
			exit 1
		else
		if [[ `grep -c "^$host" $payload` -ne 1 ]]
		then
			tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "el domínio $host no fue encontrado en archivo $payload" ; echo "" ; tput sgr0
			exit 1
		else
			grep -v "^$host" $payload > /tmp/a && mv /tmp/a $payload
			tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "Archivo $payload actualizado, y domínio fue eliminado con exito:" ; tput sgr0
			tput setaf 3 ; tput bold ; echo "" ; cat $payload ; echo "" ; tput sgr0
			if [ ! -f "/etc/init.d/squid3" ]
			then
				service squid3 reload
			elif [ ! -f "/etc/init.d/squid" ]
			then
				service squid reload
			fi	
			tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "el Proxy Squid Proxy fue recargado con éxito!" ; echo "" ; tput sgr0
			exit 1
		fi
	fi
fi