
```shell
npx hardhat node
npx hardhat run scripts/deploy.js
```

This Staking contract was inspired by Blockmancodes (https://www.youtube.com/watch?v=7QsqElEaWBQ). I modified the code so that rewards are not ETH, but pre-minted ERC20 tokens. ERC20 token contract was created. Also some parameters were changed.

I wrote a new deploy script with hardhat-deploy which deploys token and staking app, and transfers 100 tokens from deployer to staking contract.

ERC20 token was created with openzeppelin ERC20.
