// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MiladyPoland} from "../src/MiladyPoland.sol";
import {Cebula} from "../src/Cebula.sol";

//0x60D4496FfaeF491e6BE88D55dcB511F513390486 milady i remilio

// 0x2c7aC54E06506FD530275379807a9883D3E519c0 DEV WALLET

contract MiladyPolandTest is Test {
    MiladyPoland public miladyPoland;
    Cebula public cebula;

    address public randomUser = address(0x5E11E1);
    address public kryptopaul = 0x60D4496FfaeF491e6BE88D55dcB511F513390486;
    address public pehu = 0x07D3088a697DC1647413E0B7393746Dd2D6c8A55;

    address public deployer = 0x13d8cc1209A8a189756168AbEd747F2b050D075f;

    function setUp() public {
        vm.deal(randomUser, 100 ether);
        vm.startPrank(deployer);
        miladyPoland = new MiladyPoland(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33
        );
        miladyPoland.setSaleState(1);

        cebula = new Cebula(0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33);
        vm.stopPrank();
        console.log("MiladyPoland: %s", address(miladyPoland));
        console.log("Cebula: %s", address(cebula));
    }

    function test_CebulaReceiver_Receives_Two_NFTs() public {
        uint256 receiverBalance = cebula.balanceOf(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33
        );
        assertEq(2, receiverBalance);
    }

    function test_MiladyPolandReceiver_Receives_Five_NFTs() public {
        uint256 receiverBalance = miladyPoland.balanceOf(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33
        );
        assertEq(5, receiverBalance);
    }

    function test_RandomCantMint_Cebula() public {
        vm.prank(randomUser);
        vm.expectRevert();
        cebula.curse(randomUser);
    }

    // Milady Mint section
    function test_MiladyHolder_CanMint() public {
        vm.prank(kryptopaul);
        miladyPoland.FrensMint(1, "0x25a058f1958de934031b0b183dcbfa6e2208aee14a265a776f8690cc3d20cff2364d6d10cdf9108d74dcb12c8bb917a33daafcc9a0565bc4030bdac656df0ff41c");
        uint256 balance = miladyPoland.balanceOf(kryptopaul);
        assertEq(balance, 1);
    }

    function test_MiladyHolder_CantMint_MoreThanOne() public {
        vm.startPrank(kryptopaul);
        miladyPoland.FrensMint(1, "0x25a058f1958de934031b0b183dcbfa6e2208aee14a265a776f8690cc3d20cff2364d6d10cdf9108d74dcb12c8bb917a33daafcc9a0565bc4030bdac656df0ff41c");
        vm.expectRevert();
        miladyPoland.FrensMint(1, "0x25a058f1958de934031b0b183dcbfa6e2208aee14a265a776f8690cc3d20cff2364d6d10cdf9108d74dcb12c8bb917a33daafcc9a0565bc4030bdac656df0ff41c");
        vm.stopPrank();
    }

    function test_NotMiladyHolder_CantMint() public {
        vm.expectRevert();
        miladyPoland.FrensMint(1, "0x25a058f1958de934031b0b183dcbfa6e2208aee14a265a776f8690cc3d20cff2364d6d10cdf9108d74dcb12c8bb917a33daafcc9a0565bc4030bdac656df0ff41c");
    }

    // Cebula Mickey Mouse Fuck Shit

    function test_pehu_Gets_CebulaCurse() public {
        uint256 pehuCebulaBalance = cebula.balanceOf(pehu);
        assertEq(pehuCebulaBalance, 1);
    }

    function test_CebulaAndMiladyPolandMints_InEvenBlock(
        uint256 evenBlock
    ) public {
        vm.assume(evenBlock % 2 == 0 && evenBlock < 50000 && evenBlock > 1);
        vm.roll(evenBlock);
        console.log(evenBlock);
        vm.prank(deployer);
        miladyPoland.setSaleState(2);

        vm.prank(randomUser);
        miladyPoland.mint{value: 0.03 ether}(1);

        uint256 miladyPolandBalance = miladyPoland.balanceOf(randomUser);
        uint256 cebulaBalance = cebula.balanceOf(randomUser);

        assertEq(miladyPolandBalance, 1);
        assertEq(cebulaBalance, 1);
    }

    function test_CebulaAndMiladyPolandDoesNotMint_InOddBlock(
        uint256 evenBlock
    ) public {
        vm.assume(evenBlock % 2 != 0 && evenBlock < 50000);
        vm.roll(evenBlock);
        vm.prank(deployer);
        miladyPoland.setSaleState(2);

        vm.prank(randomUser);

        miladyPoland.mint{value: 0.03 ether}(1);

        uint256 miladyPolandBalance = miladyPoland.balanceOf(randomUser);
        uint256 cebulaBalance = cebula.balanceOf(randomUser);

        assertEq(miladyPolandBalance, 1);
        assertEq(cebulaBalance, 0);
    }

    function test_CebulaHolder_CanNot_transfer_Cebula(
        uint256 evenBlock
    ) public {
        // Even block so we can mint Cebula
        vm.assume(evenBlock % 2 == 0);
        vm.roll(evenBlock);
        vm.prank(kryptopaul);
        miladyPoland.FrensMint(1, "0x25a058f1958de934031b0b183dcbfa6e2208aee14a265a776f8690cc3d20cff2364d6d10cdf9108d74dcb12c8bb917a33daafcc9a0565bc4030bdac656df0ff41c");

        uint256 miladyPolandBalance = miladyPoland.balanceOf(kryptopaul);
        uint256 cebulaBalance = cebula.balanceOf(kryptopaul);

        // check balances just to be sure
        assertEq(miladyPolandBalance, 1);
        assertEq(cebulaBalance, 1);

        // check ID of kryptopaul's cebula
        uint256[] memory cebulasOfKryptopaul = cebula.tokensOfOwner(kryptopaul);
        uint256 cebulaId = cebulasOfKryptopaul[0];

        // transfer cebula from kryptopaul to randomUser using either transferFrom or safeTransferFrom
        vm.expectRevert();
        cebula.transferFrom(kryptopaul, randomUser, cebulaId);

        vm.expectRevert();
        cebula.safeTransferFrom(kryptopaul, randomUser, cebulaId);
    }

    function test_solveRiddle() public {
        miladyPoland.solveRiddle("development");
    }

    function test_riddleRevertsOnWrong() public {
        vm.expectRevert();
        miladyPoland.solveRiddle("milady");
    }
}
