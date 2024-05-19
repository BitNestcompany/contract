// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IPositionManager.sol";

contract BitNest is AccessControl {
    using SafeERC20 for IERC20;
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    IPositionManager public constant PositionManager = IPositionManager(0x46A15B0b27311cedF172AB29E4f4766fbE7F4364);
    uint256 private tokenId;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setTokenId(uint256 _tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenId = _tokenId;
    }

    function approve(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(USDT).approve(address(PositionManager), amount);
    }

    function increaseLiquidity(uint256 usdtAmount) internal {
        PositionManager.increaseLiquidity(
            IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: usdtAmount,
                amount1Desired: 0,
                amount0Min: usdtAmount,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );
    }

    function loop() external onlyRole(OPERATOR_ROLE) {
        uint256 usdtAmount = IERC20(USDT).balanceOf(address(this));
        require(usdtAmount > 0, "min amount limited");
        increaseLiquidity(usdtAmount);
    }
}
