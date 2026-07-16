# Crowdfunding Smart Contract

## Project Overview

A decentralized crowdfunding platform built on the Ethereum blockchain using Solidity. This smart contract allows users to create fundraising campaigns, accept Ether donations from multiple contributors, track campaign progress, and securely withdraw funds upon reaching funding goals. The implementation follows Solidity best practices and is designed to be beginner-friendly while maintaining security and efficiency.

## Features

- **Campaign Creation**: Anyone can create a crowdfunding campaign with title, description, funding goal, and duration
- **Secure Donations**: Users can contribute Ether to active campaigns with proper validation
- **Campaign Status Tracking**: Real-time status (Active, Successful, Expired) and progress monitoring
- **Creator Withdrawals**: Only campaign creators can withdraw funds after reaching the goal
- **Contributor Tracking**: Records of individual contributions and total contributors
- **Event Logging**: Transparent events for key actions (Security withdrawal using the Effects-Errors

## Technologies

- **Solidity** ^0.8.0 (updated to use correct spelling)
- **Event Logging**: Transparent tracking of campaign creation, donations, and withdrawals
- **Security Best Practices**: 
  - Proper access control
  - Checks-Effects-Interactions pattern
  - Overflow-safe Solidity ^0.8.x
  - Custom error messages
  - Input validation

## Technologies Used

- **Solidity** ^0.8.0
- **Ethereum Virtual Machine (EVM)**
- **Remix IDE** (for development and testing)
- **MetaMask** (optional, for testing with test networks)
- **JavaScript** (for test scripts in Remix)

## Smart Contract Architecture

### Core Components

1. **Campaign Struct**: Stores all campaign-related information
   - `id`: Unique campaign identifier
   - `creator`: Address of campaign creator
   - `title`: Campaign title
   - `description`: Detailed campaign description
   - `fundingGoal`: Target amount in wei
   - `amountRaised`: Current amount raised
   - `deadline`: Unix timestamp for campaign end
   - `contributorCount`: Number of unique contributors
   - `claimed`: Boolean indicating if funds have been withdrawn
   - `active`: Boolean indicating if campaign is still active

2. **Mappings**:
   - `campaigns`: Maps campaign ID to Campaign struct
   - `contributions`: Maps campaign ID → contributor address → amount donated

3. **State Variables**:
   - `campaignCount`: Tracks total number of campaigns created

### Key Functions

#### Campaign Management
- `createCampaign()`: Create a new crowdfunding campaign
- `donate()`: Contribute Ether to an active campaign
- `withdrawFunds()`: Withdraw funds after goal is reached (creator-only)

#### Query Functions
- `getCampaign()`: Get full campaign details
- `getCampaignStatus()`: Check if campaign is Active, Successful, or Expired
- `getCampaignProgress()`: Get funding progress and time remaining
- `getContribution()`: Get individual contributor's donation amount
- `getCampaignCount()`: Get total number of campaigns
- `getAllCampaignIds()`: Get array of all campaign IDs

#### Events
- `CampaignCreated`: Emitted when a new campaign is created
- `DonationReceived`: Emitted when a donation is made
- `FundsWithdrawn`: Emitted when funds are withdrawn

## Contract Functions Detailed

### Create Campaign
```solidity
function createCampaign(
    string memory _title,
    string memory _description,
    uint256 _fundingGoal,
    uint256 _duration
) external returns (uint256 campaignId)
```
- Creates a new campaign with specified parameters
- Validates title (≥5 chars), description (≥10 chars), goal (>0), duration (>0)
- Sets deadline as current time + duration in days
- Emits `CampaignCreated` event

### Donate to Campaign
```solidity
function donate(uint256 _campaignId) external payable
```
- Accepts Ether contributions to active campaigns
- Validates campaign exists and is active
- Ensures donation amount > 0
- Updates amount raised and contributor count
- Tracks individual contributions
- Auto-deactivates campaign if goal is reached
- Emits `DonationReceived` event

### Withdraw Funds
```solidity
function withdrawFunds(uint256 _campaignId) external
```
- Allows only campaign creator to withdraw funds
- Requires funding goal to be reached
- Ensures funds haven't been withdrawn before
- Transfers entire contract balance to creator
- Marks campaign as claimed and inactive
- Emits `FundsWithdrawn` event

### View Functions
All view functions are external and don't modify state:
- `getCampaignStatus()`: Returns "Active", "Successful", or "Expired"
- `getCampaignProgress()`: Returns amount raised, goal, percentage, time remaining
- `getContribution()`: Returns individual donation amount
- `getCampaign()`: Returns complete campaign details
- `getCampaignCount()`: Returns total campaigns
- `getAllCampaignIds()`: Returns array of all campaign IDs

## Deployment Steps

### Using Remix IDE

1. **Open Remix IDE**: Go to [https://remix.ethereum.org](https://remix.ethereum.org)
2. **Create File**: In the file explorers, create a new file named `Crowdfunding.sol` in the `contracts` folder
3. **Copy Code**: Paste the Solidity code from `contracts/Crowdfunding.sol` into this file
4. **Compile**: 
   - Go to the Solidity Compiler tab
   - Ensure compiler version is set to 0.8.0 or higher (but compatible with ^0.8.0)
   - Click "Compile Crowdfunding.sol"
5. **Deploy**:
   - Go to the Deploy & Run Transactions tab
   - Select "Injected Web3" if using MetaMask, or "JavaScript VM" for testing
   - Ensure the contract Crowdfunding is selected
   - Click "Deploy"

### Contract Parameters for Deployment
The constructor requires no arguments, so deployment is straightforward.

## Remix IDE Testing Guide

### Test Environment Setup
1. Use the JavaScript VM environment for initial testing (no gas costs)
2. Optionally connect to a testnet (Goerli, Sepolia) using MetaMask for realistic testing
3. Use multiple accounts to simulate different users

### Test Account Setup (JavaScript VM)
Remix provides test accounts with 100 ETH each by default:
- Account 0: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (Creator)
- Account 1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835Cb2 (Contributor 1)
- Account 2: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db (Contributor 2)
- etc.

## Example Transactions

### Test Case 1: Create a Campaign
1. **Account**: Creator (Account 0)
2. **Function**: `createCampaign`
3. **Parameters**:
   - `_title`: "Help Fund Open Source Project"
   - `_description": "We need funds to develop a new open-source blockchain tool"
   - `_fundingGoal`: 10 ether (10000000000000000000 wei)
   - `_duration`: 30 days
4. **Expected Results**:
   - Transaction succeeds
   - Campaign count increases to 1
   - CampaignCreated event emitted with correct parameters
   - Campaign stored with correct details

### Test Case 2: Donate from Different Accounts
1. **Account**: Contributor 1 (Account 1)
2. **Function**: `donate`
3. **Parameters**: `_campaignId`: 1
4. **Value**: 2 ether
5. **Expected Results**:
   - Transaction succeeds
   - Amount raised updated to 2 ether
   - Contributor count increases to 1
   - Contribution mapping shows 2 ether for Account 1
   - DonationReceived event emitted

6. **Account**: Contributor 2 (Account 2)
7. **Function**: `donate`
8. **Parameters**: `_campaignId`: 1
9. **Value**: 3 ether
10. **Expected Results**:
    - Transaction succeeds
    - Amount raised updated to 5 ether
    - Contributor count increases to 2
    - Contribution mapping shows 3 ether for Account 2
    - DonationReceived event emitted

### Test Case 3: Attempt Donation After Deadline
1. **Setup**: Mine enough blocks to pass the deadline (or set a short duration for testing)
2. **Account**: Any contributor
3. **Function**: `donate`
4. **Parameters**: `_campaignId`: 1
5. **Value**: 1 ether
6. **Expected Results**:
   - Transaction reverts with "CampaignNotActive" error

### Test Case 4: Withdraw Funds After Reaching Goal
1. **Setup**: Ensure campaign has reached or exceeded 10 ether goal
2. **Account**: Creator (Account 0)
3. **Function**: `withdrawFunds`
4. **Parameters**: `_campaignId`: 1
5. **Expected Results**:
   - Transaction succeeds
   - Creator receives entire balance (should be ≥10 ether)
   - Contract balance updates to 0
   - Claimed flag becomes true
   - FundsWithdrawn event emitted with correct amount

### Test Case 5: Attempt Second Withdrawal
1. **Account**: Creator (Account 0)
2. **Function**: `withdrawFunds`
3. **Parameters**: `_campaignId`: 1
4. **Expected Results**:
   - Transaction reverts with "AlreadyClaimed" error

### Test Case 6: Attempt Withdrawal by Non-Owner
1. **Account**: Contributor 1 (Account 1)
2. **Function**: `withdrawFunds`
3. **Parameters**: `_campaignId`: 1
4. **Expected Results**:
   - Transaction reverts with "NotCampaignCreator" error

## Folder Structure
```
CrowdfundingSmartContract/
│
├── contracts/
│   └── Crowdfunding.sol          # Main smart contract
│
├── screenshots/
│   ├── deploy.png                # Contract deployment in Remix
│   ├── create_campaign.png       # Campaign creation transaction
│   ├── donate.png                # Donation transactions
│   ├── withdraw.png              # Fund withdrawal transaction
│   └── remix_tests.png           # Overview of Remix testing interface
│
├── README.md                     # This file
├── LICENSE                       # MIT License
└── .gitignore                    # Git ignore file
```

## Future Improvements

1. **Campaign Categories**: Add tags/categories for better campaign discovery
2. **Updates/Comments**: Allow campaign creators to post updates
3. **Refund Mechanism**: Allow contributors to request refunds if goals aren't met
4. **Milestone Funding**: Release funds in stages based on project milestones
5. **Governance**: Add voting mechanisms for fund allocation decisions
6. **Multi-token Support**: Accept ERC-20 tokens in addition to Ether
7. **Referral System**: Reward users who bring in new contributors
8. **Analytics Dashboard**: Off-chain analytics for campaign performance
9. **NFT Rewards**: Offer NFTs as rewards for different contribution tiers
10. **Layer 2 Integration**: Deploy on Polygon or Arbitrum for lower gas costs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code Quality

- **Modular Design**: Separate concerns with clear structs, mappings, and functions
- **Descriptive Naming**: Self-explanatory variable and function names
- **Solidity Style Guide**: Follows official Solidity formatting guidelines
- **Gas Efficiency**: Optimized storage usage and minimal external calls
- **Event Logging**: Proper indexing for efficient event filtering
- **Clear Revert Messages**: Descriptive error messages for debugging
- **Beginner-Friendly**: Well-commented code with logical flow

## Expected Outcome

A fully functional Solidity crowdfunding smart contract that enables:
- Users to create fundraising campaigns with clear goals and timelines
- Multiple contributors to donate Ether securely
- Transparent tracking of campaign progress and status
- Secure withdrawal of funds only by creators upon successful fundraising
- Comprehensive testing verification through Remix IDE
- Professional documentation for easy understanding and extension

The contract implements all required security patterns and provides a solid foundation for a decentralized crowdfunding platform on Ethereum.
