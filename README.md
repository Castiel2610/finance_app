# FinanceApp - Controle Financeiro

App mobile de controle financeiro desenvolvido em Flutter para a disciplina de Mobile Nativo.

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| Framework | Flutter 3.x |
| Estado | Riverpod 2.x |
| DB Local | SQLite (sqflite) |
| DB Cloud | Firebase Firestore |
| Auth | Firebase Auth + SQLite local |
| API | NewsAPI (notícias financeiras) |
| UI | Material Design 3 + Google Fonts |
| Animações | flutter_animate + Shimmer |

## Arquitetura MVVM

```
lib/
├── core/           # Constantes, tema, utilitários
├── models/         # Entidades de dados
├── services/       # SQLite, Firebase, NewsAPI
├── repositories/   # Camada de abstração de dados
├── providers/      # Injeção de dependência (Riverpod)
├── viewmodels/     # Lógica de negócio + estado
└── views/          # Telas e widgets
    ├── screens/
    │   ├── auth/           (Login, Cadastro)
    │   ├── dashboard/      (Dashboard principal)
    │   └── transactions/   (Lista completa)
    └── widgets/            (Componentes reutilizáveis)
```

## Funcionalidades

- **Autenticação**: Login/Cadastro com validação completa
- **Dashboard**: Saldo em tempo real, receitas/despesas, notícias financeiras
- **Transações**: CRUD completo via BottomSheet sem trocar de rota
- **Filtros**: Filtrar por tipo (Todas/Receitas/Despesas) + busca por texto
- **Categorias**: 11 categorias com ícones
- **Persistência**: SQLite local + sincronização Firebase
- **Offline**: Funciona sem internet (SQLite)
- **Animações**: Transições fluidas, skeleton screens, feedback visual

---

## Instalação e Configuração

### Pré-requisitos

1. **Instalar Flutter SDK**: https://docs.flutter.dev/get-started/install
2. **Verificar instalação**: `flutter doctor`

### 1. Clonar e instalar dependências

```bash
git clone <seu-repositorio>
cd finance_app
flutter pub get
```

### 2. Configurar Firebase (para nota máxima)

**2a. Criar projeto Firebase:**
1. Acesse https://console.firebase.google.com
2. Crie um novo projeto
3. Ative **Authentication** → Sign-in method → Email/Password
4. Ative **Firestore Database** → Crie em modo de teste

**2b. Configurar no projeto:**
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar (substitui firebase_options.dart automaticamente)
flutterfire configure
```

**2c. Regras do Firestore** (cole no Console Firebase):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/transactions/{transactionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Configurar NewsAPI (opcional)

1. Cadastre-se em https://newsapi.org (grátis)
2. Copie sua API Key
3. Edite `lib/services/news_service.dart`:
```dart
static const String _apiKey = 'SUA_API_KEY_AQUI';
```
> Sem configurar, o app usa notícias de demonstração (mock).

---

## Executar o app

```bash
# Emulador Android/iOS
flutter run

# Chrome (web - para Codespaces)
flutter run -d chrome

# Listar dispositivos disponíveis
flutter devices
```

## Gerar APK

```bash
# APK de debug (mais rápido)
flutter build apk --debug

# APK de release (para entrega)
flutter build apk --release

# APK dividido por arquitetura (menor tamanho)
flutter build apk --split-per-abi
```

O APK gerado estará em: `build/app/outputs/flutter-apk/`

## Executar no GitHub Codespaces

1. Abra o repositório no GitHub
2. Clique em **Code** → **Codespaces** → **New codespace**
3. No terminal:
```bash
flutter pub get
flutter run -d web-server --web-port 8080
```
4. O Codespaces vai abrir uma porta para visualizar o app no browser

---

## Estrutura do Banco de Dados SQLite

```sql
-- Tabela de usuários
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- Tabela de transações
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  type TEXT NOT NULL,        -- 'income' | 'expense'
  category TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Grupo

- Integrantes: [Adicione os nomes aqui]
- Disciplina: Desenvolvimento Mobile Nativo
- Semestre: [Adicione o semestre]
