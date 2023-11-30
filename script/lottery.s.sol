// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;
import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/lottery.sol";

contract LotteryScript is Script {
    function run() external returns (Lottery) {
        vm.startBroadcast();
        Lottery lottery = new Lottery();
        vm.stopBroadcast();
        return lottery;
    }
}
