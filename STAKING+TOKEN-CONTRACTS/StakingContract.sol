pragma solidity ^0.8.6;
// "SPDX-License-Identifier: UNLICENSED"
import "./BuidlITToken.sol";
/////////////////////////////
contract TokenStaking is ReentrancyGuard{
    string public name = "Farming / Token dApp";
    BuidlITToken public BuidlITToken;

//work out how to get the block time in to this lot to lock things up
        uint public claimReady; //save claim  time
        uint public cooldownTime = 0 days; // cooldown time
////////////////////////////////////////////////////////////

    address public owner;

    //declaring default APY (default 100 = .1% daily or 36.5% APY yearly)
    uint256 public defaultAPY = 100;

    uint256 public totalStaked;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStakingAtm;
    address[] public stakers;

    constructor(BuidlITToken _BuidlITToken) payable {
        BuidlITToken = _BuidlITToken;
        owner = msg.sender;
        claimReady = block.timestamp + cooldownTime;

    }

    //stake tokens function

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");

        //User adding tokens
        BuidlITToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;
        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    function unstakeTokens() public {
        //get staking balance for user
// require(!timelocked);
        uint256 balance = stakingBalance[msg.sender];

        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        //transfer staked tokens back to user
        BuidlITToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;

        //reseting users staking balance
        stakingBalance[msg.sender] = 0;

        //updating staking status
        isStakingAtm[msg.sender] = false;
    }

    //claim tokens
    function claimRewards() public {
        require(msg.sender.isStakingAtm, "you are not staked");
        require(claimReady <= block.timestamp, "You can't claim now.");
        require(token.balanceOf(address(this)) > 0, "Insufficient Balance there are no more staking rewards.");

        uint _withdrawableBalance = mulScale(stakingBalance[msg.sender], 100, 10000); 
        // 100/ 10000 basis points = 1%        
            if (_withdrawableBalance > 0) {
                claimReady = block.timestamp + cooldownTime;
                _withdrawableBalance = 0;
                BuidlITToken.transfer(recipient, _withdrawableBalance);
            }
        }
    }

    function claimTokens() public nonReentrant {
    
        if(token.balanceOf(address(this)) <= _withdrawableBalance) {
            token.transfer(teamWallet, token.balanceOf(address(this)));
        } else {

            token.transfer(teamWallet, _withdrawableBalance); 
        }
    }

}
