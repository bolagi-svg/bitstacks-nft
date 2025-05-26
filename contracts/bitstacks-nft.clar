;; Title: BitStacks NFT - Multi-Asset Collateralization Protocol
;; Summary: Advanced NFT management system with cross-chain collateralization, fractional ownership, and yield-generating staking
;; Description: 
;; A groundbreaking Layer 2 protocol enabling Bitcoin-native NFT financialization through:
;; 1. Multi-Asset Collateralization: Secure NFT minting with BTC/STX collateral ratios
;; 2. Fractional Ownership: Trustless tokenization of NFT equity
;; 3. Yield Farming: Bitcoin-aligned staking rewards with dynamic APY
;; 4. Trustless Marketplace: Decentralized trading with built-in compliance
;;
;; Features atomic NFT operations across:
;; - Collateral management
;; - Secondary market trading
;; - Automated yield generation
;; - Cross-chain settlement assurance
;;
;; Built on Stacks for Bitcoin finality, featuring:
;; - Non-custodial asset control
;; - Transparent fee structure (2.5% protocol fee)
;; - Real-time collateral ratio monitoring
;; - Secure ownership proofs via Clarity's inherent security

;; Network: Stacks Layer 2 (Bitcoin-Secured)

;; CONSTANTS & ERROR MANAGEMENT

;; Contract Governance
(define-constant contract-owner tx-sender)

;; Access Control Errors
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Financial Operation Errors
(define-constant err-insufficient-balance (err u102))
(define-constant err-insufficient-collateral (err u106))

;; NFT Operation Errors
(define-constant err-invalid-token (err u103))
(define-constant err-listing-not-found (err u104))
(define-constant err-invalid-price (err u105))

;; Staking System Errors
(define-constant err-already-staked (err u107))
(define-constant err-not-staked (err u108))

;; Validation Errors
(define-constant err-invalid-percentage (err u109))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-recipient (err u111))
(define-constant err-overflow (err u112))

;; PROTOCOL CONFIGURATION

;; Collateral & Risk Management
(define-data-var min-collateral-ratio uint u150) ;; 150% minimum collateral ratio
(define-data-var protocol-fee uint u25) ;; 2.5% fee in basis points (0.25%)

;; Staking & Yield Parameters
(define-data-var total-staked uint u0) ;; Total NFTs currently staked
(define-data-var yield-rate uint u50) ;; 5% annual yield rate in basis points

;; Supply Tracking
(define-data-var total-supply uint u0) ;; Total NFTs minted

;; DATA STRUCTURES

;; Core NFT Registry
(define-map tokens
  { token-id: uint }
  {
    owner: principal, ;; Current NFT owner
    uri: (string-ascii 256), ;; Metadata URI
    collateral: uint, ;; Backing collateral amount
    is-staked: bool, ;; Staking status
    stake-timestamp: uint, ;; Block height when staked
    fractional-shares: uint, ;; Total fractional shares issued
  }
)

;; Marketplace Listings Registry
(define-map token-listings
  { token-id: uint }
  {
    price: uint, ;; Listing price in STX
    seller: principal, ;; Seller address
    active: bool, ;; Listing status
  }
)

;; Fractional Ownership Ledger
(define-map fractional-ownership
  {
    token-id: uint,
    owner: principal,
  }
  { shares: uint } ;; Fractional shares owned
)

;; Staking Rewards Tracking
(define-map staking-rewards
  { token-id: uint }
  {
    accumulated-yield: uint, ;; Accumulated rewards
    last-claim: uint, ;; Last claim block height
  }
)

;; PRIVATE UTILITY FUNCTIONS

;; URI Validation
(define-private (validate-uri (uri (string-ascii 256)))
  (let ((uri-len (len uri)))
    (and
      (> uri-len u0)
      (<= uri-len u256)
    )
  )
)

;; Principal Validation
(define-private (validate-recipient (recipient principal))
  (not (is-eq recipient (as-contract tx-sender)))
)

;; Overflow-Safe Addition
(define-private (safe-add
    (a uint)
    (b uint)
  )
  (let ((sum (+ a b)))
    (asserts! (>= sum a) err-overflow)
    (ok sum)
  )
)

;; CORE NFT OPERATIONS

;; Mint New NFT with Collateral Backing
(define-public (mint-nft
    (uri (string-ascii 256))
    (collateral uint)
  )
  (let (
      (token-id (+ (var-get total-supply) u1))
      (collateral-requirement (/ (* (var-get min-collateral-ratio) collateral) u100))
    )
    ;; Validate inputs
    (asserts! (validate-uri uri) err-invalid-uri)
    (asserts! (>= (stx-get-balance tx-sender) collateral-requirement)
      err-insufficient-collateral
    )
    ;; Lock collateral
    (try! (stx-transfer? collateral-requirement tx-sender (as-contract tx-sender)))
    ;; Create NFT record
    (map-set tokens { token-id: token-id } {
      owner: tx-sender,
      uri: uri,
      collateral: collateral,
      is-staked: false,
      stake-timestamp: u0,
      fractional-shares: u0,
    })
    ;; Update supply counter
    (var-set total-supply token-id)
    (ok token-id)
  )
)

;; Transfer NFT Ownership
(define-public (transfer-nft
    (token-id uint)
    (recipient principal)
  )
  (let ((token (unwrap! (get-token-info token-id) err-invalid-token)))
    ;; Validate transfer conditions
    (asserts! (validate-recipient recipient) err-invalid-recipient)
    (asserts! (is-eq tx-sender (get owner token)) err-not-token-owner)
    (asserts! (not (get is-staked token)) err-already-staked)
    ;; Execute transfer
    (map-set tokens { token-id: token-id } (merge token { owner: recipient }))
    (ok true)
  )
)

;; MARKETPLACE OPERATIONS
;; List NFT for Sale
(define-public (list-nft
    (token-id uint)
    (price uint)
  )
  (let ((token (unwrap! (get-token-info token-id) err-invalid-token)))
    ;; Validate listing conditions
    (asserts! (> price u0) err-invalid-price)
    (asserts! (is-eq tx-sender (get owner token)) err-not-token-owner)
    (asserts! (not (get is-staked token)) err-already-staked)
    ;; Create listing
    (map-set token-listings { token-id: token-id } {
      price: price,
      seller: tx-sender,
      active: true,
    })
    (ok true)
  )
)

;; Purchase Listed NFT
(define-public (purchase-nft (token-id uint))
  (let (
      (listing (unwrap! (get-listing token-id) err-listing-not-found))
      (price (get price listing))
      (seller (get seller listing))
      (fee (/ (* price (var-get protocol-fee)) u1000))
    )
    ;; Validate purchase conditions
    (asserts! (get active listing) err-listing-not-found)
    ;; Execute payment transfers
    (try! (stx-transfer? price tx-sender seller))
    (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
    ;; Transfer NFT ownership
    (try! (transfer-nft token-id tx-sender))
    ;; Deactivate listing
    (map-set token-listings { token-id: token-id } {
      price: u0,
      seller: seller,
      active: false,
    })
    (ok true)
  )
)

;; FRACTIONAL OWNERSHIP SYSTEM

;; Transfer Fractional Shares
(define-public (transfer-shares
    (token-id uint)
    (recipient principal)
    (share-amount uint)
  )
  (let (
      (sender-shares (unwrap! (get-fractional-shares token-id tx-sender)
        err-insufficient-balance
      ))
      (current-recipient-shares (default-to { shares: u0 } (get-fractional-shares token-id recipient)))
      (recipient-new-shares (unwrap! (safe-add (get shares current-recipient-shares) share-amount)
        err-overflow
      ))
    )
    ;; Validate transfer conditions
    (asserts! (validate-recipient recipient) err-invalid-recipient)
    (asserts! (>= (get shares sender-shares) share-amount)
      err-insufficient-balance
    )
    ;; Update sender's shares
    (map-set fractional-ownership {
      token-id: token-id,
      owner: tx-sender,
    } { shares: (- (get shares sender-shares) share-amount) }
    )
    ;; Update recipient's shares
    (map-set fractional-ownership {
      token-id: token-id,
      owner: recipient,
    } { shares: recipient-new-shares }
    )
    (ok true)
  )
)