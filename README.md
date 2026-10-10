# Atualização do Winget e WSL

Script em lote (`.bat`) para automatizar a atualização de aplicativos do Windows, do Windows Subsystem for Linux (WSL) e dos pacotes da distribuição Linux utilizando o APT.

O script reúne as principais etapas de manutenção em um único processo, com registro de logs e tratamento básico de erros para facilitar o acompanhamento da execução.

## Funcionalidades

- **Atualização do Winget:** atualiza todos os pacotes disponíveis, incluindo aqueles cuja versão instalada é desconhecida.
- **Atualização do WSL:** verifica e instala as atualizações disponíveis para o Windows Subsystem for Linux.
- **Reinicialização do ambiente WSL:** encerra as instâncias em execução para reiniciar o ambiente após a atualização.
- **Atualização dos pacotes Linux:** executa `apt-get update`, `apt-get full-upgrade` e `apt-get autoremove` na distribuição padrão do WSL.
- **Registro de logs:** registra as etapas, datas, horários e erros identificados durante a execução.
- **Tratamento de erros:** exibe avisos quando alguma etapa falha ou retorna um código de erro.

## Requisitos

- Windows 10 ou Windows 11 compatível com o Winget e o WSL.
- [Windows Package Manager (Winget)](https://learn.microsoft.com/pt-br/windows/package-manager/winget/).
- [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/pt-br/windows/wsl/).
- Uma distribuição Linux instalada no WSL que utilize APT, como Ubuntu ou Debian.
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

> **Observação:** alguns pacotes podem exigir privilégios administrativos. O comando `sudo` também poderá solicitar autenticação dentro da distribuição Linux.

## Etapas da execução

O script executa as seguintes operações, em sequência:

1. Atualiza os aplicativos do Windows com o Winget.
2. Atualiza o WSL com `wsl --update`.
3. Encerra as instâncias em execução com `wsl --shutdown`.
4. Atualiza os índices, instala atualizações e remove pacotes desnecessários na distribuição Linux padrão.

A execução das etapas seguintes pode ser interrompida caso ocorra uma falha nas atualizações do WSL ou dos pacotes Linux.

## Logs

Os arquivos de log são armazenados no diretório temporário do usuário do Windows (`%TEMP%`).

| Arquivo | Finalidade |
|---|---|
| `atualizacao.log` | Registra o início, as etapas executadas, os erros identificados e o encerramento do processo. |
| `winget-atualizacao.log` | Nome reservado para um possível log detalhado do Winget. |

**Importante:** na versão atual, o script define o caminho de `winget-atualizacao.log`, mas não redireciona a saída do Winget para esse arquivo. Para consultar os logs gerados pelo próprio Winget, utilize:

```bat
winget.exe --logs
```

## Comandos utilizados

| Comando | Descrição |
|---|---|
| `winget upgrade --all` | Atualiza os pacotes identificados pelo Winget. |
| `wsl --update` | Atualiza o WSL. |
| `wsl --shutdown` | Encerra as instâncias em execução do WSL. |
| `apt-get update` | Atualiza a lista de pacotes disponíveis. |
| `apt-get full-upgrade -y` | Instala atualizações, permitindo alterações nas dependências dos pacotes. |
| `apt-get autoremove -y` | Remove pacotes considerados desnecessários pelo APT. |

## Avisos importantes

- O comando `wsl --shutdown` encerra todas as distribuições WSL em execução, interrompendo temporariamente seus processos.
- O `apt-get full-upgrade` pode instalar ou remover pacotes para concluir as atualizações.
- O `apt-get autoremove` pode remover dependências que deixaram de ser necessárias.
- A atualização do Winget utiliza o parâmetro `--silent`, mas alguns instaladores podem apresentar comportamentos diferentes.
- O script não reinicia o Windows automaticamente.
- Recomenda-se salvar o trabalho em andamento e revisar eventuais erros antes de considerar a manutenção concluída.

## Licença

Este projeto pode ser distribuído sob os termos de uma licença de sua escolha. Caso deseje permitir seu uso, modificação e redistribuição publicamente, considere adicionar um arquivo `LICENSE` ao repositório.

---

Desenvolvido para simplificar a manutenção de aplicativos do Windows e pacotes Linux em ambientes que utilizam Winget e WSL.
