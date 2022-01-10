CREATE OR REPLACE FUNCTION p_service.send_email(_from text, _password text, smtp text, port integer, bcc text, receiver text, subject text, send_message text)
 RETURNS text
 LANGUAGE plpython3u
AS $function$
# -------------------------------------------------------
# Отправка сообщений через функцию в базе данных
# _from - логин и e-mail пользователя
# _password - пароль пользователя
# smtp - адрес почтового сервера smtp
# port - порт почтового сервера smtp
# bcc - e-mail получателя (скрытая копия)
# receiver - e-mail получателя
# subject - тема письма
# send_message - текст письма
# -------------------------------------------------------
import smtplib
from smtplib import SMTPException
message = ("From: %snTo: %snBcc: %snMIME-Version: 1.0nContent-type: text/htmlnSubject: %snn %s" % (_from,receiver,bcc,subject,send_message))
try:
  smtpObj = smtplib.SMTP(smtp,port)
  smtpObj.starttls()
  smtpObj.login(_from, _password)
  smtpObj.sendmail(_from,receiver,message.encode('utf-8'))
  print ('Successfully sent email')
except SMTPException:
  print ('Error: unable to send email')
return message
$function$
;
