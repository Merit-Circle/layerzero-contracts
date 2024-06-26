// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "./BaseOFTWithFeeUpgradeable.sol";

contract OFTWithFeePermitUpgradeable is Initializable, BaseOFTWithFeeUpgradeable, ERC20Upgradeable, Proxied, ERC20PermitUpgradeable {
    uint internal ld2sdRate;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _sharedDecimals,
        address _lzEndpoint
    ) public virtual initializer {
        __OFTWithFeePermitUpgradeable_init(_name, _symbol, _sharedDecimals, _lzEndpoint);
    }

    function __OFTWithFeePermitUpgradeable_init(
        string memory _name,
        string memory _symbol,
        uint8 _sharedDecimals,
        address _lzEndpoint
    ) internal onlyInitializing {
        __Ownable_init_unchained();
        __LzAppUpgradeable_init_unchained(_lzEndpoint);
        __OFTCoreV2Upgradeable_init_unchained(_sharedDecimals);

        __ERC20_init_unchained(_name, _symbol);
        __ERC20Permit_init_unchained(_name);

        __OFTWithFeePermitUpgradeable_init_unchained(_sharedDecimals);
    }

    function __OFTWithFeePermitUpgradeable_init_unchained(uint8 _sharedDecimals) internal onlyInitializing {
        uint8 decimals = decimals();
        require(_sharedDecimals <= decimals, "OFTWithFee: sharedDecimals must be <= decimals");
        ld2sdRate = 10**(decimals - _sharedDecimals);
    }

    /************************************************************************
     * public functions
     ************************************************************************/
    function circulatingSupply() public view virtual override returns (uint) {
        return totalSupply();
    }

    function token() public view virtual override returns (address) {
        return address(this);
    }

    /************************************************************************
     * internal functions
     ************************************************************************/
    function _debitFrom(
        address _from,
        uint16,
        bytes32,
        uint _amount
    ) internal virtual override returns (uint) {
        address spender = _msgSender();
        if (_from != spender) _spendAllowance(_from, spender, _amount);
        _burn(_from, _amount);
        return _amount;
    }

    function _creditTo(
        uint16,
        address _toAddress,
        uint _amount
    ) internal virtual override returns (uint) {
        _mint(_toAddress, _amount);
        return _amount;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint _amount
    ) internal virtual override returns (uint) {
        address spender = _msgSender();
        // if transfer from this contract, no need to check allowance
        if (_from != address(this) && _from != spender) _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
        return _amount;
    }

    function _ld2sdRate() internal view virtual override returns (uint) {
        return ld2sdRate;
    }
}
