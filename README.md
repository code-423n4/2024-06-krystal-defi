# Krystal DeFi audit details
- Total Prize Pool: $20,000 in USDC
  - HM awards: $15,840 in USDC
  - QA awards: $660 in USDC 
  - Judge awards: $3,000 in USDC
  - Scout awards: $500 in USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-06-krystal-defi/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts June 21, 2024 20:00 UTC
- Ends July 1, 2024 20:00 UTC


## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*


## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

# Overview

Krystal's smart contracts simplify the experience of managing liquidity on concentrated liquidity DEXs, such as 
Uniswap V3 or Quickswap V3, by providing these features:
- **Zap In**: Swap any token and add the resulting liquidity to the pool.
- **Adjust**: Withdraw all liquidity from your current position, including unclaimed fees, and then re-add it to a new position.
- **Compound**: Claim your unclaimed fees and automatically add them back to your current position.
- **Zap Out**: Withdraw all liquidity and unclaimed fees from your position, then swap them to any token. 

Users can use any features above in one single transaction. They can leverage these features through the smart contract 
`V3Utils` for manual control. Alternatively, they can allow Krystal to automate the process through the `V3Automation` smart contract.

## Links

- **Previous audits:**  N/A
- **Documentation:** https://docs.krystal.app/
- **Website:** https://krystal.app/
- **X/Twitter:** https://twitter.com/KrystalDefi
- **Telegram:** https://t.me/KrystalDeFi_Global

---


### Files in scope

*See [scope.txt](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/scope.txt)*

| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/Common.sol | 1| 1 | 555 | Handles swap, manages liquidity and charges fees |v3-periphery/interfaces/external/IWETH9.sol<br>v3-periphery/interfaces/INonfungiblePositionManager.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>v3-core/libraries/FullMath.sol<br>@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/security/Pausable.sol|
| /src/EIP712.sol | 1| **** | 35 | |@openzeppelin/contracts/utils/cryptography/ECDSA.sol|
| /src/StructHash.sol | 1| **** | 231 | ||
| /src/V3Automation.sol | 1| **** | 142 | Executes users's order||
| /src/V3Utils.sol | 1| **** | 174 | Helps users managing liquidity manually |@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol|
| **Totals** | **5** | **1** | **1137** | | |

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./script/Common.s.sol |
| ./script/Init.s.sol |
| ./script/StructHash.s.sol |
| ./script/V3Automation.s.sol |
| ./script/V3Utils.s.sol |
| ./script/Verify.s.sol |
| ./test/Helper.t.sol |
| ./test/IntegrationTestBase.sol |
| ./test/integration/Common.t.sol |
| ./test/integration/V3Automation.t.sol |
| ./test/integration/V3Utils.t.sol |
| Totals: 11 |


## Scoping Q &amp; A

### General questions



| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       Any             |
| Test coverage                           | 84.43% (423/501 statements)          |
| ERC721 used  by the protocol            |            ERC721 tokens which minted through NonfungiblePositionManager (NFPM) on Dexs (Uniswap V3, QuickSwap V3)  |
| ERC777 used by the protocol             |           None              |
| ERC1155 used by the protocol            |           None            |
| Chains the protocol will be deployed on | Ethereum,Arbitrum,Base,BSC,Optimism,Polygon |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   Yes  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  No  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | No    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   No  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | No    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | Yes    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | Yes    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | Yes    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | Yes    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | Yes    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | Yes    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | Yes    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  Yes   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | Yes    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   Yes  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | Yes    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | Yes    |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  Yes   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist
N/A


# Additional context

## Main invariants

N/A


## Attack ideas (where to focus for bugs)
N/A

## All trusted roles in the protocol

| Role                                | Description                       |
| ----------------------------------- | ---------------------------- |
| Admin                                | Manage roles, set the maximum fees, pause/unpause contract operation, whitelist NFPM contracts, set fee taker address                  |
| Operator                             | Execute automatic orders for users |
| Withdrawer                           | Withdraw tokens (ERC-20, ERC-721) and native currency |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A


## Running tests

```bash
git clone https://github.com/code-423n4/2024-06-krystal-defi.git
cd 2024-06-krystal-defi
forge update # Install dependencies
cp sample.env  .env

forge test --gas-report
```

To run code coverage
```bash
forge coverage
```


| File                 | % Lines          | % Statements     | % Branches       | % Funcs         |
|----------------------|------------------|------------------|------------------|-----------------|
| src/Common.sol       | 79.23% (164/207) | 82.75% (235/284) | 51.75% (59/114)  | 79.31% (23/29)  |
| src/EIP712.sol       | 60.00% (3/5)     | 75.00% (6/8)     | 100.00% (0/0)    | 75.00% (3/4)    |
| src/StructHash.sol   | 100.00% (16/16)  | 100.00% (32/32)  | 100.00% (0/0)    | 100.00% (16/16) |
| src/V3Automation.sol | 82.26% (51/62)   | 82.86% (58/70)   | 55.26% (21/38)   | 85.71% (6/7)    |
| src/V3Utils.sol      | 82.93% (68/82)   | 85.98% (92/107)  | 58.33% (28/48)   | 100.00% (4/4)   |
| Total                | 81.18% (302/372) | 84.43% (423/501) | 54.00% (108/200)  | 86.67% (52/60) |

## Miscellaneous
Employees of Krystal and employees' family members are ineligible to participate in this audit.
