//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Farmtoken is ERC20 {
    constructor() ERC20("Farmtoken", "FARM") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    } 
    receive () external payable{}
    fallback () external payable{}
}
