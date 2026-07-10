# ATMOS App

Aplicativo de gestao do departamento de adolescentes ATMOS.

O app centraliza presencas, cadastro de adolescentes, visitantes, aniversariantes,
relatorios e acompanhamento dos grupos Conectados. Ele foi pensado para uso
mobile-first pela equipe de lideranca.

## Visao Geral

O projeto nasceu como um controle de presenca baseado em Google Sheets e Apps
Script. Durante a transicao, o app foi rotacionado para uma estrutura mais
autonoma com Supabase como backend/banco de dados e Firebase Hosting para
publicacao web.

O objetivo principal e apoiar a gestao de pessoas: saber quem esta presente,
quem esta faltando, quem esta em transicao, quem chegou como visitante e como
cada adolescente esta caminhando nos eventos e nos Conectados.

## Funcionalidades Principais

- Login por email e senha.
- Marcacao de presenca por evento.
- Cadastro de adolescentes pelo app.
- Verificacao inteligente de nomes semelhantes antes de cadastrar.
- Cadastro de visitantes.
- Relatorio de visitantes da semana.
- Aniversariantes do mes.
- Cartao de aniversario personalizado com versiculo.
- Relatorio individual por adolescente.
- Relatorio gerencial mensal.
- Relatorio de transicao para adolescentes com 17 anos ou mais.
- Confirmacao de transicao com dupla confirmacao.
- Modulo Conectados.
- Registro de encontros dos Conectados com confirmacao final.
- Transferencia de adolescentes entre Conectados sem perder historico.
- Remocao de adolescente do Conectado sem apagar o cadastro.
- Relatorio Conectados com panorama geral e detalhe por grupo.
- Exportacao de PDFs em fluxos de relatorio.

## Eventos Suportados

- Culto Domingo Manha
- Culto Domingo Noite
- Conectadao
- Atmosfera
- Reuniao

## Modulo Conectados

O modulo Conectados gerencia os grupos de discipulado dos adolescentes.

Cada grupo possui:

- nome
- genero
- lider/responsavel
- cor de identidade
- membros ativos
- encontros
- presencas por encontro

O registro de encontro funciona em modo rascunho: o lider marca os adolescentes
presentes e somente ao tocar em `Confirmar Encontro` o app cria/atualiza o
encontro e grava presencas/faltas. Isso evita encontros acidentais criados
apenas por abrir uma data errada.

## Relatorios

### Relatorio Individual

Mostra o historico completo de um adolescente:

- dados pessoais
- total de presencas
- total de faltas
- frequencia geral
- eventos que mais participa
- historico por evento
- dados do Conectado atual
- presencas/faltas nos encontros dos Conectados

### Relatorio Gerencial

Mostra um panorama mensal dos adolescentes nos eventos gerais, incluindo
frequencia, faltas e itens de acompanhamento.

### Relatorio Conectados

Mostra o panorama mensal dos Conectados:

- grupos
- encontros
- presencas
- faltas
- percentual geral

Ao tocar em um grupo, abre o detalhe daquele Conectado com encontros do mes e
frequencia individual dos membros.

### Relatorio de Transicao

Lista adolescentes ativos com 17 anos ou mais. A equipe pode confirmar a
transicao quando o adolescente sair do departamento.

Ao confirmar a transicao:

- o adolescente fica `ativo = false`
- ele deixa de aparecer nas listas e relatorios ativos
- o historico e o ID permanecem preservados
- vinculo ativo em Conectados e encerrado

## Backend

O app usa Supabase como backend principal.

Principais tabelas usadas:

- `adolescentes`
- `eventos`
- `presencas`
- `visitantes`
- `conectados_grupos`
- `conectados_membros`
- `conectados_encontros`
- `conectados_presencas`
- `conectados_transferencias`

## Scripts SQL de Apoio

Arquivos relevantes no projeto:

- `supabase_conectados.sql`: cria estrutura do modulo Conectados.
- `supabase_conectados_import_via_csv.sql`: apoio para importar membros dos Conectados via CSV.
- `supabase_reset_dados_eventos.sql`: zera historico de eventos/presencas preservando adolescentes e grupos.
- `supabase_limpar_adolescentes_duplicados_v3.sql`: limpa cadastros duplicados de adolescentes.

## Desenvolvimento Local

Instale as dependencias Flutter e rode:

```powershell
flutter pub get
```

Build web:

```powershell
flutter build web --web-renderer canvaskit
```

Servidor local do build:

```powershell
.\scripts\serve_build.cmd
```

URL local:

```text
http://127.0.0.1:55222/
```

## Deploy

O app e publicado no Firebase Hosting.

Build:

```powershell
flutter build web --web-renderer canvaskit
```

Deploy oficial:

```powershell
firebase deploy --only hosting
```

URL de producao:

```text
https://gestaoatmos.web.app
```

## Uso Interno

Projeto de uso interno do departamento de adolescentes ATMOS.
