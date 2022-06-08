**1、检查已安装的mariadb，并强制卸载**

```shell
[root@zhou bin]# rpm -qa | grep mariadb
mariadb-10.3.9-8.ky10.x86_64
mariadb-server-10.3.9-8.ky10.x86_64
mariadb-common-10.3.9-8.ky10.x86_64
mariadb-errmessage-10.3.9-8.ky10.x86_64
mariadb-connector-c-3.0.6-6.ky10.x86_64

[root@zhou bin]# rpm -e --nodeps mariadb-10.3.9-8.ky10.x86_64
[root@zhou bin]# rpm -e --nodeps mariadb-server-10.3.9-8.ky10.x86_64
[root@zhou bin]# rpm -e --nodeps mariadb-common-10.3.9-8.ky10.x86_64
[root@zhou bin]# rpm -e --nodeps mariadb-errmessage-10.3.9-8.ky10.x86_64
[root@zhou bin]# rpm -e --nodeps mariadb-connector-c-3.0.6-6.ky10.x86_64
```

**2、下载并上传mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz到服务器/usr/local目录**

https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz

**3、添加mysql组和mysql用户**

```shell
groupadd mysql
useradd -r -g mysql mysql
```

-r 参数表示mysql用户是系统用户，不可用于登录系统。

-g 参数表示把mysql用户添加到mysql用户组中。

**4、解压mysql安装包到指定的目录 /usr/local**

```shell
cd /usr/local //进入目录
tar -zxvf mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz
```

**5、将解压后的目录改名为mysql**

```shell
mv mysql-5.7.36-linux-glibc2.12-x86_64 mysql
```

**6、更改权限**

```shell
chown -R mysql:mysql mysql/
```

**7、创建配置文件vim /etc/my.cnf**

```cnf
[client]
# 设置mysql客户端默认字符集
default-character-set = utf8mb4
#如果不设置会报错ERROR 2002 (HY000): Can't connect to local MySQL server through socket
socket=/data/mysql57/data/mysql.sock

[mysqld]
#设置3306端口
port=3306
character-set-server = utf8mb4

# 设置mysql的安装目录
basedir=/usr/local/mysql

# 设置mysql数据库的数据的存放目录
datadir=/data/mysql57/data
socket=/data/mysql57/data/mysql.sock

# 禁用主机名解析
skip-name-resolve

# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
lower_case_table_names=1

# 过小可能会导致写入(导入)数据失败
max_allowed_packet = 256M
group_concat_max_len = 10240

# 允许最大连接数
max_connections=200

# 提到 join 的效率
join_buffer_size = 16M
# 事务日志大小
innodb_log_file_size = 256M
# 日志缓冲区大小
innodb_log_buffer_size = 4M
# 事务在内存中的缓冲
innodb_log_buffer_size = 3M

[mysqldump]
# 开启快速导出
quick
default-character-set = utf8mb4
max_allowed_packet = 256M
```

**8、创建目录，改变权限**

```shell
#递归创建目录
[root@zhou mysql]# mkdir -p /data/mysql57/data
#更改权限
[root@zhou mysql]## chown -R mysql:mysql /data/mysql57/data
#初始化数据库，记下最后一行的密码（牢记初次登录需要）
[root@zhou mysql]#  bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql57/data
2022-06-06T13:25:18.167714Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
 100 200
 100 200
2022-06-06T13:25:18.805252Z 0 [Warning] InnoDB: New log files created, LSN=45790
2022-06-06T13:25:18.834456Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2022-06-06T13:25:18.890107Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 1bfd846a-e59c-11ec-a37c-000c2966cbfa.
2022-06-06T13:25:18.890947Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2022-06-06T13:25:19.568868Z 0 [Warning] A deprecated TLS version TLSv1 is enabled. Please use TLSv1.2 or higher.
2022-06-06T13:25:19.569096Z 0 [Warning] A deprecated TLS version TLSv1.1 is enabled. Please use TLSv1.2 or higher.
2022-06-06T13:25:19.569752Z 0 [Warning] CA certificate ca.pem is self signed.
2022-06-06T13:25:19.990378Z 1 [Note] A temporary password is generated for root@localhost: eUp>B%K!e8zJ
```

**9、启动数据库**

```shell
#源目录启动数据库
[root@zhou mysql]# /usr/local/mysql/support-files/mysql.server start
Starting MySQL.Logging to '/data/mysql57/data/zhou.err'.
. SUCCESS!
```

**10、设置自动启动mysql**

```shell
# 复制启动脚本到资源目录
[root@zhou mysql]# cp /usr/local/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld
# 增加mysqld服务控制脚本执行权限
[root@zhou mysql]# chmod +x /etc/rc.d/init.d/mysqld
#将mysqld添加到系统服务，并检查是否生效
[root@zhou mysql]# chkconfig --add mysqld
[root@zhou mysql]# chkconfig --list mysqld
注意：该输出结果只显示 SysV 服务，并不包含原生 systemd 服务。SysV 配置数据可能被原生 systemd 配置覆盖。如果您想列出 systemd 服务,请执行 'systemctl list-unit-files'。欲查看对特定 target 启用的服务请执行'systemctl list-dependencies [target]'。
mysqld 0:关1:关2:开3:开4:开5:开6:关
```

数字代表运行级别0：关机1：单用户模式2：无网络连接的多用户命令行模式3：有网络连接的多用户命令行模式4：保留级别5：带图形界面的多用户模式6：重新启动

```shell
#启动服务
[root@zhou mysql]# service mysqld start
Starting MySQL. SUCCESS!
#可以使用以下命令启动/停止/重启mysqld服务
service mysqld start/stop/restart
```

**11、登录mysql，修改初始密码和远程登录权限**

```shell
# 建立一个链接文件。因为系统默认会查找/usr/bin下的命令。
ln -s /usr/local/mysql/bin/mysql /usr/bin
#以root用户登录，输入系统产生的随机密码
[root@localhost mysql]# mysql -uroot -p
Enter password:
#登录以后，修改用户密码
```

```sql
#登录以后，修改用户密码
mysql> set password for root@localhost=password("123456");
#设置root远程登录
mysql> GRANT ALL PRIVILEGES ON *.* TO'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
Query OK, 0 rows affected, 1 warning (0.00 sec)
#更新权限
mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
```

**12、防火墙的设置**

```shell
mysql> exit; //退出mysql
#为firewalld添加开放mysql3306端口
[root@zhou mysql]# firewall-cmd --zone=public --add-port=3306/tcp --permanent
[root@zhou mysql]# firewall-cmd --reload //重启防火墙，上面开启的端口生效
#也可以使用关闭/开启防火墙
[root@zhou mysql]# systemctl stop/start firewalld.service //关闭防火墙
```

