// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
//testnet router: https://pancake.kiemtienonline360.com/- 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 
//shit wallet-3 -0x22204A6bd11965F19F3ccf64541f34EcdF560d45- 0xD12BF4c31b4aE8de5a89D0cDD05a1a5014560569 
import "./Libraries.sol";

contract Buidl_IT {
    string public name = "Buidl IT Token";
    string public symbol = "BUIDL";
    uint256 public totalSupply = 15000000; // 100 millon
    uint8 public decimals = 0;

    address public dev_marketing_wallet; // marownerketing
    address public staking_contract; // staking contract
    address private vendor_contract; // team vesting contract

    IUniswapV2Router02 router; // Router.
    address private pancakePairAddress; // the pancakeswap pair address.
    uint public liquidityLockTime = 0 days; // how long do we lock up liquidity
    uint public liquidityLockCooldown;// cooldown period for changes to liquidity settings and removal

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(
        address _dev_marketing_wallet, 
        address _staking_contract, 
        address _vendor_contract) {

        dev_marketing_wallet = _dev_marketing_wallet;
        staking_contract = _staking_contract;
        vendor_contract = _vendor_contract;

        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//router address for pair creation
        pancakePairAddress = IPancakeFactory(router.factory()).createPair(address(this), router.WETH());
        
        uint _dev_Marketing_Tokens =     150000;
        uint _staking_contract_Tokens =   7425000;
        uint _vendor_contract_Tokens =   7425000;

        uint _contractTokens = totalSupply - (_vendor_contract_Tokens + _dev_Marketing_Tokens + _staking_contract_Tokens);

        balanceOf[dev_marketing_wallet] = _dev_Marketing_Tokens;
        balanceOf[staking_contract] = _staking_contract_Tokens;
        balanceOf[vendor_contract] = _vendor_contract_Tokens;

        balanceOf[address(this)] = _contractTokens;
    }

    modifier onlyOwner() {
        require(msg.sender == dev_marketing_wallet, 'You must be the owner.');
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public virtual returns (bool) {
        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] + _addedValue);

        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {
            _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
        }
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _approve(msg.sender, _spender, _value);

        return true;
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        _allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function burn(uint256 _amount) public virtual {
        _burn(msg.sender, _amount);
    }

    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), '');
        require(balanceOf[_account] >= _amount, 'tokens insuficient.');

        balanceOf[_account] -= _amount;
        totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }
    
    function addLiquidity(uint _tokenAmount) public payable onlyOwner {
        require(_tokenAmount > 0 || msg.value > 0, "Insufficient tokens or BNBs.");
        
        _approve(address(this), address(router), _tokenAmount);

        liquidityLockCooldown = block.timestamp + liquidityLockTime;

        router.addLiquidityETH{value: msg.value}(
            address(this),
            _tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function removeLiquidity() public onlyOwner {
        require(block.timestamp >= liquidityLockCooldown, "Locked");

        IERC20 liquidityTokens = IERC20(pancakePairAddress);
        uint _amount = liquidityTokens.balanceOf(address(this));
        liquidityTokens.approve(address(router), _amount);

        router.removeLiquidityETH(
            address(this),
            _amount,
            0,
            0,
            dev_marketing_wallet,
            block.timestamp
        );
    }
}
