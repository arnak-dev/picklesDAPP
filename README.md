
---

## ⚙️ Smart Contracts Overview

### 🎯 `Betting` (coming soon in full version)
The platform supports creating and participating in decentralized bets.  
Although the betting contract is not in this demo, the structure is designed for:

- Multi-option predictions  
- USDC-based staking  
- Time-based finalization & reward distribution

---

### 🔒 `Staking.sol`
Users can stake tokens (e.g., USDT or platform-native token) to earn rewards.  
Rewards are based on staking amount and duration. The contract supports:

- Deposit and withdraw  
- Time-based lock logic  
- Admin-configurable reward rates

---

### 🎮 `Game.sol`
This contract defines logic for an on-chain mini-game, such as a prediction round, lottery, or simple skill-based mechanic.  
Can be expanded for reward pools and multiplayer logic.

---

### 👤 `Profile.sol`
Enables users to activate their profiles and participate in gated platform features like staking, voting, or higher-level rewards.  
Includes:

- Profile creation  
- Activation toggle  
- Basic KYC/gamification layer (off-chain optional)

---

## 🌐 Frontend DApp

The demo frontend is built in vanilla HTML & JavaScript and located in `/frontend/index.html`.  
It allows users to:

- Connect MetaMask wallet  
- Interact with staking and game contracts  
- Simulate profile activation  

---

## 🧪 Disclaimer

> ⚠️ **This is a DEMO version (MVP)** of PicklesPad.  
> Not intended for production. Contracts are subject to audit, and this repo is for **testing and showcasing only**.

---

## 📅 Status

- ✅ Contracts uploaded  
- ✅ Frontend DApp integrated  
- 🚧 Full betting engine and cross-chain logic in progress

---

Made with 🥒 by [ARNAK-DEV](https://github.com/ARNAK-DEV)
