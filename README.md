# 🧱 BitStacks NFT Protocol

## Multi-Asset Collateralized NFTs on Bitcoin via Stacks

## 🌐 Overview

**BitStacks** is a cutting-edge Layer 2 NFT protocol built on the [Stacks](https://www.stacks.co/) network to bring **Bitcoin-native NFT financialization**. It unlocks liquidity, utility, and composability for NFTs by enabling collateralization, fractional ownership, and yield generation—all with Bitcoin finality.

## 🔧 Key Features

### ✅ **Multi-Asset Collateralization**

* Mint NFTs backed by **BTC/STX collateral**.
* Enforced **minimum collateral ratio** for security (default 150%).

### ✅ **Fractional Ownership**

* Trustless tokenization of NFT equity.
* Seamless share transfer between principals.

### ✅ **Yield Farming**

* Stake NFTs to earn **dynamic APY** in STX.
* Transparent rewards calculation and claiming.

### ✅ **Decentralized Marketplace**

* List and trade NFTs securely.
* Protocol-enforced compliance and fee handling (2.5%).

### ✅ **Cross-Chain Compatibility**

* Anchored to Bitcoin via Stacks.
* Enables **cross-chain settlement assurance** and real-time collateral monitoring.

## 🧱 Protocol Architecture

```plaintext
                        +--------------------+
                        |   Users & Wallets  |
                        +---------+----------+
                                  |
                                  v
                      +-------------------------+
                      |  Clarity Smart Contract |
                      |     (BitStacks Core)    |
                      +-----------+-------------+
                                  |
         +------------------------+------------------------+
         |                        |                        |
         v                        v                        v
+----------------+     +----------------------+   +----------------------+
| NFT Registry   |     | Fractional Ownership |   | Staking & Yield      |
| - Token URI    |     | - Share Transfers     |   | - Rewards Calculation|
| - Collateral   |     | - Ownership Proofs    |   | - Staking Logic      |
+----------------+     +----------------------+   +----------------------+
                                  |
                                  v
                        +----------------------+
                        |   Marketplace Engine  |
                        | - Listings & Sales    |
                        | - Fee Distribution    |
                        +----------------------+

                             Powered by:
                    - Stacks Blockchain (L2)
                    - Bitcoin Security Layer
```

## 📄 Contract Highlights

* **Language:** [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview)

* **Security:**

  * Overflow-safe arithmetic
  * Immutable ownership & compliance logic
  * URI and principal validation

* **Constants:**

  * `min-collateral-ratio`: 150% (default)
  * `protocol-fee`: 2.5% (in basis points)
  * `yield-rate`: 5% APY (adjustable)

* **State Maps:**

  * `tokens`: NFT metadata and collateral tracking
  * `fractional-ownership`: Share distribution by principal
  * `staking-rewards`: Accrued yields per NFT
  * `token-listings`: Marketplace listings and pricing

## 📈 How It Works

### ➤ Minting an NFT

1. Submit valid metadata URI and collateral.
2. Smart contract locks collateral.
3. NFT is minted with unique `token-id`.

### ➤ Trading NFTs

1. List NFT with price in STX.
2. Buyer pays price + protocol fee.
3. Ownership is transferred atomically.

### ➤ Fractionalization

1. Owner issues shares to participants.
2. Shares can be transferred trustlessly.

### ➤ Staking for Yield

1. NFT is locked for staking.
2. Yields are calculated per block.
3. Owner can claim or unstake to realize rewards.

---

## 💰 Revenue Model

| Source            | Fee                                   |
| ----------------- | ------------------------------------- |
| Marketplace Sales | 2.5% protocol fee                     |
| Staking System    | No protocol cut (rewards go to users) |

---

## 🚀 Deployment

* **Network:** Stacks Layer 2 (Bitcoin-Secured)
* **Contract Language:** Clarity
* **Compatibility:** Hiro Wallet, Clarity Tools

To deploy:

```bash
clarity-cli launch bitstacks-nft.clar
```

## 🧪 Testing

Test with:

* `clarinet test` for unit tests
* Simulate staking and yield logic across block heights
* Verify safe collateralization edge cases

## 📚 Developer Notes

* NFT URI must be valid (max 256 ASCII chars).
* Fractional shares are tracked per NFT and principal.
* Staking is only possible if NFT is not listed or transferred.
* Rewards are calculated using block height approximation (`~52,560 blocks/year`).

## 🛡️ Security Considerations

* **Non-Custodial:** All asset transfers are enforced via Clarity logic.
* **Immutable Logic:** Once deployed, contract logic is publicly auditable and unchangeable.
* **Overflow Checks:** Custom `safe-add` for reward accrual.

## 👥 Community & Contributions

Want to contribute? Open a PR or issue in the repository.

**Join us in building Bitcoin-secured NFT finance!**
