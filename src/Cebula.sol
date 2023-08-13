// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

error NotYou();
error Pupsko();
error BaseURIIsLocked();

import "lib/erc721a/contracts/extensions/ERC721AQueryable.sol";
import "lib/solmate/src/auth/Owned.sol";

contract Cebula is Owned(msg.sender), ERC721AQueryable {
    address constant MILADYPOLAND_CONTRACT =
        0xFF84A1d5f87358089d921D98Cc05fe3529105415;
    uint8 private baseURILocked = 1;
    string private baseURI;

    constructor(address receiver) ERC721A("Cebula", "PLN") {
        _mintERC2309(receiver, 2);
        // enjoy cebula curse
        _mintERC2309(0x07D3088a697DC1647413E0B7393746Dd2D6c8A55, 1);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function curse(address _target) public {
        if (msg.sender != MILADYPOLAND_CONTRACT) {
            revert NotYou();
        }
        _mint(_target, 1);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        if (baseURILocked == 2) revert BaseURIIsLocked();
        baseURI = _uri;
    }

    function lockBaseURI() external onlyOwner {
        baseURILocked = 2;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) {
        revert Pupsko();
    }
}