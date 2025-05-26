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