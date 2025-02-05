// Solidity(ethruem) Smart Contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarriageContract {
    // Parties involved
    address public partyA;
    address public partyB;

    // Contract terms
    uint256 public startDate;
    uint256 public endDate;
    uint256 public renewalTerm; // Renewal term in seconds (e.g., 1 year = 365 days = 365*24*60*60)
    bool public isActive;

    // Financial contributions by parties
    uint256 public financialContributionsA;
    uint256 public financialContributionsB;

    // Milestone tracking
    uint256 public milestonesAchievedA;
    uint256 public milestonesAchievedB;
    uint256 public vestingSchedule; // Percentage of coins unlocked based on milestones (0-100%)

    // Investors mapping
    mapping(address => uint256) public investorBalance;

    // Agreement clauses (simplified)
    string public agreementClause;

    // Third-party Oracle (address for KYC verification)
    address public verificationOracle;

    // Events
    event ContractCreated(address partyA, address partyB, uint256 startDate, uint256 endDate);
    event ContractRenewed(address partyA, address partyB, uint256 newEndDate);
    event GoalAchieved(address party, uint256 progress);
    event TokenInvested(address investor, uint256 amount);
    event ContractExited(address party);

    modifier onlyActive() {
        require(isActive, "Contract is not active");
        _;
    }

    modifier onlyParty() {
        require(msg.sender == partyA || msg.sender == partyB, "Only participants can perform this action");
        _;
    }

    modifier onlyInvestor() {
        require(investorBalance[msg.sender] > 0, "Only investors can perform this action");
        _;
    }

    // Contract constructor
    constructor(
        address _partyA,
        address _partyB,
        uint256 _startDate,
        uint256 _renewalTerm,
        address _verificationOracle
    ) {
        partyA = _partyA;
        partyB = _partyB;
        startDate = _startDate;
        renewalTerm = _renewalTerm;
        endDate = _startDate + _renewalTerm;
        isActive = true;
        financialContributionsA = 0;
        financialContributionsB = 0;
        milestonesAchievedA = 0;
        milestonesAchievedB = 0;
        vestingSchedule = 0;
        agreementClause = "Default agreement terms...";
        verificationOracle = _verificationOracle;

        emit ContractCreated(partyA, partyB, startDate, endDate);
    }

    // Verify participants (call third-party Oracle for KYC validation)
    function verifyParticipants() public onlyActive {
        require(verificationOracle != address(0), "Verification oracle not set");

        bool verifiedA = verify(partyA);
        bool verifiedB = verify(partyB);

        require(verifiedA && verifiedB, "Both participants must be verified");
    }

    // Simulate third-party verification (you can integrate an actual KYC oracle here)
    function verify(address participant) internal view returns (bool) {
        // This is a placeholder function for actual KYC verification logic
        return true; // Assume all participants are verified in this example
    }

    // Set financial contributions by either party
    function setFinancialContribution(uint256 amount, bool isPartyAContribution) public onlyParty {
        if (isPartyAContribution) {
            financialContributionsA += amount;
        } else {
            financialContributionsB += amount;
        }
    }

    // Set milestone progress for each participant
    function setMilestoneProgress(uint256 progress, bool isPartyAProgress) public onlyParty {
        if (isPartyAProgress) {
            milestonesAchievedA += progress;
        } else {
            milestonesAchievedB += progress;
        }

        // Check if milestones are met and unlock coins
        if (milestonesAchievedA >= 100) {
            vestCoins(partyA);
        }

        if (milestonesAchievedB >= 100) {
            vestCoins(partyB);
        }

        emit GoalAchieved(isPartyAProgress ? partyA : partyB, progress);
    }

    // Vest coins (mock-up function, integrate actual token minting logic)
    function vestCoins(address participant) internal {
        // Mint or unlock coins for the participant
        uint256 mintedAmount = 100; // Example value
        emit TokenInvested(participant, mintedAmount);
    }

    // Allow investors to invest in the contract
    function invest(uint256 amount) public {
        require(amount > 0, "Investment amount must be greater than zero");

        investorBalance[msg.sender] += amount;
        emit TokenInvested(msg.sender, amount);
    }

    // Renew the contract for another term
    function renewContract() public onlyActive {
        require(block.timestamp >= endDate, "Contract cannot be renewed before expiration");

        endDate = block.timestamp + renewalTerm;
        emit ContractRenewed(partyA, partyB, endDate);
    }

    // Allow a party to exit the contract
    function exitContract() public onlyParty {
        isActive = false;
        emit ContractExited(msg.sender);
    }

    // Function to check if the contract is still active
    function isContractActive() public view returns (bool) {
        return isActive;
    }

    // Get contract details
    function getContractDetails() public view returns (string memory) {
        return agreementClause;
    }

    // Update agreement clause
    function setAgreementClause(string memory newClause) public onlyParty {
        agreementClause = newClause;
    }
}
