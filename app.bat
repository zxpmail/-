@ECHO OFF 
@COLOR 0a
@SET currentDir=%~dp0
::设置全局变量
call:ReadiniAndExecCmd global 0
rem ===============设置窗口TITLE================================================================
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
		goto Menu
	)
	if /i not  "%TheOS%"=="Windows10" (
		@echo 运行该程序必须是windows7或是window10
		pause >nul
		goto End
	)
	
)
rem ===============设置菜单函数=========================================================================================
:Menu
	@set tm1=%time:~0,2%
	@set tm2=%time:~3,2%
	@set tm3=%time:~6,2%
	@TITLE 一键安装工具 [%date% %tm1%:%tm2%:%tm3%]。
	CLS
	ECHO =========================================
	ECHO 一键安装工具
	ECHO version:v2.0
	ECHO by zhouxp
	ECHO.
	ECHO 请选择要进行的操作，然后按回车
	ECHO.
	ECHO 1. 启动数据库
	ECHO 2. 启动项目服务
	ECHO 3. 停止数据库
	ECHO 4. 停止项目服务
	ECHO 5. 卸载数据库
	ECHO 6. 备份数据库
	ECHO 0. 退出
	ECHO =========================================
	ECHO.
rem ===============设置选择项目函数=====================================================================================
:Item
	SET Choice=
	SET /P Choice=选择:
	rem 设定变量"Choice"为用户输入的字符
	IF NOT "%Choice%"=="" SET Choice=%Choice:~0,1%
	rem 如果输入大于1位,取第1位,比如输入132,则返回值为1
	ECHO.
	IF /I "%Choice%"=="1" GOTO StartDatabase
	IF /I "%Choice%"=="2" GOTO StartProjectServices
	IF /I "%Choice%"=="3" GOTO StopDatabase
	IF /I "%Choice%"=="4" GOTO StopProjectServices
	IF /I "%Choice%"=="5" GOTO UninstallDatabase
	IF /I "%Choice%"=="6" GOTO BackupDatabase
	IF /I "%Choice%"=="0" GOTO End
	rem 为避免出现返回值为空或含空格而导致程序异常,需在变量外另加双引号
	rem 注意,IF语句需要双等于号
	rem 如果输入的字符不是以上数字,将返回重新输入
	ECHO 选择无效，请重新输入...
	ECHO.
	GOTO Item	
rem ===============启动项目服务======================================================================================
:StartProjectServices
	call:ReadiniAndExecCmd startproject 1
rem ===============停止项目服务======================================================================================
:StopProjectServices
	call:ReadiniAndExecCmd endproject 2
pause
goto End

rem ===============配置文件中数据并执行操作====================================================
:: 读取ini配置.%~1:命令
:ReadiniAndExecCmd
	@set area=%~1
	@set cmd=%~2
	@setlocal enableextensions enabledelayedexpansion
	IF NOT EXIST "%currentDir%tool.ini" (@echo 配置文件不存在，请与管理员联系！！！& PAUSE & GOTO End )
	FOR /F "eol=; tokens=* delims==" %%a IN (%currentDir%tool.ini) DO (
		set  ln=%%a
		if "x!ln:~0,1!"=="x[" (
			set currarea=!ln:~1,-1!
			if !cmd!==2 (
			    if not "!currarea!"=="global" (
					@echo 正在停止!currarea!
					taskkill /f /t /im !currarea!* 2> nul 1>nul 
					ping -n 5 127.0.0.1>nul
				)
			)
		) else ( 
			for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
				set currkey=%%b
				set currval=%%c
				if "!area!"=="!currarea!" (				
					if "path"=="!currkey!" (
						set path=!path!;!currval!
					) else (
						set !currkey!=!currval!
					)
				) else (
					if !cmd!==1 (
						if "pro"=="!currkey!" (
							set pro=!currval!
						)
						if "param"=="!currkey!" (
							start !pro! !currval!
							rem 等待5秒，ping一次1秒
							ping -n 5 127.0.0.1>nul
						)
					)
				)
			)
		)
	)
	@setlocal disableDelayedexpansion
	@endlocal
	if not %cmd%==0 (
		ECHO 执行完成，按任意键继续...
		PAUSE >nul
	)
	GOTO Menu
:StartDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO Install)
	NET START MySQL

	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu

rem ===============2-1设置安装MySQL函数====================================================================================
:Install
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO Init) else goto Exist

rem ===============2-2设置安装MySQL并初始化函数============================================================================
:Init
	rem 安装数据库
	@echo 初始化数据库
	@mysqld --initialize --console
	@echo 开始安装数据库
	@mysqld install
	@net start MySQL
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
	@echo basedir=%dbpath%
	@echo # 设置mysql数据库的数据的存放目录
	@echo datadir=%dbpath%\data
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
	) > "%dbpath%\my.ini"

	@net stop MySQL
	@net start MySQL

	@echo 导入以文件表结构 %importsql%
	@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% < %importsql% 2>nul

	if %ibd%==1 (
		@echo 使文件恢复的表空间失效
		@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% < %failuretable% 2>nul

		@echo 移动ibd数据文件到数据库中
		@copy %ibdpath%*.ibd  %dbpath%\data\%dbname%\

		@echo 使表中数据库中生效
		@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% < %effectiveform% 2>nul
	)
	@echo 数据库安装成功
	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu

rem ===============MySQL服务存在========================================================================================
:Exist
	echo 服务存在
	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu

rem ===============MySQL服务不存在======================================================================================
:NotExist
	echo mysql没有安装，请先安装MySQL 
	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu
rem ===============4、停止数据库========================================================================================
:StopDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO NotExist)
	NET STOP MySQL
	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu
rem ===============6、卸载数据库=======================================================================================
:UninstallDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO NotExist)
	@netstat -ano | findstr ".*:3306\>" >nul
	if errorlevel  0 ( 
		ECHO 停止MySQL
		net stop MySQL
		ECHO 卸载MySQL
		mysqld -remove MySQL
		@move %dbpath%\data\%dbname%\*.ibd  %ibdpath%
		rd /S /q %dbpath%\data
	)
	ECHO 按任意键继续...
	PAUSE >nul
	GOTO Menu
rem ================7、备份数据库=======================================================================================
:BackupDatabase
	ECHO 开始备份.......
	mysqldump -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% --max_allowed_packet=268435456 --net_buffer_length=16384 --set-gtid-purged=OFF > %backupdir%%dbname%%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.sql
	ECHO 备份已经完成,按任意键继续...
	PAUSE >nul
	GOTO Menu	
rem ===============0、设置退出函数======================================================================================
:End
	EXIT	