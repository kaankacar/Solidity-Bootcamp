// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Final_Homework {
    uint256 private counter;
    address private owner;
    mapping(uint256 => Proposal) private proposal_history;

    // 1st change: Vote Tracking
    mapping(address => bool) private hasVoted;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool is_active;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You're not the owner.");
        _;
    }

    modifier activeProposal() {
        require(proposal_history[counter].is_active, "No active proposal.");
        _;
    }

    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "Address has already voted.");
        _;
    }

    function createProposal(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        // 4th change: One proposal at a time
        require(!proposal_history[counter].is_active, "Existing proposal still active.");
        counter++;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, true);
    }

    function vote(uint8 choice) external activeProposal hasNotVoted {
        Proposal storage proposal = proposal_history[counter];
        hasVoted[msg.sender] = true;

        if (choice == 1) proposal.approve++;
        else if (choice == 2) proposal.reject++;
        else if (choice == 0) proposal.pass++;

        //2nd change: Automatic State Updates
        if (proposal.approve + proposal.reject + proposal.pass >= proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    //3rd change: No current_state Variable

    function terminateProposal() external onlyOwner activeProposal {
        proposal_history[counter].is_active = false;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns (Proposal memory) {
        require(number <= counter, "Proposal does not exist.");
        return proposal_history[number];
    }
}
