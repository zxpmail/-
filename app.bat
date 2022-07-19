@echo off
@color f9

rem ===============��ȡ����ԱȨ��=======================================================================================
%1 %2
ver|find "5.">nul&&goto :Init
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :Init","","runas",1)(window.close)&goto :End
rem ============�ж��Ƿ���windowsϵͳ 64λ����ϵͳ win7��win10ϵͳ�Լ���ʼ������
:Init
	@set currentDir=%~dp0
	if /i not "%os%"=="Windows_NT" (
		@echo ���иó��������windows7����window10 64λ����ϵͳ
		pause >nul
		goto End
	) else (
		ver | find "6.1" > nul && set TheOS=Windows7
		ver | find "10.0"> nul && set TheOS=Windows10
	)
    if /i not "%PROCESSOR_ARCHITECTURE:~-2%"=="64" (
		@echo ���иó������64λ����ϵͳ
		pause >nul
		goto End
	) else (
		if /i "%TheOS%"=="Windows7" (
			move %currentDir%msvcp120.dll %systemroot%\system32 1>nul 2>nul
			move %currentDir%msvcr120.dll %systemroot%\system32 1>nul 2>nul
			goto Mysql
		)
		if /i not  "%TheOS%"=="Windows10" (
			@echo ���иó��������windows7����window10
			pause >nul
			goto End
		)
		
	)
rem ===============��ʼ��Mysql����=======================================================================================	
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
rem ===============����jdk����==============================================	
:Jdk
	if (%JAVA_HOME%)==() (
		setx JAVA_HOME "%currentDir%jdk1.8.0_131" /M
		setx path "%path%;%%JAVA_HOME%%\bin" /M
		setx CLASSPATH .;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar /M
	)
	@set javaw="%JAVA_HOME%\bin\javaw.exe"
	@set path=%JAVA_HOME%\bin;%path%

rem ===============�������ò˵�����=======================================================================================
:Menu
	rem ===============���ô���TITLE=======================================================================================
	@set tm1=%time:~0,2%
	@set tm2=%time:~3,2%
	@set tm3=%time:~6,2%
	@title һ����װApp���� [%date% %tm1%:%tm2%:%tm3%]��

	cls
	@echo =========================================
	@echo App һ����װ
	@echo version:v1.0
	@echo by zhouxp
	@echo.
	@echo ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
	@echo.
	@echo 1. ��װ App
	@echo 2. ж�� App
	@echo 3. ��������
	@echo 4. �ָ�����
	@echo 0. �˳�
	@echo =========================================
	@echo.
rem ===============����ѡ����Ŀ����=======================================================================================
:Item
	set Choice=
	set /P Choice=ѡ��:
	rem �趨����"Choice"Ϊ�û�������ַ�
	if not "%Choice%"=="" set Choice=%Choice:~0,1%
	rem ����������1λ,ȡ��1λ,��������132,�򷵻�ֵΪ1
	@echo.
	if /I "%Choice%"=="1" goto Install
	if /I "%Choice%"=="2" goto Uninstall
	if /I "%Choice%"=="3" goto Backup
	if /I "%Choice%"=="4" goto Restore
	if /I "%Choice%"=="0" goto End
	rem Ϊ������ַ���ֵΪ�ջ򺬿ո�����³����쳣,���ڱ��������˫����
	rem ע��,IF�����Ҫ˫���ں�
	rem ���������ַ�������������,��������������
	@echo ѡ����Ч������������...
	@echo.
	goto Item
rem ===============��װ App service=======================================================================================
:Install
	rem �ж��Ƿ��Ѿ���װmysql
	sc query MySQL > nul
	if errorlevel 1060 ( goto InstallMysql) else goto InstallServices
	rem ===============���ð�װMySQL����ʼ������=======================================================================================
:InstallMysql
	rem ��װ���ݿ�
	@echo ��ʼ�����ݿ�
	cd %currentDir%%mysqlpath%\bin
	@mysqld --initialize --console
	@echo ��ʼ��װ���ݿ�
	@mysqld install
	@net start MySQL
	cd %currentDir%
	rem ִ���޸�����Ϳ��ŷ���Ȩ�޵�SQLָ��

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
	rem �ָ�Ȩ����֤
	(
		@echo [mysqld]
		@echo # ����3306�˿�
		@echo port=3306
		@echo # ����mysql�İ�װĿ¼
		@echo basedir=%currentDir%%mysqlpath%
		@echo # ����mysql���ݿ�����ݵĴ��Ŀ¼
		@echo datadir=%currentDir%%mysqlpath%\data
		@echo # �������������
		@echo max_connections=200
		@echo # ��������ʧ�ܵĴ���������Ϊ�˷�ֹ���˴Ӹ�������ͼ�������ݿ�ϵͳ
		@echo max_connect_errors=10
		@echo # �����ʹ�õ��ַ���Ĭ��ΪUTF8
		@echo character-set-server=utf8
		@echo # �����±�ʱ��ʹ�õ�Ĭ�ϴ洢����
		@echo default-storage-engine=INNODB
		@echo # Ĭ��ʹ�á�mysql_native_password�������֤
		@echo default_authentication_plugin=mysql_native_password
		@echo skip-grant-tables
		@echo [mysql]
		@echo # ����mysql�ͻ���Ĭ���ַ���
		@echo default-character-set=utf8
		@echo [client]
		@echo # ����mysql�ͻ������ӷ����ʱĬ��ʹ�õĶ˿�
		@echo port=3306
		@echo default-character-set=utf8
	) > "%currentDir%my.ini"
	@move /Y %currentDir%my.ini %currentDir%%mysqlpath%\my.ini >nul

	@net stop MySQL
	@net start MySQL
	@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% < %currentDir%hos.sql 2>nul
	@echo ���ݿⰲװ�ɹ�
	goto InstallServices
rem ===============��װ����==============================================
:InstallService
	@echo ******����%~1����******
	@set exist=0
	tasklist|find/c  "%~2.exe" >nul && set exist=1
	@set app="%JAVA_HOME%\bin\%~2"
	@set exe=%~3
	if %exist%==0 (
		if %exe%==1 (
			start  %currentDir%%~1\%~2.exe %~4
		) else (
			rem �����ļ�
			
			if not exist %app% (
				copy %javaw% %app%
			)
			start %~2 -jar %currentDir%%~2.jar
		)
		rem �ȴ�8�룬pingһ��1��
		ping -n 8 127.0.0.1>nul
	)
	goto:eof
rem ===============��װ�����б�==============================================
:InstallServices
	set javaw="%JAVA_HOME%\bin\javaw.exe"
	call :InstallService ע������ hgd-eureka 0
	call :InstallService ���� hgd-gateway 0
	call :InstallService redis redis-server 1 
	call :InstallService nginx nginx 1 "-p %currentDir%nginx" 
	echo �����������...
	pause >nul
	goto Menu
:Uninstall
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 ( 
		echo ֹͣMySQL
		net stop MySQL
		echo ж��MySQL
		mysqld -remove MySQL
		@echo off
		rd /S /q %currentDir%%mysqlpath%\data
		@echo Y|PowerShell.exe -NoProfile -Command Clear-RecycleBin 2>nul
	)
	echo ******���ڹر����س���******
	taskkill /f /t /im hgd-gateway.exe 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******���ڹر�ע�����ĳ���******
	taskkill /f /t /im hgd-eureka.exe 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******���ڹر�nginx����******
	taskkill /f /t /im nginx* 2>nul 
	ping -n 3 127.0.0.1>nul
	echo ******���ڹر�redis����******
	taskkill /f /t /im redis* 2>nul 
	ping -n 4 127.0.0.1>nul
	echo �����������...
	pause >nul
	goto Menu
rem ================�������ݿ�============================================================================
:Backup
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 ( 
		@echo ��ʼ����.......
		rem ע�⣺��mysql���������ִ��max_allowed_packet��net_buffer_lengthʹ�ĵ��뵼�����ݱ��
		rem show variables like 'max_allowed_packet'; �õ�max_allowed_packet��С
		rem show variables like 'net_buffer_length';�õ�net_buffer_length��С
		rem max_allowed_packet��net_buffer_length�Ĵ�С���ܳ���Ŀ�����ݿ����������Ĵ�С
		mysqldump -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd --max_allowed_packet=4194304--net_buffer_length=16384 --set-gtid-purged=OFF > %currentDir%stk_v2_hgd%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.sql
		@echo �����Ѿ����,�����������...
		pause >nul
	) else (
		goto NotExist
	)
	goto Menu
rem ================�������ݿ�============================================================================
:Restore
	set exist=0
	tasklist|find /c "mysqld.exe" >nul && set exist=1
	if %exist%==1 (
		set /p var=������Ҫ�ָ������ݿ��ļ� :  
		if not exist %currentDir%%var% (
			@echo ���� %currentDir%%var% �ļ�������,�����������...
			pause >nul
			goto Restore
		)
		@echo ��ʼ�ָ�.......
		mysql -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd < %currentDir%%var% 2>nul
		@echo �ָ������Ѿ����,�����������...
		pause >nul
	) else (
		goto NotExist
	)
	goto Menu
rem ===============MySQL���񲻴���=======================================================================================
:NotExist
	@echo mysqlû�а�װ�����Ȱ�װMySQL 
	@echo �����������...
	pause >nul
	goto Menu
rem ===============�����˳�����=======================================================================================
:End
	exit