
@echo off
setlocal
title Atualizacao do Winget, WSL e Python

set "LOG=%TEMP%\atualizacao.log"
set "WINGETLOG=%TEMP%\winget-atualizacao.log"

echo.
echo ==========================================
echo  ATUALIZACAO DO WINGET, WSL E PYTHON
echo ==========================================
echo.

echo.>> "%LOG%"
echo [%date% %time%] Inicio da atualizacao>> "%LOG%"

REM ==========================================
REM 1 - Atualizar aplicativos Windows
REM ==========================================

echo.
echo [1/6] Atualizando aplicativos com Winget...
echo [%date% %time%] Inicio do Winget>> "%LOG%"

winget.exe upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --silent > "%WINGETLOG%" 2>&1
set "WINGET_RC=%ERRORLEVEL%"

if not "%WINGET_RC%"=="0" (
    echo AVISO: Winget retornou codigo %WINGET_RC%.
    echo Consulte: "%WINGETLOG%"
    echo [%date% %time%] Erro Winget: %WINGET_RC%>> "%LOG%"
) else (
    echo Winget concluido.
    echo [%date% %time%] Winget concluido>> "%LOG%"
)

REM ==========================================
REM 2 - Atualizar pip e pacotes Python Windows
REM ==========================================

echo.
echo [2/6] Atualizando Python, pip e pacotes no Windows...
echo [%date% %time%] Inicio Python Windows>> "%LOG%"

set "PYTHON_CMD="

where py.exe >nul 2>&1
if not errorlevel 1 set "PYTHON_CMD=py -m"

if not defined PYTHON_CMD (
    where python.exe >nul 2>&1
    if not errorlevel 1 set "PYTHON_CMD=python -m"
)

if not defined PYTHON_CMD (
    echo AVISO: Python nao encontrado no Windows.
    echo Instale o Python ou verifique o PATH.
    echo [%date% %time%] Python Windows nao encontrado>> "%LOG%"
    goto :wsl_update
)

%PYTHON_CMD% pip --version
if errorlevel 1 (
    echo AVISO: pip nao esta disponivel no Windows.
    echo Tentando habilitar pip...
    %PYTHON_CMD% ensurepip --upgrade
)

%PYTHON_CMD% pip --version >nul 2>&1
if errorlevel 1 (
    echo AVISO: Nao foi possivel disponibilizar o pip.
    echo [%date% %time%] pip Windows indisponivel>> "%LOG%"
    goto :wsl_update
)

echo Atualizando pip no Windows...
%PYTHON_CMD% pip install --upgrade pip
if errorlevel 1 (
    echo AVISO: Falha ao atualizar pip no Windows.
    echo [%date% %time%] Falha pip Windows>> "%LOG%"
) else (
    echo pip do Windows atualizado.
    echo [%date% %time%] pip Windows atualizado>> "%LOG%"
)

echo Atualizando pacotes Python do usuario no Windows...
%PYTHON_CMD% pip list --user --outdated --format=freeze > "%TEMP%\python-pacotes-desatualizados.txt" 2>> "%LOG%"

if errorlevel 1 (
    echo AVISO: Nao foi possivel listar os pacotes Python.
    echo [%date% %time%] Falha ao listar pacotes Windows>> "%LOG%"
) else (
    for /f "usebackq tokens=1 delims==" %%P in ("%TEMP%\python-pacotes-desatualizados.txt") do (
        if not "%%P"=="" (
            echo Atualizando pacote %%P...
            %PYTHON_CMD% pip install --user --upgrade "%%P"
            if errorlevel 1 echo AVISO: Falha ao atualizar %%P.
        )
    )
)

REM ==========================================
REM 3 - Atualizar WSL
REM ==========================================

:wsl_update
echo.
echo [3/6] Atualizando o WSL...
echo [%date% %time%] Inicio WSL>> "%LOG%"

wsl --update
if errorlevel 1 (
    echo AVISO: Nao foi possivel atualizar o WSL.
    echo [%date% %time%] Erro WSL>> "%LOG%"
) else (
    echo WSL atualizado.
    echo [%date% %time%] WSL atualizado>> "%LOG%"
)

REM ==========================================
REM 4 - Reiniciar ambiente WSL
REM ==========================================

echo.
echo [4/6] Reiniciando o ambiente WSL...
wsl --shutdown

if errorlevel 1 (
    echo AVISO: Erro ao encerrar o WSL.
    echo [%date% %time%] Erro shutdown WSL>> "%LOG%"
)

REM ==========================================
REM 5 - Atualizar pacotes Linux
REM ==========================================

echo.
echo [5/6] Atualizando pacotes Linux...
echo [%date% %time%] Inicio pacotes Linux>> "%LOG%"

wsl -e sh -lc "sudo apt-get update && sudo apt-get full-upgrade -y && sudo apt-get autoremove -y"

if errorlevel 1 (
    echo AVISO: Falha na atualizacao dos pacotes Linux.
    echo [%date% %time%] Falha pacotes Linux>> "%LOG%"
) else (
    echo Pacotes Linux atualizados.
    echo [%date% %time%] Pacotes Linux atualizados>> "%LOG%"
)

REM ==========================================
REM 6 - Atualizar pip e pacotes Python no WSL
REM ==========================================

echo.
echo [6/6] Atualizando pip e pacotes Python no WSL...
echo [%date% %time%] Inicio Python WSL>> "%LOG%"

wsl -e sh -lc "sudo apt-get install -y python3-pip python3-venv"

if errorlevel 1 (
    echo AVISO: Nao foi possivel preparar o pip no WSL.
    echo [%date% %time%] Falha preparando pip WSL>> "%LOG%"
    goto :fim
)

REM O pip do sistema pode ser gerenciado pelo apt/PEP 668.
REM Nao forcar atualizacao global com break-system-packages.

wsl -e sh -lc "python3 -m pip --version"

if errorlevel 1 (
    echo AVISO: pip nao esta disponivel no WSL.
    echo [%date% %time%] pip WSL indisponivel>> "%LOG%"
    goto :fim
)

echo Atualizando pacotes Python do usuario no WSL...
wsl -e sh -lc "python3 -m pip list --user --outdated --format=freeze 2>/dev/null | cut -d= -f1 | while IFS= read -r pacote; do [ -n \"$pacote\" ] && python3 -m pip install --user --upgrade \"$pacote\" || echo \"AVISO: falha ao atualizar $pacote\"; done"

if errorlevel 1 (
    echo AVISO: Pode ter ocorrido falha nos pacotes Python do WSL.
    echo [%date% %time%] Aviso pacotes Python WSL>> "%LOG%"
) else (
    echo Verificacao dos pacotes Python do WSL concluida.
    echo [%date% %time%] Pacotes Python WSL verificados>> "%LOG%"
)

REM Tentar atualizar pip no WSL sem violar PEP 668.
REM Se o sistema bloquear, usar um ambiente virtual dedicado.

wsl -e sh -lc "python3 -m venv \"$HOME/.venvs/atualizador-pip\" && \"$HOME/.venvs/atualizador-pip/bin/python\" -m pip install --upgrade pip"

if errorlevel 1 (
    echo AVISO: Nao foi possivel atualizar pip no ambiente virtual do WSL.
    echo [%date% %time%] Aviso pip WSL>> "%LOG%"
) else (
    echo pip atualizado no ambiente virtual auxiliar do WSL.
    echo [%date% %time%] pip WSL atualizado no venv>> "%LOG%"
)

:fim
echo.
echo ==========================================
echo       PROCESSO FINALIZADO
echo ==========================================
echo.
echo Log geral: "%LOG%"
echo Log detalhado Winget: "%WINGETLOG%"
echo.

echo [%date% %time%] Fim da execucao>> "%LOG%"
pause
endlocal
