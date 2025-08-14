# 📱 ATMOS App — Gestão de Presença de Adolescentes

# 📱 ATMOS App — Gestão de Presença de Adolescentes

O **ATMOS App** é um aplicativo desenvolvido em **Flutter** para auxiliar no controle de presença dos adolescentes nos eventos do departamento da igreja, como:

- Culto
- Conectadão
- Atmosfera

A aplicação permite registrar presenças diretamente via celular (APK), salvando os dados em uma planilha **Google Sheets**.  
Isso garante facilidade de acesso para a equipe de gestão, sem necessidade de conhecimento técnico em programação.

---

## ✨ Funcionalidades

- ✅ **Listagem automática** de adolescentes cadastrados no Google Sheets.
- ✅ **Marcação de presença** para cada evento do dia.
- ✅ **Cadastro de visitantes** com nome, telefone e idade.
- ✅ **Integração com Google Sheets API** via Google Apps Script.
- ✅ **Pré-carregamento** das presenças já registradas no mesmo dia e evento.
- ✅ **Feedback visual** após cada registro.
- ✅ **Interface simples e responsiva** para uso em qualquer celular Android.
- ✅ **Menu inicial com seleção de evento**.
- ✅ **Menu lateral** com opções de **Marcar Presença** e **Adicionar Visitante**.

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** (SDK)
- **Dart**
- **Google Sheets API** via Apps Script
- **HTTP package** para requisições
- **Intl package** para formatação de datas

---

## 📂 Estrutura de Pastas

```plaintext
lib/
├── models/
│   ├── adolescente.dart       # Modelo de dados do adolescente
│   └── tipo_evento.dart       # Enum dos tipos de eventos
├── screens/
│   ├── home_screen.dart       # Tela inicial com menu lateral e seleção de evento
│   ├── presenca_screen.dart   # Tela de marcação de presença
│   └── visitante_form_screen.dart # Tela para cadastro de visitante
├── services/
│   └── google_sheets_api.dart # Comunicação com o Apps Script/Sheets
assets/
└── icon/
    └── atmos.png              # Ícone oficial do app
```

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- **Flutter SDK** instalado  
- **VS Code** ou Android Studio configurado  
- Celular Android em **modo desenvolvedor** ou emulador configurado  

---

### Passos

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/andreacmdev/atmos_a-pp.git
   cd atmos_a-pp

2. **Instale as dependências**:
    
    ```js
    flutter pub get
    ```

Configure seu arquivo **assets/icon/gestao.png** (ícone do app).

## Rode o app:
```bash
flutter run
```

## 📡 Integração com Google Sheets

O backend do app é um Google Apps Script que:

- Lê a lista de adolescentes na aba adolescentes.
- Registra presenças na aba presencas.
- Registra visitantes na aba visitantes.
- Retorna IDs já presentes para marcar na UI.

Endpoints
```js
action=getAdolescentes
 → retorna lista de adolescentes.

action=registrarPresenca
 → salva presença no Sheets.

action=getPresencas&data=YYYY-MM-DD&tipo_evento=culto
 → retorna IDs já registrados no dia/evento.

action=registrarVisitante
    → salva nome, telefone e idade do visitante na aba 'visitantes'.
```

## 📷 Capturas de Tela (exemplo)

(adicione imagens reais do app rodando)

Tela Home	Marcar Presença	Feedback

	
	
## 📦 Gerar APK

Para instalar o app direto no celular via APK:

```bash
flutter build apk --release
```

O arquivo estará em:
```js
build/app/outputs/flutter-apk/app-release.apk
```

📜 Licença

Este projeto é de uso interno do Departamento de Adolescentes da Igreja Verbo da Vida Zona Norte e não possui licença pública.

Feito pode Dedev