#!/usr/bin/env python
# encoding: utf-8
import smtplib,socket,sys
from os import system
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
_NOME_ = sys.argv[1]
_IP_ = sys.argv[2]
_ADRESS_OS_ = '/etc/issue.net'
OS = open(_ADRESS_OS_).readlines()
for SYS in OS:
	_OS_ = SYS.replace('\n','')
_DATA_ = datetime.now()
_ANO_ = str(_DATA_.year)
_MES_ = str(_DATA_.month)
_DIA_ = str(_DATA_.day)
_HORA_ = str(_DATA_.hour)
_MINUTO_ = str(_DATA_.minute)
_SEGUNDO_ = str(_DATA_.second)
_MSG_ = MIMEMultipart('alternative')
_MSG_['Subject'] = "INSTALACIONES MSC"
_MSG_['From'] = 'MSC@gmail.com'
_MSG_['To'] = 'MSC@gmail.com'
_TEXTO_ = """\
<html>
<head></head>
<body>
<b><i>Ola! msc</i></b>
<br></b>
<b><i>SU SCRIPT FUE INSTALADO EN SU VPS<i></b>
<br></br>
<b><p>══════════════════════════</p><b><i>INFORMACIONES DE INSTALACAO<i></b>
<br><b><font color="blue">IP:</b> </font><i><b><font color="red">""" + _IP_ + """</font></b></i>
<br><b><font color="blue">Nome: </b></font> <i><b><font color="red">""" + _NOME_ + """</font></b></i>
<br><b><font color="blue">Sistema: </b></font> <i><b><font color="red">""" + _OS_ + """</font></b></i>
<b><p>══════════════════════════</p><b><i>DATA DE INSTALACIÓN<i></b>
<br><b><font color="blue">Dia: </b></font> <i><b><font color="red">"""+_DIA_+"""</font></b></i>
<br><b><font color="blue">Mes: </b></font> <i><b><font color="red">"""+_MES_+"""</font></b></i>
<br><b><font color="blue">Ano: </b></font> <i><b><font color="red">"""+_AÑO_+"""</font></b></i>
<b><p>══════════════════════════</p><b/>
<b><i>HORA DE INSTALACIÓN<i>
<br><b><font color="blue">Hora: </b></font><i> <b><font color="red">""" + _HORA_ +"""</font></b></i>
<br><b><font color="blue">Minutos: </b></font> <i><b><font color="red">""" + _MINUTO_ + """</font></b></i>
<br><b><font color="blue">Segundos: </b></font> <i><b><font color="red">""" + _SEGUNDO_ + """</font></b></i>
<b><p>══════════════════════════</p><b><b><i><font color="#00FF00">By: msc</i></b></br></p>
</body>
</html>
"""
_MSG2_ = MIMEText(_TEXTO_, 'html')
_MSG_.attach(_MSG2_)
_SERVER_ = smtplib.SMTP('smtp.gmail.com',587)
_SERVER_.ehlo()
_SERVER_.starttls()
_SERVER_.login('ga6055602@gmail.com','gustavo123!')
_SERVER_.sendmail('ga6055602@gmail.com','crzvpn@gmail.com',_MSG_.as_string())
