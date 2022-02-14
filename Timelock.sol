// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Token.sol';

contract Timelock {
	address public _deployer;
	address[] public _owners;
	Token _token = Token(0x5EF6b5ABaA7e9b75Fa4DaEBF0Fc722f9AFF12B40);

	struct Lock {
		uint256 amount;
		uint256 unlockedAt;
		string description;
	}

	Lock[] public _lock;

	constructor(address[] memory owners) {
		_deployer = msg.sender;
		_owners = owners;
	}

	function lock(uint256[] memory amounts, uint256[] memory daysToUnlock, string[] memory descriptions) public {
		require(daysToUnlock.length == amounts.length, 'arrays should have the same length');

		uint256 total = 0;
		for (uint256 i = 0; i < amounts.length; i++) {
			total += amounts[i];
		}

		require(total <= _token.balanceOf(address(this)), 'contract balance too low');

		for (uint256 i = 0; i < amounts.length; i++) {
			_lock.push(Lock(amounts[i], block.timestamp + daysToUnlock[i] * 1 days, descriptions[i]));
		}
	}

	function withdrawAll() public {
		require(isOwner(msg.sender), 'owner only');

		uint256 unlocked = unlockedAmount();
		require(unlocked > 0, 'nothing to withdraw');
		withdraw(unlocked);
	}

	function withdraw(uint256 amount) public {
		uint256 balance = _token.balanceOf(address(this));
		uint256 locked = lockedAmount();
		uint256 unlocked = unlockedAmount();

		require(unlocked > 0, 'nothing to withdraw');

		require(isOwner(msg.sender), 'owner only');

		require(amount > 0, 'amount should be larger than 0');
		require(amount <= unlockedAmount(), 'amount too large');

		require(balance > locked, 'nothing to withdraw');
		require(balance - locked >= amount, 'amount too large');

		_token.transfer(msg.sender, amount);
	}

	function lockedAmount() public view returns (uint256) {
		uint256 amount = 0;
		for (uint256 i = 0; i < _lock.length; i++) {
			if (_lock[i].unlockedAt < block.timestamp) continue;
			amount += _lock[i].amount;
		}
		return amount;
	}

	function unlockedAmount() public view returns (uint256) {
		uint256 balance = _token.balanceOf(address(this));
		uint256 locked = lockedAmount();
		if (balance > locked) return (balance - locked);
		return 0;
	}

	function isOwner(address account) public view returns (bool) {
		bool owner = account == _deployer;
		if (!owner) {
			for (uint256 i = 0; i < _owners.length; i++) {
				if (_owners[i] == account) {
					owner = true;
					break;
				}
			}
		}
		return owner;
	}

	function setOwners(address[] memory owners) public {
		require(isOwner(msg.sender), 'owner only');
		_owners = owners;
	}
}
