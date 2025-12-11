 # LovU – diários e metas para casais

  Companheiro diário para casais acompanharem momentos especiais, recados rápidos de carinho e metas em conjunto, tudo sincronizado em tempo real entre
  dois dispositivos.

  ## Capturas de tela
  - Home / cabeçalho do casal: `docs/screens/home.png`
  - Criação de conta & login: `docs/screens/auth.png`
  - Gestão de convites/conexão: `docs/screens/connection.png`
  - Datas especiais & metas: `docs/screens/special-dates-goals.png`
  - Love message + expiração: `docs/screens/love-message.png`
  - Paywall / assinatura: `docs/screens/paywall.png`

  ## Sumário
  - [Visão geral](#visão-geral)
  - [Stack](#stack)
  - [Arquitetura](#arquitetura)
  - [Principais fluxos](#principais-fluxos)
  - [Persistência Firebase](#persistência-firebase)
  - [Localização & UI](#localização--ui)
  - [Como rodar](#como-rodar)
  - [Pastas-chave](#pastas-chave)
  - [Próximos passos](#próximos-passos)

  ## Visão geral
  - Autenticação com Firebase Auth, gestão de sessão e reautenticação.
  - Convite entre parceiros via código único, com fluxo de convite/aceite/recusa.
  - Dashboard que mostra tempo juntos, próximos marcos e status do relacionamento.
  - Datas especiais configuráveis com seleção do que aparece na Home.
  - Metas compartilhadas com checklist e exibição resumida na Home.
  - Love messages diárias (expiram em 24h) com aviso de validade e exclusão antecipada.
  - Upload de avatar para cada usuário (Firebase Storage + Kingfisher).
  - Paywall e assinaturas StoreKit 2, com detecção de assinatura compartilhada pelo parceiro.
  - Gestão de acesso por nível: free, conexão obrigatória, premium.

  ## Stack
  - SwiftUI + Combine para UI declarativa e reatividade.
  - Firebase (Auth, Firestore, Storage) para autenticação, dados em tempo real e mídia.
  - StoreKit 2 (`SubscriptionStoreView`) com arquivo `Subscription/Subscriptions.storekit` para sandbox local.
  - Kingfisher para cache e prefetch de imagens de perfil.
  - OSLog para telemetria básica.
  - Localização via `Localized/Localizable.xcstrings`.

  ## Arquitetura
  - `LovUApp.swift`: configura Firebase e injeta `AuthManager`, `NavigationManager` e `AuthenticationSheetControllerViewModel` via `EnvironmentObject`.
  - Managers por domínio (ex.: `ConnectionManager`, `SpecialDateManager`, `GoalsManager`, `LoveMessageManager`, `SubscriptionManager`) cuidam de regras de
  negócio e orquestram handlers/observadores de Firestore.
  - Handlers Firestore (`SpecialDateHandlerFirestore`, `GoalHandlerFirestore`, `LoveMessageHandlerFirestore`, `ConnectionCodeHandlerFirestore`,
  `SubscriptionHandlerFirestore`) isolam operações CRUD em coleções específicas.
  - Observers (`UserObserverManager`, `SpecialDateObserverManager`, `GoalObserverManager`, `LoveMessageObserverManager`) mantêm os modelos sincronizados
  em tempo real com Combine.
  - Padrão de callback via protocolos `...Output` para reportar sucesso/erro às ViewModels.
  - Controle de acesso centralizado (`AccessLevelEnum`, `AccessRestrictionManager`) decide quando exigir login, conexão ou premium antes de liberar ações.

  ## Principais fluxos
  - **Autenticação & sessão**
    - Sheets customizadas para login (`Authentication/View/SignInSheetView.swift`), criação multi-etapas (`Authentication/View/
  CreateAccountSheetView.swift`) e esqueci a senha.
    - `AuthManager` (`Authentication/Logic/AuthManager.swift`) inicializa sessão, pré-carrega imagens (Kingfisher) e injeta dados em todos os managers.
  - **Conexão entre parceiros**
    - Código único gerado em `ConnectionCodeGenerator.swift` e exibido em `ManageConnectionCodeView.swift`.
    - Convites enviados/aceitos/recusados via `ConnectionCodeHandlerFirestore` com reflexo instantâneo na Home e em Settings.
  - **Home dashboard**
    - `Home/View/HomeView.swift` mostra cabeçalho com tempo juntos, dois próximos marcos e avatares (`HeaderView.swift`), convite pendente, datas
  especiais, metas e love messages.
  - **Datas especiais**
    - Cadastro em `AddNewSpecialDateView.swift` com tipos padrão/premium (`SpecialDateType`) e seleção do que exibir na Home. Dados ficam em
  `connectionData/{connectionId}/specialDates`.
  - **Metas compartilhadas**
    - Criação e checklist em `Goals/View/AddGoalView.swift`, com auto-sync de marcações. Persistência em `connectionData/{connectionId}/goals`.
  - **Love messages diárias**
    - Criação em `LoveMessages/View/CreateLoveMessageView.swift`; mensagens expiram em 24h e mostram progresso até expirar. Armazenadas por usuário em
  `connectionData/{connectionId}/loveMessages`.
  - **Perfil & Settings**
    - Upload de foto (Storage) e exibição na Home/Settings. Botões de sign-out e deleção de conta com reautenticação quando necessário (`User/ViewModel/
  DeleteUserAccountViewModel.swift`).
  - **Assinaturas / Paywall**
    - Paywall nativo (`Subscription/View/SubscriptionsPickerDefaultView.swift`) com callbacks para finalizar compra em `SubscriptionManager`.
    - Compartilhamento de premium: se o parceiro for premium, `SubscriptionManager` adiciona acesso ao usuário conectado.

  ## Persistência Firebase
  - `users/{uid}`: dados do usuário, `connectionCode`, `connectionId`, `userImageLink`, `subscribedProductId`, `subscriptionExpirationDate`.
  - `connectionInvitations/{connectionId}`: `from`, `to`, `createdAt`, `isAccepted`.
  - `connectionData/{connectionId}/specialDates/{uuid}`: `dateType`, `date`, `isSelectedToDisplayInHomeView`, `addedBy`, `addedAt`.
  - `connectionData/{connectionId}/goals/{uuid}`: `title`, `idsChecked`, `isSelectedToDisplayInHomeView`, `addedBy`, `addedAt`.
  - `connectionData/{connectionId}/loveMessages/{userId}`: `content`, `addedBy`, `addedAt`.
  - Storage: `userImages/{uid}.jpg`.

  ## Localização & UI
  - Cores/gradientes em `Assets.xcassets` (convites, assinatura, datas, love messages).
  - Componentes reutilizáveis em `Shared/View` (text fields, pickers, botões com loading, headers de cards).
  - Espaçamentos padronizados em `Shared/Constants/SpacingConstants.swift`.
  - Localização pronta via `Localized/Localizable.xcstrings` (inglês/PT-BR).

  ## Como rodar
  1. Requisitos: Xcode 15+, iOS 17+ simulador ou device; conta Firebase com Auth/Firestore/Storage; StoreKit 2 habilitado.
  2. Abra `LovU.xcodeproj` na raiz do repositório.
  3. Confirme o arquivo `GoogleService-Info.plist` (`LovU/GoogleService-Info.plist`). Substitua pelo seu se usar outro projeto Firebase.
  4. Se precisar de StoreKit sandbox, use `Subscription/Subscriptions.storekit` e configure o Group ID `1A6A4159` ou ajuste para o seu.
  5. `Run` no esquema LovU (target iOS).

  ## Pastas-chave
  - `LovUApp.swift`: bootstrap e injeção de dependências.
  - `Authentication/`: sheets de login/criação/reauth + handlers Firebase.
  - `ConnectionCode/`: convites, código único e vínculo entre parceiros.
  - `Home/`, `Header/`, `SpecialDates/`, `Goals/`, `LoveMessages/`: features principais exibidas na Home.
  - `Settings/` e `User/`: perfil, foto, sign-out, deleção de conta.
  - `Subscription/`: paywall e sincronização de assinatura.
  - `Shared/`: componentes visuais, enums de acesso e utilitários.
  - `Images/`: upload de avatar (Storage + Kingfisher).
