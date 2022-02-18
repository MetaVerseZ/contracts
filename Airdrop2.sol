// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Token.sol';

contract MZTAirdrop2 {
	Token _token = Token(0x5EF6b5ABaA7e9b75Fa4DaEBF0Fc722f9AFF12B40);
	address public _admin;
	uint256 _value;

	constructor() {
		_value = 0;
		_admin = msg.sender;
	}

	function distribute(address[] memory addresses, uint256[] memory amounts) external {
		require(msg.sender == _admin, 'not admin');
		require(addresses.length == amounts.length, 'arrays should have the same length');

		uint256 total = 0;
		for (uint256 i = 0; i < amounts.length; i++) {
			total += amounts[i];
		}
		total = total * 1 ether;

		require(_token.balanceOf(address(this)) >= total, 'low balance');

		for (uint256 i = 0; i < addresses.length; i++) {
			sendTokens(addresses[i], amounts[i] * 1 ether);
		}

		_value = 0;
	}

	function sendTokens(address to, uint256 amount) private {
		_token.transfer(to, amount);
	}

	function withdrawAll() public {
		require(msg.sender == _admin, 'not admin');
		_token.transfer(_admin, _token.balanceOf(address(this)));
	}

	function withdraw(uint256 amount) public {
		require(msg.sender == _admin, 'not admin');
		require(amount <= _token.balanceOf(address(this)), 'amount is larger than token balance');
		_token.transfer(_admin, amount);
	}
}
