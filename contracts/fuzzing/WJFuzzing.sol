// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
import "../WJ.sol";


/// @dev A contract that will receive wj, and allows for it to be retrieved.
contract MockHolder {
    constructor (address payable wj, address retriever) {
        WJ(wj).approve(retriever, type(uint).max);
    }
}

/// @dev Invariant testing
contract WJFuzzing {

    WJ internal wj;
    address internal holder;

    /// @dev Instantiate the WJ contract, and a holder address that will return wj when asked to.
    constructor () {
        wj = new WJ();
        holder = address(new MockHolder(payable(wj), address(this)));
    }

    /// @dev Receive J when withdrawing.
    receive () external payable { }

    /// @dev Add two numbers, but return 0 on overflow
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a); // Normally it would be a `require`, but we want the test to fail if there is an overflow, not to be ignored.
    }

    /// @dev Subtract two numbers, but return 0 on overflow
    function sub(uint a, uint b) internal pure returns (uint c) {
        c = a - b;
        assert(c <= a); // Normally it would be a `require`, but we want the test to fail if there is an overflow, not to be ignored.
    }

    /// @dev Test that supply and balance hold on deposit.
    function deposit(uint jAmount) public {
        uint supply = address(wj).balance;
        uint balance = wj.balanceOf(address(this));
        wj.deposit{value: jAmount}(); // It seems that echidna won't let the total value sent go over type(uint256).max
        assert(address(wj).balance == add(supply, jAmount));
        assert(wj.balanceOf(address(this)) == add(balance, jAmount));
        assert(address(wj).balance == address(wj).balance);
    }

    /// @dev Test that supply and balance hold on withdraw.
    function withdraw(uint jAmount) public {
        uint supply = address(wj).balance;
        uint balance = wj.balanceOf(address(this));
        wj.withdraw(jAmount);
        assert(address(wj).balance == sub(supply, jAmount));
        assert(wj.balanceOf(address(this)) == sub(balance, jAmount));
        assert(address(wj).balance == address(wj).balance);
    }

    /// @dev Test that supply and balance hold on transfer.
    function transfer(uint jAmount) public {
        uint thisBalance = wj.balanceOf(address(this));
        uint holderBalance = wj.balanceOf(holder);
        wj.transfer(holder, jAmount);
        assert(wj.balanceOf(address(this)) == sub(thisBalance, jAmount));
        assert(wj.balanceOf(holder) == add(holderBalance, jAmount));
        assert(address(wj).balance == address(wj).balance);
    }

    /// @dev Test that supply and balance hold on transferFrom.
    function transferFrom(uint jAmount) public {
        uint thisBalance = wj.balanceOf(address(this));
        uint holderBalance = wj.balanceOf(holder);
        wj.transferFrom(holder, address(this), jAmount);
        assert(wj.balanceOf(address(this)) == add(thisBalance, jAmount));
        assert(wj.balanceOf(holder) == sub(holderBalance, jAmount));
        assert(address(wj).balance == address(wj).balance);
    }
}
