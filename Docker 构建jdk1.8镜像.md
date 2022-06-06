1、拉取centos基础镜像

```shell
docker pull centos
```

2、下载jdk8安装包并上传至已创建的特定目录

```shell
[root@zhou jdk]# ll
总用量 190564
-rw-r--r-- 1 root root       625  6月  6 11:03 Dockerfile
-rw-r--r-- 1 root root 195132576  6月  6 10:33 jdk-8u251-linux-x64.tar.gz
```

 3、Dockerfile内容如下

```
FROM centos:latest

#2、指明该镜像的作者和电子邮箱
MAINTAINER zxp "151800757@qq.com"

#3、在构建镜像时，指定镜像的工作目录，之后的命令都是基于此工作目录，如果不存在，则会创建目录
WORKDIR /usr/local/jdk

#4、一个复制命令，把jdk安装文件复制到镜像中，语法 ADD SRC DEST ,ADD命令具有自动解压功能
ADD jdk-8u251-linux-x64.tar /usr/local/jdk

#5、配置环境变量，此处目录为tar.gz包解压后的名称，需提前解压知晓：
ENV JAVA_HOME=/usr/local/jdk/jdk1.8.0_251
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH=$JAVA_HOME/bin:$PATH

#6、设置启动命令
CMD ["java","-version"]

docker build -t jdk8:v1.0 .
docker run -itd --name jdk jdk8:v1.0 /bin/bash
```

4、在Dockerfile所在目录执行构建命令

```shell
docker build -t jdk8:v1.0 .
```

5、构建完成后查看镜像列表

```shell
[root@zhou jdk]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jdk8                v1.0                019c607c3ad4        3 hours ago         637MB
centos              latest              5d0da3dc9764        8 months ago        231MB
```

 6、通过镜像构建容器并后台启动，run具备create和start的功能。

```shell
[root@zhou jdk]# docker run -itd --name jdk jdk8:v1.0 /bin/bash
fcc49e4e63fa62a4e618ee4913ae3025038dbf7947922792de393434f8e0d96f
```

7、查看已运行容器列表

```shell

[root@zhou jdk]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS               NAMES
fcc49e4e63fa        jdk8:v1.0           "/bin/bash"         About a minute ago   Up About a minute                       jdk

```

8、查看jdk在容器内部是否生效，需进入容器内部执行。

```shell
[root@zhou jdk]# docker exec -it jdk /bin/bash
[root@fcc49e4e63fa local]# java -version
java version "1.8.0_251"
Java(TM) SE Runtime Environment (build 1.8.0_251-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.251-b08, mixed mode)
[root@fcc49e4e63fa local]#

```

9、退出容器：exit