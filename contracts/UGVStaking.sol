// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ugvTokenStaking {
    uint256 public constant FREE_PERCENTAGE = 3;
    uint256 public constant PARTIAL_PERCENTAGE = 30;
    uint256 public constant MAXIMA_PERCENTAGE = 100;

    enum StakeType {
        Free,
        Partial,
        Maxima
    }

    struct LockedBalance {
        uint256 amount;
        uint256 duration;
    }

    IERC20 public ugvToken;

    address public stakingWallet;

    mapping(address => uint256) public stakedAmounts;

    uint256 internal allStakes;

    uint256 constant internal _magnitude = 2**128;

    uint256 internal _magnifiedRewardPerStake = 0; 

    mapping(address => int256) internal _magnifiedRewardCorrections;

    mapping(address => uint256) internal _withdrawals;

    mapping(address => uint256) public lockedBalances;

    // EVENTS

    event Staked(address account, uint256 amount);

    event Unstaked(address account, uint256 amount);

    event DividendsDistributed(uint256 amount);

    // CONSTRUCTOR

    constructor(address ugvToken_) {
        require(ugvToken_ != address(0), "Invalid address");

        ugvToken = IERC20(ugvToken_);
    }

    function stake(uint256 amount, StakeType stakeType) external {
        if (stakeType == StakeType.Free) {
            // lockedBalances[msg.sender] = 
        }

        // if (stakeType == StakeType.Partial) {
        //     lockedBalances[msg.sender] = LockedBalance({

        //     });
        // }

        // if (stakeType == StakeType.Maxima) {

        // }
        require(amount > 0, "Staking amount could not be zero");

        ugvToken.transferFrom(msg.sender, address(this), amount);
        
        stakedAmounts[msg.sender] += amount;
        _magnifiedRewardCorrections[msg.sender] -= int256(_magnifiedRewardPerStake * amount);
        allStakes += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Unstaking amount could not be zero");
        require(amount <= stakedAmounts[msg.sender], "User's stake is less than amount");
        
        stakedAmounts[msg.sender] -= amount;
        _magnifiedRewardCorrections[msg.sender] += int256(_magnifiedRewardPerStake * amount);
        allStakes -= amount;
        
        ugvToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function accumulativeRewardOf(address stakeholder) public view returns(uint256) {
        return uint256(int256(stakedAmounts[stakeholder] * _magnifiedRewardPerStake) 
                       + _magnifiedRewardCorrections[stakeholder]) / _magnitude;
    }

    function withdrawnRewardOf(address stakeholder) public view returns(uint256) {
        return _withdrawals[stakeholder];
    }

    function withdrawableRewardOf(address stakeholder) public view returns(uint256) {
        return accumulativeRewardOf(stakeholder) - withdrawnRewardOf(stakeholder);
    }

    function withdrawReward() external {
        uint256 withdrawable = withdrawableRewardOf(msg.sender);

        require(withdrawable > 0, "Nothing to withdraw");

        ugvToken.transfer(msg.sender, withdrawable);
        _withdrawals[msg.sender] += withdrawable;
    }

    function distribute(uint256 amount) external {
        require(msg.sender == stakingWallet, "Only ERM can call distribute");

        if (amount > 0 && allStakes > 0) {
            _magnifiedRewardPerStake += (_magnitude * amount) / allStakes;
            emit DividendsDistributed(amount);
        }
    }
}
