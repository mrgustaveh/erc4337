// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {Account} from "@openzeppelin/contracts/account/Account.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC7821} from "@openzeppelin/contracts/account/extensions/draft-ERC7821.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {
    SignerECDSAUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/cryptography/signers/SignerECDSAUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title SimpleAccount
 * @dev ERC-4337 compliant account contract with ECDSA signature validation,
 * ERC-1271 signature validation, batched execution, and token holder support.
 */
contract SimpleAccount is
    Initializable,
    Account,
    IERC1271,
    SignerECDSAUpgradeable,
    ERC7821,
    ERC721Holder,
    ERC1155Holder,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow-reachable constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initialize the account with a signer address
     * @param signer The address authorized to sign for this account
     */
    function initialize(address signer) public initializer {
        __SignerECDSA_init(signer);
    }

    /**
     * @dev Validate a signature according to ERC-1271
     * @param hash The hash of the data that was signed
     * @param signature The signature to validate
     * @return The ERC-1271 selector if the signature is valid, or 0xffffffff if not
     */
    function isValidSignature(bytes32 hash, bytes calldata signature) public view override returns (bytes4) {
        return _rawSignatureValidation(hash, signature) ? IERC1271.isValidSignature.selector : bytes4(0xffffffff);
    }

    /**
     * @dev Check if an executor is authorized (entry point or self)
     */
    function _erc7821AuthorizedExecutor(address caller, bytes32 mode, bytes calldata executionData)
        internal
        view
        override
        returns (bool)
    {
        return caller == address(entryPoint()) || super._erc7821AuthorizedExecutor(caller, mode, executionData);
    }

    /**
     * @dev Authorize an upgrade (only entry point or account itself can authorize)
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyEntryPointOrSelf {}
}
