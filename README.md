# ICO Contract
This is the repository for the presale / ICO contract

# Project Status
The project is completed. 

# Specs

Are found in the [ICO.pdf](./ICO.pdf) file

# Getting Started
Recommended Node version is 16.0.0 and above.

```bash
$ npm install
$ npx hardhat test 
```

# Project Structure
This a hardhat javascript project.

## Tests

Tests are found in the `./test/` folder.

## Deployment

Create a .env file according to the .envExample file. Enter private key and bscscan api in the environment file.

Open the code in vscode. 
Inside vscode open the terminal and run the following:

```bash
$ npm install
$ npx hardhat compile
$ npx hardhat --network BSCMainnet run ./scripts/deploy.js
```

Note the addresses of the two contracts
## Verification

1. Verify token contract
```bash
$ npx hardhat --network BSCTestnet verify [TokenAddress]
```

2. Verify ICO contract
Go to the file [arguments.js](./scripts/arguments.js) file
On line 2 change the address to the token address that was displayed during deployment

```bash
$ npx hardhat --network BSCTestnet verify [ICOAddress] --constructor-args scripts/arguments.js
```


## Contracts

Solidity smart contracts are found in `./contracts/`.
