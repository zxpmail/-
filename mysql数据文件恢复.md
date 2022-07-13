

# mysql 通过拷贝data文件夹进行恢复

```
解决了，确实可以通过拷贝data文件夹进行恢复。

1. 删掉现有的data文件夹（先备份一份）
2. 将需要恢复的data文件夹放到对应位置
3. 修改my.cnf，加入innodb_force_recovery=4或者6
4. 直接启动，注意err文件的报错
5. 有可能报一些权限上的错误，逐条修改即可
6. 启动之后直接mysqldump，赶紧恢复数据
7. 成功
注意mysql版本号和data权限！
chmod data
chown -R mysql:mysql data
来自http://t.zoukankan.com/jamescr7-p-7843452.html没有亲自测试
```

## 1、恢复步骤概要

- 备份frm、ibd文件
- 如果mysql版本发生变化，安装回原本的mysql版本
- 创建和原本库名一致新库，字符集都要保持一样
- 通过frm获取到原先的表结构，通过的得到的表结构创建一个和原先结构一样的空表。
- 使用“ALTER TABLE DISCARD TABLESPACE;”命令卸载掉表空间
- 将原先的ibd拷贝到mysql的仓库下
- 添加用户权限 “chown . .ibd”,如果是操作和mysql的使用权限一致可以跳过
- 通过“ALTER TABLE IMPORT TABLESPACE;”命令恢复表空间
- 完成





## 2、实际操作



**1）备份文件**



```
mkdir /usr/local/backup
cp * /usr/local/backup
```



**2）安装原本版本的数据库**



略



**3）创建和原本一致的库**



创建和原本库名一致新库，字符集都要保持一样



**4）frm获取到原先的表结构**



这里使用dbsake读取frm的表结构



- dbsake安装



```
#下载
curl -s get.dbsake.net > dbsake
#添加执行权限
chmod u+x dbsake
```



- 使用dbsake读取表结构



```
#基础使用
./dbsake frmdump [frm-file-path]

#将所有读取结果输入到文件中
./dbsake frmdump [frm-file-path] > <文件名>
例如：
./dbsake frmdump student.frm teacher.frm > school.txt
```



- 恢复表结构



文件中存放的是frm对应表结构的sql，直接复制出来运行就行了，此时数据库中所有的结构都恢复了，就是还没有数据



**5）卸载表空间**



在mysql中执行命令，卸载掉表空间



```
ALTER TABLE <tabelName> DISCARD TABLESPACE;

例如：
ALTER TABLE student DISCARD TABLESPACE;
ALTER TABLE teacher DISCARD TABLESPACE;
```



**6）拷贝原本的ibd，到新的库中**



- 确定新数据库的数据存放位置



在mysql中执行命令



```
show variables like 'datadir';
```



进入对应文件夹中，会有一个和需要恢复的数据库名完全一样的文件夹，进入文件夹



- 将ibd文件复制过来



cp命令直接复制过来就行了



**7）命令恢复表空间**



在mysql执行命令，恢复表空间



```
ALTER TABLE <tabelName> IMPORT TABLESPACE;

例如：
ALTER TABLE student IMPORT TABLESPACE;
ALTER TABLE teacher IMPORT TABLESPACE;
```



**8）完成**



如果mysql有什么特别配置，还需要在添加一下，比如：原本的用户账户、原先配置的sql_mode等等

来自：https://www.csdn.net/tags/MtTaEg3sMDIxMi1ibG9n.html 亲自测试过