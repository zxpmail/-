监控mysql状态有假死的情况重启mysql

1、建立check.sh

```shell
#!/bin/bash
host="127.0.0.1"
port="3306"
userName="root"
password="123456"
dbname="mysql"
dbset="--default-character-set=utf8 -A"
_disk_used="select sum((data_length+index_length)/1024/1024) M from information_schema.tables where table_schema=\"m_dp_eup\""
_disk_used_val=$(mysql -h${host} -u${userName} -p${password} ${dbname} -P${port} -e "${_disk_used}")
if [ $? == 0 ]; then
        echo `date` "success!"
else
        echo `date` "error!"
service mysqld restart
fi
```

2、增加可执行权限

```shell
[root@zhou mysql]# chmod +x check.sh
```

3、用crontab每分钟执行一次

```shell
crontab -e
* * * * * /usr/local/mysql/check.sh >> /usr/local/mysql/1
```

操作和vi类似