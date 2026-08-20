# NeoVote Backend: Rust/Solana High-Performance Infrastructure

## 1. Architectural Philosophy & System Overview
The **NeoVote Backend** is a distributed, cryptographically resilient engine engineered to handle high-concurrency electronic voting with sub-second latency, zero gas fees for end voters, and mathematical ballot integrity.

It pairs **Actix-Web** (a lightning-fast, actor-based asynchronous web framework in Rust) with **Anchor & Solana SDK** (for deterministic Proof-of-History transaction processing), backed by **PostgreSQL** (for institutional metadata), **Redis** (for sub-millisecond caching and transaction queuing), and **Safaricom Daraja / Stripe** (for monetization).

```
+-----------------------------------------------------------------------------------------------+
|                               NEOVOTE RUST BACKEND ARCHITECTURE                               |
+-----------------------------------------------------------------------------------------------+
|                                                                                               |
|  +--------------------+     +---------------------+     +----------------------------------+  |
|  |  Flutter Mobile    |     |   Admin Dashboard   |     | External Webhooks (M-Pesa/Stripe)|  |
|  +---------+----------+     +----------+----------+     +----------------+-----------------+  |
|            |                           |                                 |                    |
|            v                           v                                 v                    |
|  +-----------------------------------------------------------------------------------------+  |
|  |                                  ACTIX-WEB API GATEWAY                                  |  |
|  |  - `FirebaseAuthMiddleware`: JWT validation & token claims verification                |  |
|  |  - `StructuralLogging`: Forensic JSON request/response telemetry                      |  |
|  |  - `CorsMiddleware`: Strict origin validation for Admin Portal                          |  |
|  |  - Rate-Limiting & Anti-DDoS Bucket Token Filter                                        |  |
|  +---------------------------------------------+-------------------------------------------+  |
|                                                |                                              |
|                                                v                                              |
|  +-----------------------------------------------------------------------------------------+  |
|  |                                 DOMAIN & SERVICES LAYER                                 |  |
|  |  - `v1_handlers.rs`: Auth verification, election discovery, vote preparation            |  |
|  |  - `election_manager.rs`: State machine (Pending -> Active -> Paused -> Finalized)     |  |
|  |  - `ballot_processor.rs`: Rule enforcement (Choice count, Candidate uniqueness)        |  |
|  |  - `voter_verification.rs`: Whitelist & KYC verification engine                         |  |
|  |  - `payment_gateway.rs`: M-Pesa STK push & OAuth token engine                          |  |
|  +-----------------------+-----------------------------+-------------------+---------------+  |
|                          |                             |                   |                  |
|                          v                             v                   v                  |
|  +-------------------------------+ +-----------------------------+ +-----------------------+  |
|  |     POSTGRESQL (via SQLx)     | |    REDIS IN-MEMORY STORE    | |  SOLANA RELAYER ENGINE |  |
|  |  - Organizations & Admins     | |  - Active Ballot Caching    | |  - Gasless Fee Payer  |  |
|  |  - Voter Roster & Eligibility | |  - Rate Limit Counters      | |  - Nonce Management   |  |
|  |  - Forensic Audit Trail Chain | |  - Tx Idempotency Lock      | |  - Tx Batch Submitter |  |
|  +-------------------------------+ +-----------------------------+ +-----------+-----------+  |
|                                                                                |              |
|                                                                                v RPC Client   |
|  +-----------------------------------------------------------------------------------------+  |
|  |                           SOLANA ON-CHAIN ANCHOR SMART CONTRACTS                        |  |
|  |  - `neovote_program`: Program ID: `B4ohcfsHo66iKeJyz27sKAdc62rpdYUg5a15c5cNthiA`        |  |
|  |  - PDAs: `Election`, `Ballot`, `BallotOption`, `Vote` / `Nullifier`, `VoterReceipt`      |  |
|  +-----------------------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------------------+
```

---

## 2. Comprehensive Entity-Relationship Diagram (ERD)

The relational schema stores institutional metadata, administrative logs, voter rosters, and billing states while all definitive vote tallies and receipts live immutably on the Solana blockchain.

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ ADMIN_USERS : employs
    ORGANIZATIONS ||--o{ ELECTIONS : owns
    ORGANIZATIONS ||--o{ BILLING_TRANSACTIONS : pays
    ADMIN_USERS ||--o{ AUDIT_LOGS : performs
    ELECTIONS ||--o{ BALLOTS : contains
    ELECTIONS ||--o{ VOTER_ELIGIBILITY : registers
    BALLOTS ||--o{ BALLOT_OPTIONS : offers
    VOTERS ||--o{ VOTER_ELIGIBILITY : qualifies_for
    VOTERS ||--o{ OFFLINE_SYNC_QUEUE : enqueues
    VOTERS ||--o{ NOTIFICATION_LOGS : receives
    VOTER_ELIGIBILITY ||--o| VOTE_RECEIPTS : produces

    ORGANIZATIONS {
        uuid id PK
        string name
        string domain
        string logo_url
        string primary_color
        string status
        timestamp created_at
    }

    ADMIN_USERS {
        uuid id PK
        uuid organization_id FK
        string email
        string role "SUPER_ADMIN | ORG_ADMIN | AUDITOR"
        string password_hash
        boolean mfa_enabled
        timestamp last_login
    }

    ELECTIONS {
        uuid id PK
        uuid organization_id FK
        bigint solana_election_id UK
        string title
        text description
        string status "PENDING | ACTIVE | PAUSED | FINALIZED"
        timestamp start_time
        timestamp end_time
        boolean allow_ranked_choice
        int max_choices
        int min_choices
        string on_chain_pubkey
    }

    BALLOTS {
        uuid id PK
        uuid election_id FK
        bigint solana_ballot_id UK
        string question
        string ballot_type "SINGLE_CHOICE | RANKED_CHOICE | APPROVAL"
        int order_index
        boolean is_active
        int option_count
    }

    BALLOT_OPTIONS {
        uuid id PK
        uuid ballot_id FK
        bigint solana_option_id UK
        string candidate_name
        string party_affiliation
        string manifesto_url
        string avatar_url
        int display_order
        bigint cached_vote_count
    }

    VOTERS {
        uuid id PK
        string firebase_uid UK
        string encrypted_national_id
        string encrypted_email
        string biometric_pubkey_hash
        boolean is_verified
        timestamp created_at
    }

    VOTER_ELIGIBILITY {
        uuid id PK
        uuid voter_id FK
        uuid election_id FK
        string voter_nullifier_hash UK
        string status "INVITED | VERIFIED | VOTED | REVOKED"
        timestamp voted_at
    }

    VOTE_RECEIPTS {
        uuid id PK
        uuid eligibility_id FK
        bigint solana_vote_id
        string transaction_signature UK
        bigint block_number
        timestamp block_timestamp
        string receipt_hash
    }

    BILLING_TRANSACTIONS {
        uuid id PK
        uuid organization_id FK
        string gateway "MPESA | STRIPE"
        decimal amount
        string currency
        string status "PENDING | COMPLETED | FAILED"
        string merchant_request_id
        string checkout_request_id
        string receipt_number
        timestamp created_at
    }

    AUDIT_LOGS {
        uuid id PK
        uuid actor_id FK
        string actor_type "ADMIN | RELAYER | SYSTEM"
        string event_type
        jsonb payload
        string previous_log_hash
        string current_hash
        timestamp created_at
    }

    OFFLINE_SYNC_QUEUE {
        uuid id PK
        uuid voter_id FK
        text encrypted_vote_payload
        string nonce UK
        string sync_status "QUEUED | PROCESSING | CONFIRMED | FAILED"
        string failure_reason
        timestamp enqueued_at
    }

    NOTIFICATION_LOGS {
        uuid id PK
        uuid voter_id FK
        string channel "FCM | SMS"
        string template_id
        string status "SENT | DELIVERED | FAILED"
        timestamp sent_at
    }
```

---

## 3. Solana On-Chain Account State & PDA Architecture

The Solana Anchor program (`neovote_program`) uses Program Derived Addresses (PDAs) to ensure deterministic, permissioned access to state accounts without centralized custody.

```mermaid
graph TD
    Authority["Program Authority / Relayer Keypair"] -->|"Initializes (ELECTION_SEED, election_id)"| ElectionPDA["Election PDA Account<br/>Seeds: ['election', election_id]"]
    ElectionPDA -->|"Initializes (BALLOT_SEED, election, ballot_id)"| BallotPDA["Ballot PDA Account<br/>Seeds: ['ballot', election_pubkey, ballot_id]"]
    BallotPDA -->|"Initializes (OPTION_SEED, ballot, option_id)"| OptionPDA["Option PDA Account<br/>Seeds: ['option', ballot_pubkey, option_id]"]
    
    Voter["Voter (Signing via Relayer)"] -->|"Casts Vote (VOTE_SEED, ballot, payer)"| VotePDA["Vote PDA Account<br/>Seeds: ['vote', ballot_pubkey, payer_pubkey]"]
    Voter -->|"Mints Receipt (RECEIPT_SEED, ballot, payer)"| ReceiptPDA["VoterReceipt PDA Account<br/>Seeds: ['receipt', ballot_pubkey, payer_pubkey]"]
    
    VotePDA -->|"Updates Vote Count"| OptionPDA
```

### PDA Derivation Reference Table

| Account | Seed Derivation Scheme | Space Allocated | Description |
| :--- | :--- | :--- | :--- |
| `Election` | `[b"election", &election_id.to_le_bytes()]` | `8 + Election::INIT_SPACE` | Stores election metadata, timeline, creator, and active status |
| `Ballot` | `[b"ballot", election.key().as_ref(), &ballot_id.to_le_bytes()]` | `8 + Ballot::INIT_SPACE` | Represents a contest/question inside an election |
| `BallotOption` | `[b"option", ballot.key().as_ref(), &option_id.to_le_bytes()]` | `8 + BallotOption::INIT_SPACE` | Represents candidate or referendum choice; holds vote tally |
| `Vote` | `[b"vote", ballot.key().as_ref(), payer.key().as_ref()]` | `8 + Vote::INIT_SPACE` | On-chain vote record preventing double voting |
| `VoterReceipt` | `[b"receipt", ballot.key().as_ref(), payer.key().as_ref()]` | `8 + VoterReceipt::INIT_SPACE` | Anonymized voter receipt containing cryptographic proof |
| `BlockchainTransaction` | Unseeded Init | `8 + BlockchainTransaction::INIT_SPACE` | Forensic transaction record referencing Solana blockhash |

---

## 4. Backend Source Code Breakdown (`src/`)

```
src/
|-- api/
|   |-- mod.rs                  # Module aggregator & route binder
|   |-- v1_handlers.rs          # HTTP endpoint handlers (/auth/verify, /elections/list, /votes/prepare)
|   `-- middleware/
|       |-- auth.rs             # Actix-Web Transform & Service for Firebase JWT authentication
|       |-- logging.rs          # Structured JSON request/response telemetry Logger
|       `-- cors.rs             # Cross-Origin Resource Sharing policy definition
|-- domain/
|   |-- mod.rs                  # Domain exports
|   |-- models.rs               # Strongly typed domain entities (VoterId, ElectionId, Ballot, Rules)
|   |-- election_manager.rs     # Election state machine & lifecycle transition validators
|   |-- voter_verification.rs   # Identity validation & eligibility revocation logic
|   `-- ballot_processor.rs     # Ballot integrity & candidate uniqueness validation rules
|-- blockchain/
|   |-- mod.rs                  # Blockchain exports
|   |-- solana_client.rs        # Non-blocking Solana RPC wrapper with exponential backoff retry logic
|   |-- program_interface.rs    # Borsh-serialized payload layouts matching Anchor program
|   |-- transaction_builder.rs  # Solana instruction compiler & fee-payer relayer signer
|   `-- contract_tests.rs       # Anchor test harnesses using solana-program-test
|-- security/
|   |-- mod.rs                  # Security primitives exports
|   |-- aes_engine.rs           # AES-256-GCM symmetric encryption for voter PII
|   |-- hsm_connector.rs        # Interface for AWS CloudHSM / Azure Key Vault relayer signing
|   `-- audit_trail.rs          # Tamper-evident cryptographic SHA-256 hash-chained log engine
|-- services/
|   |-- mod.rs                  # Services exports
|   |-- payment_gateway.rs      # Safaricom M-Pesa Daraja OAuth & STK Push integration
|   |-- notification_engine.rs  # Asynchronous FCM push & Twilio SMS delivery dispatcher
|   `-- analytics_service.rs    # Real-time turnout aggregator for admin graphs
|-- infra/
|   |-- mod.rs                  # Infra exports
|   |-- config.rs               # Environment variable parser with typed fallbacks
|   |-- db_pool.rs              # PostgreSQL connection pool builder using SQLx
|   `-- redis_cache.rs          # Redis connection pool & async cache helper methods
|-- lib.rs                      # Library root, AppState definition, and module hierarchy
`-- main.rs                     # Runtime entry point initializing pools, workers, and HTTP server
```

---

## 5. Core API Endpoints Specification

### 1. Digital Identity Verification
- **Endpoint**: `POST /api/v1/auth/verify`
- **Headers**: `Authorization: Bearer <FIREBASE_ID_TOKEN>`
- **Request Body**:
  ```json
  {
    "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "valid": true,
    "uid": "usr_9a4f21cb880e"
  }
  ```

### 2. Active Election Discovery
- **Endpoint**: `GET /api/v1/elections/list`
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Response** (`200 OK`):
  ```json
  [
    {
      "id": "e0b83b40-77a8-48b9-a298-b80c10ad8192",
      "title": "University Student Council Presidential Election 2026",
      "description": "General election for university-wide student leadership.",
      "active": true,
      "start_time": "2026-08-20T08:00:00Z",
      "end_time": "2026-08-20T17:00:00Z",
      "rules": {
        "allow_ranked_choice": false,
        "max_choices": 1,
        "min_choices": 1
      }
    }
  ]
  ```

### 3. Gasless Vote Preparation & Relayer Nonce
- **Endpoint**: `POST /api/v1/votes/prepare`
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Request Body**:
  ```json
  {
    "election_id": "e0b83b40-77a8-48b9-a298-b80c10ad8192",
    "voter_id": "usr_9a4f21cb880e"
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "fee_lamports": 5000,
    "recent_blockhash": "EkSnNWgr2Yy3A8679EPiW9c3vj8yTpmxYkY... "
  }
  ```

### 4. M-Pesa STK Push Payment Initiation
- **Endpoint**: `POST /api/v1/payments/mpesa/stkpush`
- **Request Body**:
  ```json
  {
    "phone_number": "254712345678",
    "amount": 50.00,
    "account_reference": "ELEC-2026-01",
    "transaction_desc": "NeoVote Election Activation Fee"
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "merchant_request_id": "29115-34620561-1",
    "checkout_request_id": "ws_CO_19082026112835987",
    "response_code": "0",
    "response_description": "Success. Request accepted for processing"
  }
  ```

---

## 6. Environment Variables & Configuration

Create a `.env` file in the backend root directory:

```ini
# Server Binding
BIND_ADDRESS=0.0.0.0
BIND_PORT=8080
WORKERS=4
REQUEST_TIMEOUT=10

# Database & Cache
DATABASE_URL=postgres://neovote_user:neovote_secret@localhost:5432/neovote_db
REDIS_URL=redis://127.0.0.1:6379

# Solana Blockchain
SOLANA_RPC_URL=https://api.devnet.solana.com
SOLANA_RELAYER_KEYPAIR_PATH=/etc/neovote/relayer-keypair.json
SOLANA_PROGRAM_ID=B4ohcfsHo66iKeJyz27sKAdc62rpdYUg5a15c5cNthiA

# Payment Gateways (M-Pesa Daraja & Stripe)
DAR_AJA_KEY=Ap4kwlo9rpFuTDdEnLZHv9BDEM40WtuCBBSIQGJz3MRQrY7O
DAR_AJA_SECRET=l0ACacu8GeQoUgWs7mlStgAoFpGusXxrmGhC0EKRrGt5LvTQjmqN2nDHyGKyue0W
STRIPE_SECRET_KEY=sk_test_...

# Messaging & Alerts
FCM_SERVER_KEY=AAAAv8...
SMS_API_KEY=atk_live_...
SMS_GATEWAY_URL=https://api.africastalking.com/version1/messaging
```

---

## 7. Building & Testing Commands

```bash
# 1. Check syntax and compilation
cargo check

# 2. Run unit and integration test suite
cargo test

# 3. Run with release optimizations
cargo run --release

# 4. Build and test Solana Anchor program
anchor build
anchor test
```
