// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
  ___                      _   _
 | _ )_  _ _ _  _ _ _  _  | | | |
 | _ \ || | ' \| ' \ || | |_| |_|
 |___/\_,_|_||_|_||_\_, | (_) (_)
                    |__/

*
* MIT License
* ===========
*
* Copyright (c) 2020 BunnyFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

import "./BEP20.sol";
import "./SafeBEP20.sol";
import "./SafeMath.sol";

import "./IBunnyMinterV2.sol";
import "./IStakingRewards.sol";

import "../PriceCalculator/PriceCalculator.sol";
import "../zap/ZapBSC.sol";

contract BunnyMinterV2 is IBunnyMinterV2, OwnableUpgradeable {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    /* ========== CONSTANTS ============= */

    address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public constant BUNNY = 0x1870695A97B0e157511DDD3Af9277CA6695A6C7f;
    address public constant BUNNY_BNB = 0x80D395F4D052f2F9EF550Fa46F6e7802691580DD;
    address public constant BUNNY_POOL = 0xAF1DBf12B9c8A6067641A990ceEDE6caa8f7F684;

    address public constant DEPLOYER = 0x8E4Cf799B68F01f3A54c7154EeB1D94cc26fBCe9;
    address private constant TIMELOCK = 0x9B8FAF94e2BE69132169333459E936EF95874b8f;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint public constant FEE_MAX = 10000;

    ZapBSC public constant zapBSC = ZapBSC(0x6DAB5690548BDD3e8C239AE352df41039Ed7dAf7);
    PriceCalculatorBSC public constant priceCalculator = PriceCalculatorBSC(0xa04eFB13c10F73bD92cC9ce5da8bDcfe780BF58F);

    /* ========== STATE VARIABLES ========== */

    address public bunnyChef;
    mapping(address => bool) private _minters;
    address public _deprecated_helper; // deprecated

    uint public PERFORMANCE_FEE;
    uint public override WITHDRAWAL_FEE_FREE_PERIOD;
    uint public override WITHDRAWAL_FEE;

    uint public override bunnyPerProfitBNB;
    uint public bunnyPerBunnyBNBFlip;   // will be deprecated

    /* ========== MODIFIERS ========== */

    modifier onlyMinter {
        require(isMinter(msg.sender) == true, "BunnyMinterV2: caller is not the minter");
        _;
    }

    modifier onlyBunnyChef {
        require(msg.sender == bunnyChef, "BunnyMinterV2: caller not the bunny chef");
        _;
    }

    receive() external payable {}

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        WITHDRAWAL_FEE_FREE_PERIOD = 3 days;
        WITHDRAWAL_FEE = 50;
        PERFORMANCE_FEE = 3000;
         __Ownable_init();//!!!!!!!!!!!!!!!!!!!!!!!!!bloodmoon:warning,unexpected error that if u dont use this function(u cant activated this contract)
        bunnyPerProfitBNB = 5e18;
        bunnyPerBunnyBNBFlip = 6e18;

        IBEP20(BUNNY).approve(BUNNY_POOL, uint(-1));
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function transferBunnyOwner(address _owner) external onlyOwner {
        Ownable(BUNNY).transferOwnership(_owner);
    }

    function setWithdrawalFee(uint _fee) external onlyOwner {
        require(_fee < 500, "wrong fee");
        // less 5%
        WITHDRAWAL_FEE = _fee;
    }

    function setPerformanceFee(uint _fee) external onlyOwner {
        require(_fee < 5000, "wrong fee");
        PERFORMANCE_FEE = _fee;
    }

    function setWithdrawalFeeFreePeriod(uint _period) external onlyOwner {
        WITHDRAWAL_FEE_FREE_PERIOD = _period;
    }

    function setMinter(address minter, bool canMint) external override onlyOwner {
        if (canMint) {
            _minters[minter] = canMint;
        } else {
            delete _minters[minter];
        }
    }

    function setBunnyPerProfitBNB(uint _ratio) external onlyOwner {
        bunnyPerProfitBNB = _ratio;
    }

    function setBunnyPerBunnyBNBFlip(uint _bunnyPerBunnyBNBFlip) external onlyOwner {
        bunnyPerBunnyBNBFlip = _bunnyPerBunnyBNBFlip;
    }

    function setBunnyChef(address _bunnyChef) external onlyOwner {
        require(bunnyChef == address(0), "BunnyMinterV2: setBunnyChef only once");
        bunnyChef = _bunnyChef;
    }

    /* ========== VIEWS ========== */

    function isMinter(address account) public view override returns (bool) {
        if (IBEP20(BUNNY).getOwner() != address(this)) {
            return false;
        }
        return _minters[account];
    }

    function amountBunnyToMint(uint bnbProfit) public view override returns (uint) {
        return bnbProfit.mul(bunnyPerProfitBNB).div(1e18);
    }

    function amountBunnyToMintForBunnyBNB(uint amount, uint duration) public view override returns (uint) {
        return amount.mul(bunnyPerBunnyBNBFlip).mul(duration).div(365 days).div(1e18);
    }

    function withdrawalFee(uint amount, uint depositedAt) external view override returns (uint) {
        if (depositedAt.add(WITHDRAWAL_FEE_FREE_PERIOD) > block.timestamp) {
            return amount.mul(WITHDRAWAL_FEE).div(FEE_MAX);
        }
        return 0;
    }

    function performanceFee(uint profit) public view override returns (uint) {
        return profit.mul(PERFORMANCE_FEE).div(FEE_MAX);
    }

    /* ========== V1 FUNCTIONS ========== */

    function mintFor(address asset, uint _withdrawalFee, uint _performanceFee, address to, uint) external payable override onlyMinter {
        uint feeSum = _performanceFee.add(_withdrawalFee);
        _transferAsset(asset, feeSum);

        if (asset == BUNNY) {
            IBEP20(BUNNY).safeTransfer(DEAD, feeSum);
            return;
        }

        uint bunnyBNBAmount = _zapAssetsToBunnyBNB(asset);
        if (bunnyBNBAmount == 0) return;

        IBEP20(BUNNY_BNB).safeTransfer(BUNNY_POOL, bunnyBNBAmount);
        IStakingRewards(BUNNY_POOL).notifyRewardAmount(bunnyBNBAmount);

        (uint valueInBNB,) = priceCalculator.valueOfAsset(BUNNY_BNB, bunnyBNBAmount);
        uint contribution = valueInBNB.mul(_performanceFee).div(feeSum);
        uint mintBunny = amountBunnyToMint(contribution);
        if (mintBunny == 0) return;
        _mint(mintBunny, to);
    }

    // @dev will be deprecated
    function mintForBunnyBNB(uint amount, uint duration, address to) external override onlyMinter {
        uint mintBunny = amountBunnyToMintForBunnyBNB(amount, duration);
        if (mintBunny == 0) return;
        _mint(mintBunny, to);
    }

    /* ========== V2 FUNCTIONS ========== */

    function mint(uint amount) external override onlyBunnyChef {
        if (amount == 0) return;
        _mint(amount, address(this));
    }

    function safeBunnyTransfer(address _to, uint _amount) external override onlyBunnyChef {
        if (_amount == 0) return;

        uint bal = IBEP20(BUNNY).balanceOf(address(this));
        if (_amount <= bal) {
            IBEP20(BUNNY).safeTransfer(_to, _amount);
        } else {
            IBEP20(BUNNY).safeTransfer(_to, bal);
        }
    }

    // @dev should be called when determining mint in governance. Bunny is transferred to the timelock contract.
    function mintGov(uint amount) external override onlyOwner {
        if (amount == 0) return;
        _mint(amount, TIMELOCK);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _transferAsset(address asset, uint amount) private {
        if (asset == address(0)) {
            // case) transferred BNB
            require(msg.value >= amount);
        } else {
            IBEP20(asset).safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function _zapAssetsToBunnyBNB(address asset) private returns (uint) {
        if (asset != address(0) && IBEP20(asset).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(asset).safeApprove(address(zapBSC), uint(-1));
        }

        if (asset == address(0)) {
            zapBSC.zapIn{value : address(this).balance}(BUNNY_BNB);
        }
        else if (keccak256(abi.encodePacked(IPancakePair(asset).symbol())) == keccak256("Cake-LP")) {
            zapBSC.zapOut(asset, IBEP20(asset).balanceOf(address(this)));

            IPancakePair pair = IPancakePair(asset);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (token0 == WBNB || token1 == WBNB) {
                address token = token0 == WBNB ? token1 : token0;
                if (IBEP20(token).allowance(address(this), address(zapBSC)) == 0) {
                    IBEP20(token).safeApprove(address(zapBSC), uint(-1));
                }
                zapBSC.zapIn{value : address(this).balance}(BUNNY_BNB);
                zapBSC.zapInToken(token, IBEP20(token).balanceOf(address(this)), BUNNY_BNB);
            } else {
                if (IBEP20(token0).allowance(address(this), address(zapBSC)) == 0) {
                    IBEP20(token0).safeApprove(address(zapBSC), uint(-1));
                }
                if (IBEP20(token1).allowance(address(this), address(zapBSC)) == 0) {
                    IBEP20(token1).safeApprove(address(zapBSC), uint(-1));
                }

                zapBSC.zapInToken(token0, IBEP20(token0).balanceOf(address(this)), BUNNY_BNB);
                zapBSC.zapInToken(token1, IBEP20(token1).balanceOf(address(this)), BUNNY_BNB);
            }
        }
        else {
            zapBSC.zapInToken(asset, IBEP20(asset).balanceOf(address(this)), BUNNY_BNB);
        }

        return IBEP20(BUNNY_BNB).balanceOf(address(this));
    }

    function _mint(uint amount, address to) private {
        BEP20 tokenBUNNY = BEP20(BUNNY);

        tokenBUNNY.mint(amount);
        if (to != address(this)) {
            tokenBUNNY.transfer(to, amount);
        }

        uint bunnyForDev = amount.mul(15).div(100);
        tokenBUNNY.mint(bunnyForDev);
        IStakingRewards(BUNNY_POOL).stakeTo(bunnyForDev, DEPLOYER);
    }
}
