

首先，感谢天朝的墙，我心中有一万个羊驼飘过，node把人差点整疯，npm、cnpm，yarn镜像不断换，node不断的重装，直到windows不断的蓝屏，重装。百度、谷歌几乎搜遍TMD终于搞定了，真累

1、安装最新的nodejs+npm +cnpm +yarn https://nodejs.org/en/

2、安装git环境，https://git-scm.com/

3、运行git-bash

4、npm install -g node-gyp

5、安装windows-build-tools

- 注意，安装这玩意有巨坑，非常我的网络环境下非常之慢，要查询[.NET Framework下载](https://dotnet.microsoft.com/download/visual-studio-sdks)

是否安装了吗，我用了4.6.2版本

```shell
npm install --global --production windows-build-tools
```

- 执行上面的命令可能依然很慢，网上说3小时以上，我等了24小时，还是他不动，我动了。。。。，这个问题有两种解决方案

  方案一

  ```
  在资源管理器中粘贴 %temp% 打开Windows temp目录
  创建一个名为 dd_client_.log 的文件
  写入 Closing installer. Return code: 3010. 然后保存文件
  ```

  方案二

  ```
  在用户的当前用户目录下的打开.windows-build-tools文件夹中的build-tools-log.txt，添加Variable: IsInstalled = 1，保存，关闭。
  ```

6、npm install nw-gyp -g

7、npm install node-pre-gyp -g

8、下载node-sqlite3源码 https://github.com/mapbox/node-sqlite3#building-for-node-webkit 解压到sqlite3目录或者用npm i sqlite3  我是用cnpm i sqlite3的 npm时好时坏或者换成淘宝源https://registry.npmmirror.com/（注意淘宝源上有些没有）

9、git-bash中进入sqlite3目录

10、编译

```
npm install --build-from-source --runtime=node-webkit --target_arch=x64 --target=0.65.0
```

- 注意这个玩意也是是个坑，我的网络也很慢很慢，这是我的处理方案如下：

```
我用的NW版本是0.65.0的，别的都一样
https://dl.nwjs.io/v0.65.0/
下载
nw-headers-v0.65.0.tar.gz
nw.lib
node.lib
x64/目录下两个文件
在下载nginx 把中几个文件及X64目录及文件复制到nginx/html/v0.65.0目录中
执行命令：npm install --build-from-source --runtime=node-webkit --target_arch=x64 --target=0.65.0 --dist-url=http://localhost
就可以编译成功了
```

11、就可以在你的NW项目中使用node了但我们不想用node-moudles下面有很多的小文件，我们就可以ncc编译我们js例如：我在网上抄了一段js代码sqlite3.js如下：

```js
var fs = require('fs');
var sqlite3 = require('sqlite3').verbose();
 
var DB = DB || {};
 
DB.SqliteDB = function(file){
    DB.db = new sqlite3.Database(file);
 
    DB.exist = fs.existsSync(file);
    if(!DB.exist){
        console.log("Creating db file!");
        fs.openSync(file, 'w');
    };
};
 
DB.printErrorInfo = function(err){
    console.log("Error Message:" + err.message + " ErrorNumber:" + errno);
};
 
DB.SqliteDB.prototype.createTable = function(sql){
    DB.db.serialize(function(){
        DB.db.run(sql, function(err){
            if(null != err){
                DB.printErrorInfo(err);
                return;
            }
        });
    });
};
 
/// tilesData format; [[level, column, row, content], [level, column, row, content]]
DB.SqliteDB.prototype.insertData = function(sql, objects){
    DB.db.serialize(function(){
        var stmt = DB.db.prepare(sql);
        for(var i = 0; i < objects.length; ++i){
            stmt.run(objects[i]);
        }
    
        stmt.finalize();
    });
};
 
DB.SqliteDB.prototype.queryData = function(sql, callback){
    DB.db.all(sql, function(err, rows){
        if(null != err){
            DB.printErrorInfo(err);
            return;
        }
 
        /// deal query data.
        if(callback){
            callback(rows);
        }
    });
};
 
DB.SqliteDB.prototype.executeSql = function(sql){
    DB.db.run(sql, function(err){
        if(null != err){
            DB.printErrorInfo(err);
        }
    });
};
 
DB.SqliteDB.prototype.close = function(){
    DB.db.close();
};
 
/// export SqliteDB.
exports.SqliteDB = DB.SqliteDB;
```

