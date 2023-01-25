#!/bin/bash
# Criado por Guilherme Soncini - Script para backupear contas de email Zimbra.

data=`date +%b%d%y | tr 'A-Z' 'a-z'`
dominio=exemplo.com.br
empresa=empresa-exemplo
destino=/home/backupemails
LOGFILE="/var/log/backup/zimbrabkp_"${data}.log
#
# Habilita log copiando a saída padrão para o arquivo LOGFILE
exec 1> >(tee -a "$LOGFILE")

# Faz o mesmo para a saída de ERROS
exec 2>&1

echo " - Backup Contas de Email ${dominio} - " >> $LOGFILE

echo "Volume montado, fazendo backup ..." >> $LOGFILE
su zimbra -c "/opt/zimbra/bin/zmprov -l gaa ${dominio} > ${destino}/lista_de_emails.txt"
su zimbra -c "/bin/mkdir -p ${destino}/backups-${data}"
su zimbra -c "/bin/chown zimbra.zimbra ${destino}/backups-${data}"

for i in `cat ${destino}/lista_de_emails.txt`; do
su zimbra -c "/opt/zimbra/bin/zmmailbox -z -m $i getRestURL "//?fmt=tgz" > ${destino}/backups-${data}/zmbkp_$i.tgz"
done

echo "Removendo backups antigos ..." >> $LOGFILE
NMINUTOS=600
#NDIAS=1
find ${destino} -mmin +$NMINUTOS >> $LOG
find ${destino} -mmin +$NMINUTOS -exec rm -rf {} \;
#find ${destino} -mtime +1 >> $LOGFILE
#find ${destino} -mtime +1 -exec rm -rf {} \;

# Lista arquivos backupeados
echo "Listando arquivos do backup ..." >> $LOGFILE
/bin/ls -lha ${destino}/backups-${data}/ >> $LOGFILE

# Desmonta
#echo "Desmontando volume ..." >> $LOGFILE
#/bin/umount -l /backup/

echo "Backup finalizado em: `date +%d-%m-%y_%H:%M`" >> $LOGFILE
echo "Backup executado!!! ${empresa}" >> $LOGFILE
# Notificação por Email
(/bin/echo "Subject: Backup Zimbra ${empresa} - ${dominio}  - `date +%d/%m/%Y-%kh%Mm`";/bin/cat /var/log/backup/zimbrabkp_${data}.log) | /usr/sbin/sendmail teste@exemplo.com.br

# Notificação por Telegram ( Necessita do Telegram Notify estar instalado )
# /usr/local/sbin/telegram-notify --success --text " Backup mail-server X realizado com SUCESSO!"
