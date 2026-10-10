
@echo off
setlocal
title Atualizacao do Winget e WSL

set "LOG=%TEMP%\atualizacao.log"
set "WINGETLOG=%TEMP%\winget-atualizacao.log"

echo.
echo ==========================================
echo    ATUALIZACAO DO WINGET E WSL
echo ==========================================
echo.

echo.>> "%LOG%"
echo [%date% %time%] Inicio da atualizacao>> "%LOG%"

REM ==========================================
REM 1 - Atualizar aplicativos do Windows
REM ==========================================


REM ==========================================
REM 1 - Atualizar aplicativos com Winget
REM ==========================================

echo.
echo [1/4] Atualizando pacotes com Winget...
echo.

echo [%date% %time%] Inicio do Winget>> "%LOG%"

winget.exe upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --silent

set "WINGET_RC=%ERRORLEVEL%"

if not "%WINGET_RC%"=="0" (
    echo.
    echo AVISO: Winget retornou o codigo %WINGET_RC%.
    echo Consulte os logs do Winget com:
    echo winget.exe --logs
    echo [%date% %time%] Winget retornou codigo %WINGET_RC%>> "%LOG%"
) else (
    echo.
    echo Winget concluido com sucesso.
    echo [%date% %time%] Winget concluido>> "%LOG%"
)

REM ==========================================
REM 2 - Atualizar o WSL
REM ==========================================

echo.
echo [2/4] Atualizando o WSL...
echo [%date% %time%] Inicio da atualizacao do WSL>> "%LOG%"

wsl --update

if errorlevel 1 (
    echo.
    echo ERRO: Nao foi possivel atualizar o WSL.
    echo Verifique a mensagem exibida acima.
    echo [%date% %time%] Erro na atualizacao do WSL>> "%LOG%"
    goto :fim
)

echo WSL atualizado com sucesso.
echo [%date% %time%] WSL atualizado>> "%LOG%"

REM ==========================================
REM 3 - Encerrar instancias do WSL
REM ==========================================

echo.
echo [3/4] Reiniciando o ambiente WSL...
echo [%date% %time%] Encerrando instancias WSL>> "%LOG%"

wsl --shutdown

if errorlevel 1 (
    echo AVISO: O comando de encerramento do WSL retornou um erro.
    echo [%date% %time%] Erro no wsl --shutdown>> "%LOG%"
)

REM ==========================================
REM 4 - Atualizar pacotes Linux
REM ==========================================

echo.
echo [4/4] Atualizando pacotes da distribuicao Linux...
echo Isso pode demorar. Acompanhe as mensagens abaixo.
echo [%date% %time%] Inicio da atualizacao Linux>> "%LOG%"

wsl -e sh -lc "sudo apt-get update && sudo apt-get full-upgrade -y && sudo apt-get autoremove -y"

if errorlevel 1 (
    echo.
    echo ERRO: A atualizacao do Linux falhou ou foi interrompida.
    echo Verifique as mensagens exibidas acima.
    echo [%date% %time%] Erro na atualizacao Linux>> "%LOG%"
    goto :fim
)

echo.
echo Atualizacao dos pacotes Linux concluida.
echo [%date% %time%] Atualizacao Linux concluida>> "%LOG%"

:fim
echo.
echo ==========================================
echo    PROCESSO FINALIZADO
echo ==========================================
echo.
echo Log das etapas: "%LOG%"
echo Log detalhado do Winget: "%WINGETLOG%"
echo.
echo Se algum comando falhou, confira as mensagens acima.
echo.

echo [%date% %time%] Fim da execucao>> "%LOG%"

pause
endlocal
