pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";


contract DaiCrowdsale is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 private _token;

  IERC20 private _dai;

  // Address where funds are collected
  address private _wallet;

  // How many token units a buyer gets per dai.
  // The rate is the conversion between dai and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
  // 1 dai will give you 1 unit, or 0.001 TOK.
  uint256 private _rate;

  // Amount of dai raised in 10^18 units
  uint256 private _daiRaised;

  /**
   * Event for token purchase logging
   * @param buyer who got the tokens
   * @param daiAmount dais paid for purchase
   * @param tokenAmount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed buyer,
    uint256 daiAmount,
    uint256 tokenAmount
  );

  /**
   * @param rate Number of token units a buyer gets per dai
   * @dev The rate is the conversion between the smallest and indivisible unit 
   * of dai tokens (18 decimals) and the smallest and indivisible unit of crowdsale
   * tokens token units. So, if you are using a rate of 1 with a ERC20Detailed token
   * with 18 decimals called MER, 1^-18 of DAI will give you 1^-18 unit of MER.
   * @param token Address of the token being sold
   */
  constructor(uint256 rate, address wallet, IERC20 token, IERC20 dai) internal {
    require(rate > 0); // must be >=1 1 since type == uint
    require(wallet != address(0));
    require(token != address(0));
    require(dai != address(0));
    


    _rate = rate;
    _wallet = wallet;
    _token = token;
    _dai = dai;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   * Note that other contracts will transfer fund with a base gas stipend
   * of 2300, which is not enough to call buyTokens. Consider calling
   * buyTokens directly when purchasing tokens from a contract.
   */
//   function () external {
      
//   }

  /**
   * @return the token being sold.
   */
  function token() public view returns(IERC20) {
    return _token;
  }

  /**
   * @return the token being sold.
   */
  function dai() public view returns(IERC20) {
    return _dai;
  }

  /**
   * @return the address where funds are collected.
   */
  function wallet() public view returns(address) {
    return _wallet;
  }

  /**
   * @return the number of token units a buyer gets per dai.
   */
  function rate() public view returns(uint256) {
    return _rate;
  }

  /**
   * @return the amount of dai raised.
   */
  function daiRaised() public view returns (uint256) {
    return _daiRaised;
  }

  function buyTokens(address buyer, uint256 daiAmount) public nonReentrant {
    //check if tokens remain, buyer is the sender address, and amount ins positive 
    _preValidatePurchase(buyer, daiAmount);    
    uint256 tokenAmount = _getTokenAmount(daiAmount);
    require(remainingTokens() >= tokenAmount, "No tokens remain for sale");
    _processPurchase(buyer, daiAmount, tokenAmount);
    _daiRaised = _daiRaised.add(daiAmount);
    
    emit TokensPurchased(
      msg.sender,
      daiAmount,
      tokenAmount
    );

  }
    // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------
    function remainingTokens() public view returns (uint256) {
      return Math.min(
        token().balanceOf(_wallet),
        token().allowance(_wallet, this)
      );
    }
  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(buyer, daiAmount);
   *   require(daiRaised().add(daiAmount) <= cap);
   * @param buyer Address performing the token purchase
   * @param daiAmount Value in dai involved in the purchase
   */
  function _preValidatePurchase(
    address buyer, 
    uint256 daiAmount)
    internal
    view
  {
    require(buyer != address(0));
    require(buyer == msg.sender);
    require(daiAmount != 0);
  }
    /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param buyer Address performing the token purchase
   * @param daiAmount Value in dai involved in the purchase
   */


  function _swap(
    address buyer, 
    uint256 daiAmount, 
    uint256 tokenAmount

  )
    internal
    returns(bool)
  {
    return (_transferTokens(buyer, tokenAmount) && _transferDai(buyer, daiAmount));
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param buyer Address performing the token purchase
   * @param tokenAmount Number of tokens to be emitted
   */
  function _transferTokens(
    address buyer,
    uint256 tokenAmount
  )
    internal
    returns(bool)
  {
    _token.safeTransferFrom(_wallet, buyer, tokenAmount); // safeTransferFrom wraps transferFrom with require()
    return true;
  }
    /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param buyer Address performing the token purchase
   * @param daiAmount Number of tokens to be emitted
   */
  function _transferDai(
    address buyer,
    uint256 daiAmount
  )
    internal
    returns(bool)
  {
    _dai.safeTransferFrom(buyer, _wallet, daiAmount);
    return true;
    
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.
   * @param buyer Address receiving the tokens
   * @param daiAmount Number of dai being sent
   * @param tokenAmount Number of tokens being sent
   */
  function _processPurchase(
    address buyer,
    uint256 daiAmount,
    uint256 tokenAmount
  )
    internal
  {
    assert(_swap(buyer, daiAmount, tokenAmount));
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param buyer Address receiving the tokens
   * @param daiAmount Value in dai involved in the purchase
   */


  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @return Number of tokens that can be purchased with the specified _daiAmount
   */
  function _getTokenAmount(uint256 daiAmount)
    internal view returns (uint256)
  {
    return daiAmount.mul(_rate);
  }

}