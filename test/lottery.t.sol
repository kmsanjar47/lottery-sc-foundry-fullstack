// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

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

    function testIfManagerAccesedRandomNumGenerator() public {
        vm.prank(USER);
        vm.expectRevert();
        lottery.randomNumGenerator();
    }

    function testIfUserSendMinBalance() public {
        //Test Minimum Balance
        vm.expectRevert();
        lottery.enterToGame();
    }

    function testIfUserNotManagerAndPLayerCountIncreased() public {
        //Test If The User is Not Manager and player count
        //increased
        uint playerCountBefore = lottery.getCurrentPlayerNo();
        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        lottery.enterToGame{value: 0.2 ether}();
        vm.stopPrank();
        console.log(playerCountBefore, lottery.getCurrentPlayerNo());
        assert(playerCountBefore < lottery.getCurrentPlayerNo());
    }

    function testIfFundAndUserUpdated() public {
        //Test If Fund And User is Updated in contract
        uint balanceBeforeIncrement = lottery.getBalance();

        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        lottery.enterToGame{value: FUND_SENT}();
        vm.stopPrank();

        assertEq(lottery.getBalance(), balanceBeforeIncrement + FUND_SENT);
        assertEq(lottery.players(0), USER);
    }

    function testIfOnlyManagerAcessSendFundToWinner() public {
        //Test if normal user can access this
        vm.startPrank(USER);
        vm.expectRevert();
        lottery.sendFundToWinner();
        vm.stopPrank();
    }

    function testSendFundToWinnerFunctionalities() public {
        uint totalBalance = lottery.getBalance();
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
        assertEq(currentBalance, totalBalance);

        // vm.prank(lottery.getManager());
        // lottery.sendFundToWinner();
        // assertEq(lottery.getBalance(), 0);
    }
}
