# Fluxo de teste e deploy

Use estes comandos a partir da pasta `atmos_app`.

## Teste local com hot reload

```powershell
.\scripts\dev_local.cmd
```

Abre o app em `http://localhost:55222`.

Para testar no celular na mesma rede, acesse:

```text
http://IP_DO_COMPUTADOR:55222
```

## Build local

```powershell
.\scripts\build_web.cmd
```

Gera a versao web em `build/web`, sem publicar nada.

Se o navegador mostrar uma versao antiga, force um rebuild limpo:

```powershell
.\scripts\rebuild_web.cmd
```

## Servir build local

```powershell
.\scripts\serve_build.cmd
```

Abre a versao compilada em `http://127.0.0.1:55222` com cache desativado.

## Preview temporario no Firebase

```powershell
.\scripts\preview_deploy.cmd
```

Publica em um canal temporario chamado `teste`, com validade de 7 dias. Esse
fluxo serve para testar no celular sem substituir o site oficial
`gestaoatmos.web.app`.

## Deploy oficial

```powershell
firebase deploy --only hosting
```

Use apenas quando a versao testada estiver aprovada.

## Comandos diretos

Se algum script nao rodar no terminal atual, use os comandos diretos:

```powershell
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 55222
flutter build web --web-renderer canvaskit
firebase hosting:channel:deploy teste --expires 7d
```
