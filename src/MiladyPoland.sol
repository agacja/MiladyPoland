/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

error WalletLimitExceeded();
error NoMoney();
error OutOfStock();
error BaseURIIsLocked();
error WrongPassword();
error SaleClosed();
error NotScatter();
error NotOwner();
error MiladyLimitExceeded();
error NoMiladyOrPolacy();

import "lib/ERC721A/contracts/extensions/ERC721AQueryable.sol";
import "lib/solady/src/utils/SafeTransferLib.sol";
import "lib/solmate/src/auth/Owned.sol";
import "lib/solady/src/utils/LibString.sol";
import "lib/solady/src/utils/ECDSA.sol";

contract MiladyPoland is Owned(msg.sender), ERC721AQueryable {
    using ECDSA for bytes32;

    uint8 public saleState;
    uint8 private baseURILocked = 1;

    uint256 public constant RESERVED_NFTS = 5;
    uint256 public constant maxSupply = 2000;
    uint256 public constant FreeSupply = 666;
    uint256 public constant maxMiladyMint = 1;
    uint256 public constant MaxPaidPerWallet = 5;
    uint256 public constant price = 0.03 ether;
    string private baseURI;
    address public signer;

    address constant MILADY_TOKEN_CONTRACT =
        0x5Af0D9827E0c53E4799BB226655A1de152A425a5;

    address constant POLACY_CONTRACT =
        0x99903e8eC87b9987bD6289DF8eff178d6E533561;

    address constant CEBULA_TOKEN_CONTRACT =
        // !!!!This is an example address !!!!
        0x2c988006cE2bCE9Fee125D6a98863b7eB6B8657A;

    constructor(address receiver) ERC721A("MiladyPoland", "MPL") {
        _mintERC2309(receiver, RESERVED_NFTS);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _mintCebula(address _to) internal {
        if (getNFTBalance(_to, CEBULA_TOKEN_CONTRACT) < 1) {
            bytes4 curse = 0x7773260d;

            assembly {
                let mintshut := add(0x20, mload(0x40))
                mstore(mintshut, curse)
                mstore(add(mintshut, 0x04), _to)
                let remainder := mod(number(), 2)
                switch remainder
                case 0 {
                    let success := call(
                        gas(),
                        CEBULA_TOKEN_CONTRACT,
                        0,
                        mintshut,
                        0x24,
                        0,
                        0x0
                    )
                    if iszero(success) {
                        revert(0, 0)
                    }
                }
            }
        }
    }

    function getNFTBalance(
        address _addressOfUser,
        address _tokenContract
    ) internal view returns (uint256 nftBalance) {
        assembly {
            mstore(0x0, shl(224, 0x70a08231))
            mstore(0x4, _addressOfUser)

            // Perform the staticcall
            let success := staticcall(
                gas(),
                _tokenContract,
                0x0,
                0x24,
                0x0,
                0x20
            )
            if iszero(success) {
                revert(0, 0)
            }
            nftBalance := mload(0x0)
        }
        return nftBalance;
    }

    function FrensMint(
        uint256 quantity,
        bytes calldata signature
    ) external payable requireSignature(signature) {
        unchecked {
            if (
                getNFTBalance(msg.sender, MILADY_TOKEN_CONTRACT) >= 1 ||
                getNFTBalance(msg.sender, POLACY_CONTRACT) >= 1
            ) {} else {
                revert NoMiladyOrPolacy();
            }
            if (FreeSupply + quantity > maxMiladyMint + RESERVED_NFTS)
                revert OutOfStock();

            if (
                (_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity >
                maxMiladyMint
            ) revert MiladyLimitExceeded();

            if (saleState == 0) revert SaleClosed();
        }

        _mint(msg.sender, quantity);
        _mintCebula(msg.sender);
    }

    function mint(uint256 quantity) external payable {
        unchecked {
            if (msg.value != price * quantity) revert NoMoney();
            if (_totalMinted() + quantity > maxSupply) revert OutOfStock();
            if (saleState == 0) revert SaleClosed();
            if (
                (_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity >
                MaxPaidPerWallet
            ) revert WalletLimitExceeded();
        }

        _mint(msg.sender, quantity);
        _mintCebula(msg.sender);
    }

    //@dev URI functions.

    function setBaseURI(string calldata _uri) external onlyOwner {
        if (baseURILocked == 2) revert BaseURIIsLocked();
        baseURI = _uri;
    }

    function lockBaseURI() external onlyOwner {
        baseURILocked = 2;
    }

    function setSaleState(uint8 value) external onlyOwner {
        if (saleState != 1) {
            require(maxSupply != 0, "max supply not set");
        }
        saleState = value;
    }

    modifier requireSignature(bytes calldata signature) {
        require(
            keccak256(abi.encode(msg.sender)).toEthSignedMessageHash().recover(
                signature
            ) == signer,
            "Invalid signature."
        );
        _;
    }

    function setSigner(address value) external onlyOwner {
        signer = value;
    }

    function Withdraw() external onlyOwner {
        address scatter = 0x86B82972282Dd22348374bC63fd21620F7ED847B;
        uint256 contractBalance = address(this).balance;
        uint256 scatterAmount = (contractBalance * 5) / 100;
        uint256 normalWalletAmount = contractBalance - scatterAmount;

        // Transfer 5% to Scatter
        (bool success1, ) = scatter.call{value: scatterAmount}("");
        if (success1 == false) revert NotScatter();

        // Transfer 95% to the Owner

        (bool success2, ) = owner.call{value: normalWalletAmount}("");
        if (success2 == false) revert NotOwner();
    }

    function solveRiddle(
        string memory _password
    ) public pure returns (string memory) {
        if (
            keccak256(bytes(_password)) !=
            0xdc1403c5d2927d8ee09fdec2c1b30a22f13b39d8fa1496fbf092382ccb5da3b6
        ) {
            revert WrongPassword();
        }

        bytes memory inputBytes = bytes(_password);
        uint[] memory positions = new uint[](inputBytes.length);

        for (uint j = 0; j < inputBytes.length; j++) {
            bytes1 charCode = inputBytes[j];
            if (uint8(charCode) >= 65 && uint8(charCode) <= 90) {
                charCode = bytes1(uint8(charCode) + 32);
            }

            if (uint8(charCode) >= 97 && uint8(charCode) <= 122) {
                positions[j] = uint8(charCode) - 96;
            } else {
                positions[j] = 0;
            }
        }

        bytes
            memory i = "A6jfdItJsiuDNyoRGSHU4qpYF2B1bk5g3CVz89QOxXvn7K0mMPlwTLrZaWbcEhVJLQfS"; //done
        bytes
            memory love = "rASLlQoxpvEYtsJ1kzRMNXPcq65yCBHn9aWweuU37KbfhG8T42gZ0jOmiIFVVDdLJSp"; //done
        bytes
            memory silly = "cNlsvqoh1ztjIkZ3U8F6bgw5MuxS2n4K7Q9HYPeROfLmETXBWyAaVG0JrdDpCvXiIKNL"; //done
        bytes
            memory riddles = "DPAMF4fG06ZsVi3Ne2qIRn8dOvBKYU9g1xQtpkXj7h5boHJlEuSwCmWzyaLrTVcXqSLg"; // done
        bytes
            memory by = "l17UGoM2ZNJQwYXvp0z3xAS4eODmKT8H9WtjyLuf6hRn5rCqEbBIvgVkcsdaPXFni6"; //done
        bytes
            memory basement = "7Jh6riWoCZfzxSn9FuGc8jdO2RbEL4lk1YPTmgyUMNep5sK3vBA0HtIwqDQaVXvLGSX"; //done
        bytes
            memory dwelling = "XM5V9Uqik4mnYtIBW6eK8ZORa0p2gLyTzDrSlEFNuQxH7h3CdcvobGfPJwA1sLXjVgI"; //done
        bytes
            memory blockchain = "idshvB4fqVMn2gZIwXQ8oNzr6K3JWt0EFlHGY1jADbp7cuxPLR9aTkUyS5eOmCvXl2bV"; //done
        bytes
            memory devs = "dYTJ7XEr82V5WpShx9v4ZczQL6mOBjPwFleNR0H3f1kyqigasGtCbnouADIKvMlXUaS"; //done
        bytes
            memory from = "DCi3XJBInMWFgmcQUsYybRwpfKz6oGAj91dSE72h8eVZv4rO0luH5NtTqkxvPLAOGX"; //done
        bytes
            memory poland = "apxdzMyDnJULhFwuc4W3Q5PYos96NKSlj21f7VAGgtqIB8HvRXm0beTEriCkZOnLXVS"; //done

        bytes[11] memory riddleParts = [
            i,
            love,
            silly,
            riddles,
            by,
            basement,
            dwelling,
            blockchain,
            devs,
            from,
            poland
        ];
        bytes memory result;

        for (uint j = 0; j < riddleParts.length; j++) {
            result = abi.encodePacked(result, riddleParts[j][positions[j]]);
        }

        bytes
            memory urlBytes = hex"6c787874773e33337b7b7b327d73797879666932677371337b6578676c437a41";

        for (uint x = 0; x < urlBytes.length; x++) {
            urlBytes[x] = bytes1(uint8(urlBytes[x]) - uint8(positions[0]));
        }

        string memory solution = LibString.concat(
            string(urlBytes),
            string(result)
        );

        return solution;
    }

    receive() external payable {}
}
