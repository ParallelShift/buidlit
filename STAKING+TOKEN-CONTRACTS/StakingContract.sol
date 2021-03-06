// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "./BuidlITToken.sol";
/////////////////////////////
contract TokenStaking is ReentrancyGuard{
    BuidlITToken public buidlITToken;
    string public name = "Buidl IT Staking Platform";
        uint public stakeLock; 
        uint public stakeCooldownTime = 0 days; //stake locked time 6 months 180 days
        uint public claimReady; 
        uint public rewards_claim_frequency = 0 days; // cooldown time

    address public owner;

    //declaring default APY (default 100 = .1% daily or 36.5% APY yearly)
    uint256 public defaultAPY = 100;
    uint public _withdrawableBalance;
    uint256 public totalStaked;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStakingAtm;
    address[] public stakers;

    constructor(BuidlITToken _buidlITToken) payable {
        buidlITToken = _buidlITToken;
        owner = msg.sender;
        claimReady = block.timestamp + rewards_claim_frequency;
    }

    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    function stakeTokens(uint256 _amount) public {
        require(_amount > 100, "amount cannot be less than 100 BUIDL");
        stakeLock = block.timestamp + stakeCooldownTime;
        buidlITToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        if (!hasStaked[msg.sender]) 
            {stakers.push(msg.sender);}
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    function unstakeTokens() public {
        require(stakeLock <= block.timestamp, "You can't claim now.");
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        buidlITToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;
        stakingBalance[msg.sender] = 0;
        isStakingAtm[msg.sender] = false;
    }

    function claimRewards() public {
        require(isStakingAtm[msg.sender], "you are not staked");
        require(claimReady <= block.timestamp, "You can't claim now.");
        require(buidlITToken.balanceOf(address(this)) > 0, "Insufficient Balance there are no more staking rewards.");

        uint256 withdrawable = mulScale(stakingBalance[msg.sender], 100, 10000); 
        // 100/ 10000 basis points = 1%        
            if (withdrawable > 0) {
                claimReady = block.timestamp + rewards_claim_frequency;
                // buidlITToken.transfer(recipient, 111);
                buidlITToken.transfer(msg.sender, withdrawable);
                withdrawable = 0;
            }
    }
}
