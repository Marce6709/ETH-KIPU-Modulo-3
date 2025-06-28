# SimpleSwap

## Index

* [Project Description](#project-description)
* [Features](#features)
* [Author](#author)
* [License](#license)

## Project Description

SimpleSwap is an educational smart contract that replicates core Uniswap V2 functionalities: adding and removing liquidity, executing token swaps, querying prices, and calculating output amounts. It is intended solely for learning and should not be used in production.

## Features

* **addLiquidity**: Add liquidity to an ERC-20 token pair and mint LP tokens.
* **removeLiquidity**: Burn LP tokens and return proportional underlying tokens.
* **swapExactTokensForTokens**: Swap an exact amount of input tokens for output tokens, with a minimum output requirement.
* **getPrice**: Retrieve the current price ratio between two tokens based on the pool’s reserves.
* **getAmountOut**: Calculate the output token amount given an input amount and current reserves.
* **Deadline Enforcement**: Ensure transactions execute before a specified deadline.


## Author

Einarmig

## License

MIT License
