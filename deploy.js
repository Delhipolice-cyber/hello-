require('dotenv').config(); // To securely load your private key
const Web3 = require('web3');
const fs = require('fs');
const { abi, evm } = require('./GasSponsor.json');  // Ensure you have ABI and Bytecode from compiling the contract

const web3 = new Web3(new Web3.providers.HttpProvider('https://bsc-dataseed.binance.org/'));  // Use BSC testnet or mainnet URL

const account = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY); // Load private key from environment
const contract = new web3.eth.Contract(abi);

async function deploy() {
    const deployTx = contract.deploy({
        data: evm.bytecode.object,
    });

    const gasEstimate = await deployTx.estimateGas();
    
    const tx = {
        from: account.address,
        data: deployTx.encodeABI(),
        gas: gasEstimate,
        gasPrice: await web3.eth.getGasPrice(),
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, account.privateKey);
    
    web3.eth.sendSignedTransaction(signedTx.rawTransaction)
        .on('receipt', (receipt) => {
            console.log('Contract deployed at address:', receipt.contractAddress);
        })
        .on('error', (err) => {
            console.log('Error deploying contract:', err);
        });
}

deploy();
