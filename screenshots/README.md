# Screenshots Directory

This directory should contain screenshots demonstrating the functionality of the Crowdfunding Smart Contract when tested in Remix IDE.

Expected screenshots:

1. **deploy.png** - Shows the contract deployment in Remix IDE
2. **create_campaign.png** - Shows the createCampaign function being called with sample
3. **donate.png** - Shows the donate function being called from multiple accounts
4. **withdraw.png** - Shows the withdrawFunds function being called by the contract creator
5. **remix_tests.png** - Shows the overall Remix IDE interface with the contract deployed and tested

## How to Generate These Screenshots

1. Deploy the contract in Remix IDE using the JavaScript VM environment
2. Call the createCampaign function with test parameters
3. Call the donate function from multiple accounts with different amounts
4. Check the campaign status and progress using the view functions
5. Call the withdrawFunds function from the contract creator
6. Attempt restricted operations (like withdrawing before goal, withdrawing twice, non-owner withdrawal) to see the revert messages
7. Take screenshots of each step demonstrating the functionality

## Alternative: Test Networks

You can also test on a public testnet (Goerli, Sepolia) using MetaMask for a more realistic demonstration:
- Connect MetaMask to a testnet
- Get test ETH from a faucet
- Deploy and test the contract with real transactions