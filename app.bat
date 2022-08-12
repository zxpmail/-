@ECHO OFF 
@COLOR 0a
@SET currentDir=%~dp0
::����ȫ�ֱ���
call:ReadiniAndExecCmd global 0
rem ===============���ô���TITLE================================================================
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
		goto Menu
	)
	if /i not  "%TheOS%"=="Windows10" (
		@echo ���иó��������windows7����window10
		pause >nul
		goto End
	)
	
)
rem ===============���ò˵�����=========================================================================================
:Menu
	@set tm1=%time:~0,2%
	@set tm2=%time:~3,2%
	@set tm3=%time:~6,2%
	@TITLE һ����װ���� [%date% %tm1%:%tm2%:%tm3%]��
	CLS
	ECHO =========================================
	ECHO һ����װ����
	ECHO version:v2.0
	ECHO by zhouxp
	ECHO.
	ECHO ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
	ECHO.
	ECHO 1. �������ݿ�
	ECHO 2. ������Ŀ����
	ECHO 3. ֹͣ���ݿ�
	ECHO 4. ֹͣ��Ŀ����
	ECHO 5. ж�����ݿ�
	ECHO 6. �������ݿ�
	ECHO 0. �˳�
	ECHO =========================================
	ECHO.
rem ===============����ѡ����Ŀ����=====================================================================================
:Item
	SET Choice=
	SET /P Choice=ѡ��:
	rem �趨����"Choice"Ϊ�û�������ַ�
	IF NOT "%Choice%"=="" SET Choice=%Choice:~0,1%
	rem ����������1λ,ȡ��1λ,��������132,�򷵻�ֵΪ1
	ECHO.
	IF /I "%Choice%"=="1" GOTO StartDatabase
	IF /I "%Choice%"=="2" GOTO StartProjectServices
	IF /I "%Choice%"=="3" GOTO StopDatabase
	IF /I "%Choice%"=="4" GOTO StopProjectServices
	IF /I "%Choice%"=="5" GOTO UninstallDatabase
	IF /I "%Choice%"=="6" GOTO BackupDatabase
	IF /I "%Choice%"=="0" GOTO End
	rem Ϊ������ַ���ֵΪ�ջ򺬿ո�����³����쳣,���ڱ��������˫����
	rem ע��,IF�����Ҫ˫���ں�
	rem ���������ַ�������������,��������������
	ECHO ѡ����Ч������������...
	ECHO.
	GOTO Item	
rem ===============������Ŀ����======================================================================================
:StartProjectServices
	call:ReadiniAndExecCmd startproject 1
rem ===============ֹͣ��Ŀ����======================================================================================
:StopProjectServices
	call:ReadiniAndExecCmd endproject 2
pause
goto End

rem ===============�����ļ������ݲ�ִ�в���====================================================
:: ��ȡini����.%~1:����
:ReadiniAndExecCmd
	@set area=%~1
	@set cmd=%~2
	@setlocal enableextensions enabledelayedexpansion
	IF NOT EXIST "%currentDir%tool.ini" (@echo �����ļ������ڣ��������Ա��ϵ������& PAUSE & GOTO End )
	FOR /F "eol=; tokens=* delims==" %%a IN (%currentDir%tool.ini) DO (
		set  ln=%%a
		if "x!ln:~0,1!"=="x[" (
			set currarea=!ln:~1,-1!
			if !cmd!==2 (
			    if not "!currarea!"=="global" (
					@echo ����ֹͣ!currarea!
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
							rem �ȴ�5�룬pingһ��1��
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
		ECHO ִ����ɣ������������...
		PAUSE >nul
	)
	GOTO Menu
:StartDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO Install)
	NET START MySQL

	ECHO �����������...
	PAUSE >nul
	GOTO Menu

rem ===============2-1���ð�װMySQL����====================================================================================
:Install
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO Init) else goto Exist

rem ===============2-2���ð�װMySQL����ʼ������============================================================================
:Init
	rem ��װ���ݿ�
	@echo ��ʼ�����ݿ�
	@mysqld --initialize --console
	@echo ��ʼ��װ���ݿ�
	@mysqld install
	@net start MySQL
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
	@echo basedir=%dbpath%
	@echo # ����mysql���ݿ�����ݵĴ��Ŀ¼
	@echo datadir=%dbpath%\data
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
	) > "%dbpath%\my.ini"

	@net stop MySQL
	@net start MySQL

	@echo �������ļ���ṹ %importsql%
	@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% < %importsql% 2>nul

	if %ibd%==1 (
		@echo ʹ�ļ��ָ��ı�ռ�ʧЧ
		@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% < %failuretable% 2>nul

		@echo �ƶ�ibd�����ļ������ݿ���
		@copy %ibdpath%*.ibd  %dbpath%\data\%dbname%\

		@echo ʹ�������ݿ�����Ч
		@mysql -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% < %effectiveform% 2>nul
	)
	@echo ���ݿⰲװ�ɹ�
	ECHO �����������...
	PAUSE >nul
	GOTO Menu

rem ===============MySQL�������========================================================================================
:Exist
	echo �������
	ECHO �����������...
	PAUSE >nul
	GOTO Menu

rem ===============MySQL���񲻴���======================================================================================
:NotExist
	echo mysqlû�а�װ�����Ȱ�װMySQL 
	ECHO �����������...
	PAUSE >nul
	GOTO Menu
rem ===============4��ֹͣ���ݿ�========================================================================================
:StopDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO NotExist)
	NET STOP MySQL
	ECHO �����������...
	PAUSE >nul
	GOTO Menu
rem ===============6��ж�����ݿ�=======================================================================================
:UninstallDatabase
	sc query MySQL > nul
	if errorlevel 1060 ( GOTO NotExist)
	@netstat -ano | findstr ".*:3306\>" >nul
	if errorlevel  0 ( 
		ECHO ֹͣMySQL
		net stop MySQL
		ECHO ж��MySQL
		mysqld -remove MySQL
		@move %dbpath%\data\%dbname%\*.ibd  %ibdpath%
		rd /S /q %dbpath%\data
	)
	ECHO �����������...
	PAUSE >nul
	GOTO Menu
rem ================7���������ݿ�=======================================================================================
:BackupDatabase
	ECHO ��ʼ����.......
	mysqldump -h%dbhost% -u%dbuser% -p%dbpasswd% %dbname% --max_allowed_packet=268435456 --net_buffer_length=16384 --set-gtid-purged=OFF > %backupdir%%dbname%%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.sql
	ECHO �����Ѿ����,�����������...
	PAUSE >nul
	GOTO Menu	
rem ===============0�������˳�����======================================================================================
:End
	EXIT	