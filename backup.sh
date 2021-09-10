
#!bin/bash
START=$(date +%s);
echo '==================================================================================================='
echo '=                                              BACKUP                                             ='
echo '==================================================================================================='
user=pi@
current_date=`date +%Y-%m-%d`
mkdir -p /mnt/vcdevs-nfs/img-backup/$current_date
cd /mnt/vcdevs-nfs/img-backup/$current_date

while read ip; do
  echo '---------------------------------------------------------------------------------------------------'
  echo 'backup started for: '$ip
  LOOP_START=$(date +%s);
  host_to_backup=$user$ip
  file_name=$(ssh -n $host_to_backup echo '$HOSTNAME')
  file_name=$current_date'_'$file_name'.img'
  disk_name=`ssh -n $host_to_backup sudo -- "sh -c 'lsblk -oMOUNTPOINT,PKNAME -P | grep /boot | cut -d "=" -f3'"`
  disk_name=`echo $disk_name | cut -d'"' -f2`
  echo 'filename: '${file_name}' | disk to backup: '$disk_name  
  ssh -n $host_to_backup sudo -- "sh -c 'dd if=/dev/$disk_name of=/mnt/vcdevs-nfs/img-backup/$current_date/$file_name bs=1M'"
  sudo pishrink.sh -z $file_name
  LOOP_END=$(date +%s);
  echo $ip backup operation took `echo $((LOOP_END-LOOP_START)) | awk '{print int($1/60)":"int($1%60)}'` minutes
  echo '---------------------------------------------------------------------------------------------------'
done < /home/pi/scripts/backup/backup_host_list
END=$(date +%s);
echo Complete backup operation took `echo $((END-START)) | awk '{print int($1/60)":"int($1%60)}'` minutes
echo '==================================================================================================='
