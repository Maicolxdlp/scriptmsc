#!/bin/bash
[[ $1 != "" ]] && id="$1" || id="es"
clear
barra="\033[0;34m =================================== \033[1;37m"
_cores="./cores"
_dr="./idioma"

#LISTA PORTAS
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

#MEU IP
fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
}

#ETHOOL SSH
fun_eth () {
eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
    echo -e "$barra"
    echo -e "${cor[3]} "Aplicar el sistema para mejorar los paquetes Ssh?")"
    echo -e "${cor[3]} "Opciones para usuarios avanzados")"
    echo -e "$barra"
    read -p " [S/N]: " -e -i n sshsn
           [[ "$sshsn" = @(s|S|y|Y) ]] && {
           echo -e "${cor[1]} "Corrección de problemas de paquetes en SSH...")"
           echo -e " ("Qual A Taxa RX")"
           echo -ne "[ 1 - 999999999 ]: "; read rx
           [[ "$rx" = "" ]] && rx="999999999"
           echo -e " ("Qual A Taxa TX")"
           echo -ne "[ 1 - 999999999 ]: "; read tx
           [[ "$tx" = "" ]] && tx="999999999"
           apt-get install ethtool -y > /dev/null 2>&1
           ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
           }
     echo -e "$barra"
     }
}

#FUN_BAR
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

#INSTALADOR SQUID
fun_squid  () {
  if [[ -e /etc/squid/squid.conf ]]; then
  var_squid="/etc/squid/squid.conf"
  elif [[ -e /etc/squid3/squid.conf ]]; then
  var_squid="/etc/squid3/squid.conf"
  fi
  #Reiniciando
  service squid3 restart > /dev/null 2>&1
  service squid restart > /dev/null 2>&1
  [[ -e $var_squid ]] && {
  echo -e "$barra\n\033[1;32m ("ELIMINANDO SQUID")\n$barra"
  fun_bar "apt-get remove squid3 -y"
  service squid stop > /dev/null 2>&1
  service squid3 stop > /dev/null 2>&1
  echo -e "$barra\n\033[1;32m ("Procedimento Concluido")\n$barra"
  [[ -e $var_squid ]] && rm $var_squid
  return 0
  }
#Instalar
echo -e "$barra\n\033[1;32m ("INSTALADOR DE SQUID CSM")\n$barra"
fun_ip
echo -ne "("Confirme su ip")"; read -p ": " -e -i $IP ip
echo -e "$barra\n ("Ahora elige los Puertos que desea en el Squid")"
echo -e " ("Seleccione los Puertos, Ejemplo: 8080 3128")"
echo -ne " "Digite los Puertos:" "; read portasx
echo -e "$barra"
totalporta=($portasx)
unset PORT
   for((i=0; i<${#totalporta[@]}; i++)); do
        [[ $(mportas|grep "${totalporta[$i]}") = "" ]] && {
        echo -e "\033[1;33m ("Puerto elegido:")\033[1;32m ${totalporta[$i]} OK"
        PORT+="${totalporta[$i]}\n"
        } || {
        echo -e "\033[1;33m ("Puerto elegido:")\033[1;31m ${totalporta[$i]} FAIL"
        }
   done
  [[ "$(echo -e $PORT)" = "" ]] && {
  echo -e "\033[1;31m ("Ningun Puerto Valido Fue Elegida")\033[0m"
  return 1
  }
echo -e "$barra"
echo -e " ("INSTALANDO SQUID")"
echo -e "$barra"
fun_bar "apt-get install squid3 -y"
echo -e "$barra"
echo -e " ("INICIANDO CONFIGURACIÓN")"
echo -e "$barra"
echo -e "" > /etc/payloads
#Añadir Host Squid
payload="/etc/payloads"
echo -e "" > /etc/payloads
echo -e " ${txt[219]}"
echo -e " ${txt[220]}" 
read -p " (Agregar Host): " hos
if [[ $hos != \.* ]]; then
echo -e "$barra"
echo -e "\033[1;31m (" [!] Host-Squid debe iniciar con "."")\033[0m"
echo -e "\033[1;31m (" Asegurese de agregarlo despues corretamente!")\033[0m"
fi
host="$hos/"
if [[ -z $host ]]; then
echo -e "$barra"
echo -e "\033[1;31m (" [!] Host-Squid no agregado")"
echo -e "\033[1;31m (" Asegurese de agregarlo despues!")\033[0m"
fi
echo "$host" >> $payload && grep -v "^$" $payload > /tmp/a && mv /tmp/a $payload
echo -e "$barra\n\033[1;32m ("Ahora Escoja Una Conf Para Su Proxy")\n$barra"
echo -e " |1| ("Comum")"
echo -e " |2| ("Customizado") -\033[1;31m ("Usuario Deve Ajustar")\033[1;37m\n$barra"
read -p " [1/2]: " -e -i 1 proxy_opt
unset var_squid
if [[ -d /etc/squid ]]; then
var_squid="/etc/squid/squid.conf"
elif [[ -d /etc/squid3 ]]; then
var_squid="/etc/squid3/squid.conf"
fi
if [[ "$proxy_opt" = @(02|2) ]]; then
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 dstdomain -i localhost
acl accept dstdomain -i GET
acl accept dstdomain -i POST
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i CONNECT
acl accept dstdomain -i PUT
acl HEAD dstdomain -i HEAD
acl accept dstdomain -i TRACE
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i PATCH
acl accept dstdomain -i PROPATCH
acl accept dstdomain -i DELETE
acl accept dstdomain -i REQUEST
acl accept dstdomain -i METHOD
acl accept dstdomain -i NETDATA
acl accept dstdomain -i MOVE
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow accept
http_access allow HEAD
http_access deny all

# Request Headers Forcing

request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all

# Response Headers Spoofing

reply_header_access Via deny all
reply_header_access X-Cache deny all
reply_header_access X-Cache-Lookup deny all


#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-CSM

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
 else
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 dstdomain -i localhost
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access deny all

#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-CSM

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
fi
fun_eth
echo -e "$barra\n \033[1;31m [ ! ] \033[1;33m ("REINICIANDO SERVICIOS")"
squid3 -k reconfigure > /dev/null 2>&1
squid -k reconfigure > /dev/null 2>&1
service ssh restart > /dev/null 2>&1
service squid3 restart > /dev/null 2>&1
service squid restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
echo -e "$barra\n ${cor[3]} ("SQUID CONFIGURADO")\n$barra"
mportas > /tmp/portz
while read portas; do
[[ $portas = "" ]] && break
done < /tmp/portz
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}

fun_dropbear () {
 [[ -e /etc/default/dropbear ]] && {
 echo -e "$barra\n\033[1;32m ("ELIMINADO DROPBEAR")\n$barra"
 fun_bar "apt-get remove dropbear -y"
 echo -e "$barra\n\033[1;32m ("Dropbear ELIMINADO")\n$barra"
 [[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
 user -k 443/tcp > /dev/null 2>&1
 return 0
 }
echo -e "$barra\n\033[1;32m ("INSTALADOR DROPBEAR CSM-GRATIS")\n$barra"
echo -e " ("DROPBEAR USA EL PUERTO 443")\033[1;37m"
echo -e "$barra"
   [[ $(mportas|grep 443) != "" ]] && {
   echo -e "\033[1;31m "PUERTO 443 EN USO")\033[1;37m"
   echo -e "\033[1;31m ("INTENTE NUEVAMENTE")\033[1;37m"
   fuser -k 443/tcp > /dev/null 2>&1
   echo -e "$barra"
   return 1
   }
sysvar=$(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //' | grep -o Ubuntu)
shells=$(cat /etc/shells|grep "/bin/false")
[[ ! ${shells} ]] && echo -e "/bin/false" >> /etc/shells
[[ "$sysvar" != "" ]] && {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
echo -e "${cor[2]} ("Instalando dropbear")"
echo -e "$barra"
fun_bar "apt-get install dropbear -y"
echo -e "$barra"
touch /etc/dropbear/banner
echo -e "${cor[2]} ("Configurando dropbear")"
echo -e "NO_START=0" > /etc/default/dropbear
echo -e 'DROPBEAR_EXTRA_ARGS="-p 443"' >> /etc/default/dropbear
echo -e 'DROPBEAR_BANNER="/etc/dropbear/banner"' >> /etc/default/dropbear
echo -e "DROPBEAR_RECEIVE_WINDOW=65536" >> /etc/default/dropbear
} || {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
echo -e "${cor[2]} "Instalando dropbear")"
echo -e "$barra"
fun_bar "apt-get install dropbear -y"
touch /etc/dropbear/banner
echo -e "$barra"
echo -e "${cor[2]} "Configurando dropbear")"
echo -e "NO_START=0" > /etc/default/dropbear
echo -e 'DROPBEAR_EXTRA_ARGS="-p 443"' >> /etc/default/dropbear
echo -e 'DROPBEAR_BANNER="/etc/dropbear/banner"' >> /etc/default/dropbear
echo -e "DROPBEAR_RECEIVE_WINDOW=65536" >> /etc/default/dropbear
}
fun_eth
service ssh restart > /dev/null 2>&1
service dropbear restart > /dev/null 2>&1
echo -e "$barra\n${cor[3]} "Su dropbear fue configurado con exitó")\n$barra"
mportas > /tmp/portz
while read portas; do
[[ $portas = "" ]] && break
done < /tmp/portz
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}


instala_ovpn () {
parametros_iniciais () {
#Verifica o Sistema
if [[ "$EUID" -ne 0 ]]; then
	echo -e "$barra"
	echo " Sorry, you need to run this as root"
	echo -e "$barra"
	read -p " Enter"
	exit
fi

if [[ ! -e /dev/net/tun ]]; then
	echo -e "$barra"
	echo " The TUN device is not available"
	echo -e "$barra"
	read -p " Enter" 
	exit
fi
if [[ -e /etc/debian_version ]]; then
OS="debian"
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
IPTABLES='/etc/iptables/iptables.rules'
SYSCTL='/etc/sysctl.conf'
 [[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.10"' ]] && {
 echo " Sua versão do Debian / Ubuntu não é suportada."
 while [[ $CONTINUE != @(y|Y|s|S|n|N) ]]; do
 read -p "Continuar ? [y/n]: " -e CONTINUE
 done
 [[ "$CONTINUE" = @(n|N) ]] && return 2
 }
else
echo -e "$barra\n\033[1;33m $(source trans -b pt:${id} "Parece que você não está executando este instalador em um sistema Debian ou Ubuntu")\n$barra"
return 1
fi
#Pega Interface
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
echo -e "$barra\n\033[1;33m "Sistema preparado para recibir el OPENVPN"\n$barra"
}
add_repo () {
#INSTALACAO E UPDATE DO REPOSITORIO
# Debian 7
if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable wheezy main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
# Debian 8
elif [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable jessie main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
# Ubuntu 14.04
elif [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable trusty main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
fi
}
coleta_variaveis () {
	#Instal
	echo -e " ("Responda las perguntas para iniciar la instalación")"
	echo -e " ("Responda corretamente")\n$barra "
	echo -e " \033[1;33m "Primero necesitamos el ip de su máquina, esta ip esta correcta?")\033[0m"
	# Autodetect IP address and pre-fill for the user
	IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
	read -p " IP address: " -e -i $IP IP
	# If $IP is a private IP address, the server must be behind NAT
	if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
		echo
		echo " \033[1;33mEste servidor está detrás de NAT. ¿Cuál es el public IPv4 address o hostname?"
		read -p " Public IP address / hostname: " -e PUBLICIP
	fi
	echo -e "$barra\n \033[1;31m "Elegir el tipo de protocolo para") OPENVPN"
	echo -e " \033[1;31mA menos que el UDP esté bloqueado, debe utilizar TCP (pero lento)\n$barra"
	#PROTOCOLO
	while [[ $PROTOCOL != @(UDP|TCP) ]]; do
	read -p " Protocol [UDP/TCP]: " -e -i TCP PROTOCOL
	done
	[[ $PROTOCOL = "UDP" ]] && PROTOCOL=udp
	[[ $PROTOCOL = "TCP" ]] && PROTOCOL=tcp
	echo -e "$barra\n \033[1;33m "Que puerto desea usar?")\033[0m\n$barra"
	read -p " Port: " -e -i 1194 PORT
	#DNS
	echo -e "$barra\n \033[1;33m "Que DNS desea usar?")\n$barra"
	echo "   1) Usar DNS del sistema"
	echo "   2) Cloudflare (Anycast: worldwide)"
	echo "   3) Quad9 (Anycast: worldwide)"
	echo "   4) FDN (France)"
	echo "   5) DNS.WATCH (Germany)"
	echo "   6) OpenDNS (Anycast: worldwide)"
	echo "   7) Google (Anycast: worldwide)"
	echo "   8) Yandex Basic (Russia)"
	echo "   9) AdGuard DNS (Russia)"
	while [[ $DNS != @(1|2|3|4|5|6|7|8|9) ]]; do
	read -p " DNS [1-9]: " -e -i 1 DNS
	done
	#CIPHER
	echo -e "$barra\n \033[1;33m "Elegir el tipo de codificacion para el canal de datos:")\n$barra"
	echo "   1) AES-128-CBC"
	echo "   2) AES-192-CBC"
	echo "   3) AES-256-CBC"
	echo "   4) CAMELLIA-128-CBC"
	echo "   5) CAMELLIA-192-CBC"
	echo "   6) CAMELLIA-256-CBC"
	echo "   7) SEED-CBC"
	while [[ $CIPHER != @(1|2|3|4|5|6|7) ]]; do
	read -p " Cipher [1-7]: " -e -i 1 CIPHER
	done
	case $CIPHER in
	1) CIPHER="cipher AES-128-CBC";;
	2) CIPHER="cipher AES-192-CBC";;
	3) CIPHER="cipher AES-256-CBC";;
	4) CIPHER="cipher CAMELLIA-128-CBC";;
	5) CIPHER="cipher CAMELLIA-192-CBC";;
	6) CIPHER="cipher CAMELLIA-256-CBC";;
	7) CIPHER="cipher SEED-CBC";;
	esac
	echo -e "$barra\n \033[1;33m "Estamos listos para configurar su servidor OpenVPN")\n$barra"
	read -n1 -r -p " Enter Continue..."
	echo -e "$barra"
	}
parametros_iniciais # BREVE VERIFICACAO
coleta_variaveis # COLETA VARIAVEIS PARA INSTALAÇÃO
add_repo # ATUALIZA REPOSITÓRIO OPENVPN E INSTALA OPENVPN
# Cria Diretorio
[[ ! -d /etc/openvpn ]] && mkdir /etc/openvpn
# Install openvpn
echo -ne "\033[1;31m [ ! ] apt-get update"
apt-get update -q > /dev/null 2>&1 && echo -e "\033[1;32m [OK]"
echo -ne "\033[1;31m [ ! ] apt-get install openvpn curl openssl"
apt-get install -qy openvpn curl > /dev/null 2>&1 && echo -e "\033[1;32m [OK]"
# IP Address
SERVER_IP=$(wget -qO- ipv4.icanhazip.com)
if [[ -z "${SERVER_IP}" ]]; then
    SERVER_IP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
fi
# Generate CA Config
echo -ne "\033[1;31m [ ! ] Generating CA Config"
(
openssl dhparam -out /etc/openvpn/dh.pem 2048 > /dev/null 2>&1
openssl genrsa -out /etc/openvpn/ca-key.pem 2048 > /dev/null 2>&1
chmod 600 /etc/openvpn/ca-key.pem > /dev/null
openssl req -new -key /etc/openvpn/ca-key.pem -out /etc/openvpn/ca-csr.pem -subj /CN=OpenVPN-CA/ > /dev/null 2>&1
openssl x509 -req -in /etc/openvpn/ca-csr.pem -out /etc/openvpn/ca.pem -signkey /etc/openvpn/ca-key.pem -days 365 > /dev/null 2>&1
echo 01 > /etc/openvpn/ca.srl
) && echo -e "\033[1;32m [OK]"
# Gerando server.con
echo -ne "\033[1;31m [ ! ] Generating Server Config"
(
case $DNS in
1)
i=0
grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
dns[$i]="push \"dhcp-option DNS $line\""
done
if [[ ! "${dns[@]}" ]]; then
dns[0]='push "dhcp-option DNS 8.8.8.8"'
dns[1]='push "dhcp-option DNS 8.8.4.4"'
fi
;;
2)
dns[0]='push "dhcp-option DNS 1.0.0.1"'
dns[1]='push "dhcp-option DNS 1.1.1.1"'
;;
3)
dns[0]='push "dhcp-option DNS 9.9.9.9"'
dns[1]='push "dhcp-option DNS 1.1.1.1"'
;;
4)
dns[0]='push "dhcp-option DNS 80.67.169.40"'
dns[1]='push "dhcp-option DNS 80.67.169.12"'
;;
5)
dns[0]='push "dhcp-option DNS 84.200.69.80"'
dns[1]='push "dhcp-option DNS 84.200.70.40"'
;;
6)
dns[0]='push "dhcp-option DNS 208.67.222.222"'
dns[1]='push "dhcp-option DNS 208.67.220.220"'
;;
7)
dns[0]='push "dhcp-option DNS 8.8.8.8"'
dns[1]='push "dhcp-option DNS 8.8.4.4"'
;;
8)
dns[0]='push "dhcp-option DNS 77.88.8.8"'
dns[1]='push "dhcp-option DNS 77.88.8.1"'
;;
9)
dns[0]='push "dhcp-option DNS 176.103.130.130"'
dns[1]='push "dhcp-option DNS 176.103.130.131"'
;;
esac
cat > /etc/openvpn/server.conf <<EOF
server 10.8.0.0 255.255.255.0
verb 3
duplicate-cn
key client-key.pem
ca ca.pem
cert client-cert.pem
dh dh.pem
keepalive 10 120
persist-key
persist-tun
comp-lzo
float
push "redirect-gateway def1 bypass-dhcp"
${dns[0]}
${dns[1]}
user nobody
group nogroup

${CIPHER}
proto ${PROTOCOL}
port $PORT
dev tun
status openvpn-status.log
EOF
PLUGIN=$(find / | grep openvpn-plugin-auth-pam.so | head -1) && [[ $(echo ${PLUGIN}) != "" ]] && {
echo "client-to-client
client-cert-not-required
username-as-common-name
plugin $PLUGIN login" >> /etc/openvpn/server.conf
}
) && echo -e "\033[1;32m [OK]"

# Generate Client Config
echo -ne "\033[1;31m [ ! ] Generating Client Config"
(
openssl genrsa -out /etc/openvpn/client-key.pem 2048 > /dev/null 2>&1
chmod 600 /etc/openvpn/client-key.pem
openssl req -new -key /etc/openvpn/client-key.pem -out /etc/openvpn/client-csr.pem -subj /CN=OpenVPN-Client/ > /dev/null 2>&1
openssl x509 -req -in /etc/openvpn/client-csr.pem -out /etc/openvpn/client-cert.pem -CA /etc/openvpn/ca.pem -CAkey /etc/openvpn/ca-key.pem -days 36525 > /dev/null 2>&1
) && echo -e "\033[1;32m [OK]"
teste_porta () {
  echo -ne " \033[1;31m"Verificando: ")"
  sleep 1s
  [[ ! $(mportas | grep $1) ]] && {
    echo -e " \033[1;33m$Abriendo un Puerto en Python"
    cd /etc/adm-lite
    [[ $(screen -h|wc -l) -lt '30' ]] && apt-get install screen -y 
    screen -dmS screen python ./openproxy.py "$1"    
    } || {
    echo -e "\033[1;32m [Pass]"
    return 1
    }
   }
echo -e "$barra\n \033[1;33mAhora se necesita el puerto de su Proxy Squid Socks"
echo -e " \033[1;33mSi no existe un proxy en la puerta, un proxy Python será abierto!\n$barra"
while [[ $? != "1" ]]; do
read -p " Confirme un Puerto(Proxy): " -e -i 80 PPROXY
teste_porta $PPROXY
done
cat > /etc/openvpn/client-common.txt <<EOF
client
nobind
dev tun
redirect-gateway def1 bypass-dhcp
remote ${SERVER_IP} ${PORT} ${PROTOCOL}
http-proxy ${SERVER_IP} ${PPROXY}
$CIPHER
comp-lzo yes
keepalive 10 20
float
auth-user-pass
EOF
# Iptables
if [[ ! -f /proc/user_beancounters ]]; then
    N_INT=$(ip a |awk -v sip="$SERVER_IP" '$0 ~ sip { print $7}')
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $N_INT -j MASQUERADE
else
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source $SERVER_IP
fi
iptables-save > /etc/iptables.conf
cat > /etc/network/if-up.d/iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.conf
EOF
chmod +x /etc/network/if-up.d/iptables
# Enable net.ipv4.ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
#Liberando DNS
DDNS=S
agrega_dns () {
echo -e "\033[1;33m "Digite o DNS que desea Adicionar")"
read -p " [NewDNS]: " NEWDNS
dns_var=$(cat /etc/hosts|grep -v "$NEWDNS")
echo "127.0.0.1 $NEWDNS" > /etc/hosts
echo "$dns_var" >> /etc/hosts
unset NEWDNS 
}
echo -e "$barra\n \033[1;33m"Ultima etapa, Configuración DNS")\n$barra"
while [[ $DDNS = @(s|S|y|Y) ]]; do
echo -ne "\033[1;33m"
read -p " Adicionar DNS [S/N]: " -e -i n DDNS
[[ $DDNS = @(s|S|y|Y) ]] && agrega_dns
done
echo -e "$barra"
# REINICIANDO OPENVPN
if [[ "$OS" = 'debian' ]]; then
 if pgrep systemd-journal; then
 sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
 sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
 sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
 #systemctl daemon-reload
 (
 systemctl restart openvpn
 systemctl enable openvpn
 ) > /dev/null 2>&1
 echo -ne
 else
 /etc/init.d/openvpn restart
 fi
else
 if pgrep systemd-journal; then
  (
 systemctl restart openvpn@server.service
 systemctl enable openvpn@server.service
  ) > /dev/null 2>&1
  echo -ne
 else
 service openvpn restart
 chkconfig openvpn on
 fi
fi
apt-get install ufw -y > /dev/null 2>&1
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
#Restart OPENVPN
(
killall openvpn 2>/dev/null
systemctl stop openvpn@server.service > /dev/null 2>&1
service openvpn stop > /dev/null 2>&1
sleep 0.1s
cd /etc/openvpn > /dev/null 2>&1
/etc/iptables-openvpn > /dev/null 2>&1
openvpn --config server.conf & > /dev/null 2>&1
) > /dev/null 2>&1
echo -e "$barra\n \033[1;33m"Openvpn configurado con éxito!")"
echo -e " \033[1;33m"Ahora Crear un usuario para generar un cliente!")\n$barra"
return 0
}

	
fun_openvpn () {
[[ -e /etc/openvpn/server.conf ]] && {
unset OPENBAR
[[ $(ps x|grep -v grep|grep openvpn) ]] && OPENBAR="\033[1;32mOnline" || OPENBAR="\033[1;31mOffline"
teste_porta () {
echo -ne " \033[1;31m"Verificando: ")"
sleep 1s
[[ ! $(mportas | grep $1) ]] && {
echo -e " \033[1;33m"Abriendo un Puerto en Python")"
cd /etc/adm-lite
[[ $(screen -h|wc -l) -lt '30' ]] && apt-get install screen -y 
screen -dmS screen python ./openproxy.py "$1"    
} || {
	echo -e "\033[1;32m [Pass]"
	return 1
	}
}
echo -e "$barra\n\033[1;33m "OPENVPN ESTA INSTALADO")\n$barra"
echo -e "\033[1;31m [ 1 ] \033[1;33m "Remover Openvpn")"
echo -e "\033[1;31m [ 2 ] \033[1;33m "Editar Cliente Openvpn") \033[1;31m(comand nano)"
echo -e "\033[1;31m [ 3 ] \033[1;33m "INICIAR o DETENER OPENVPN") $OPENBAR\n$barra"
echo -ne "\033[1;33m "Opcao"): "
read xption
case $xption in 
1)
	echo -e "$barra\n\033[1;33m "DESINSTALAR OPENVPN")\n$barra"
	(
	ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
	killall openvpn 2>/dev/null
	systemctl stop openvpn@server.service >/dev/null 2>&1 & 
	service openvpn stop > /dev/null 2>&1
	) > /dev/null 2>&1
	#Purge
	if [[ "$OS" = 'debian' ]]; then
	fun_bar "apt-get remove --purge -y openvpn openvpn-blacklist"
	else
	fun_bar "yum remove openvpn -y"
	fi
	tuns=$(cat /etc/modules | grep -v tun) && echo -e "$tuns" > /etc/modules
	rm -f /etc/sysctl.d/30-openvpn-forward.conf
	rm -rf /etc/openvpn && rm -rf /usr/share/doc/openvpn*
	echo -e "$barra\n\033[1;33m "Procedimento Concluido")\n$barra"
	return 0;;
 2)
   nano /etc/openvpn/client-common.txt
   return 0;;
 3)
	[[ $(ps x|grep -v grep|grep openvpn) ]] && {
	ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
	killall openvpn > /dev/null
	systemctl stop openvpn@server.service > /dev/null 2>&1
	service openvpn stop > /dev/null 2>&1
	echo -e "$barra\n\033[1;31m "OPENVPN Detenido")\n$barra"
	} || {
	(
	ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
	killall openvpn 2>/dev/null
	systemctl stop openvpn@server.service >/dev/null 2>&1 & 
	service openvpn stop > /dev/null 2>&1
	cd /etc/openvpn > /dev/null 2>&1
	/etc/iptables-openvpn > /dev/null 2>&1
	openvpn --config server.conf & > /dev/null 2>&1
	) > /dev/null 2>&1
	echo -e "${barra}"
	read -p " Confirme a Puerto(Proxy): " -e -i 80 PPROXY
	teste_porta $PPROXY
	echo -e "$barra\n\033[1;32m "OPENVPN iniciado")\n$barra"
	}
	return 0;;
 *)
	echo -e "${barra}"
	return 0
 esac
 }
[[ -e /etc/squid/squid.conf ]] && instala_ovpn && return 0
[[ -e /etc/squid3/squid.conf ]] && instala_ovpn && return 0
echo -e "$barra\n\033[1;33m "Squid No Encontrado")"
echo -e "\033[1;33m "Proseguir Con Instalación?")\n$barra"
read -p " [S/N]: " -e -i n instnosquid && [[ $instnosquid = @(s|S|y|Y) ]] && instala_ovpn || return 1
}

fun_shadowsocks () {
[[ -e /etc/shadowsocks.json ]] && {
[[ $(ps x|grep ssserver|grep -v grep|awk '{print $1}') != "" ]] && kill -9 $(ps x|grep ssserver|grep -v grep|awk '{print $1}') > /dev/null 2>&1 && ssserver -c /etc/shadowsocks.json -d stop > /dev/null 2>&1
echo -e "${barra}\n\033[1;33m "SHADOWSOCKS PARADO")\n${barra}${cor[0]}"
rm /etc/shadowsocks.json
return 0
}
       while true; do
       echo -e "${barra}\n\033[1;33m "Seleccione una Criptografia")\n${barra}${cor[0]}"
       encript=(aes-256-gcm aes-192-gcm aes-128-gcm aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20-ietf-poly1305 chacha20-ietf chacha20 rc4-md5)
       for((s=0; s<${#encript[@]}; s++)); do
       echo -e " [${s}] - ${encript[${s}]}"
       done
       echo -e "$barra"
       while true; do
       unset cript
       echo -ne " "Escoja una Opción"): "; read cript
       [[ ${encript[$cript]} ]] && break
       echo -e " "Opción Invalida")"
       done
       echo -e "$barra"
       encriptacao="${encript[$cript]}"
       [[ ${encriptacao} != "" ]] && break
       echo -e " "Opción Invalida")"
      done
#ESCOLHENDO LISTEN
      echo -e "${barra}\n\033[1;33m "Seleccione Un Puerto Para Shadowsocks")\n${barra}${cor[0]}"
      while true; do
      unset Lport
      read -p " Listen Port: " Lport
      [[ $(mportas|grep "$Lport") = "" ]] && break
      echo -e " ${Lport}: Porta Invalida)"      
      done
#INICIANDO
echo -e "${barra}\n\033[1;33m "Digite una contraseña Shadowsocks")${cor[0]}"
read -p" Pass: " Pass
echo -e "${barra}\n\033[1;33m Instalando)\n${barra}${cor[0]}"
fun_bar 'apt-get install python-pip python-m2crypto -y'
fun_bar 'pip install --upgrade pip'
fun_bar 'pip install shadowsocks'
echo -ne '{\n"server":"' > /etc/shadowsocks.json
echo -ne "0.0.0.0" >> /etc/shadowsocks.json
echo -ne '",\n"server_port":' >> /etc/shadowsocks.json
echo -ne "${Lport},\n" >> /etc/shadowsocks.json
echo -ne '"local_port":1080,\n"password":"' >> /etc/shadowsocks.json
echo -ne "${Pass}" >> /etc/shadowsocks.json
echo -ne '",\n"timeout":600,\n"method":"aes-256-cfb"\n}' >> /etc/shadowsocks.json
echo -e "${barra}\n\033[1;31m STARTING\033[0m"
ssserver -c /etc/shadowsocks.json -d start > /dev/null 2>&1
value=$(ps x |grep ssserver|grep -v grep)
[[ $value != "" ]] && value="\033[1;32mSTARTED" || value="\033[1;31mERROR"
echo -e "${barra}\n ${value} ${cor[0]}\n${barra}"
return 0
}

telegran_bot () {
if [[ "$(ps x | grep "ultimatebot" | grep -v "grep")" = "" ]]; then
echo -e "${barra}"
read -p " TELEGRAN BOT TOKEN: " tokenxx
read -p " TELEGRAN BOT LOGUIN: " loguin
read -p " TELEGRAN BOT PASS: " pass
read -p " BOT LINGUAGE [pt/es/en/fr]: " lang
echo -e "${barra}"
echo -e "${loguin}:${pass}" > ./bottokens
screen -dmS screen bash ./ultimatebot "$tokenxx" "$lang" > /dev/null 2>&1
echo -e " LOADING BOT, WAIT"
sleep 10s
echo -e " RUNNING"
echo -e "${barra}"
else
kill -9 $(ps x | grep "ultimatebot" | grep -v "grep" | awk '{print $1}') > /dev/null 2>&1
[[ -e ./bottokens ]] && rm ./bottokens
echo -e "${barra}"
echo -e " BOT STOPED"
echo -e "${barra}"
fi
return 0
}

web_min () {
 [[ -e /etc/webmin/miniserv.conf ]] && {
 echo -e "$barra\n\033[1;32m ELIMINANDO WEBMIN)\n$barra"
 fun_bar "apt-get remove webmin -y"
 echo -e "$barra\n\033[1;32m (Webmin Eliminado)\n$barra"
 [[ -e /etc/webmin/miniserv.conf ]] && rm /etc/webmin/miniserv.conf
 return 0
 }
echo -e " \033[1;36mInstalando Webmin, espere:"
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.850_all.deb"
dpkg --install webmin_1.850_all.deb;
apt-get -y -f install;
rm /root/webmin_1.850_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
echo -e "${barra}\n Accede via web usando el enlace: https;//ip_del_vps:10000)\n${barra}"
echo -e " ("Procedimento terminado")\n${barra}"
return 0
}

iniciarsocks () {
pstop () {
[[ -e /etc/adm-lite/sockson ]] && {
echo -e "${barra}\n Deteniendo Socks Python)\n${barra}"
pidproxy=$(ps x | grep "proxypub.py" | grep -v "grep" | awk -F "pts" '{print $1}')
fun_bar "kill -9 $pidproxy"
pidproxy2=$(ps x | grep "proxypriv.py" | grep -v "grep" | awk -F "pts" '{print $1}')
fun_bar "kill -9 $pidproxy2"
pidproxy3=$(ps x | grep "proxydirect.py" | grep -v "grep" | awk -F "pts" '{print $1}')
fun_bar "kill -9 $pidproxy3"
pidproxy4=$(ps x | grep "openproxy.py" | grep -v "grep" | awk -F "pts" '{print $1}')
fun_bar "kill -9 $pidproxy4"
echo -e "${barra}\n Socks Detenido)\n${barra}"
rm /etc/adm-lite/sockson
[[ -e /etc/adm-lite/sockpub ]] && rm /etc/adm-lite/sockpub
[[ -e /etc/adm-lite/sockpriv ]] && rm /etc/adm-lite/sockpriv
[[ -e /etc/adm-lite/sockdirect ]] && rm /etc/adm-lite/sockdirect
[[ -e /etc/adm-lite/sockopen ]] && rm /etc/adm-lite/sockopen
}
return 0
}
socksinstal () {
[[ ! -e /etc/adm-lite/sockson ]] && touch /etc/adm-lite/sockson
}

pconfig () {
echo -e "${barra}\n ("Seleccione el puerto en el que socks va escuchar")\n${barra}"
while true; do
unset porta_socket
echo -ne "\033[1;37m"
	 read -p " Local-Port: " porta_socket
	 if [[ ! -z $porta_socket ]]; then
		 if [[ $(echo $porta_socket|grep [0-9]) ]]; then
			[[ $(mportas|grep $porta_socket) = "" ]] && break || echo -e "\033[1;31m "Puerto Invalido")"
		 fi
	 fi
done
echo -e "${barra}\n "Escoja el Texto de Conexión"\n${barra}"
read -p " Text Socket: " -e -i MSCPERU texto_soket
}
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
[[ -e /etc/adm-lite/sockpub ]] && _sockpub="\033[1;32mOn" || _sockpub="\033[1;31mOff"
[[ -e /etc/adm-lite/sockpriv ]] && _sockpriv="\033[1;32mOn" || _sockpriv="\033[1;31mOff"
[[ -e /etc/adm-lite/sockdirect ]] && _sockdirect="\033[1;32mOn" || _sockdirect="\033[1;31mOff"
[[ -e /etc/adm-lite/sockopen ]] && _sockopen="\033[1;32mOn" || _sockopen="\033[1;31mOff"
echo -e "${barra}"
echo -e "${cor[2]} [ 1 ] ${cor[3]}Socks Python SIMPLE ${_sockpub}"
echo -e "${cor[2]} [ 2 ] ${cor[3]}Socks Python SEGURO ${_sockpriv}"
echo -e "${cor[2]} [ 3 ] ${cor[3]}Socks Python DIRECTO ${_sockdirect}"
echo -e "${cor[2]} [ 4 ] ${cor[3]}Socks Python OPENVPN ${_sockopen}"
echo -e "${cor[2]} [ 5 ] ${cor[3]}Detener Socks Python \n${barra}"
while true; do
read -p " Option: " portproxy
    case $portproxy in
    1)
	pconfig
    screen -dmS screen python ./proxypub.py "$porta_socket" "$texto_soket"
	[[ $(mportas|grep $porta_socket) != "" ]] || touch /etc/adm-lite/sockpub && socksinstal
    break;;
    2)
	pconfig
    screen -dmS screen python3 ./proxypriv.py "$porta_socket" "$texto_soket" "$IP"
	[[ $(mportas|grep $porta_socket) != "" ]] || touch /etc/adm-lite/sockpriv && socksinstal
    break;;
    3)
	pconfig
    screen -dmS screen python ./proxydirect.py "$porta_socket" "$texto_soket"
	[[ $(mportas|grep $porta_socket) != "" ]] || touch /etc/adm-lite/sockdirect && socksinstal
    break;;
	4)
	pconfig
    screen -dmS screen python ./openproxy.py "$porta_socket" "$texto_soket"
	[[ $(mportas|grep $porta_socket) != "" ]] || touch /etc/adm-lite/sockopen && socksinstal
    break;;
	5)
	pstop
    break;;
	*)
	echo -e "${barra}"
	return 0
    esac
done
echo -e "${barra}\n "Procedimento terminado"\n${barra}"
return 0
}

gettunel_fun () {
[[ -e /etc/adm-lite/gettun ]] && {
echo -e "${barra}\n DETENIENDO GETTUNEL\n${barra}"
pid=$(ps x | grep "get.py" | grep -v grep | awk '{print $1}')
if [ "$pid" != "" ]; then
for pids in $(echo $pid); do
fun_bar "kill -9 $pids"
done
fi
rm /etc/adm-lite/gettun
echo -e "${barra}\n (Gettunel "desactivado")\n${barra}"
return 0
}
echo -e "${barra}\n GETTUNEL PROXY\n${barra}"
echo -e "${cor[3]} ("seleccione Un Puerto donde Gettunel va Escuchar")"
while true; do
unset portas
echo -ne "\033[1;37m"
	 read -p " Local-Port: " portas
	 if [[ ! -z $portas ]]; then
		 if [[ $(echo $portas|grep [0-9]) ]]; then
		[[ $(mportas|grep $portas) = "" ]] && break || echo -e " ("Puerto invalido")"
		fi
	fi
done
sed -s "s;CONFIG_LISTENING = '0.0.0.0:8799';CONFIG_LISTENING = '0.0.0.0:$portas';g" ./get > ./get.py
screen -dmS screen python ./get.py
sleep 1s
rm ./get.py
 [[ "$(ps x | grep get.py | grep -v grep | awk '{print $1}')" != "" ]] && {
 echo -e "${barra}\n Gettunel "Iniciado con exitó"\n${barra} "
 echo -e " Su password es:"
 echo -e "${cor[3]} Pass:\033[1;32m MSCPERU"
 echo -e "$barra"
 touch /etc/adm-lite/gettun
 } || {
echo -e "$barra\n Gettunel "no se ha iniciado"\n$barra"
 }
}

tcpbypass_fun () {
[[ -e /etc/adm-lite/edbypass ]] && {
echo -e "$barra\n "Parando Tcp Bypass")\n$barra"
pid=$(ps x | grep "scktcheck" | grep -v grep | awk '{print $1}')
if [ "$pid" != "" ]; then
for pids in $(echo $pid); do
fun_bar "kill -9 $pids"
done
fi
echo -e "$barra\n "Parado con exitó")\n$barra"
rm /etc/adm-lite/edbypass
return 0
}
echo -e "$barra\n ("TCP Bypass VIP")\n$barra"
chmod +x ./overtcp
./overtcp || { 
echo -e "$barra"
return 1
}
touch /etc/adm-lite/edbypass
tput cuu1 && tput dl1
echo -e "$barra\n ("Procedimento Concluido")\n$barra"
return 0
}

ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
echo -e "$barra"
echo -e "\033[1;33m ("Parando Stunnel")"
echo -e "$barra"
fun_bar "apt-get purge stunnel4 -y"
echo -e "$barra"
echo -e "\033[1;33m ("Parado Con exitó!")"
echo -e "$barra"
return 0
}
echo -e "$barra"
echo -e "\033[1;36m ("SSL Stunnel")"
echo -e "$barra"
echo -e "\033[1;33m ("Selecione Un Puerto De Redirecionamento Interna")"
echo -e "\033[1;33m ("Es decir, un puerto en su servidor para SSL")"
echo -e "$barra"
         while true; do
         echo -ne "\033[1;37m"
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m ("Puerto Invalido")"
             fi
         fi
         done
echo -e "$barra"
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m ("Ahora el Puerto SSL, que va a escuchar")"
echo -e "$barra"
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep $SSLPORT) ]] || break
    echo -e "\033[1;33m ("El puerto seleccionado ya se encuentra en uso")"
    unset SSLPORT
	echo -e "$barra"
	return 0
    done
echo -e "$barra"
echo -e "\033[1;33m ("Instalando SSL")"
echo -e "$barra"
fun_bar "apt-get install stunnel4 -y"
echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:${DPORT}\naccept = ${SSLPORT}" > /etc/stunnel/stunnel.conf
openssl genrsa -out key.pem 2048 > /dev/null 2>&1
(echo pe; echo pe; echo csm; echo vip; echo msc; echo mscperu; echo @mscperu)|openssl req -new -x509 -key key.pem -out cert.pem -days 1095 > /dev/null 2>&1
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
echo -e "$barra"
echo -e "\033[1;33m ("INSTALADO CON EXITO")"
echo -e "$barra"
return 0
}

painel_upload () {
echo -e "$barra"
echo -e "${cor[2]} ("Desea Instalar Panel De descargas msc?")"
echo -e "$barra"
read -p " [ s | n ]: " up_load
echo -e "$barra"
   [[ "$up_load" = @(s|S|y|Y) ]] && bash /etc/adm-lite/instalar_wep || {
   echo -e "${cor[2]} ("Instalación cancelado")"
   echo -e "$barra"
   }
}

antiddos (){
if [ -d '/usr/local/ddos' ]; then
	if [ -e '/usr/local/sbin/ddos' ]; then
		rm -f /usr/local/sbin/ddos
	fi
	if [ -d '/usr/local/ddos' ]; then
		rm -rf /usr/local/ddos
	fi
	if [ -e '/etc/cron.d/ddos.cron' ]; then
		rm -f /etc/cron.d/ddos.cron
	fi
	sleep 4s
	echo -e "$barra"
	echo -e "\033[1;31m ANTIDDOS DESINSTALADO CON EXITO\033[1;37m"
	echo -e "$barra"
	return 1
else
	mkdir /usr/local/ddos
fi
wget -q -O /usr/local/ddos/ddos.conf https://raw.githubusercontent.com/scripmsc/master/DDOS/ddos.conf -o /dev/null
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE -o /dev/null
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list -o /dev/null
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh -o /dev/null
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
sleep 2s
echo -e "$barra"
echo -e "\033[1;32m ANTIDDOS INSTALADO CON EXITO.\033[1;37m"
echo -e "$barra"
}

#FUNCOES
funcao_addcores () {
if [ "$1" = "0" ]; then
cor[$2]="\033[0m"
elif [ "$1" = "1" ]; then
cor[$2]="\033[1;31m"
elif [ "$1" = "2" ]; then
cor[$2]="\033[1;32m"
elif [ "$1" = "3" ]; then
cor[$2]="\033[1;33m"
elif [ "$1" = "4" ]; then
cor[$2]="\033[1;34m"
elif [ "$1" = "5" ]; then
cor[$2]="\033[1;35m"
elif [ "$1" = "6" ]; then
cor[$2]="\033[1;36m"
elif [ "$1" = "7" ]; then
cor[$2]="\033[1;37m"
fi
}

[[ -e $_cores ]] && {
_cont="0"
while read _cor; do
funcao_addcores ${_cor} ${_cont}
_cont=$(($_cont + 1))
done < $_cores
} || {
cor[0]="\033[0m"
cor[1]="\033[1;34m"
cor[2]="\033[1;32m"
cor[3]="\033[1;37m"
cor[4]="\033[1;36m"
cor[5]="\033[1;33m"
cor[6]="\033[1;35m"
}
unset squid
unset dropbear
unset openvpn
unset stunel
unset shadow
unset telegran
unset socks
unset gettun
unset tcpbypass
unset webminn
unset ddos
[[ -e /etc/squid/squid.conf ]] && squid="\033[1;32m ("Online")"
[[ -e /etc/squid3/squid.conf ]] && squid="\033[1;32m ("Online")"
[[ -e /etc/default/dropbear ]] && dropbear="\033[1;32m ("Online")"
[[ -e /etc/openvpn/server.conf ]] && openvpn="\033[1;32m ("Configurado")"
[[ $(mportas|grep stunnel4|head -1) ]] && stunel="\033[1;32m ("Online")"
[[ -e /etc/shadowsocks.json ]] && shadow="\033[1;32m ("Online")"
[[ "$(ps x | grep "ultimatebot" | grep -v "grep")" != "" ]] && telegran="\033[1;32m ("Online")"
[[ -e /etc/adm-lite/sockson ]] && socks="\033[1;32m ("Online")"
[[ -e /etc/adm-lite/gettun ]] && gettun="\033[1;32m ("Online")"
[[ -e /etc/adm-lite/edbypass ]] && tcpbypass="\033[1;32m ("Online")"
[[ -e /etc/webmin/miniserv.conf ]] && webminn="\033[1;32m ("Online")"
[[ -e /usr/local/ddos/ddos.conf ]] && ddos="\033[1;32m ("Online")"
echo -e "$barra"
echo -e "${cor[5]} MENU EXTRA MSC"
echo -e "$barra"
echo -e "${cor[2]} [1] □ ${cor[3]}SQUID $squid"
echo -e "${cor[2]} [2] □ ${cor[3]}DROPBEAR $dropbear"
echo -e "${cor[2]} [3] □ ${cor[3]}OPENVPN $openvpn"
echo -e "${cor[2]} [4] □ ${cor[3]}SSL TUNNEL $stunel"
echo -e "${cor[2]} [5] □ ${cor[3]}SHADOW SOCKS $shadow"
echo -e "${cor[2]} [6] □ ${cor[3]}PROXY SOCKS $socks"
echo -e "${cor[2]} [7] □ ${cor[3]}PROXY GETTUNEL $gettun"
echo -e "${cor[2]} [8] □ ${cor[3]}TCP OVER BYPASS $tcpbypass"
echo -e "${cor[2]} [9] □ ${cor[3]}TELEGRAN MANAGER BOT $telegran"
echo -e "${cor[2]} [10]□ ${cor[3]}WEBMIN 10000 $webminn"
echo -e "${cor[2]} [11]□ ${cor[3]}WEP MSC $ddos"
echo -e "$barra"
echo -ne "\033[1;37m ${txt[338]}: "
read optons
case $optons in
1)
fun_squid
read -p " Enter";;
2)
fun_dropbear
read -p " Enter";;
3)
wget https://raw.githubusercontent.com/scriptmsc/scriptmsc/mscvip/openvpn-msc.sh -O openvpn-msc.sh && bash openvpn-msc.sh
read -p " Enter";;
4)
ssl_stunel
read -p " Enter";;
5)
fun_shadowsocks
read -p " Enter";;
6)
iniciarsocks
read -p " Enter";;
7)
gettunel_fun
read -p " Enter";;
8)
tcpbypass_fun
read -p " Enter";;
9)
telegran_bot
read -p " Enter";;
10)
web_min
read -p " Enter";;
11)
painel_upload
read -p " Enter";;
esac

#Reinicia ADM
menu
