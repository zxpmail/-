@Echo OFF

@color 02
rem ===============��ȡ����ԱȨ��=======================================================================================
%1 %2
ver|find "5.">nul&&goto :Admin
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :Admin","","runas",1)(window.close)&goto :eof
:Admin
rem ===============���û�������=======================================================================================
@SET dbhost=127.0.0.1
@SET dbuser=root
@SET dbpasswd=123456
set currentDir=%~dp0
set mysqlpath=mysql-5.7.38-winx64
if (%MYSQL_HOME%)==() (
    @setx /M MYSQL_HOME "%currentDir%%mysqlpath%
	@setx path "%path%;%%MYSQL_HOME%%\bin" /M
)

@set path=%MYSQL_HOME%\bin;%path%
rem ===============���ô���TITLE=======================================================================================
@set tm1=%time:~0,2%
@set tm2=%time:~3,2%
@set tm3=%time:~6,2%
@TITLE һ����װMySQL���� [%date% %tm1%:%tm2%:%tm3%]��

rem ===============���ò˵�����=======================================================================================
:Menu
CLS
ECHO =========================================
ECHO MySQL һ����װ
ECHO version:v0.1
ECHO by zhouxp
ECHO.
ECHO ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
ECHO.
ECHO 1. ��װMySQL
ECHO 2. ж��MySQL
ECHO 3. ����MySQL
ECHO 4. ֹͣMySQL
ECHO 5. ��������
ECHO 6. �ָ�����
ECHO 0. �˳�
ECHO =========================================
ECHO.
rem ===============����ѡ����Ŀ����=======================================================================================
:Item
SET Choice=
SET /P Choice=ѡ��:
rem �趨����"Choice"Ϊ�û�������ַ�
IF NOT "%Choice%"=="" SET Choice=%Choice:~0,1%
rem ����������1λ,ȡ��1λ,��������132,�򷵻�ֵΪ1
ECHO.
IF /I "%Choice%"=="1" GOTO Install
IF /I "%Choice%"=="2" GOTO Uninstall
IF /I "%Choice%"=="3" GOTO Start
IF /I "%Choice%"=="4" GOTO Stop
IF /I "%Choice%"=="5" GOTO Backup
IF /I "%Choice%"=="6" GOTO Restore
IF /I "%Choice%"=="0" GOTO End
rem Ϊ������ַ���ֵΪ�ջ򺬿ո�����³����쳣,���ڱ��������˫����
rem ע��,IF�����Ҫ˫���ں�
rem ���������ַ�������������,��������������
ECHO ѡ����Ч������������...
ECHO.
GOTO Item

rem ===============��������MySQL����=======================================================================================
:Start
sc query MySQL > nul
if errorlevel 1060 ( GOTO NotExist)
NET START MySQL
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ===============����ֹͣMySQL����=======================================================================================
:Stop
sc query MySQL > nul
if errorlevel 1060 ( GOTO NotExist)
NET STOP MySQL
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ===============���ð�װMySQL����=======================================================================================
:Install
sc query MySQL > nul
if errorlevel 1060 ( GOTO Init) else goto Exist
rem ===============���ð�װMySQL����ʼ������=======================================================================================
:Init
rem ��װ���ݿ�
@echo ��ʼ�����ݿ�
cd %currentDir%%mysqlpath%\bin
@mysqld --initialize --console
@echo ��ʼ��װ���ݿ�
@mysqld install
@net start MySQL
cd %currentDir
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
@ECHO ���ݿⰲװ�ɹ�
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ===============MySQL�������=======================================================================================
:Exist
echo �������
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ===============MySQL���񲻴���=======================================================================================
:NotExist
echo mysqlû�а�װ�����Ȱ�װMySQL 
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ===============����ж��MySQL����=======================================================================================
:Uninstall
sc query MySQL > nul
if errorlevel 1060 ( GOTO NotExist)
@netstat -ano | findstr ".*:3306\>" >nul
if errorlevel  0 ( 
ECHO ֹͣMySQL
net stop MySQL
ECHO ж��MySQL
mysqld -remove MySQL
@echo off
rd /S /q %currentDir%%mysqlpath%\data
@echo Y|PowerShell.exe -NoProfile -Command Clear-RecycleBin 2>nul
)
ECHO 
ECHO �����������...
PAUSE >nul
GOTO Menu

rem ================�������ݿ�============================================================================
:Backup
ECHO ��ʼ����.......
rem ע�⣺��mysql���������ִ��max_allowed_packet��net_buffer_lengthʹ�ĵ��뵼�����ݱ��
rem show variables like 'max_allowed_packet'; �õ�max_allowed_packet��С
rem show variables like 'net_buffer_length';�õ�net_buffer_length��С
rem max_allowed_packet��net_buffer_length�Ĵ�С���ܳ���Ŀ�����ݿ����������Ĵ�С
mysqldump -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd --max_allowed_packet=4194304--net_buffer_length=16384 --set-gtid-purged=OFF > %currentDir%stk_v2_hgd%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.sql
ECHO �����Ѿ����,�����������...
PAUSE >nul
GOTO Menu
rem ================�������ݿ�============================================================================
:Restore
@echo off
set /p var=������Ҫ�ָ������ݿ��ļ� :  
if not exist %currentDir%%var% (
	ECHO ���� %currentDir%%var% �ļ�������,�����������...
	PAUSE >nul
	GOTO Restore
)
ECHO ��ʼ�ָ�.......
mysql -h%dbhost% -u%dbuser% -p%dbpasswd% stk_v2_hgd < %currentDir%%var% 2>nul
ECHO �ָ������Ѿ����,�����������...
PAUSE >nul
GOTO Menu
rem ===============�����˳�����=======================================================================================
:End
EXIT
