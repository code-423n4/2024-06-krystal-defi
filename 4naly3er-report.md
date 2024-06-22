# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 8 |
| [GAS-2](#GAS-2) | Using bools for storage incurs overhead | 2 |
| [GAS-3](#GAS-3) | Cache array length outside of loop | 1 |
| [GAS-4](#GAS-4) | For Operations that will not overflow, you could use unchecked | 65 |
| [GAS-5](#GAS-5) | Use Custom Errors instead of Revert Strings to save Gas | 2 |
| [GAS-6](#GAS-6) | Avoid contract existence checks by using low level calls | 16 |
| [GAS-7](#GAS-7) | Functions guaranteed to revert when called by normal users can be marked `payable` | 4 |
| [GAS-8](#GAS-8) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 2 |
| [GAS-9](#GAS-9) | Using `private` rather than `public` for constants, saves gas | 3 |
| [GAS-10](#GAS-10) | Increments/decrements can be unchecked in for-loops | 3 |
| [GAS-11](#GAS-11) | Use != 0 instead of > 0 for unsigned integer comparison | 16 |
### <a name="GAS-1"></a>[GAS-1] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (8)*:
```solidity
File: src/V3Automation.sol

292:                 targetAmount += amountOutDelta;

294:                 targetAmount += state.amount0;

313:                 targetAmount += amountOutDelta;

315:                 targetAmount += state.amount1;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

352:                 targetAmount += amountOutDelta;

354:                 targetAmount += amount0;

373:                 targetAmount += amountOutDelta;

375:                 targetAmount += amount1;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="GAS-2"></a>[GAS-2] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (2)*:
```solidity
File: src/Common.sol

149:     bool private _initialized = false;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

11:     mapping(bytes32 => bool) _cancelledOrder;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

### <a name="GAS-3"></a>[GAS-3] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (1)*:
```solidity
File: src/Common.sol

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="GAS-4"></a>[GAS-4] For Operations that will not overflow, you could use unchecked

*Instances (65)*:
```solidity
File: src/Common.sol

144:         _maxFeeX64[FeeType.GAS_FEE] = 1844674407370955264; // 10%

145:         _maxFeeX64[FeeType.PROTOCOL_FEE] = 1844674407370955264; // 10%

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

202:         address recipient; // recipient of tokens

229:         address recipient; // recipient of leftover tokens

298:         for (uint i = 0; i < count; ++i) {

377:                 amount0 - amountAdded0

380:             if (balanceAfter - balanceBefore != amount0 - amountAdded0) {

381:                 revert TransferError(); // reverts for fee-on-transfer tokens

390:                 amount1 - amountAdded1

393:             if (balanceAfter - balanceBefore != amount1 - amountAdded1) {

394:                 revert TransferError(); // reverts for fee-on-transfer tokens

408:                 amountOther - amountAddedOther

412:                 balanceAfter - balanceBefore != amountOther - amountAddedOther

414:                 revert TransferError(); // reverts for fee-on-transfer tokens

454:                     address(this), // is sent to real recipient aftwards

477:                     address(this), // is sent to real recipient aftwards

550:                 address(this), // is sent to real recipient aftwards

654:             total0 = params.amount0 - amountInDelta;

655:             total1 = params.amount1 + amountOutDelta;

667:             total1 = params.amount1 - amountInDelta;

668:             total0 = params.amount0 + amountOutDelta;

684:             total0 = params.amount0 + amountOutDelta0;

685:             total1 = params.amount1 + amountOutDelta1;

687:             if (params.amount2 < amountInDelta0 + amountInDelta1) {

691:             uint256 leftOver = params.amount2 - amountInDelta0 - amountInDelta1;

720:         uint256 left0 = params.total0 - params.added0;

721:         uint256 left1 = params.total1 - params.added1;

795:             amountInDelta = balanceInBefore - balanceInAfter;

796:             amountOutDelta = balanceOutAfter - balanceOutBefore;

858:         if (balanceAfter0 - balanceBefore0 != amount0) {

861:         if (balanceAfter1 - balanceBefore1 != amount1) {

887:                 uint256 fees0Return = amount0 - positionAmount0;

888:                 uint256 fees1Return = amount1 - positionAmount1;

1015:         uint256 Q64 = 2 ** 64;

1027:             amount0Left = params.amount0 - feeAmount0;

1036:             amount1Left = params.amount1 - feeAmount1;

1045:             amount2Left = params.amount2 - feeAmount2;

1139:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

54:         uint128 liquidity; // liquidity the calculations are based on

66:         uint256 amountRemoveMin0; // min amount to be removed from liquidity

67:         uint256 amountRemoveMin1; // min amount to be removed from liquidity

68:         uint256 deadline; // for uniswap operations - operator promises fair value

69:         uint64 gasFeeX64; // amount of tokens to be used as gas fee

70:         uint64 protocolFeeX64; // amount of tokens to be used as protocol fee

168:             state.amount0 = state.amount0 - gasFeeAmount0 - protocolFeeAmount0;

169:             state.amount1 = state.amount1 - gasFeeAmount1 - protocolFeeAmount1;

288:                         state.amount0 - amountInDelta,

292:                 targetAmount += amountOutDelta;

294:                 targetAmount += state.amount0;

309:                         state.amount1 - amountInDelta,

313:                 targetAmount += amountOutDelta;

315:                 targetAmount += state.amount1;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

34:         bytes swapData0; // encoded data from 0x api call (address,bytes) - allowanceTarget,data

39:         bytes swapData1; // encoded data from 0x api call (address,bytes) - allowanceTarget,data

348:                         amount0 - amountInDelta,

352:                 targetAmount += amountOutDelta;

354:                 targetAmount += amount0;

369:                         amount1 - amountInDelta,

373:                 targetAmount += amountOutDelta;

375:                 targetAmount += amount1;

412:         address recipient; // recipient of tokenOut and leftover tokenIn (if any leftover)

414:         bool unwrap; // if tokenIn or tokenOut is WETH - unwrap

433:             params.amountIn0 + params.amountIn1 > params.amount2

526:             params.amountIn0 + params.amountIn1 > params.amount2

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="GAS-5"></a>[GAS-5] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (2)*:
```solidity
File: src/Common.sol

786:                 revert("swap failed!");

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Utils.sol

514:         require(owner == msg.sender, "sender is not owner of position");

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="GAS-6"></a>[GAS-6] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (16)*:
```solidity
File: src/Common.sol

299:             uint256 balance = tokens[i].balanceOf(address(this));

372:             uint256 balanceBefore = token0.balanceOf(address(this));

379:             uint256 balanceAfter = token0.balanceOf(address(this));

385:             uint256 balanceBefore = token1.balanceOf(address(this));

392:             uint256 balanceAfter = token1.balanceOf(address(this));

403:             uint256 balanceBefore = otherToken.balanceOf(address(this));

410:             uint256 balanceAfter = otherToken.balanceOf(address(this));

778:             uint256 balanceInBefore = tokenIn.balanceOf(address(this));

779:             uint256 balanceOutBefore = tokenOut.balanceOf(address(this));

792:             uint256 balanceInAfter = tokenIn.balanceOf(address(this));

793:             uint256 balanceOutAfter = tokenOut.balanceOf(address(this));

844:         uint256 balanceBefore0 = token0.balanceOf(address(this));

845:         uint256 balanceBefore1 = token1.balanceOf(address(this));

854:         uint256 balanceAfter0 = token0.balanceOf(address(this));

855:         uint256 balanceAfter1 = token1.balanceOf(address(this));

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/EIP712.sol

32:         return ECDSA.recover(digest, signature);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/EIP712.sol)

### <a name="GAS-7"></a>[GAS-7] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (4)*:
```solidity
File: src/Common.sol

310:     function withdrawNative(address to) external onlyRole(WITHDRAWER_ROLE) {

1075:     function pause() external onlyRole(ADMIN_ROLE) {

1079:     function unpause() external onlyRole(ADMIN_ROLE) {

1148:     function setFeeTaker(address feeTaker) external onlyRole(ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="GAS-8"></a>[GAS-8] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (2)*:
```solidity
File: src/Common.sol

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

1139:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="GAS-9"></a>[GAS-9] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (3)*:
```solidity
File: src/Common.sol

54:     bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

55:     bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

10:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

### <a name="GAS-10"></a>[GAS-10] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (3)*:
```solidity
File: src/Common.sol

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

298:         for (uint i = 0; i < count; ++i) {

1139:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="GAS-11"></a>[GAS-11] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (16)*:
```solidity
File: src/Common.sol

300:             if (balance > 0) {

312:         if (nativeBalance > 0) {

644:             if (params.amount0 < params.amountIn1) {

890:                 if (fees0Return > 0) {

897:                 if (fees1Return > 0) {

1025:         if (params.amount0 > 0) {

1034:         if (params.amount1 > 0) {

1043:         if (params.amount2 > 0) {

1109:         require(_value > 0);

1121:         if (returnData.length > 0) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

130:             if (params.gasFeeX64 > 0) {

150:             if (params.protocolFeeX64 > 0) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

118:         if (instructions.protocolFeeX64 > 0) {

139:             amount0 < instructions.amountIn0 || amount1 < instructions.amountIn1

449:         if (params.protocolFeeX64 > 0) {

541:         if (params.protocolFeeX64 > 0) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe | 3 |
| [NC-2](#NC-2) | Constants should be in CONSTANT_CASE | 16 |
| [NC-3](#NC-3) | `constant`s should be defined rather than using magic numbers | 3 |
| [NC-4](#NC-4) | Control structures do not follow the Solidity Style Guide | 10 |
| [NC-5](#NC-5) | Critical Changes Should Use Two-step Procedure | 1 |
| [NC-6](#NC-6) | Default Visibility for constants | 16 |
| [NC-7](#NC-7) | Functions should not be longer than 50 lines | 22 |
| [NC-8](#NC-8) | Change uint to uint256 | 2 |
| [NC-9](#NC-9) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 2 |
| [NC-10](#NC-10) | Consider using named mappings | 2 |
| [NC-11](#NC-11) | Take advantage of Custom Error's return value property | 27 |
| [NC-12](#NC-12) | Avoid the use of sensitive terms | 17 |
| [NC-13](#NC-13) | Use Underscores for Number Literals (add an underscore every 3 digits) | 2 |
| [NC-14](#NC-14) | Variables need not be initialized to zero | 3 |
### <a name="NC-1"></a>[NC-1] Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe
When using `abi.encodeWithSignature`, it is possible to include a typo for the correct function signature.
When using `abi.encodeWithSignature` or `abi.encodeWithSelector`, it is also possible to provide parameters that are not of the correct type for the function.

To avoid these pitfalls, it would be best to use [`abi.encodeCall`](https://solidity-by-example.org/abi-encode/) instead.

*Instances (3)*:
```solidity
File: src/Common.sol

939:             abi.encodeWithSignature("positions(uint256)", tokenId)

1105:             abi.encodeWithSelector(token.approve.selector, _spender, 0)

1119:             abi.encodeWithSelector(token.approve.selector, _spender, _value)

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="NC-2"></a>[NC-2] Constants should be in CONSTANT_CASE
For `constant` variable names, each word should use all capital letters, with underscores separating each word (CONSTANT_CASE)

*Instances (16)*:
```solidity
File: src/StructHash.sol

9:     bytes32 constant AutoCompound_TYPEHASH = 0xc696e49b5b777ed39ec78fbfc2b42b9399d1edc7f3ea2bcf66b5d1fbd1e44ea8;

23:     bytes32 constant AutoCompoundAction_TYPEHASH = 0x3368609ed4d6c8bbf3f89c3340dfda10f6a3b6cbbf269a1ee1acab352e39d592;

39:     bytes32 constant TickOffsetCondition_TYPEHASH = 0x62a0ad438254a5fc08168ddf3cb49a0b3c0e730e76f4fa785b4df532bc2dafb9;

55:     bytes32 constant PriceOffsetCondition_TYPEHASH = 0xee7cf2600f91b8ddafa790dd184ce3c665f9dc116423525b336e1edac8e07e12;

73:     bytes32 constant TokenRatioCondition_TYPEHASH = 0x45ae7b1ead003f850829121834fe562edded567cc66a42e8315561c98a7735f9;

89:     bytes32 constant RebalanceCondition_TYPEHASH = 0x79a6efb57bb0d511e670abb964181b04730ebe3a5fd187d05341eeb9288deef8;

113:     bytes32 constant TickOffsetAction_TYPEHASH = 0xf5f25bd65589108507b815014b323a5f159027eba9a477039a198a5f7fc368fc;

129:     bytes32 constant PriceOffsetAction_TYPEHASH = 0x0a6de33fb4ce9e036ea5aa72e73288d926400e8cc438f63c7c1c84b392c5801c;

147:     bytes32 constant TokenRatioAction_TYPEHASH = 0x2d91584261cab64f66268846e106be0b9e325f19b0457d3be9790bff2e4d9259;

163:     bytes32 constant RebalanceAction_TYPEHASH = 0xe862ada4db7ad1d390d5445cf9eae9093553a68a1c33bdc043a9b9868c555579;

189:     bytes32 constant RebalanceConfig_TYPEHASH = 0xf415885b16dd99154167dc3471d942b4653222ee365743f5e7f22f0f11f6b37c;

209:     bytes32 constant RangeOrderCondition_TYPEHASH = 0xb6800e34595dae872617c5005f10a6a9e2b6a2520654db474bf4750fdd70a0c8;

227:     bytes32 constant RangeOrderAction_TYPEHASH = 0xf512215c27c5930c08d4f9d3f8d89d9b5735fb786bebf2231b3e88df5c4015d9;

245:     bytes32 constant RangeOrderConfig_TYPEHASH = 0x896dec1198540e9a29dda867832b7bb119f2cec50527c0f5ee63ef305b0f539a;

261:     bytes32 constant OrderConfig_TYPEHASH = 0x065b4cd96c3232169bffd05f96758c6381c4797dce4724b29ca398f302c8d58a;

277:     bytes32 constant Order_TYPEHASH = 0x8201e8c31784c3b8b26a36edc724801769c61b18d1a75e21a780d4bf1ad29272;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/StructHash.sol)

### <a name="NC-3"></a>[NC-3] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (3)*:
```solidity
File: src/Common.sol

144:         _maxFeeX64[FeeType.GAS_FEE] = 1844674407370955264; // 10%

145:         _maxFeeX64[FeeType.PROTOCOL_FEE] = 1844674407370955264; // 10%

1015:         uint256 Q64 = 2 ** 64;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="NC-4"></a>[NC-4] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (10)*:
```solidity
File: src/Common.sol

397:         if (

411:             if (

773:         if (

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/EIP712.sol

10:             "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/EIP712.sol)

```solidity
File: src/V3Utils.sol

138:         if (

330:         } else if (

412:         address recipient; // recipient of tokenOut and leftover tokenIn (if any leftover)

414:         bool unwrap; // if tokenIn or tokenOut is WETH - unwrap

430:         if (

523:         if (

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="NC-5"></a>[NC-5] Critical Changes Should Use Two-step Procedure
The critical procedures should be two step process.

See similar findings in previous Code4rena contests for reference: <https://code4rena.com/reports/2022-06-illuminate/#2-critical-changes-should-use-two-step-procedure>

**Recommended Mitigation Steps**

Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:
```solidity
File: src/Common.sol

1148:     function setFeeTaker(address feeTaker) external onlyRole(ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="NC-6"></a>[NC-6] Default Visibility for constants
Some constants are using the default visibility. For readability, consider explicitly declaring them as `internal`.

*Instances (16)*:
```solidity
File: src/StructHash.sol

9:     bytes32 constant AutoCompound_TYPEHASH = 0xc696e49b5b777ed39ec78fbfc2b42b9399d1edc7f3ea2bcf66b5d1fbd1e44ea8;

23:     bytes32 constant AutoCompoundAction_TYPEHASH = 0x3368609ed4d6c8bbf3f89c3340dfda10f6a3b6cbbf269a1ee1acab352e39d592;

39:     bytes32 constant TickOffsetCondition_TYPEHASH = 0x62a0ad438254a5fc08168ddf3cb49a0b3c0e730e76f4fa785b4df532bc2dafb9;

55:     bytes32 constant PriceOffsetCondition_TYPEHASH = 0xee7cf2600f91b8ddafa790dd184ce3c665f9dc116423525b336e1edac8e07e12;

73:     bytes32 constant TokenRatioCondition_TYPEHASH = 0x45ae7b1ead003f850829121834fe562edded567cc66a42e8315561c98a7735f9;

89:     bytes32 constant RebalanceCondition_TYPEHASH = 0x79a6efb57bb0d511e670abb964181b04730ebe3a5fd187d05341eeb9288deef8;

113:     bytes32 constant TickOffsetAction_TYPEHASH = 0xf5f25bd65589108507b815014b323a5f159027eba9a477039a198a5f7fc368fc;

129:     bytes32 constant PriceOffsetAction_TYPEHASH = 0x0a6de33fb4ce9e036ea5aa72e73288d926400e8cc438f63c7c1c84b392c5801c;

147:     bytes32 constant TokenRatioAction_TYPEHASH = 0x2d91584261cab64f66268846e106be0b9e325f19b0457d3be9790bff2e4d9259;

163:     bytes32 constant RebalanceAction_TYPEHASH = 0xe862ada4db7ad1d390d5445cf9eae9093553a68a1c33bdc043a9b9868c555579;

189:     bytes32 constant RebalanceConfig_TYPEHASH = 0xf415885b16dd99154167dc3471d942b4653222ee365743f5e7f22f0f11f6b37c;

209:     bytes32 constant RangeOrderCondition_TYPEHASH = 0xb6800e34595dae872617c5005f10a6a9e2b6a2520654db474bf4750fdd70a0c8;

227:     bytes32 constant RangeOrderAction_TYPEHASH = 0xf512215c27c5930c08d4f9d3f8d89d9b5735fb786bebf2231b3e88df5c4015d9;

245:     bytes32 constant RangeOrderConfig_TYPEHASH = 0x896dec1198540e9a29dda867832b7bb119f2cec50527c0f5ee63ef305b0f539a;

261:     bytes32 constant OrderConfig_TYPEHASH = 0x065b4cd96c3232169bffd05f96758c6381c4797dce4724b29ca398f302c8d58a;

277:     bytes32 constant Order_TYPEHASH = 0x8201e8c31784c3b8b26a36edc724801769c61b18d1a75e21a780d4bf1ad29272;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/StructHash.sol)

### <a name="NC-7"></a>[NC-7] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (22)*:
```solidity
File: src/Common.sol

48:     function WNativeToken() external view returns (address);

310:     function withdrawNative(address to) external onlyRole(WITHDRAWER_ROLE) {

1079:     function unpause() external onlyRole(ADMIN_ROLE) {

1090:     function getMaxFeeX64(FeeType feeType) external view returns (uint64) {

1130:     function _isWhitelistedNfpm(address nfpm) internal view returns (bool) {

1148:     function setFeeTaker(address feeTaker) external onlyRole(ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/StructHash.sol

13:     function _hash(AutoCompound memory obj) private pure returns (bytes32) {

28:     function _hash(AutoCompoundAction memory obj) private pure returns (bytes32) {

44:     function _hash(TickOffsetCondition memory obj) private pure returns (bytes32) {

61:     function _hash(PriceOffsetCondition memory obj) private pure returns (bytes32) {

78:     function _hash(TokenRatioCondition memory obj) private pure returns (bytes32) {

98:     function _hash(RebalanceCondition memory obj) private pure returns (bytes32) {

118:     function _hash(TickOffsetAction memory obj) private pure returns (bytes32) {

135:     function _hash(PriceOffsetAction memory obj) private pure returns (bytes32) {

152:     function _hash(TokenRatioAction memory obj) private pure returns (bytes32) {

173:     function _hash(RebalanceAction memory obj) private pure returns (bytes32) {

196:     function _hash(RebalanceConfig memory obj) private pure returns (bytes32) {

215:     function _hash(RangeOrderCondition memory obj) private pure returns (bytes32) {

233:     function _hash(RangeOrderAction memory obj) private pure returns (bytes32) {

250:     function _hash(RangeOrderConfig memory obj) private pure returns (bytes32) {

266:     function _hash(OrderConfig memory obj) private pure returns (bytes32) {

286:     function _hash(Order memory obj) external pure returns (bytes32) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/StructHash.sol)

### <a name="NC-8"></a>[NC-8] Change uint to uint256
Throughout the code base, some variables are declared as `uint`. To favor explicitness, consider changing all instances of `uint` to `uint256`

*Instances (2)*:
```solidity
File: src/Common.sol

297:         uint count = tokens.length;

298:         for (uint i = 0; i < count; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="NC-9"></a>[NC-9] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (2)*:
```solidity
File: src/Common.sol

161:         require(msg.sender == _initializer);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Utils.sol

514:         require(owner == msg.sender, "sender is not owner of position");

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="NC-10"></a>[NC-10] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (2)*:
```solidity
File: src/Common.sol

142:     mapping(FeeType => uint64) private _maxFeeX64;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

11:     mapping(bytes32 => bool) _cancelledOrder;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

### <a name="NC-11"></a>[NC-11] Take advantage of Custom Error's return value property
An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (27)*:
```solidity
File: src/Common.sol

159:             revert();

353:                     revert TooMuchEtherSent();

358:                     revert TooMuchEtherSent();

363:                     revert TooMuchEtherSent();

366:                 revert NoEtherToken();

381:                 revert TransferError(); // reverts for fee-on-transfer tokens

394:                 revert TransferError(); // reverts for fee-on-transfer tokens

414:                 revert TransferError(); // reverts for fee-on-transfer tokens

482:             revert NotSupportedProtocol();

645:                 revert AmountError();

658:                 revert AmountError();

688:                 revert AmountError();

756:                 revert EtherSendFailed();

800:                 revert SlippageError();

859:             revert CollectError();

862:             revert CollectError();

919:             revert NotSupportedProtocol();

942:             revert GetPositionFailed();

1017:             revert TooMuchFee();

1022:             revert NoFees();

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

410:             revert NotSupportedAction();

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

89:             revert SelfSend();

141:             revert AmountError();

396:             revert NotSupportedAction();

424:             revert SameToken();

435:             revert AmountError();

528:             revert AmountError();

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="NC-12"></a>[NC-12] Avoid the use of sensitive terms
Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (17)*:
```solidity
File: src/Common.sol

137:     EnumerableSet.AddressSet private _whitelistedNfpm;

155:         address[] calldata whitelistedNfpms

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

170:             EnumerableSet.add(_whitelistedNfpm, whitelistedNfpms[i]);

1130:     function _isWhitelistedNfpm(address nfpm) internal view returns (bool) {

1131:         return EnumerableSet.contains(_whitelistedNfpm, nfpm);

1134:     function setWhitelistNfpm(

1136:         bool isWhitelist

1140:             if (isWhitelist) {

1141:                 EnumerableSet.add(_whitelistedNfpm, nfpms[i]);

1143:                 EnumerableSet.remove(_whitelistedNfpm, nfpms[i]);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

20:         address[] calldata whitelistedNfpms

27:             whitelistedNfpms

87:         require(_isWhitelistedNfpm(address(params.nfpm)));

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

92:         require(_isWhitelistedNfpm(address(nfpm)));

426:         require(_isWhitelistedNfpm(address(params.nfpm)));

512:         require(_isWhitelistedNfpm(address(params.nfpm)));

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="NC-13"></a>[NC-13] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (2)*:
```solidity
File: src/Common.sol

144:         _maxFeeX64[FeeType.GAS_FEE] = 1844674407370955264; // 10%

145:         _maxFeeX64[FeeType.PROTOCOL_FEE] = 1844674407370955264; // 10%

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="NC-14"></a>[NC-14] Variables need not be initialized to zero
The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (3)*:
```solidity
File: src/Common.sol

169:         for (uint256 i = 0; i < whitelistedNfpms.length; i++) {

298:         for (uint i = 0; i < count; ++i) {

1139:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Use of `tx.origin` is unsafe in almost every context | 1 |
| [L-2](#L-2) | Use of `tx.origin` is unsafe in almost every context | 1 |
| [L-3](#L-3) | Do not use deprecated library functions | 4 |
| [L-4](#L-4) | `domainSeparator()` isn't protected against replay attacks in case of a future chain split  | 5 |
| [L-5](#L-5) | External call recipient may consume all transaction gas | 4 |
| [L-6](#L-6) | Initializers could be front-run | 6 |
| [L-7](#L-7) | Unsafe ERC20 operation(s) | 6 |
| [L-8](#L-8) | Unsafe solidity low-level call can cause gas grief attack | 1 |
| [L-9](#L-9) | Upgradeable contract not initialized | 9 |
### <a name="L-1"></a>[L-1] Use of `tx.origin` is unsafe in almost every context
According to [Vitalik Buterin](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof), contracts should _not_ `assume that tx.origin will continue to be usable or meaningful`. An example of this is [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074#allowing-txorigin-as-signer-1) which explicitly mentions the intention to change its semantics when it's used with new op codes. There have also been calls to [remove](https://github.com/ethereum/solidity/issues/683) `tx.origin`, and there are [security issues](solidity.readthedocs.io/en/v0.4.24/security-considerations.html#tx-origin) associated with using it for authorization. For these reasons, it's best to completely avoid the feature.

*Instances (1)*:
```solidity
File: src/Common.sol

146:         _initializer = tx.origin;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="L-2"></a>[L-2] Use of `tx.origin` is unsafe in almost every context
According to [Vitalik Buterin](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof), contracts should _not_ `assume that tx.origin will continue to be usable or meaningful`. An example of this is [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074#allowing-txorigin-as-signer-1) which explicitly mentions the intention to change its semantics when it's used with new op codes. There have also been calls to [remove](https://github.com/ethereum/solidity/issues/683) `tx.origin`, and there are [security issues](solidity.readthedocs.io/en/v0.4.24/security-considerations.html#tx-origin) associated with using it for authorization. For these reasons, it's best to completely avoid the feature.

*Instances (1)*:
```solidity
File: src/Common.sol

146:         _initializer = tx.origin;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="L-3"></a>[L-3] Do not use deprecated library functions

*Instances (4)*:
```solidity
File: src/Common.sol

782:             _safeApprove(tokenIn, swapRouter, amountIn);

790:             _safeApprove(tokenIn, swapRouter, 0);

1110:         _safeApprove(token, _spender, _value);

1113:     function _safeApprove(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="L-4"></a>[L-4] `domainSeparator()` isn't protected against replay attacks in case of a future chain split 
Severity: Low.
Description: See <https://eips.ethereum.org/EIPS/eip-2612#security-considerations>.
Remediation: Consider using the [implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol#L77-L90) from OpenZeppelin, which recalculates the domain separator if the current `block.chainid` is not the cached chain ID.
Past occurrences of this issue:
- [Reality Cards Contest](https://github.com/code-423n4/2021-06-realitycards-findings/issues/166)
- [Swivel Contest](https://github.com/code-423n4/2021-09-swivel-findings/issues/98)
- [Malt Finance Contest](https://github.com/code-423n4/2021-11-malt-findings/issues/349)

*Instances (5)*:
```solidity
File: src/EIP712.sol

13:     bytes32 public immutable DOMAIN_SEPARATOR;

16:         DOMAIN_SEPARATOR = keccak256(

38:         return toTypedDataHash(DOMAIN_SEPARATOR, structHash);

51:         bytes32 domainSeparator,

58:             mstore(add(ptr, 0x02), domainSeparator)

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/EIP712.sol)

### <a name="L-5"></a>[L-5] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (4)*:
```solidity
File: src/Common.sol

754:             (bool sent, ) = to.call{value: amount}("");

784:             (bool success, ) = swapRouter.call(swapData);

938:         (bool success, bytes memory data) = address(nfpm).call(

1104:         address(token).call(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="L-6"></a>[L-6] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (6)*:
```solidity
File: src/Common.sol

141:     address private _initializer;

146:         _initializer = tx.origin;

150:     function initialize(

161:         require(msg.sender == _initializer);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

15:     function initialize(

22:         super.initialize(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

### <a name="L-7"></a>[L-7] Unsafe ERC20 operation(s)

*Instances (6)*:
```solidity
File: src/Common.sol

313:             payable(to).transfer(nativeBalance);

328:         nfpm.transferFrom(address(this), to, tokenId);

484:         params.nfpm.transferFrom(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

97:         params.nfpm.transferFrom(positionOwner, address(this), params.tokenId);

412:         params.nfpm.transferFrom(address(this), positionOwner, params.tokenId);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

```solidity
File: src/V3Utils.sol

400:         nfpm.transferFrom(address(this), from, tokenId);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)

### <a name="L-8"></a>[L-8] Unsafe solidity low-level call can cause gas grief attack
Using the low-level calls of a solidity address can leave the contract open to gas grief attacks. These attacks occur when the called contract returns a large amount of data.

So when calling an external contract, it is necessary to check the length of the return data before reading/copying it (using `returndatasize()`).

*Instances (1)*:
```solidity
File: src/Common.sol

938:         (bool success, bytes memory data) = address(nfpm).call(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

### <a name="L-9"></a>[L-9] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (9)*:
```solidity
File: src/Common.sol

141:     address private _initializer;

146:         _initializer = tx.origin;

149:     bool private _initialized = false;

150:     function initialize(

157:         require(!_initialized);

161:         require(msg.sender == _initializer);

173:         _initialized = true;

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

15:     function initialize(

22:         super.initialize(

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 10 |
| [M-2](#M-2) | Using `transferFrom` on ERC721 tokens | 2 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (10)*:
```solidity
File: src/Common.sol

51: abstract contract Common is AccessControl, Pausable {

296:     ) external onlyRole(WITHDRAWER_ROLE) {

310:     function withdrawNative(address to) external onlyRole(WITHDRAWER_ROLE) {

327:     ) external onlyRole(WITHDRAWER_ROLE) {

1075:     function pause() external onlyRole(ADMIN_ROLE) {

1079:     function unpause() external onlyRole(ADMIN_ROLE) {

1086:     ) external onlyRole(ADMIN_ROLE) {

1137:     ) external onlyRole(ADMIN_ROLE) {

1148:     function setFeeTaker(address feeTaker) external onlyRole(ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Automation.sol

86:     ) public payable onlyRole(OPERATOR_ROLE) whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Automation.sol)

### <a name="M-2"></a>[M-2] Using `transferFrom` on ERC721 tokens
The `transferFrom` function is used instead of `safeTransferFrom` and [it's discouraged by OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/109778c17c7020618ea4e035efb9f0f9b82d43ca/contracts/token/ERC721/IERC721.sol#L84). If the arbitrary address is a contract and is not aware of the incoming ERC721 token, the sent token could be locked.

*Instances (2)*:
```solidity
File: src/Common.sol

328:         nfpm.transferFrom(address(this), to, tokenId);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/Common.sol)

```solidity
File: src/V3Utils.sol

400:         nfpm.transferFrom(address(this), from, tokenId);

```
[Link to code](https://github.com/code-423n4/2024-06-krystal-defi/blob/main/src/V3Utils.sol)
