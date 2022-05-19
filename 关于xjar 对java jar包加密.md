关于xjar 对java jar包加密

1、装go环境

https://dl.google.com/go/go1.18.2.windows-amd64.msi

```shell
1. yum install -y epel-release
2. yum install golang
```

2、下载xjar并编译

https://codeload.github.com/core-lib/loadkit/zip/refs/heads/master

https://codeload.github.com/core-lib/xjar/zip/refs/heads/master

3、编译并打包安装到maven仓库

4、建立加密源程序

```xml
        <dependency>
            <groupId>io.xjar</groupId>
            <artifactId>xjar</artifactId>
            <version>4.0.2</version>
        </dependency>
```

```java
    public static void main(String[] args) throws Exception {
        produce();
    }

    public static void produce() throws Exception {
        XCryptos.encryption()
                // 项目生成的jar
                .from("C:\\Users\\EDY\\Desktop\\test\\target\\test-1.0.jar")
                // 加密的密码
                .use("123")
                // 要加密的资源
                .include("/**/*.class")
                .include("/**/*.xml")
                .include("/**/*.yml")
                // 加密后的jar，此时：通过jd-gui反编译失败
                .to("C:\\Users\\EDY\\Desktop\\test\\target\\test.jar");
    }
```

5、编译脚本

```shell
go build xjar.go
```

#### 6. 启动运行

```shell
xjar java -jar test.jar
```

