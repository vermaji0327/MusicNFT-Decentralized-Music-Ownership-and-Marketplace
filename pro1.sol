// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 interface (simplified version)
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract GamifiedCourses {
    address public owner;
    IERC20 public rewardToken;  // Token to reward users
    mapping(address => uint256) public userMilestones;  // Track the last completed milestone by user
    mapping(uint256 => uint256) public milestoneRewards;  // Store rewards for each milestone

    event MilestoneSet(uint256 milestone, uint256 rewardAmount);
    event MilestoneCompleted(address indexed user, uint256 milestone, uint256 rewardAmount);
    event TokensWithdrawn(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _rewardToken) {
        owner = msg.sender;
        rewardToken = IERC20(_rewardToken);
    }

    // Set the reward for completing a specific milestone
    function setMilestoneReward(uint256 milestone, uint256 rewardAmount) external onlyOwner {
        milestoneRewards[milestone] = rewardAmount;
        emit MilestoneSet(milestone, rewardAmount);
    }

    // Function for users to complete a milestone and claim their reward
    function completeMilestone(uint256 milestone) external {
        uint256 currentMilestone = userMilestones[msg.sender];
        require(milestone == currentMilestone + 1, "Complete previous milestones first"); // Ensure milestones are completed sequentially
        require(milestoneRewards[milestone] > 0, "Reward not set for this milestone");

        // Update user milestone
        userMilestones[msg.sender] = milestone;

        // Transfer reward tokens to the user
        uint256 rewardAmount = milestoneRewards[milestone];
        require(rewardToken.balanceOf(address(this)) >= rewardAmount, "Insufficient contract balance");

        rewardToken.transfer(msg.sender, rewardAmount);

        emit MilestoneCompleted(msg.sender, milestone, rewardAmount);
    }

    // Owner can withdraw tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient contract balance");
        rewardToken.transfer(owner, amount);
        emit TokensWithdrawn(owner, amount);
    }

    // Get the milestone completed by a user
    function getUserMilestone(address user) external view returns (uint256) {
        return userMilestones[user];
    }
}
