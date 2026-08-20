# NeoVote: Enterprise Decentralized Voting Platform (Mobile App)

## 1. Executive Summary & Architectural Overview
**NeoVote** is a mission-critical, enterprise-grade decentralized voting ecosystem designed to eliminate electoral fraud, guarantee absolute voter anonymity, and maximize democratic participation across universities, non-governmental organizations (NGOs), corporate shareholder boards, and governmental bodies.

The platform marries the **Solana High-Throughput Proof-of-History (PoH) Blockchain** with a **Cross-Platform Flutter Client (iOS & Android)**, backed by a **High-Performance Rust/Actix-Web Relayer Service** and a **React/Next.js Institutional Admin Dashboard**.

```
+-----------------------------------------------------------------------------------+
|                                 NEOVOTE ECOSYSTEM                                 |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|   +--------------------------+                 +------------------------------+   |
|   |   Voter Mobile App       |                 |   Admin Dashboard            |   |
|   |   (Flutter - iOS/Android)|                 |   (React / Next.js Web)      |   |
|   +------------+-------------+                 +--------------+---------------+   |
|                |                                              |                   |
|   HTTPS/gRPC   | (Biometrics, JWT, Encrypted Ballots)         | (RBAC, Audit)     |
|                v                                              v                   |
|   +---------------------------------------------------------------------------+   |
|   |                       Rust Actix-Web Relayer & API Gate                   |   |
|   |  - Token Verification (Firebase/JWT)     - Daraja M-Pesa & Stripe Gateway |   |
|   |  - Zero-Knowledge Nullifier Verification - Redis Queue & Idempotency      |   |
|   |  - Fee-Payer Gasless Transaction Relayer - PostgreSQL State & Audit Log   |   |
|   +-------------------------------------+-------------------------------------+   |
|                                         |                                         |
|                               RPC Calls | (Anchor Program Dispatch)               |
|                                         v                                         |
|   +---------------------------------------------------------------------------+   |
|   |                     Solana Blockchain (Proof-of-History)                  |   |
|   |  - `neovote_program` Smart Contracts (Anchor Framework)                   |   |
|   |  - Immutable Election, Ballot, Option & Nullifier PDAs                    |   |
|   |  - Verifiable Cryptographic Vote Receipts & Mathematical Overflow Checks  |   |
|   +---------------------------------------------------------------------------+   |
+-----------------------------------------------------------------------------------+
```

---

## 2. Business Plan Roadmap & Phase Breakdown

### Phase 1: The Foundation (Months 0–3)
- **Core Security & Cryptography**: Implementation of hardware-backed biometric authentication via LocalAuth, AES-256-GCM voter PII encryption, and Solana Anchor smart contracts.
- **Relayer Architecture**: Stateless Rust relayer paying gas fees so voters do not need native SOL balances.
- **Pilot Deployments**: Pilot voting trials across 3 contracted university student unions (East Africa & Europe).
- **Compliance Baseline**: Decoupling voter identity from ballot selections to guarantee GDPR/Data Protection Act adherence.

### Phase 2: Validation & UX Modernization (Months 4–6)
- **Turnout Telemetry**: Real-time admin analytics dashboard displaying turnout velocity, voter demographics, and anomaly alerts.
- **Localization (i18n)**: Native multi-language support for English (EN), Swahili (SW), and Kinyarwanda (RW).
- **Scale Validation**: 5+ large-scale institutional elections handling 50,000+ concurrent voters with sub-second finality.

### Phase 3: Institutional Expansion (Months 7–12)
- **Complex Ballot Modules**: Ranked-choice (Instant Runoff Voting - IRV), quadratic voting, and weighted shareholder voting.
- **Offline "Queue & Sync" Engine**: SQLite-backed local encrypted queue with nonce collision prevention for low-connectivity zones.
- **Enterprise Integrations**: Active Directory / LDAP / University Student Information System (SIS) roster synchronizers.
- **NGO & County Pilots**: Deployments with international NGOs (e.g., Doctors Without Borders) and Kenyan county governments.

### Phase 4: Enterprise Scale & Sovereign Governance (Year 2+)
- **Zero-Knowledge Proofs (ZKP)**: Complete Groth16/Plonk ZK-SNARK circuit integration for end-to-end mathematical ballot secrecy and tally verifiability.
- **Hardware Security Modules (HSM)**: AWS CloudHSM / Azure Key Vault key custody for all administrative transaction signers.
- **ISO 27001 & SOC 2 Type II**: Full security certification, penetration testing, and forensic audit trail export.
- **Pan-African & Global Expansion**: Rollouts across Tanzania, Uganda, Rwanda, Nigeria, and North American institutions.

---

## 3. Flutter Application Architecture (Comprehensive)

The mobile client is engineered using **Feature-First Clean Architecture**, separating business logic, state management, data repositories, and UI presentations.

```
lib/
|-- app/
|   |-- config/
|   |   |-- app_constants.dart          # Environment variables, cluster endpoints, API URLs
|   |   |-- app_localizations.dart      # Translation engine (English, Swahili, Kinyarwanda)
|   |   |-- app_router.dart             # Declarative route guards, deep link handlers
|   |   `-- app_theme.dart              # Material 3 dark/light palettes, typography, glassmorphism
|   `-- observers/
|       |-- app_observer.dart           # App lifecycle monitor (auto-logout on backgrounding)
|       `-- navigation_observer.dart    # Telemetry and funnel analytics tracking
|-- core/
|   |-- data/
|   |   `-- services/
|   |       `-- offline_service.dart    # SQLite-backed offline encrypted vote queue & background sync
|   |-- errors/
|   |   |-- app_exception.dart          # Base domain exceptions (Network, Auth, Crypto, Solana)
|   |   |-- error_handler.dart          # Global crashlytics and exception catcher
|   |   `-- failure.dart                # User-facing failure representations
|   |-- network/
|   |   |-- api_client.dart             # HTTP/Dio client with JWT interceptors, auto-retry, backoff
|   |   |-- api_exception.dart          # REST & Solana RPC error response deserializer
|   |   `-- network_info.dart           # Connectivity listener for auto-switching offline mode
|   |-- presentation/
|   |   `-- widgets/
|   |       |-- neovote_button.dart     # Primary design system button with haptic feedback
|   |       |-- custom_text_field.dart  # Form fields with animated validation states
|   |       |-- loading_overlay.dart    # Glassmorphism loading barrier
|   |       `-- glass_card.dart         # Frosted glass card with dynamic gradient borders
|   |-- storage/
|   |   |-- database_service.dart       # SQLite local database instance for election caching
|   |   |-- local_storage_service.dart  # Shared preferences for non-sensitive UI settings
|   |   `-- secure_storage_service.dart # Android Keystore / iOS Keychain for private keys & JWTs
|   `-- utils/
|       |-- crypto_utils.dart           # SHA-256, HMAC, and Ed25519 signing helpers
|       |-- data_formatter.dart         # Blockchain signature and address truncator
|       |-- formatters.dart             # Currency, timestamp, and number formatters
|       |-- logger.dart                 # Production-stripped debug logger
|       `-- validators.dart             # National ID, student email, and password regex rules
|-- features/
|   |-- auth/
|   |   |-- data/
|   |   |   |-- models/user_model.dart             # Voter identity, verification level, org affiliation
|   |   |   `-- repositories/auth_repository.dart  # Firebase, Google, GitHub, Biometric auth flows
|   |   |-- presentation/
|   |   |   |-- pages/
|   |   |   |   |-- custom_scaffold.dart           # Shared branded scaffold with background assets
|   |   |   |   |-- forgot_password.dart           # Password reset flow
|   |   |   |   |-- login_page.dart                # Multi-modal login (Email, Google, GitHub, Biometrics)
|   |   |   |   |-- screen_page.dart               # Onboarding landing page
|   |   |   |   `-- signup_page.dart               # Voter enrollment & registration
|   |   |   |-- theme/theme.dart                   # Auth-specific color schemes & styles
|   |   |   `-- widgets/
|   |   |       |-- auth_header.dart               # Branded top banner
|   |   |       `-- screen_button.dart             # Rounded onboarding action button
|   |   `-- providers/auth_provider.dart           # ChangeNotifier managing auth states & sessions
|   |-- elections/
|   |   |-- data/
|   |   |   |-- models/election_model.dart         # Ballot schema, candidate profiles, timelines
|   |   |   `-- repositories/election_repository.dart # Backend election discovery & cached metadata
|   |   |-- presentation/
|   |   |   |-- pages/
|   |   |   |   |-- election_detail_page.dart      # Candidate manifestos, rules, voting window
|   |   |   |   |-- election_list_page.dart        # Filtered active/upcoming/closed feeds
|   |   |   |   `-- elections_page.dart            # Main election discovery dashboard
|   |   |   `-- widgets/election_card.dart         # Interactive election countdown & status card
|   |   `-- providers/election_provider.dart       # State management for election catalog
|   |-- voting/
|   |   |-- data/
|   |   |   |-- models/ballot_model.dart           # Solana payload, selections, nullifier hash
|   |   |   `-- repositories/voting_repository.dart# Relayer preparation, signature, and submission
|   |   |-- presentation/
|   |   |   |-- pages/
|   |   |   |   |-- voting_page.dart               # Interactive ballot casting (Single/Ranked/Approval)
|   |   |   |   `-- vote_confirmation.dart         # Cryptographic receipt, QR verification, Tx ID
|   |   |   `-- widgets/vote_option_tile.dart      # Candidate selector with animated selection state
|   |   `-- providers/voting_provider.dart         # State manager for ballot drafting & submission
|   |-- notifications/
|   |   |-- data/
|   |   |   |-- models/notification_model.dart     # Push notification payload structure
|   |   |   |-- repositories/notification_repository.dart # Notification history fetcher
|   |   |   `-- services/fcm_service.dart          # Firebase Cloud Messaging background handler
|   |   `-- presentation/
|   |       |-- pages/notifications_page.dart      # Notification feed & alerts inbox
|   |       `-- widgets/notification_tile.dart     # Dismissible notification list tile
|   `-- payments/
|       |-- data/
|       |   |-- models/payment_model.dart          # STK push / Stripe charge model
|       |   `-- services/payment_service.dart      # M-Pesa Daraja STK Push & Stripe checkout client
|       `-- presentation/pages/payment_page.dart   # Institution fee settlement page
|-- firebase_options.dart                          # Firebase configuration for multi-platform
`-- main.dart                                      # Application entry point with DI initialization
```

---

## 4. End-to-End Voter Flow & Verification Lifecycle

1. **Onboarding & Authentication**:
   - Voter launches app -> passes biometric check (Touch ID / Face ID / Android BiometricPrompt).
   - Secure token exchange: Firebase ID Token is exchanged with the NeoVote Rust backend for a scoped Session JWT.
2. **Election Discovery**:
   - `election_repository.dart` requests eligible elections for the authenticated voter's organization.
   - Metadata is cached in local SQLite via `database_service.dart` for instant offline accessibility.
3. **Ballot Preparation & Cryptographic Anonymization**:
   - Voter selects candidates on `voting_page.dart`.
   - The app derives a deterministic **Voter Nullifier Hash**:
     $$\text{Nullifier} = \text{HMAC-SHA256}(\text{VoterPrivateKey}, \text{ElectionID})$$
   - This ensures **1 Person = 1 Vote** without linking the voter's public key or PII to the ballot on-chain.
4. **Gasless Blockchain Relaying**:
   - The app prepares a `VotePreparationPayload` and sends it to the Rust Relayer `/v1/votes/prepare`.
   - The Rust Relayer acts as the fee-payer, signs the outer transaction, and submits it to the Solana cluster.
5. **Instant Receipt Generation**:
   - Solana records the vote and returns the Transaction Signature.
   - The app displays `vote_confirmation.dart` containing a verifiable QR code, block number, and nullifier receipt.

---

## 5. Requirement Traceability Matrix

| Business / Security Requirement | Architecture Component | Implementation File(s) |
| :--- | :--- | :--- |
| **Solana Immutability** | Anchor Smart Contract | `voting_repository.dart`, `ballot_model.dart`, `neovote_program` |
| **Secret Ballot / Anonymity** | Cryptographic Nullifier & Relayer | `crypto_utils.dart`, `secure_storage_service.dart`, `voting_repository.dart` |
| **Biometric & Social Auth** | LocalAuth + Firebase | `login_page.dart`, `auth_repository.dart`, `auth_provider.dart` |
| **Offline "Queue & Sync"** | SQLite + Background Sync Engine | `offline_service.dart`, `database_service.dart`, `network_info.dart` |
| **M-Pesa STK Push Payment** | Safaricom Daraja API | `payment_service.dart`, `payment_model.dart` |
| **Multi-Language Support** | Flutter Localizations (i18n) | `app_localizations.dart`, ARB translation files |
| **Secure Key Storage** | Android Keystore / iOS Keychain | `secure_storage_service.dart` |
| **Forensic Crash Tracking** | Error Management & Sentry | `error_handler.dart`, `app_exception.dart`, `failure.dart` |

---

## 6. Setup & Installation Guide

### Prerequisites
- Flutter SDK (>= 3.12.2)
- Dart SDK (>= 3.3.0)
- Android Studio / Xcode with CocoaPods
- Firebase Project with Auth and Cloud Messaging enabled
- Local or Devnet Solana RPC node

### Commands
```bash
# 1. Clone repository
git clone https://github.com/Victor-shadow/neovote.git
cd neovote

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase (if regenerating config)
flutterfire configure

# 4. Run Static Analysis & Lint Checks
flutter analyze

# 5. Run Unit & Widget Tests
flutter test

# 6. Launch Debug Build on Connected Device
flutter run
```

---

## 7. Developer & Security Guidelines
1. **Never Log Sensitive PII or Private Keys**: All logging through `logger.dart` is automatically disabled in `kReleaseMode`.
2. **Always Use Cryptographic Nullifiers**: Do not transmit raw voter public keys or student IDs to smart contracts.
3. **Handle Offline Errors Gracefully**: Check `network_info.dart` before initiating network requests; fallback to `offline_service.dart` when disconnected.
