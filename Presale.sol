// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Token.sol';

contract Presale {
	Token _token = Token(0x5EF6b5ABaA7e9b75Fa4DaEBF0Fc722f9AFF12B40);
	address payable public _admin = payable(0x1B8bc9eb46754CC8f9a889EBBB2ece9aE9757843);
	uint256 public _round;

	constructor() {
		_round = 0;
	}

	receive() external payable {
		getTokens(msg.sender);
	}

	function getTokens(address beneficiary) public payable {
		require(_round > 0, 'presale inactive');
		uint256 value = msg.value * getRate();
		require(value <= _token.balanceOf(address(this)), 'amount is larger than token balance');
		_token.approve(beneficiary, value);
		_token.transfer(beneficiary, value);
		_admin.transfer(msg.value);
	}

	function getRate() public view returns (uint256) {
		if (_round > 0) return (600000 - (_round - 1) * 100000);
		return 0;
	}

	function withdrawAll() public {
		require(msg.sender == _admin, 'not admin');
		_token.approve(_admin, _token.balanceOf(address(this)));
		_token.transfer(_admin, _token.balanceOf(address(this)));
	}

	function withdraw(uint256 amount) public {
		require(msg.sender == _admin, 'not admin');
		require(amount <= _token.balanceOf(address(this)), 'amount is larger than token balance');
		_token.approve(_admin, amount);
		_token.transfer(_admin, amount);
	}

	function setRound(uint256 round) public {
		require(msg.sender == _admin, 'not admin');
		require(round <= 3, 'round must be between 0 and 3');
		_round = round;
	}
}
