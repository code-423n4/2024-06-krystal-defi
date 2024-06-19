// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Common.sol";
import "./EIP712.sol";

contract V3Automation is Pausable, Common, EIP712 {

    event CancelOrder(address user, StructHash.Order order, bytes signature);

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    mapping (bytes32=>bool) _cancelledOrder;

    constructor() EIP712("V3AutomationOrder", "1.0") {}

    function initialize(address _swapRouter, address admin, address withdrawer, address feeTaker, address[] calldata whitelistedNfpms) public override  {
        super.initialize(_swapRouter, admin, withdrawer, feeTaker, whitelistedNfpms);
        _grantRole(OPERATOR_ROLE, admin);
    }

    enum Action {
        AUTO_ADJUST,
        AUTO_EXIT,
        AUTO_COMPOUND
    }

    struct ExecuteState {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;

        uint256 amount0;
        uint256 amount1;

        uint128 liquidity;
    }

    struct ExecuteParams {
        Action action;
        Protocol protocol;
        INonfungiblePositionManager nfpm;

        uint256 tokenId;
        uint128 liquidity; // liquidity the calculations are based on

        // target token for swaps (if this is address(0) no swaps are executed)
        address targetToken;
    
        uint256 amountIn0;
        // if token0 needs to be swapped to targetToken - set values
        uint256 amountOut0Min;
        bytes swapData0;

        // amountIn1 is used for swap and also as minAmount1 for decreased liquidity + collected fees
        uint256 amountIn1;
        // if token1 needs to be swapped to targetToken - set values
        uint256 amountOut1Min;
        bytes swapData1;

        uint256 amountRemoveMin0; // min amount to be removed from liquidity
        uint256 amountRemoveMin1; // min amount to be removed from liquidity
        uint256 deadline; // for uniswap operations - operator promises fair value
        uint64 gasFeeX64;  // amount of tokens to be used as gas fee
        uint64 protocolFeeX64;  // amount of tokens to be used as protocol fee

        // for mint new range
        int24 newTickLower;
        int24 newTickUpper;

        // compound fee to new position or not
        bool compoundFees;

        // min amount to be added after swap
        uint256 amountAddMin0;
        uint256 amountAddMin1;

        // user signed config
        StructHash.Order userOrder;
        bytes orderSignature;
    }

    function execute(ExecuteParams calldata params) public payable onlyRole(OPERATOR_ROLE) whenNotPaused() {
        require(_isWhitelistedNfpm(address(params.nfpm)));
        address positionOwner = params.nfpm.ownerOf(params.tokenId);
        _validateOrder(params.userOrder, params.orderSignature, positionOwner);
        _execute(params, positionOwner);
    }

    function _execute(ExecuteParams calldata params, address positionOwner) internal {
        params.nfpm.transferFrom(positionOwner, address(this), params.tokenId);

        ExecuteState memory state;
        (state.token0, state.token1, state.liquidity, state.tickLower, state.tickUpper, state.fee) = _getPosition(params.nfpm, params.protocol, params.tokenId);

        require(state.liquidity != params.liquidity || params.liquidity != 0);

        (state.amount0, state.amount1) = _decreaseLiquidityAndCollectFees(DecreaseAndCollectFeesParams(params.nfpm, positionOwner, IERC20(state.token0), IERC20(state.token1), params.tokenId, params.liquidity, params.deadline, params.amountRemoveMin0, params.amountRemoveMin1, params.compoundFees));

        // deduct fees
        {
            uint256 gasFeeAmount0;
            uint256 gasFeeAmount1;
            if (params.gasFeeX64 > 0) {
                (,,, gasFeeAmount0, gasFeeAmount1,) = _deductFees(DeductFeesParams(state.amount0, state.amount1, 0, params.gasFeeX64, FeeType.GAS_FEE, address(params.nfpm), params.tokenId, positionOwner, state.token0, state.token1, address(0)), true);
            }
            uint256 protocolFeeAmount0;
            uint256 protocolFeeAmount1;
            if (params.protocolFeeX64 > 0) {
                (,,, protocolFeeAmount0, protocolFeeAmount1,) = _deductFees(DeductFeesParams(state.amount0, state.amount1, 0, params.protocolFeeX64, FeeType.PROTOCOL_FEE, address(params.nfpm), params.tokenId, positionOwner, state.token0, state.token1, address(0)), true);
            }
            state.amount0 = state.amount0 - gasFeeAmount0 - protocolFeeAmount0;
            state.amount1 = state.amount1 - gasFeeAmount1 - protocolFeeAmount1;
        }

        if (params.action == Action.AUTO_ADJUST) {
            require(state.tickLower != params.newTickLower || state.tickUpper != params.newTickUpper);
            SwapAndMintResult memory result;
            if (params.targetToken == state.token0) {
                result = _swapAndMint(SwapAndMintParams(params.protocol, params.nfpm, IERC20(state.token0), IERC20(state.token1), state.fee, params.newTickLower, params.newTickUpper, 0, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(state.token1), params.amountIn1, params.amountOut1Min, params.swapData1, 0, 0, bytes(""), params.amountAddMin0, params.amountAddMin1), false);
            } else if (params.targetToken == state.token1) {
                result = _swapAndMint(SwapAndMintParams(params.protocol, params.nfpm, IERC20(state.token0), IERC20(state.token1), state.fee, params.newTickLower, params.newTickUpper, 0, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(state.token0), 0, 0, bytes(""), params.amountIn0, params.amountOut0Min, params.swapData0, params.amountAddMin0, params.amountAddMin1), false);
            } else {
                // Rebalance without swap
                result = _swapAndMint(SwapAndMintParams(params.protocol, params.nfpm, IERC20(state.token0), IERC20(state.token1), state.fee, params.newTickLower, params.newTickUpper, 0, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(address(0)), 0, 0, bytes(""), 0, 0, bytes(""), params.amountAddMin0, params.amountAddMin1), false);
            }
            emit ChangeRange(address(params.nfpm), params.tokenId, result.tokenId, result.liquidity, result.added0, result.added1);
        } else if (params.action == Action.AUTO_EXIT) {
            IWETH9 weth = _getWeth9(params.nfpm, params.protocol);
            uint256 targetAmount;
            if (state.token0 != params.targetToken) {
                (uint256 amountInDelta, uint256 amountOutDelta) = _swap(IERC20(state.token0), IERC20(params.targetToken), state.amount0, params.amountOut0Min, params.swapData0);
                if (amountInDelta < state.amount0) {
                    _transferToken(weth, positionOwner, IERC20(state.token0), state.amount0 - amountInDelta, false);
                }
                targetAmount += amountOutDelta;
            } else {
                targetAmount += state.amount0; 
            }
            if (state.token1 != params.targetToken) {
                (uint256 amountInDelta, uint256 amountOutDelta) = _swap(IERC20(state.token1), IERC20(params.targetToken), state.amount1, params.amountOut1Min, params.swapData1);
                if (amountInDelta < state.amount1) {
                    _transferToken(weth, positionOwner, IERC20(state.token1), state.amount1 - amountInDelta, false);
                }
                targetAmount += amountOutDelta;
            } else {
                targetAmount += state.amount1; 
            }

            // send complete target amount
            if (targetAmount != 0 && params.targetToken != address(0)) {
                _transferToken(weth, positionOwner, IERC20(params.targetToken), targetAmount, false);
            }
        } else if (params.action == Action.AUTO_COMPOUND) {
            if (params.targetToken == state.token0) {
                _swapAndIncrease(SwapAndIncreaseLiquidityParams(params.protocol, params.nfpm, params.tokenId, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(state.token1), params.amountIn1, params.amountOut1Min, params.swapData1, 0, 0, bytes(""), params.amountAddMin0, params.amountAddMin1, 0), IERC20(state.token0), IERC20(state.token1), false);
            } else if (state.token0 == state.token1) {
                _swapAndIncrease(SwapAndIncreaseLiquidityParams(params.protocol, params.nfpm, params.tokenId, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(state.token0), 0, 0, bytes(""), params.amountIn0, params.amountOut0Min, params.swapData0, params.amountAddMin0, params.amountAddMin1, 0), IERC20(state.token0), IERC20(state.token1), false);
            } else {
                // compound without swap
                _swapAndIncrease(SwapAndIncreaseLiquidityParams(params.protocol, params.nfpm, params.tokenId, state.amount0, state.amount1, 0, positionOwner, params.deadline, IERC20(address(0)), 0, 0, bytes(""), 0, 0, bytes(""), params.amountAddMin0, params.amountAddMin1, 0), IERC20(state.token0), IERC20(state.token1), false);
            }
        } else {
            revert NotSupportedAction();
        }
        params.nfpm.transferFrom(address(this), positionOwner, params.tokenId);
    }

    function _validateOrder(StructHash.Order memory order, bytes memory orderSignature, address actor) internal view {
        address userAddress = recover(order, orderSignature);
        require(userAddress == actor);
        require(!_cancelledOrder[keccak256(orderSignature)]);
    }

    function cancelOrder(StructHash.Order calldata order, bytes calldata orderSignature) external {
        _validateOrder(order, orderSignature, msg.sender);
        _cancelledOrder[keccak256(orderSignature)] = true;
        emit CancelOrder(msg.sender, order, orderSignature);
    }

    function isOrderCancelled(bytes calldata orderSignature) external view returns (bool) {
        return _cancelledOrder[keccak256(orderSignature)];
    }

    receive() external payable{}
}
