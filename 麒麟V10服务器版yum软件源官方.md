**yum软件源配置**

编辑软件源 vi /etc/yum.repos.d/kylin_x86_64.repo

```repo
[ks10-adv-os]
name = Kylin Linux Advanced Server 10 - Os
baseurl = http://update.cs2c.com.cn:8080/NS/V10/V10SP1.1/os/adv/lic/base/x86_64/
gpgcheck=0
enable=1
```

清除缓存：yum clean all

建立缓存：yum makecache

接下来就可以搜索软件了，如redis

yum search redis

```shell
[root@zhou alg]# yum search redis
Last metadata expiration check: 0:00:09 ago on 2022年06月06日 星期一 16时56分44秒.
================================================== Name Exactly Matched: redis ==================================================
redis.x86_64 : A persistent key-value database
================================================= Name & Summary Matched: redis =================================================
pcp-pmda-redis.x86_64 : Redis PCP metrics
rsyslog-hiredis.x86_64 : Redis support for rsyslog
hiredis-devel.x86_64 : Development files for hiredis
hiredis.x86_64 : A minimalistic C client library for the Redis database
python2-redis.noarch : The Python2 interface to the Redis key-value store
python3-redis.noarch : The Python3 interface to the Redis key-value store

```

yum install redis 即可安装redis

