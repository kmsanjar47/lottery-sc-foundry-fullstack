// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

/// Tests :
/// - [x] Test that only manager can access the sendFundToWinner function
/// - [x] Test that only manager can access the randomlyChooseWinner function
/// - Test that user has paid the minimum balance to enter the game
/// - Test is the current user is manager whiel entering in a lottery

import {Test, console} from "forge-std/Test.sol";
import {Lottery} from "../src/lottery.sol";
import {LotteryScript} from "../script/lottery.s.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    address public USER = makeAddr("1");

    function setUp() external {
        LotteryScript lotteryScript = new LotteryScript();
        lottery = lotteryScript.run();
    }

    function testIfUserEnteredWithMinimumBalance() public {
        vm.expectRevert();
        lottery.enterToGame();
    }

    function testIfOnlyUserEnteredTheLottery() public {
        vm.expectRevert();
        lottery.enterToGame();
    }

    function testIfManagerAccessedSendFundToWinner() public {
        vm.prank(USER);
        vm.expectRevert();
        lottery.sendFundToWinner();
    }

    function testIfManagerAccessedRandomlyChooseWinner() public {
        vm.prank(USER);
        vm.expectRevert();
        lottery.randomlyChooseWinner();
    }

    function testEnterToGameFuntionalities() public {
        uint balanceBeforeIncrement = lottery.getBalance();

        uint fundSent = 0.1 ether;
        address userAddress = USER;

        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        lottery.enterToGame{value: fundSent}();
        vm.stopPrank();

        if (lottery.getBalance() != (balanceBeforeIncrement + fundSent)) {
            revert("Balance not matched");
        }
        if (lottery.players(0) != userAddress) {
            revert("Address not matched");
        }
    }
}
