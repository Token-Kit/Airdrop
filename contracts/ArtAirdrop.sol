pragma solidity ^0.5.16;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

// Inheritance
import "./interfaces/IArtAirdrop.sol";
import "./Owned.sol";

contract ArtAirdrop is IArtAirdrop, Owned {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public token;
  mapping(address => uint256) public claimableTokens;

  uint256 public allocTotal = 0;  
  mapping(address => uint256) public allocPoints;
  address[] public participants;

  uint256 public epoch = 0;
  uint256 public epochDistributeSupply = 0;

  constructor(
    address _owner,
    address _token
  ) public Owned(_owner) {
    token = IERC20(_token);
  }

  function claimable(address account) external view returns (uint256) {
    return claimableTokens[account];
  }

  function claim() external {
    uint256 amount = claimableTokens[msg.sender];
    require(amount > 0, "No ART to claim");

    token.safeTransfer(msg.sender, amount);
    claimableTokens[msg.sender] = 0;
    emit Claimed(msg.sender, amount);
  }

  function init() external onlyOwner {
    for (uint256 i = 0; i < participants.length; i ++) {
      delete allocPoints[participants[i]];
    }
    
    delete participants;
    allocTotal = 0;
    emit Inited();
  }

  function update(address[] calldata accounts, uint256[] calldata points) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i ++) {
      address _addr = accounts[i];
      if (allocPoints[_addr] <= 0) {
        participants.push(_addr);
      }
      allocPoints[_addr] = allocPoints[_addr].add(points[i]);
      allocTotal = allocTotal.add(points[i]);
    }
  }

  function epochStart() external onlyOwner {
    for (uint256 i = 0; i < participants.length; i ++) {
      address _addr = participants[i];
      claimableTokens[_addr] = claimableTokens[_addr].add(allocPoints[_addr].mul(epochDistributeSupply).div(allocTotal));
    }

    epoch = epoch.add(1);
    emit EpochStarted(epoch);
  }

  function notifyAirdropAmount(uint256 amount) external onlyOwner {
    epochDistributeSupply = amount;
    uint balance = token.balanceOf(address(this));
    require(amount <= balance, "Provided amount too high");

    emit Depositied(amount);
  }

  function recover(uint256 amount) external onlyOwner {
    require(amount <= epochDistributeSupply, "Provided amount too high");
    epochDistributeSupply = epochDistributeSupply.sub(amount);
    token.safeTransfer(owner, amount);
    emit Recovered(amount);
  }

  /* ========== EVENTS ========== */

  event Depositied(uint256 _amount);
  event Claimed(address indexed _user, uint256 _amount);
  event EpochStarted(uint256 _epoch);
  event Recovered(uint256 _amount);
  event Inited();
}
