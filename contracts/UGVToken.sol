// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UGVToken is ERC20Capped, Ownable {
    struct VestingLockData {
        uint256 start;
        uint256 amount;
        uint256 cliff;
        uint256 linear;
    }

    mapping(address => VestingLockData) public vestingLockDataOf;

    constructor () ERC20("UGV Coin", "UGV") ERC20Capped(150 * 10**(6 + uint256(decimals()))) {
        // _totalSupply = 150 * 10**6;
        _mint(msg.sender, 10000 * 10**uint256(decimals()));
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        require(
            amount <= balanceOf(msg.sender) - vestingLockedBalanceOf(msg.sender), 
            "Can't burn locked tokens"
        );
        _burn(msg.sender, amount);
    }

    function investorMint(
        address to, 
        uint256 amount, 
        uint256 cliff, 
        uint256 linear
    ) external onlyOwner {
        vestingLockDataOf[to] = VestingLockData({
            start: block.timestamp,
            amount: amount,
            cliff: cliff,
            linear: linear
        });
        _mint(to, amount);
    }

    receive() external payable {
        revert("Contarct does not accept coin transfers");
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function vestingLockedBalanceOf(address account) public view returns (uint256) {
        VestingLockData memory lockData = vestingLockDataOf[account];
        uint256 endDate = lockData.start + (lockData.cliff + lockData.linear) * 1 days;
        if (block.timestamp >= endDate)
            return 0;

        uint256 endCliff = lockData.start + lockData.cliff * 1 days;
        if (block.timestamp < endCliff) {
            return lockData.amount; 
        } else {
            return lockData.amount - lockData.amount * (block.timestamp - endCliff) / (endDate - lockData.linear * 1 days);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            amount <= balanceOf(from) - vestingLockedBalanceOf(from), 
            "Can't transfer locked tokens"
        );

        super._transfer(from, to, amount);
    }
}
