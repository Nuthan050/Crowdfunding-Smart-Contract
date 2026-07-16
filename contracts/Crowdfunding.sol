// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crowdfunding Smart Contract
 * @dev A decentralized crowdfunding platform allowing users to create campaigns,
 *      accept donations, and withdraw funds upon reaching goals.
 *      Follows Solidity best practices including Checks-Effects-Interactions pattern.
 */
contract Crowdfunding {
    /* ===== STRUCTS ===== */
    struct Campaign {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 fundingGoal; // in wei
        uint256 amountRaised;
        uint256 deadline; // unix timestamp
        uint256 contributorCount;
        bool claimed;
        bool active; // true if active, false if expired/successful
    }

    /* ===== STATE VARIABLES ===== */
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    /* ===== EVENTS ===== */
    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed creator,
        string title,
        uint256 fundingGoal,
        uint256 deadline
    );

    event DonationReceived(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

    event FundsWithdrawn(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 amount
    );

    /* ===== ERRORS ===== */
    error CampaignDoesNotExist();
    error CampaignNotActive();
    error CampaignAlreadyEnded();
    error GoalNotReached();
    error AlreadyClaimed();
    error NotCampaignCreator();
    error InvalidAmount();
    error InvalidDeadline();
    error TitleTooShort();
    error DescriptionTooShort();

    /* ===== MODIFIERS ===== */
    modifier onlyCampaignCreator(uint256 campaignId) {
        require(
            msg.sender == campaigns[campaignId].creator,
            "NotCampaignCreator"
        );
        _;
    }

    modifier campaignExists(uint256 campaignId) {
        require(campaignId > 0 && campaignId <= campaignCount, "CampaignDoesNotExist");
        _;
    }

    modifier campaignActive(uint256 campaignId) {
        require(
            campaigns[campaignId].active &&
            block.timestamp < campaigns[campaignId].deadline,
            "CampaignNotActive"
        );
        _;
    }

    modifier campaignNotEnded(uint256 campaignId) {
        require(
            block.timestamp < campaigns[campaignId].deadline,
            "CampaignAlreadyEnded"
        );
        _;
    }

    modifier goalReached(uint256 campaignId) {
        require(
            campaigns[campaignId].amountRaised >= campaigns[campaignId].fundingGoal,
            "GoalNotReached"
        );
        _;
    }

    modifier notClaimed(uint256 campaignId) {
        require(!campaigns[campaignId].claimed, "AlreadyClaimed");
        _;
    }

    /* ===== CONSTRUCTOR ===== */
    constructor() {
        campaignCount = 0;
    }

    /* ===== CORE FUNCTIONS ===== */
    /**
     * @dev Creates a new crowdfunding campaign
     * @param _title Title of the campaign (min 5 characters)
     * @param _description Description of the campaign (min 10 characters)
     * @param _fundingGoal Funding goal in wei
     * @param _duration Duration of campaign in days
     */
    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _fundingGoal,
        uint256 _duration
    ) external
        returns (uint256 campaignId)
    {
        require(bytes(_title).length >= 5, "TitleTooShort");
        require(bytes(_description).length >= 10, "DescriptionTooShort");
        require(_fundingGoal > 0, "InvalidAmount");
        require(_duration > 0, "InvalidDeadline");

        campaignCount++;
        campaignId = campaignCount;

        campaigns[campaignId] = Campaign({
            id: campaignId,
            creator: msg.sender,
            title: _title,
            description: _description,
            fundingGoal: _fundingGoal,
            amountRaised: 0,
            deadline: block.timestamp + (_duration * 86400),
            contributorCount: 0,
            claimed: false,
            active: true
        });

        emit CampaignCreated(
            campaignId,
            msg.sender,
            _title,
            _fundingGoal,
            block.timestamp + (_duration * 86400)
        );
    }

    /**
     * @dev Allows users to donate to an active campaign
     * @param _campaignId ID of the campaign to donate to
     */
    function donate(uint256 _campaignId) external payable
        campaignExists(_campaignId)
        campaignActive(_campaignId)
    {
        require(msg.value > 0, "InvalidAmount");

        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_campaignId];

        // Checks-Effects-Interactions pattern
        // Check: already handled by modifiers

        // Effects
        campaign.amountRaised += amount;

        // Update contributor count if new contributor
        if (contributions[_campaignId][msg.sender] == 0) {
            campaign.contributorCount++;
        }

        contributions[_campaignId][msg.sender] += amount;

        // Interaction
        emit DonationReceived(_campaignId, msg.sender, amount);

        // Auto-deactivate if goal reached
        if (campaign.amountRaised >= campaign.fundingGoal) {
            campaign.active = false;
        }
    }

    /**
     * @dev Allows campaign creator to withdraw funds after goal is reached
     * @param _campaignId ID of the campaign to withdraw from
     */
    function withdrawFunds(uint256 _campaignId) external
        campaignExists(_campaignId)
        onlyCampaignCreator(_campaignId)
        goalReached(_campaignId)
        notClaimed(_campaignId)
    {
        Campaign storage campaign = campaigns[_campaignId];
        uint256 amount = campaign.amountRaised;

        // Checks-Effects-Interactions pattern
        // Check: already handled by modifiers

        // Effects
        campaign.claimed = true;
        campaign.active = false;

        // Interaction
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit FundsWithdrawn(_campaignId, msg.sender, amount);
    }

    /* ===== VIEW FUNCTIONS ===== */
    /**
     * @dev Returns the status of a campaign
     * @param _campaignId ID of the campaign
     * @return status String indicating status: "Active", "Successful", or "Expired"
     */
    function getCampaignStatus(uint256 _campaignId)
        external
        view
        campaignExists(_campaignId)
        returns (string memory)
    {
        Campaign storage campaign = campaigns[_campaignId];

        if (!campaign.active) {
            if (campaign.claimed) {
                return "Successful";
            } else {
                return "Expired";
            }
        }

        if (block.timestamp >= campaign.deadline) {
            campaign.active = false;
            return "Expired";
        }

        if (campaign.amountRaised >= campaign.fundingGoal) {
            campaign.active = false;
            return "Successful";
        }

        return "Active";
    }

    /**
     * @dev Gets progress information for a campaign
     * @param _campaignId ID of the campaign
     * @return amountRaised Amount raised in wei
     * @return fundingGoal Funding goal in wei
     * @return percentageFunded Percentage of goal reached (0-100)
     * @return timeRemaining Time left in seconds (0 if expired)
     */
    function getCampaignProgress(uint256 _campaignId)
        external
        view
        campaignExists(_campaignId)
        returns (
            uint256 amountRaised,
            uint256 fundingGoal,
            uint256 percentageFunded,
            uint256 timeRemaining
        )
    {
        Campaign storage campaign = campaigns[_campaignId];
        amountRaised = campaign.amountRaised;
        fundingGoal = campaign.fundingGoal;

        if (fundingGoal > 0) {
            percentageFunded = (amountRaised * 100) / fundingGoal;
        } else {
            percentageFunded = 0;
        }

        if (block.timestamp < campaign.deadline) {
            timeRemaining = campaign.deadline - block.timestamp;
        } else {
            timeRemaining = 0;
        }
    }

    /**
     * @dev Gets contributor's donation to a specific campaign
     * @param _campaignId ID of the campaign
     * @param _contributor Address of the contributor
     * @return amount Amount contributed in wei
     */
    function getContribution(uint256 _campaignId, address _contributor)
        external
        view
        campaignExists(_campaignId)
        returns (uint256)
    {
        return contributions[_campaignId][_contributor];
    }

    /**
     * @dev Gets total number of campaigns
     * @return count Total number of campaigns created
     */
    function getCampaignCount() external view returns (uint256) {
        return campaignCount;
    }

    /**
     * @dev Gets summary information for a campaign
     * @param _campaignId ID of the campaign
     * @return title Campaign title
     * @return description Campaign description
     * @return creator Campaign creator address
     * @return fundingGoal Funding goal in wei
     * @return amountRaised Amount raised in wei
     * @return deadline Campaign deadline (unix timestamp)
     * @return contributorCount Number of contributors
     * @return claimed Whether funds have been claimed
     * @return active Whether campaign is currently active
     */
    function getCampaign(uint256 _campaignId)
        external
        view
        campaignExists(_campaignId)
        returns (
            string memory title,
            string memory description,
            address creator,
            uint256 fundingGoal,
            uint256 amountRaised,
            uint256 deadline,
            uint256 contributorCount,
            bool claimed,
            bool active
        )
    {
        Campaign storage campaign = campaigns[_campaignId];
        title = campaign.title;
        description = campaign.description;
        creator = campaign.creator;
        fundingGoal = campaign.fundingGoal;
        amountRaised = campaign.amountRaised;
        deadline = campaign.deadline;
        contributorCount = campaign.contributorCount;
        claimed = campaign.claimed;
        active = campaign.active;
    }

    /**
     * @dev Gets all campaign IDs
     * @return ids Array of all campaign IDs
     */
    function getAllCampaignIds() external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](campaignCount);
        for (uint256 i = 1; i <= campaignCount; i++) {
            ids[i-1] = i;
        }
        return ids;
    }
}