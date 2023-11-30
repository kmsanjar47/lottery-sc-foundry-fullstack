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
    uint public constant FUND_SENT = 0.01 ether;

    function setUp() external {
        LotteryScript lotteryScript = new LotteryScript();
        lottery = lotteryScript.run();
    }

    function testIfManagerAccessedRandomlyChooseWinner() public {
        vm.prank(USER);
        vm.expectRevert();
        lottery.randomlyChooseWinner();
    }

    function testEnterToGameFuntionalities() public {
        uint balanceBeforeIncrement = lottery.getBalance();

        //Test Minimum Balance
        vm.expectRevert();
        lottery.enterToGame();

        //Test If The User is Not Manager
        vm.expectRevert();
        lottery.enterToGame();

        //Test If Fund And User is Updated in contract
        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        lottery.enterToGame{value: FUND_SENT}();
        vm.stopPrank();

        if (lottery.getBalance() != (balanceBeforeIncrement + FUND_SENT)) {
            revert("Balance not matched");
        }
        if (lottery.players(0) != USER) {
            revert("Address not matched");
        }
    }

    function testSendFundToWinnerFunctionalities() public {
        uint totalBalance = lottery.getBalance();

        //Test if normal user can access this

        vm.startPrank(USER);
        vm.expectRevert();
        lottery.sendFundToWinner();
        vm.stopPrank();

        //Test if the balance gets added

        for (uint160 i = 1; i <= 10; i++) {
            address TEMP_USER = address(i);
            vm.deal(TEMP_USER, 1 ether);
            vm.startPrank(TEMP_USER);
            lottery.enterToGame{value: FUND_SENT}();
            vm.stopPrank();
            totalBalance += FUND_SENT;
        }
        uint currentBalance = lottery.getBalance();
        assert(currentBalance == totalBalance);
    }
}
