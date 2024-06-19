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

[ ⭐️ SPONSORS: add info here ]

## Links

- **Previous audits:**  N/A
- **Documentation:** https://docs.krystal.app/
- **Website:** https://krystal.app/
- **X/Twitter:** https://twitter.com/KrystalDefi
- **Telegram:** https://t.me/KrystalDeFi_Global

---


### Files in scope

[ ⭐️ SPONSORS: please fill in the purpose column ]


*See [scope.txt](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/scope.txt)*

| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/Common.sol | 1| 1 | 555 | |v3-periphery/interfaces/external/IWETH9.sol<br>v3-periphery/interfaces/INonfungiblePositionManager.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>v3-core/libraries/FullMath.sol<br>@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/security/Pausable.sol|
| /src/EIP712.sol | 1| **** | 35 | |@openzeppelin/contracts/utils/cryptography/ECDSA.sol|
| /src/StructHash.sol | 1| **** | 231 | ||
| /src/V3Automation.sol | 1| **** | 142 | ||
| /src/V3Utils.sol | 1| **** | 174 | |@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol|
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
| Test coverage                           | ✅ SCOUTS: Please populate this after running the test coverage command                          |
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
| Enabling/disabling fees (e.g. Blur disables/enables fees) | Yes   |
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

[ ⭐️ SPONSORS: please fill in the description column ]


| Role                                | Description                       |
| ----------------------------------- | ---------------------------- |
| Owner                                |                   |
| Operator                             |                        |
| Withdrawer                           |                        |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A


## Running tests

```bash
git clone https://github.com/code-423n4/2024-06-krystal-defi.git
cd 2024-06-krystal-defi
forge update # Install dependencies

forge test --gas-report
```

To run code coverage
```bash
forge coverage
```


✅ SCOUTS: Add a screenshot of your terminal showing the test coverage

## Miscellaneous
Employees of Krystal and employees' family members are ineligible to participate in this audit.
