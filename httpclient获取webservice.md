一、建立webservice服务器

1、建立服务实现类

```java
public class MyServiceImpl  implements MyService {

    @Override
    public R authorization(@WebParam(name = "userId") String userId,
                           @WebParam(name = "password") String password) throws IOException {
        R r = new R();
        if ("admin".equals(userId) && "123456".equals(password)) {


            List<String> list;
            list = new ArrayList<>();
            list.add("z1");
            list.add("z2");
            r.setCode(200);
            r.setMsg("成功");
            r.setData(list);
        }else{
            r.setCode(500);
            r.setMsg("失败");
        }
        return r;

    }
}
```

2、建立发布服务

```java
public class MyPublisher {
    public static void main(String[] args) {
        //指定服务url
        String url = "http://127.0.0.1:8089/myservice";
        //指定服务实现类
        MyService server = new MyServiceImpl();
        //采用命令行发布者Endpoint发布服务
        Endpoint.publish(url, server);
    }
}
```

二、用原生java生产webservice客户端

命令：

```shell
wsimport -d d:/webservice -keep -p cn.piesat.test.wsimportClient -verbose http://localhost:8089/myservice?wsdl
```

结果：

```
 D:\webservice\cn\piesat\test\wsimportClient 的目录

2022/06/07  09:50    <DIR>          .
2022/06/07  09:50    <DIR>          ..
2022/06/07  09:50             1,921 Authorization.java
2022/06/07  09:50             1,392 AuthorizationResponse.java
2022/06/07  09:50             1,317 IOException.java
2022/06/07  09:50             1,159 IOException_Exception.java
2022/06/07  09:50             1,717 Login.java
2022/06/07  09:50             2,868 MyService.java
2022/06/07  09:50             3,322 ObjectFactory.java
2022/06/07  09:50               116 package-info.java
2022/06/07  09:50             2,911 R.java
               9 个文件         16,723 字节
               2 个目录 313,829,773,312 可用字节
```

把生产的结果复制到客户端程序中

建立客户端主程序

```java
public class WsClient {
    public static void main(String[] args) throws IOException_Exception {
        MyService service = new MyService();
        Login login = service.getLoginPort();

        R r = login.authorization("admin", "123456");
        System.out.println(r);
    }

}
```

执行结果：

```
R(code=200, data=[z1, z2], msg=成功)
```

三、用httpclient方式进行操作

1、下载soapui

https://www.soapui.org/downloads/soapui/soapui-os-older-versions/

在soapui中输入[127.0.0.1](http://127.0.0.1:8089/myservice?wsdl)

![1654569792382](C:\Users\EDY\AppData\Roaming\Typora\typora-user-images\1654569792382.png)

在用httpclient处理

```java
public class SoapClient {
    public static void main(String[] args) {
        //soap服务地址
        String url = "http://localhost:8089/myservice?wsdl";
        StringBuilder soapBuilder = new StringBuilder(64);
        soapBuilder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        soapBuilder.append("<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:my=\"http://cn.piesat.ws/my\">");
        soapBuilder.append("   <soapenv:Header/>");
        soapBuilder.append("        <soapenv:Body>");
        soapBuilder.append("              <my:authorization>");
        soapBuilder.append("                     <userId>").append("admin").append("</userId>");
        soapBuilder.append("                     <password>").append("123456").append("</password>");
        soapBuilder.append("                </my:authorization>");
        soapBuilder.append("    </soapenv:Body>");
        soapBuilder.append("</soapenv:Envelope>");
        //创建httpcleint对象
        CloseableHttpClient httpClient = HttpClients.createDefault();
        //创建http Post请求
        HttpPost httpPost = new HttpPost(url);
        /**
         * 构建请求配置信息
         * 创建连接的最长时间 1000
         * 从连接池中获取到连接的最长时间 500
         * 数据传输的最长时间3s
         */
        RequestConfig config = RequestConfig.custom().setConnectTimeout(1000)
                .setConnectionRequestTimeout(500)
                .setSocketTimeout(3 * 1000)
                .build();
        httpPost.setConfig(config);
        CloseableHttpResponse response = null;

        //采用SOAP1.1调用服务端，这种方式能调用服务端为soap1.1和soap1.2的服务
        httpPost.setHeader("Content-Type", "text/xml;charset=UTF-8");

        //采用SOAP1.2调用服务端，这种方式只能调用服务端为soap1.2的服务
        StringEntity stringEntity = new StringEntity(soapBuilder.toString(), StandardCharsets.UTF_8);
        httpPost.setEntity(stringEntity);
        try {
            response = httpClient.execute(httpPost);
            // 判断返回状态是否为200
            if (response.getStatusLine().getStatusCode() == 200) {
                String content = EntityUtils.toString(response.getEntity(), "UTF-8");
                Document soapRes = Jsoup.parse(content);
                Elements returnEle = soapRes.getElementsByTag("return");

                JSONObject aReturn = XML.toJSONObject(returnEle.toString()).getJSONObject("return");
                Result r =new Result();
                BeanUtils.populate(r,aReturn.toMap());
                System.out.println(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            if (null != response) {
                try {
                    response.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != httpClient) {
                try {
                    httpClient.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

```

结果：

Result(code=200, msg=成功, data=[z1, z2])

