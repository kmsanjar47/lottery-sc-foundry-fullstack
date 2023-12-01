// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract Lottery {
    address private manager;
    address[] public players;
    uint private balance = 0;
    uint private maxPlayerEntry = 10;
    uint private currentPlayerNo = 0;

    constructor() {
        manager = msg.sender;
    }

    //Views

    function getMaxPlayerEntry() public view returns (uint) {
        return maxPlayerEntry;
    }

    function getManager() public view returns (address) {
        return manager;
    }

    function getBalance() public view returns (uint) {
        return balance;
    }

    function getCurrentPlayerNo() public view returns (uint) {
        return currentPlayerNo;
    }

    //Errors

    error NotManager();
    error NotUser();
    error MaxEntryLimitReached();
    error MinimumBalanceLimitNotReached();

    // Modifiers

    modifier onlyManagerAccess() {
        if (msg.sender != manager) {
            revert NotManager();
        }
        _;
    }

    modifier onlyUserAccess() {
        if (msg.sender == manager) {
            revert NotUser();
        }
        _;
    }

    modifier minimumBalance() {
        if (msg.value < 0.01 ether) {
            revert MinimumBalanceLimitNotReached();
        }
        _;
    }

    modifier maxPlayerLimit() {
        if (maxPlayerEntry <= currentPlayerNo) {
            revert MaxEntryLimitReached();
        }
        _;
    }

    //Main Functions

    function enterToGame()
        public
        payable
        onlyUserAccess
        minimumBalance
        maxPlayerLimit
    {
        players.push(msg.sender);
        balance += msg.value;
        currentPlayerNo += 1;
    }

    function randomNumGenerator() public view onlyManagerAccess returns (uint) {
        uint randomNumber = uint(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    players
                )
            )
        );

        return randomNumber;
    }

    function randomlyChooseWinner()
        public
        view
        onlyManagerAccess
        returns (uint winner)
    {
        return randomNumGenerator() % players.length;
    }

    function sendFundToWinner() public payable onlyManagerAccess {
        uint winningPlayerIndex = randomlyChooseWinner();
        address payable finalWinner = payable(players[winningPlayerIndex]);
        finalWinner.transfer(balance);
        balance = 0;
        players = new address[](0);
    }
}
