// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UGVStaking {
    uint256 public constant SECONDS_IN_YEAR = 3600 * 24 * 365;
    uint256 public constant FREE_PERCENTAGE = 3;
    uint256 public constant PARTIAL_PERCENTAGE = 30;
    uint256 public constant MAXIMA_PERCENTAGE = 100;

    enum StakeType {
        Free,
        Partial,
        Maxima
    }

    struct StakeData {
        StakeType stakeType;
        uint256 amount;
        uint256 start;
        uint256 duration;
        uint256 APY;
        uint256 reward;
        uint256 lastWithdrawal;
    }

    IERC20 public ugvToken;

    uint256 public totalStaked;

    mapping(address => uint256) internal _withdrawals;

    mapping(address => StakeData) public stakeData;

    // EVENTS

    event Staked(address account, uint256 amount);

    event Unstaked(address account, uint256 amount);

    event RewardWithdrawn(address account, uint256 amount);

    // CONSTRUCTOR

    constructor(address ugvToken_) {
        require(ugvToken_ != address(0), "Invalid address");

        ugvToken = IERC20(ugvToken_);
    }

    function stake(uint256 amount, StakeType stakeType) external {
        require(amount > 0, "Staking amount could not be zero");
        ugvToken.transferFrom(msg.sender, address(this), amount);

        uint256 duration;
        uint256 percentage;

        if (stakeData[msg.sender].amount > 0) {
            amount += stakeData[msg.sender].amount;
        }

        if (stakeType == StakeType.Free) {
            duration = 0;
            percentage = FREE_PERCENTAGE;
        }

        if (stakeType == StakeType.Partial) {
            duration = 30 days;
            percentage = PARTIAL_PERCENTAGE;
        }

        if (stakeType == StakeType.Maxima) {
            duration = 90 days;
            percentage = MAXIMA_PERCENTAGE;
        }
        
        stakeData[msg.sender] = StakeData({
            stakeType: stakeType,
            amount: amount,
            start: block.timestamp,
            duration: duration,
            APY: percentage,
            reward: accumulativeRewardOf(msg.sender),
            lastWithdrawal: block.timestamp
        });

        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake() external {
        StakeData memory _stakeData = stakeData[msg.sender];
        uint256 amount = _stakeData.amount;
        require(amount > 0, "Nothing to unstake");
        require(
            block.timestamp >= _stakeData.duration + _stakeData.start, 
            "Tokens are locked"
        );

        totalStaked -= amount;
        amount += accumulativeRewardOf(msg.sender);
        _withdrawals[msg.sender] += accumulativeRewardOf(msg.sender);
        delete stakeData[msg.sender];

        ugvToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function withdrawnRewardOf(address stakeholder) public view returns (uint256) {
        return _withdrawals[stakeholder];
    }

    function withdrawableRewardOf(address stakeholder) public view returns (uint256) {
        return accumulativeRewardOf(stakeholder);
        //return accumulativeRewardOf(stakeholder) - withdrawnRewardOf(stakeholder);
    }

    function accumulativeRewardOf(address stakeholder) public view returns (uint256) {
        StakeData memory _stakeData = stakeData[stakeholder];
        return _stakeData.reward + 
            (block.timestamp - _stakeData.start) * _stakeData.APY / SECONDS_IN_YEAR;
    }

    function withdrawReward() external {
        StakeData memory _stakeData = stakeData[msg.sender];
        require(
            block.timestamp >= _stakeData.lastWithdrawal + 1 weeks, 
            "Last withdrawal was this week"
        );
        uint256 withdrawable = withdrawableRewardOf(msg.sender);

        require(withdrawable > 0, "Nothing to withdraw");

        stakeData[msg.sender].lastWithdrawal = block.timestamp;
        stakeData[msg.sender].reward = 0;
        _withdrawals[msg.sender] += withdrawable;
        ugvToken.transfer(msg.sender, withdrawable);

        emit RewardWithdrawn(msg.sender, withdrawable);
    }
}
