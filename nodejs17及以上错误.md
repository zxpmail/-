```
Error: error:0308010C:digital envelope routines::unsupported
    at new Hash (node:internal/crypto/hash:67:19)
    at Object.createHash (node:crypto:133:10)
```

## 问题产生的起因

V17及上版本中最近发布的OpenSSL3.0, 而OpenSSL3.0对允许算法和[密钥](https://so.csdn.net/so/search?q=密钥&spm=1001.2101.3001.7020)大小增加了严格的限制，可能会对生态系统造成一些影响.

在node.js V17以前一些可以正常运行的的应用程序,但是在 V17 及上版本可能会抛出异常

## 解决办法

- 配置 node 选项--openssl-legacy-provider

windows 环境下

```bash
set NODE_OPTIONS=--openssl-legacy-provider
```

mac 或者 linux 环境下

```bash
export NODE_OPTIONS=--openssl-legacy-provider
```

- 降级 nodejs 版本到 16.x 以及以下版本

使用`nvm`

```bash
nvm install 16.13.0
```