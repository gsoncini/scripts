#!/bin/bash
# Script para Backupear contas de e-mail individualmente
# Criado por Guilherme Soncini
# Variaveis
data=`date +%b%d%y | tr 'A-Z' 'a-z'`
destino=/home/backup
mailserver=mail.dominio.com.br

# Monta
mount -a
 
if [[ $? -eq 1 ]] 
then 
exit 1 
fi  
 
# Faz a checagem da particao montada
IS_MOUNTED=$( df -h | grep "${destino}" | wc -l ) 
  
if [[ ${IS_MOUNTED} -lt 1 ]] 
 
then 
    exit 1 
else     
 
su zimbra -c "/opt/zimbra/bin/zmprov -l gaa ${mailserver} > ${destino}/lista_de_emails.txt"
su zimbra -c "mkdir -p ${destino}/backups-${data}"
su zimbra -c "chown zimbra.zimbra ${backup}/backups-${data}"
 
for i in `cat ${destino}/lista_de_emails.txt`; do
su zimbra -c "/opt/zimbra/bin/zmmailbox -z -m $i getRestURL "//?fmt=tgz" > ${destino}/backups-${data}/$i.tgz"
done
 
# Remove os arquivos mais antigos que o periodo especificado
find ${destino} -mtime +30 -exec rm -rf {} \;
fi
 
umount -l /home/backup
