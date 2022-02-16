// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.5;


interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IUniswapV2ERC20 {
    function totalSupply() external view returns (uint);
}

interface IUniswapV2Pair is IUniswapV2ERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IUniswapV2Router02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}

contract AddLiquidityHelper {

    address public router;
    address public pair;

    constructor(address _router, address _pair){
        router = _router;
        pair = _pair;
    }

    receive() external payable {
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        address to
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity){
        IBEP20(token).transferFrom(msg.sender,address(this),amountTokenDesired);
        IBEP20(token).approve(router,amountTokenDesired);

        if(to == address(0)){
            to = msg.sender;
        }
        (amountToken, amountETH, liquidity) = IUniswapV2Router02(router).addLiquidityETH{value:msg.value}(token,amountTokenDesired,0,0,to,block.timestamp+1800);
        uint amount = IBEP20(token).balanceOf(address(this));
        if(amount > 0){
            IBEP20(token).transfer(msg.sender,amount);
        }
        amount = address(this).balance;
        if(amount > 0){
            msg.sender.transfer(amount);
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address to
    ) external returns (uint amountA, uint amountB, uint liquidity){
        IBEP20(tokenA).transferFrom(msg.sender,address(this),amountADesired);
        IBEP20(tokenB).transferFrom(msg.sender,address(this),amountBDesired);
        IBEP20(tokenA).approve(router,amountADesired);
        IBEP20(tokenB).approve(router,amountBDesired);

        if(to == address(0)){
            to = msg.sender;
        }
        (amountA, amountB, liquidity) =  IUniswapV2Router02(router).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,0,0,to,block.timestamp+1800);
        uint amount = IBEP20(tokenA).balanceOf(address(this));
        if(amount > 0){
            IBEP20(tokenA).transfer(msg.sender,amount);
        }
        amount = IBEP20(tokenB).balanceOf(address(this));
        if(amount > 0){
            IBEP20(tokenB).transfer(msg.sender,amount);
        }
    }

    function getUSDTAmount(uint amount) public view returns (uint){
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        uint _amount = IUniswapV2Router02(router).quote(amount, reserve0, reserve1);
        return _amount;
    }

    function getSRSAmount(uint amount) public view returns (uint){
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        uint _amount = IUniswapV2Router02(router).quote(amount, reserve1, reserve0);
        return _amount;
    }
}