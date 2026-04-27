<p align="center">
  <img src="assets/logo.png" alt="Palavra Viva Logo" width="120" />
</p>

<h1 align="center">Palavra Viva ✝️</h1>

<p align="center">
  <strong>Seu companheiro diário de fé — Bíblia, oração, reflexão e IA, tudo em um só app.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/OpenAI-GPT-412991?logo=openai&logoColor=white" alt="OpenAI" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey" alt="Platform" />
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License" />
</p>

---

## 📖 Sobre

**Palavra Viva** é um aplicativo mobile cristão que combina leitura bíblica, oração guiada, diário espiritual e inteligência artificial para criar uma experiência de devoção completa e personalizada.

O app foi pensado para jovens e adultos que desejam aprofundar sua fé de forma prática, moderna e acessível.

---

## ✨ Funcionalidades

| Módulo | Descrição |
|--------|-----------|
| 📖 **Bíblia** | Leitura da Bíblia completa com progresso de leitura rastreado |
| 🙏 **Oração** | Lista de pedidos de oração com acompanhamento e lembretes |
| 📝 **Diário Espiritual** | Espaço para reflexões diárias com persistência local |
| 🤖 **Palavra.AI** | Chat inteligente com IA (GPT) para tirar dúvidas bíblicas e ter conversas espirituais |
| 🏠 **Home Dinâmica** | Dashboard com versículo do dia, progresso de gamificação e acesso rápido a módulos |
| 🧠 **Quiz Bíblico** | Perguntas sobre a Bíblia com leaderboard e sistema de pontos |
| 🎯 **Dinâmicas para Jovens** | Catálogo de atividades para grupos de jovens com busca, filtros e favoritos |
| 📊 **Insights** | Painel de estatísticas inspirado no Spotify Wrapped — visualize sua jornada espiritual |
| ✝️ **Confissão** | Espaço seguro para registro de confissões pessoais |
| 🎤 **Sermões** | Acervo de sermões e pregações |
| 🏆 **Gamificação** | Sistema de XP, níveis, conquistas e streak para engajar a consistência devocional |
| ⚙️ **Configurações** | Tema claro/escuro, tamanho de fonte, perfil, termos, suporte e sobre |
| 🔔 **Notificações** | Lembretes personalizados para oração e devoção diária |
| 🔐 **Autenticação** | Login/cadastro via Supabase Auth com reset de senha |

---

## 🛠️ Tech Stack

| Camada | Tecnologia |
|--------|------------|
| **Framework** | [Flutter](https://flutter.dev) 3.x |
| **Linguagem** | [Dart](https://dart.dev) 3.11+ |
| **Backend** | [Supabase](https://supabase.com) (Auth, Database, Edge Functions) |
| **IA** | [OpenAI GPT](https://openai.com) via Supabase Edge Function Proxy |
| **Gerenciamento de Estado** | [Riverpod](https://riverpod.dev) 3.x |
| **Roteamento** | [GoRouter](https://pub.dev/packages/go_router) |
| **Armazenamento Local** | [Hive](https://pub.dev/packages/hive) + SharedPreferences |
| **HTTP** | [Dio](https://pub.dev/packages/dio) |
| **Notificações** | flutter_local_notifications |
| **Design** | Google Fonts, Lucide Icons, Flutter Animate, Shimmer |

---

## 📂 Estrutura do Projeto

```
palavra_viva/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # MaterialApp config (theme, locale, router)
│   ├── core/
│   │   ├── providers/            # Riverpod providers (theme, settings)
│   │   ├── services/             # Serviços globais
│   │   │   ├── gamification_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── openai_service.dart
│   │   ├── theme/                # Design system
│   │   │   ├── app_colors.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_theme.dart
│   │   │   └── app_typography.dart
│   │   └── widgets/              # Widgets reutilizáveis
│   ├── features/                 # Feature-first architecture
│   │   ├── activities/           # Dinâmicas para jovens
│   │   ├── auth/                 # Login, cadastro, reset
│   │   ├── bible/                # Leitura bíblica
│   │   ├── chat/                 # Palavra.AI (chat com IA)
│   │   ├── confession/           # Confissão
│   │   ├── home/                 # Dashboard principal
│   │   ├── insights/             # Insights e estatísticas
│   │   ├── journal/              # Diário espiritual
│   │   ├── onboarding/           # Splash e onboarding
│   │   ├── prayer/               # Pedidos de oração
│   │   ├── quiz/                 # Quiz bíblico + leaderboard
│   │   ├── sermons/              # Sermões
│   │   └── settings/             # Configurações, perfil, sobre
│   └── router/
│       └── app_router.dart       # GoRouter com navegação por tabs
├── assets/
│   ├── data/                     # Dados estáticos (JSON)
│   ├── images/                   # Imagens do app
│   └── logo.png                  # Ícone do app
├── .env                          # Variáveis de ambiente (NÃO commitar)
└── pubspec.yaml                  # Dependências e configuração
```

---

## 🚀 Como Rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.x
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.11
- Android Studio ou VS Code com extensões Flutter
- Emulador Android / iOS Simulator ou dispositivo físico
- Conta no [Supabase](https://supabase.com) (para backend)

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/palavra-viva.git
cd palavra-viva/palavra_viva

# 2. Instale as dependências
flutter pub get

# 3. Configure as variáveis de ambiente
# Crie um arquivo .env na raiz do projeto Flutter:
cp .env.example .env
# Edite o .env com suas credenciais:
# SUPABASE_URL=https://seu-projeto.supabase.co
# SUPABASE_ANON_KEY=sua-anon-key

# 4. Gere o ícone do app e splash screen
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# 5. Execute o app
flutter run
```

### Build para Produção

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🔐 Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto `palavra_viva/`:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anonima
```

> ⚠️ **Importante:** O `.env` está no `.gitignore`. Nunca exponha suas chaves em repositórios públicos.

---

## 🎨 Design System

O app utiliza um design system próprio com tema dark premium:

- **Cores principais:** Tons de dourado (`gold`) sobre fundo escuro
- **Tipografia:** Google Fonts (Inter)
- **Espaçamento:** Sistema de tokens consistente (`AppSpacing`)
- **Animações:** Flutter Animate + animações customizadas
- **Navbar:** Glassmorphism com backdrop blur e ícones animados
- **Splash:** Background escuro (#04060A) com logo centralizada

---

## 🏗️ Arquitetura

O projeto segue uma **Feature-First Architecture**:

```
feature/
├── domain/        # Modelos de dados e regras de negócio
├── data/          # Repositórios e fontes de dados
└── presentation/  # Telas e widgets específicos
```

**Padrões utilizados:**
- **State Management:** Riverpod (providers reativos)
- **Routing:** GoRouter com `StatefulShellRoute` para navegação por tabs
- **Storage:** Hive para dados offline + Supabase para sincronização
- **Auth Guard:** Redirect automático baseado em sessão Supabase

---

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/minha-feature`)
3. Commit suas alterações (`git commit -m 'feat: adiciona minha feature'`)
4. Push para a branch (`git push origin feature/minha-feature`)
5. Abra um Pull Request

### Convenção de Commits

```
feat:     Nova funcionalidade
fix:      Correção de bug
docs:     Alteração em documentação
style:    Formatação (sem mudança de lógica)
refactor: Refatoração de código
test:     Adição/correção de testes
chore:    Manutenção (configs, deps, scripts)
```

---

## 📄 Licença

Este projeto é **proprietário** e não possui licença open-source.  
Todos os direitos reservados © 2026 Palavra Viva.

---

## 📬 Contato

- **App:** Palavra Viva
- **Status:** Em desenvolvimento ativo 🚧
- **Plataformas:** Android & iOS

---

<p align="center">
  <em>"Lâmpada para os meus pés é a tua palavra, e luz para o meu caminho."</em><br/>
  <strong>— Salmos 119:105</strong>
</p>
