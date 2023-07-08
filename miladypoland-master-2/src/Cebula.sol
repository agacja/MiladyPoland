// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

error WalletLimitExceeded();
error PriceMustbemultipleofunit();
error OutOfStock();
error NotYou();
error NotTokenOwner();
error chujciwdupe();
error Pupsko();

import "lib/erc721a/contracts/extensions/ERC721AQueryable.sol";
import "lib/solmate/src/auth/Owned.sol";
import "forge-std/Test.sol";

contract Cebula is Owned(msg.sender), ERC721AQueryable {
    address constant MILADYPOLAND_CONTRACT =
        0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;

    constructor(address receiver) ERC721A("Cebula", "PLN") {
        _mintERC2309(receiver, 2);
        // enjoy cebula curse
        _mintERC2309(0x07D3088a697DC1647413E0B7393746Dd2D6c8A55, 1);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function curse(address _target) public {
        console.log(msg.sender);
        console.log(owner);
        if (msg.sender != MILADYPOLAND_CONTRACT) {
            revert NotYou();
        }
        _mint(_target, 1);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) {
        revert Pupsko();
    }
}
