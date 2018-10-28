pragma solidity 0.4.24;

import "./DaiCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract DaiCrowdsaleWithAllowance is AllowanceCrowdsale, DaiCrowdsale, Pausable {
    using SafeERC20 for ERC20;
    constructor(
        uint256 _rate,
        ERC20 _token,
        ERC20 _dai,
    )
        public
        DaiCrowdsale(_rate, _token, _dai)
        AllowanceCrowdsale(msg.sender)
    {
    }
}
