@echo off
@color f9

rem ===============获取管理员权限=======================================================================================
%1 %2
ver|find "5.">nul&&goto :Init
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :Init","","runas",1)(window.close)&goto :End
rem ============判断是否是windows系统 64位操作系统 win7或win10系统以及初始化变量
:Init
	@set currentDir=%~dp0
	if /i not "%os%"=="Windows_NT" (
		@echo 运行该程序必须是windows7或是window10 64位操作系统
		pause >nul
		goto End
	) else (
		ver | find "6.1" > nul && set TheOS=Windows7
		ver | find "10.0"> nul && set TheOS=Windows10
	)
    if /i not "%PROCESSOR_ARCHITECTURE:~-2%"=="64" (
		@echo 运行该程序必须64位操作系统
		pause >nul
		goto End
	) else (
		if /i "%TheOS%"=="Windows7" (
			move %currentDir%msvcp120.dll %systemroot%\system32 1>nul 2>nul
			move %currentDir%msvcr120.dll %systemroot%\system32 1>nul 2>nul
			goto Mysql
		)
		if /i not  "%TheOS%"=="Windows10" (
			@echo 运行该程序必须是windows7或是window10
			pause >nul
			goto End
		)
		
	)
rem ===============初始化Mysql变量=======================================================================================	
:Mysql
	@set dbhost=127.0.0.1
	@set dbuser=root
	@set dbpasswd=123456
	@set currentDir=%~dp0
	@set mysqlpath=mysql-5.7.38-winx64
	if (%MYSQL_HOME%)==() (
		@setx /M MYSQL_HOME "%currentDir%%mysqlpath%
		@setx path "%path%;%%MYSQL_HOME%%\bin" /M
	)
	@set path=%MYSQL_HOME%\bin;%path%
rem ===============设置jdk环境==============================================	
:Jdk
	if (%JAVA_HOME%)==() (
		setx JAVA_HOME "%currentDir%jdk1.8.0_131" /M
		setx path "%path%;%%JAVA_HOME%%\bin" /M
		setx CLASSPATH .;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar /M
	)
	@set javaw="%JAVA_HOME%\bin\javaw.exe"
	@set path=%JAVA_HOME%\bin;%path%

rem ===============设置设置菜单函数=======================================================================================
:Menu
	rem ===============设置窗口TITLE=======================================================================================
	@set tm1=%time:~0,2%
	@set tm2=%time:~3,2%
	@set tm3=%time:~6,2%
	@title 一键安装App工具 [%date% %tm1%:%tm2%:%tm3%]。

	cls
	@echo =========================================
	@echo App 一键安装
	@echo version:v1.0
	@echo by zhouxp
	@echo.
	@echo 请选择要进行的操作，然后按回车
	@echo.
	@echo 1. 安装 App
	@echo 2. 卸载 App
	@echo 3. 备份数据
	@echo 4. 恢复数据
	@echo 0. 退出
	@echo =========================================
	@echo.
rem ===============设置选择项目函数=======================================================================================
:Item
	set Choice=
	set /P Choice=选择:
	rem 设定变量"Choice"为用户输入的字符
	if not "%Choice%"=="" set Choice=%Choice:~0,1%
	rem 如果输入大于1位,取第1位,比如输入132,则返回值为1
	@echo.
	if /I "%Choice%"=="1" goto Install
	if /I "%Choice%"=="2" goto Uninstall
	if /I "%Choice%"=="3" goto Backup
	if /I "%Choice%"=="4" goto Restore
	if /I "%Choice%"=="0" goto End
	rem 为避免出现返回值为空或含空格而导致程序异常,需在变量外另加双引号
	rem 注意,IF语句需要双等于号
	rem 如果输入的字符不是以上数字,将返回重新输入
	@echo 选择无效，请重新输入...
	@echo.
	goto Item
rem ===============安装 App service=======================================================================================
:Install
	rem 判断是否已经安装mysql
	sc query MySQL > nul
	if errorlevel 1060 ( goto InstallMysql) else goto InstallServices
	rem ===============设置安装MySQL并初始化函数=======================================================================================
:InstallMysql
	rem 安装数据库
	@echo 初始化数据库
	cd %currentDir%%mysqlpath%\bin
	@mysqld --initialize --console
	@echo 开始安装数据库
	@mysqld install
	@net start MySQL
	cd %currentDir%
	rem 执行修改密码和开放访问权限的SQL指令

	set initsql=%currentDir%init.sql
	(
		@echo use mysql;
		@echo flush privileges;
		@echo set password for root@localhost = password('%dbpasswd%'^);
		@echo CREATE USER 'root'@'%' IDENTIFIED BY 'root';
		@echo GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
		@echo flush privileges;
		@echo quit
	) > %initsql%

	@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% <  %initsql% --default-character-set=utf8

	@del /Q %initsql%
	rem 恢复权限验证
	(
		@echo [mysqld]
		@echo # 设置3306端口
		@echo port=3306
		@echo # 设置mysql的安装目录
		@echo basedir=%currentDir%%mysqlpath%
		@echo # 设置mysql数据库的数据的存放目录
		@echo datadir=%currentDir%%mysqlpath%\data
		@echo # 允许最大连接数
		@echo max_connections=200
		@echo # 允许连接失败的次数。这是为了防止有人从该主机试图攻击数据库系统
		@echo max_connect_errors=10
		@echo # 服务端使用的字符集默认为UTF8
		@echo character-set-server=utf8
		@echo # 创建新表时将使用的默认存储引擎
		@echo default-storage-engine=INNODB
		@echo # 默认使用“mysql_native_password”插件认证
		@echo default_authentication_plugin=mysql_native_password
		@echo skip-grant-tables
		@echo [mysql]
		@echo # 设置mysql客户端默认字符集
		@echo default-character-set=utf8
		@echo [client]
		@echo # 设置mysql客户端连接服务端时默认使用的端口
		@echo port=3306
		@echo default-character-set=utf8
	) > "%currentDir%my.ini"
	@move /Y %currentDir%my.ini %currentDir%%mysqlpath%\my.ini >nul

	@net stop MySQL
	@net start MySQL
	@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% < %currentDir%hos.sql 2>nul
	@echo 数据库安装成功
	goto InstallServices
rem ===============安装服务==============================================
:InstallService
	@echo ******启动%~1程序******
	@set exist=0
	tasklist|find/c  "%~2.exe" >nul && set exist=1
	@set app="%JAVA_HOME%\bin\%~2"
	@set exe=%~3
	if %exist%==0 (
		if %exe%==1 (
			start  %currentDir%%~1\%~2.exe %~4
		) else (
			rem 复制文件
			
			if not exist %app% (
				copy %javaw% %app%
			)
			start %~2 -jar %currentDir%%~2.jar
		)
		rem 等待8秒，ping一次1秒
		ping -n 8 127.0.0.1>nul
	)
	goto:eof
rem ===============安装服务列表==============================================
:InstallServices
	set javaw="%JAVA_HOME%\bin\javaw.exe"
	call :InstallService 注册中心 hgd-eureka 0
	call :InstallService 网关 hgd-gateway 0
	call :InstallService redis redis-server 1 
	call :InstallService nginx nginx 1 "-p %currentDir%nginx" 
	echo 按任意键继续...
	pause >nul
	goto Menu
:Uninstall
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 ( 
		echo 停止MySQL
		net stop MySQL
		echo 卸载MySQL
		mysqld -remove MySQL
		@echo off
		rd /S /q %currentDir%%mysqlpath%\data
		@echo Y|PowerShell.exe -NoProfile -Command Clear-RecycleBin 2>nul
	)
	echo ******正在关闭网关程序******
	taskkill /f /t /im hgd-gateway.exe 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******正在关闭注册中心程序******
	taskkill /f /t /im hgd-eureka.exe 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******正在关闭nginx程序******
	taskkill /f /t /im nginx* 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******正在关闭redis程序******
	taskkill /f /t /im redis* 2>nul 
	ping -n 4 127.0.0.1>nul
	echo 按任意键继续...
	pause >nul
	goto Menu
rem ================备份数据库============================================================================
:Backup
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 ( 
		@echo 开始备份.......
		rem 注意：在mysql的命令窗口中执行max_allowed_packet和net_buffer_length使的导入导出数据变快
		rem show variables like 'max_allowed_packet'; 得到max_allowed_packet大小
		rem show variables like 'net_buffer_length';得到net_buffer_length大小
		rem max_allowed_packet和net_buffer_length的大小不能超过目标数据库两个参数的大小
		mysqldump -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd --max_allowed_packet=4194304--net_buffer_length=16384 --set-gtid-purged=OFF > %currentDir%stk_v2_hgd%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.sql
		@echo 备份已经完成,按任意键继续...
		pause >nul
	) else (
		goto NotExist
	)
	goto Menu
rem ================备份数据库============================================================================
:Restore
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 (
		set /p var=请输入要恢复的数据库文件 :  
		if not exist %currentDir%%var% (
			@echo 数据 %currentDir%%var% 文件不存在,按任意键继续...
			pause >nul
			goto Restore
		)
		@echo 开始恢复.......
		mysql -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd < %currentDir%%var% 2>nul
		@echo 恢复数据已经完成,按任意键继续...
		pause >nul
	) else (
		goto NotExist
	)
	goto Menu
rem ===============MySQL服务不存在=======================================================================================
:NotExist
	@echo mysql没有安装，请先安装MySQL 
	@echo 按任意键继续...
	pause >nul
	goto Menu
rem ===============设置退出函数=======================================================================================
:End
	exit