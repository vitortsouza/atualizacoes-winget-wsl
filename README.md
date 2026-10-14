# Atualização do Winget, WSL e Python

Script em lote (`.bat`) para automatizar a atualização de aplicativos do Windows, do Windows Subsystem for Linux (WSL), dos pacotes da distribuição Linux via APT e dos componentes Python, incluindo o `pip` e os pacotes Python instalados no ambiente do usuário.

O script reúne as principais etapas de manutenção em um único processo, com registro de logs e tratamento básico de erros para facilitar o acompanhamento da execução.

## Funcionalidades

- **Atualização do Winget:** atualiza os pacotes disponíveis, incluindo aqueles cuja versão instalada é desconhecida.
- **Atualização do Python no Windows:** utiliza o inicializador `py` ou o comando `python` para localizar o interpretador disponível.
- **Atualização do pip no Windows:** verifica a disponibilidade do `pip`, tenta habilitá-lo com `ensurepip` quando necessário e executa sua atualização.
- **Atualização dos pacotes Python no Windows:** identifica os pacotes desatualizados instalados no perfil do usuário e tenta atualizá-los individualmente.
- **Atualização do WSL:** verifica e instala as atualizações disponíveis para o Windows Subsystem for Linux.
- **Reinicialização do ambiente WSL:** encerra as instâncias em execução para reiniciar o ambiente após a atualização.
- **Atualização dos pacotes Linux:** executa `apt-get update`, `apt-get full-upgrade` e `apt-get autoremove` na distribuição padrão do WSL.
- **Atualização do pip no WSL:** verifica a disponibilidade do `pip` e tenta atualizá-lo em um ambiente virtual auxiliar, respeitando as restrições do Python gerenciado pela distribuição.
- **Atualização dos pacotes Python no WSL:** identifica e tenta atualizar os pacotes desatualizados instalados no espaço do usuário.
- **Registro de logs:** registra as etapas, datas, horários e erros identificados durante a execução.
- **Tratamento de erros:** exibe avisos quando alguma etapa falha ou retorna um código de erro, permitindo que outras etapas continuem quando possível.

## Requisitos

- Windows 10 ou Windows 11 compatível com o Winget e o WSL.
- [Windows Package Manager (Winget)](https://learn.microsoft.com/pt-br/windows/package-manager/winget/).
- [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/pt-br/windows/wsl/).
- Uma distribuição Linux instalada no WSL que utilize APT, como Ubuntu ou Debian.
- Python 3 instalado no Windows para atualizar o Python e seus pacotes nesse ambiente.
- Python 3 e `python3-pip` disponíveis ou instaláveis na distribuição Linux.
- `sudo` configurado para a distribuição Linux.
- Conexão com a internet para baixar atualizações.

## Como utilizar

1. Baixe ou clone este repositório.
2. Salve o arquivo `.bat` em uma pasta de sua preferência.
3. Abra o terminal do Windows ou o Prompt de Comando.
4. Execute o script:

   ```bat
   atualizacao.bat
   ```

   Substitua `atualizacao.bat` pelo nome real do arquivo.

5. Acompanhe as mensagens exibidas no terminal.
6. Ao final, pressione uma tecla para fechar a janela.

> **Observação:** alguns pacotes podem exigir privilégios administrativos. O comando `sudo` também poderá solicitar autenticação dentro da distribuição Linux. A atualização do pip ou de determinados pacotes Python pode falhar caso existam restrições de permissões ou conflitos com o ambiente instalado.

## Etapas da execução

O script executa as seguintes operações, em sequência:

1. Atualiza os aplicativos do Windows com o Winget.
2. Localiza o Python disponível no Windows e tenta atualizar o `pip` e os pacotes Python instalados no perfil do usuário.
3. Atualiza o WSL com `wsl --update`.
4. Encerra as instâncias em execução com `wsl --shutdown`.
5. Atualiza os índices, instala atualizações e remove pacotes desnecessários na distribuição Linux padrão.
6. Verifica o `pip` no WSL, tenta atualizar os pacotes Python do usuário e atualiza o `pip` em um ambiente virtual auxiliar.

As falhas são tratadas com avisos sempre que possível. Uma falha em determinada etapa não significa necessariamente que todas as demais etapas serão interrompidas.

## Atualização do Python e do pip

### Windows

O script prioriza o inicializador `py` e utiliza `python` como alternativa.

As operações incluem:

- Verificação da versão e disponibilidade do `pip`.
- Tentativa de habilitar o `pip` por meio de `ensurepip`, caso ele não esteja disponível.
- Atualização do `pip` com `pip install --upgrade pip`.
- Identificação dos pacotes desatualizados instalados no perfil do usuário.
- Tentativa de atualização individual dos pacotes encontrados.

**Limitações:**

- O script utiliza o interpretador selecionado pelo inicializador `py` ou pelo comando `python`; não garante a atualização de todas as versões Python instaladas no Windows.
- A atualização dos pacotes do usuário não abrange automaticamente todos os ambientes virtuais nem todas as instalações globais.
- Pacotes que exigem permissões administrativas ou dependências específicas podem falhar durante a atualização.

### WSL/Linux

O script atualiza primeiro os pacotes do sistema pelo APT, incluindo a instalação ou verificação de `python3-pip` e `python3-venv`.

Em seguida, tenta atualizar os pacotes Python instalados no espaço do usuário e utiliza um ambiente virtual auxiliar para atualizar o próprio `pip`.

O ambiente virtual auxiliar é criado no caminho:

```text
~/.venvs/atualizador-pip
```

Essa abordagem evita forçar uma atualização global do `pip` em distribuições que protegem o Python do sistema.

**Limitações:**

- A atualização dos pacotes do usuário não abrange automaticamente os ambientes virtuais existentes nos projetos.
- Pacotes instalados pelo APT devem, em geral, ser atualizados pelo próprio APT.
- A disponibilidade do `pip`, as permissões e as políticas da distribuição Linux podem afetar o resultado.
- O ambiente virtual auxiliar é independente dos ambientes virtuais utilizados pelos projetos.

### Ambientes virtuais e PEP 668

Algumas distribuições Linux implementam a proteção conhecida como PEP 668, que impede a instalação ou atualização de pacotes Python diretamente no ambiente gerenciado pelo sistema operacional.

O script não utiliza `--break-system-packages`, pois forçar essa operação pode causar conflitos entre o `pip` e o gerenciador de pacotes do sistema.

Para atualizar as dependências de um projeto específico, recomenda-se ativar seu ambiente virtual e executar:

```bash
python -m pip install --upgrade pip
python -m pip list --outdated
```

Para atualizar um pacote específico:

```bash
python -m pip install --upgrade nome-do-pacote
```

## Logs

Os arquivos de log são armazenados no diretório temporário do usuário do Windows (`%TEMP%`).

| Arquivo | Finalidade |
|---|---|
| `atualizacao.log` | Registra o início, as etapas executadas, os erros identificados e o encerramento do processo. |
| `winget-atualizacao.log` | Armazena a saída detalhada do Winget, incluindo mensagens de erro, quando a saída é redirecionada para esse arquivo. |
| `python-pacotes-desatualizados.txt` | Arquivo temporário que lista os pacotes Python desatualizados detectados no Windows. |

**Importante:** os registros detalhados do Python e do WSL não são necessariamente consolidados integralmente em um único arquivo. Alguns comandos exibem mensagens diretamente no terminal.

Para consultar os logs gerados pelo próprio Winget, utilize:

```bat
winget.exe --logs
```

## Comandos utilizados

| Comando | Descrição |
|---|---|
| `winget upgrade --all` | Atualiza os pacotes identificados pelo Winget. |
| `py -m pip --version` | Verifica o pip associado ao Python selecionado pelo inicializador `py`. |
| `python -m pip --version` | Verifica o pip associado ao interpretador Python disponível pelo comando `python`. |
| `python -m ensurepip --upgrade` | Tenta habilitar ou atualizar o pip usando os recursos incluídos no Python. |
| `python -m pip install --upgrade pip` | Atualiza o pip no ambiente Python selecionado. |
| `python -m pip list --user --outdated` | Lista pacotes desatualizados no espaço do usuário, quando suportado pelo ambiente. |
| `python -m pip install --user --upgrade nome-do-pacote` | Atualiza um pacote Python no espaço do usuário. |
| `wsl --update` | Atualiza o WSL. |
| `wsl --shutdown` | Encerra as instâncias em execução do WSL. |
| `apt-get update` | Atualiza a lista de pacotes disponíveis. |
| `apt-get full-upgrade -y` | Instala atualizações, permitindo alterações nas dependências dos pacotes. |
| `apt-get autoremove -y` | Remove pacotes considerados desnecessários pelo APT. |
| `python3 -m venv` | Cria um ambiente virtual Python isolado. |
| `python3 -m pip install --upgrade pip` | Atualiza o pip no ambiente Python correspondente, desde que permitido pelo ambiente. |

## Avisos importantes

- O comando `wsl --shutdown` encerra todas as distribuições WSL em execução, interrompendo temporariamente seus processos.
- O `apt-get full-upgrade` pode instalar ou remover pacotes para concluir as atualizações.
- O `apt-get autoremove` pode remover dependências que deixaram de ser necessárias.
- A atualização do Winget utiliza o parâmetro `--silent`, mas alguns instaladores podem apresentar comportamentos diferentes.
- O script não reinicia o Windows automaticamente.
- O Python do Windows e o Python do WSL são instalações independentes. Atualizar um não atualiza o outro.
- Atualizar pacotes Python pode introduzir incompatibilidades em projetos que dependem de versões específicas.
- O script não garante a atualização de todas as versões do Python nem de todos os ambientes virtuais existentes.
- Recomenda-se salvar o trabalho em andamento, manter cópias dos arquivos de dependências dos projetos e revisar eventuais erros antes de considerar a manutenção concluída.

## Licença

Este projeto pode ser distribuído sob os termos de uma licença de sua escolha. Caso deseje permitir seu uso, modificação e redistribuição publicamente, considere adicionar um arquivo `LICENSE` ao repositório.

---

Desenvolvido para simplificar a manutenção de aplicativos do Windows, do WSL, dos pacotes Linux e dos ambientes Python em sistemas que utilizam Winget e WSL.
