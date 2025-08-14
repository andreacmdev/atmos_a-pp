# 📱 ATMOS App — Gestão de Presença de Adolescentes

## 📖 Visão Geral
O **ATMOS App** foi desenvolvido para o Departamento de Adolescentes da Igreja Verbo da Vida com o objetivo de registrar e gerenciar a presença de adolescentes nos eventos **Culto**, **Conectadão** e **Atmosfera**.

Ele funciona de forma **offline para interface** e **online para registro**, integrando-se a uma **planilha Google Sheets** via **Google Apps Script**.

---

## 🎯 Objetivos do Projeto
- Substituir o registro manual em papel por uma solução digital.
- Facilitar o trabalho da equipe de gestão, que poderá registrar presenças diretamente no celular.
- Criar relatórios de presença de forma mais rápida e acessível.
- Adicionar funcionalidades para controle de visitantes.

---

## 🛠️ Tecnologias Utilizadas
- **Flutter** (Dart)
- **Google Sheets API** via Google Apps Script
- **HTTP package** (requisições)
- **Intl package** (formatação de datas)
- **VS Code** (desenvolvimento)
- **GitHub** (controle de versão)

---

## 📂 Estrutura do Projeto

```
lib/
├── models/
│   ├── adolescente.dart       # Modelo de dados dos adolescentes
│   └── tipo_evento.dart       # Enum dos eventos
├── screens/
│   ├── home_screen.dart       # Tela inicial com menu lateral
│   ├── presenca_screen.dart   # Tela de marcação de presença
│   └── visitante_screen.dart  # Tela de registro de visitantes
├── services/
│   └── google_sheets_api.dart # Comunicação com o backend (Apps Script)
assets/
└── icon/
    └── atmos.png              # Ícone oficial do app
```

---

## 🚀 Etapas de Desenvolvimento

### **1. Definição da Estrutura**
Criamos um documento inicial definindo:
- Páginas necessárias
- Modelos de dados
- Serviços para comunicação com o backend
- Layout e cores baseados na identidade visual ATMOS

---

### **2. Modelagem**
**Arquivo:** `adolescente.dart`
- Representa o adolescente com: `id`, `nome`, `dataNascimento`, `telefone`.
- Inclui `fromMap` e `toMap` para conversão entre JSON e objetos Dart.

---

### **3. Backend no Google Sheets**
**Google Apps Script** com as funções:
- `getAdolescentes()` → Lista de adolescentes
- `registrarPresenca()` → Registra presença
- `getPresencas()` → Retorna IDs já registrados no dia/evento
- `registrarVisitante()` → Registra visitantes em aba separada

---

### **4. Integração Flutter ↔ Sheets**
**Arquivo:** `google_sheets_api.dart`
- Funções para buscar e enviar dados via HTTP.
- Uso do `http.get` e `http.post` para comunicar com o Apps Script.

---

### **5. Interface**
- **HomeScreen**: Logo + Botão para “Marcar Presença” + “Adicionar Visitante” no menu lateral.
- **PresencaScreen**: Lista de adolescentes com pré-seleção se já registrado.
- **VisitanteScreen**: Formulário com Nome, Telefone e Idade.

---

### **6. Melhorias**
- Tema global com paleta ATMOS.
- Botões personalizados.
- Gradiente no fundo da tela inicial.
- Barra de pesquisa na lista de adolescentes.
- Feedback visual após registro.
- Pré-carregamento de presenças para evitar duplicidade no mesmo dia/evento.

---

## 📦 Geração do APK

### **Comando**
```bash
flutter build apk --release
```

### **Local do arquivo**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📡 Fluxo de Integração Google Sheets

1. **Planilha** com abas:
   - `adolescentes` → Lista fixa de membros
   - `presencas` → Registros de presença
   - `visitantes` → Registros de visitantes

2. **Apps Script**:
   - Publicado como Web App (`Deploy > New Deployment`).
   - Permissão para "Qualquer pessoa com o link".

3. **Flutter App**:
   - Consome os endpoints via HTTP.
   - Atualiza a interface imediatamente após registros.

---

## 📜 Licença
Uso interno do Departamento de Adolescentes da Igreja Verbo da Vida — Zona Norte.  
Não possui licença pública.

---

**Feito com ❤️ por André Cândido Machado**
