// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract Lottery {
    address private manager;
    address[] public players;
    uint private balance;

    constructor() {
        manager = msg.sender;
    }

    function getManager() public view returns (address) {
        return manager;
    }

    function getBalance() public view returns (uint) {
        return balance;
    }

    modifier onlyManagerAccess() {
        require(
            msg.sender == manager,
            "Only manager can access this function!"
        );
        _;
    }

    modifier onlyUserAccess() {
        require(msg.sender != manager, "Manager can't participate!!");
        _;
    }

    modifier minimumBalance() {
        require(msg.value >= 0.01 ether, "Minimum balance is 0.01 ether");
        _;
    }

    function enterToGame() public payable onlyUserAccess minimumBalance {
        players.push(msg.sender);
        balance += msg.value;
    }

    function randomlyChooseWinner()
        public
        view
        onlyManagerAccess
        returns (uint winner)
    {
        uint randomNumber = uint(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    players
                )
            )
        );
        return randomNumber % players.length;
    }

    function sendFundToWinner() public payable onlyManagerAccess {
        uint winningPlayerIndex = randomlyChooseWinner();
        address payable finalWinner = payable(players[winningPlayerIndex]);
        finalWinner.transfer(balance);
        balance = 0;
        players = new address[](0);
    }
}
