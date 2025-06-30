// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking {
    IERC20 public stakeToken;
    IERC20 public rewardToken;
    address public owner;

    uint256 public rewardRatePerSecond;
    uint256 public lockPeriod; // seconds
    uint256 public totalStaked;

    struct User {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingReward;
        uint256 lastUpdate;
        uint256 depositTime;
    }

    mapping(address => User) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _stakeToken, address _rewardToken, uint256 _rewardRatePerSecond, uint256 _lockPeriod) {
        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        lockPeriod = _lockPeriod;
        owner = msg.sender;
    }

    function setLockPeriod(uint256 _seconds) external onlyOwner {
        lockPeriod = _seconds;
    }

    function updateReward(address _user) internal {
        User storage user = users[_user];
        if (user.amount > 0) {
            uint256 duration = block.timestamp - user.lastUpdate;
            uint256 reward = (duration * rewardRatePerSecond * user.amount) / totalStaked;
            user.pendingReward += reward;
        }
        user.lastUpdate = block.timestamp;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        updateReward(msg.sender);

        stakeToken.transferFrom(msg.sender, address(this), amount);

        users[msg.sender].amount += amount;
        users[msg.sender].depositTime = block.timestamp;

        totalStaked += amount;
    }

    function unstake() external {
        User storage user = users[msg.sender];
        require(user.amount > 0, "Nothing staked");
        require(block.timestamp >= user.depositTime + lockPeriod, "Locked");

        updateReward(msg.sender);

        uint256 amount = user.amount;
        uint256 reward = user.pendingReward;

        user.amount = 0;
        user.pendingReward = 0;
        totalStaked -= amount;

        require(stakeToken.transfer(msg.sender, amount), "Stake transfer failed");
        require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
    }

    function pendingReward(address _user) external view returns (uint256) {
        User memory user = users[_user];
        if (user.amount == 0) return user.pendingReward;

        uint256 duration = block.timestamp - user.lastUpdate;
        uint256 reward = (duration * rewardRatePerSecond * user.amount) / totalStaked;
        return user.pendingReward + reward;
    }

    function getUserInfo(address _user) external view returns (uint256 amount, uint256 depositTime, uint256 pending) {
        amount = users[_user].amount;
        depositTime = users[_user].depositTime;
        pending = this.pendingReward(_user);
    }

    function withdrawExcessRewards(address to, uint256 amount) external onlyOwner {
        require(rewardToken.transfer(to, amount), "Transfer failed");
    }
}
