#!/bin/bash
if [ $# -ne 1 ];then
  echo "Retry!" && exit 11;
fi

#kill lived mysqld process 
ps -ef | awk '/mysqld/ && !/awk/{print $2}' | xargs kill -9 &> /dev/null

sleep 5

tardir=$(echo $1 | sed -n 's/.tar.gz//p')
if [ -d $tardir ];then
  rm -rf $tardir
fi
tar -xf $1 -C /opt
if [ -d /mysql ];then
  rm -rf /mysql
fi
mv $tardir /mysql
mkdir /mysql/{data,tmp,log}
touch /mysql/log/err.log

rpm -qi libaio &> /dev/null
if [ $? -ne 0 ];then
  yum install -y libaio &>/dev/null
fi

#if user mysql exists,then delete and recreate it
id mysql &> /dev/null
if [ $? -eq 0 ];then
  userdel -r mysql
fi
  useradd mysql
  echo "oracle" | passwd --stdin mysql &> /dev/null
chown mysql:mysql -R /mysql

#Begin to initialize mysql db with no password
/mysql/bin/mysqld --initialize-insecure -b /mysql -h /mysql/data -u mysql &> /dev/null
/mysql/bin/mysql_ssl_rsa_setup --datadir=/mysql/data &> /dev/null
echo '[client]
socket=/mysql/tmp/mysql.sock
[mysqld]
datadir=/mysql/data
tmpdir=/mysql/tmp
socket=/mysql/tmp/mysql.sock
character-set-server = utf8mb4
[mysqld_safe]
log-error=/mysql/log/err.log
pid-file=/mysql/tmp/mysql8.pid' > /etc/my.cnf
/mysql/bin/mysqld_safe --user=mysql &  &>/dev/null
sleep 10
/mysql/bin/mysql -uroot -e "alter user 'root'@'localhost' identified by 'oracle'"

echo 'MYSQL_HOME=/mysql
export PATH=$PATH:$MYSQL_HOME/bin' >> /root/.bash_profile

echo 'MYSQL_HOME=/mysql
export PATH=$PATH:$MYSQL_HOME/bin' >> /home/mysql/.bash_profile
