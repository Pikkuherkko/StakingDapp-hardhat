//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Farmtoken.sol";

contract Staking {
    address public owner;
    IERC20 public farmToken;

    struct Position {
        uint256 positionId;
        address walletAddress;
        uint256 createdDate;
        uint256 unlockDate;
        uint256 percentInterest;
        uint256 weiStaked;
        uint256 weiInterest;
        bool open;
    }

    Position position;

    uint256 currentPositionId;
    mapping (uint256 => Position) public positions; // each position is queryble by ID
    mapping(address => uint256[]) public positionIdsByAddress; // each user can query their positions
    mapping(uint256 => uint256) public tiers; // find interest by number of days
    uint256[] lockPeriods;

    constructor(address _farmToken) payable {
        owner = msg.sender;
        farmToken = IERC20(_farmToken);
        currentPositionId = 0;
        
        tiers[1] = 700; // 7%
        tiers[3] = 1000; // 10%
        tiers[6] = 1200; // 12%
        lockPeriods.push(1);
        lockPeriods.push(3);
        lockPeriods.push(6);
    }

    function StakeEther(uint256 _numDays) external payable {
        require(tiers[_numDays] > 0, "Lockup period not found");

        positions[currentPositionId] = Position(
            currentPositionId, 
            msg.sender,
            block.timestamp,
            block.timestamp + (_numDays * 1 days),
            tiers[_numDays],
            msg.value,
            calculateInterest(tiers[_numDays], msg.value),
            true
        );

        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId++;
    }

    function calculateInterest(uint256 _basisPoints, uint256 _weiAmount) private pure returns (uint256) {
        return _basisPoints * _weiAmount / 10000;
    }

    function modifyLockPeriods(uint256 _numDays, uint256 _basisPoints) external {
        require(owner == msg.sender, "Msg.sender not owner");
        tiers[_numDays] = _basisPoints; // creating anew tier
        lockPeriods.push(_numDays);
    }

    function getLockPeriods() external view returns (uint256[] memory) {
        return lockPeriods;
    }

    function getInterestRate(uint256 _numDays) external view returns (uint256) {
        return tiers[_numDays];
    }

    function getPositionById(uint256 _positionId) external view returns (Position memory) {
        return positions[_positionId];
    }

    function getPositionIdsForAddress(address _walletAddress) external view returns (uint256[] memory) {
        return positionIdsByAddress[_walletAddress];
    }

    function changeUnlockDate(uint256 _positionId, uint256 _newUnlockDate) external {
        require(owner == msg.sender, "Msg.sender not owner");
        positions[_positionId].unlockDate = _newUnlockDate;
    } 

    function closePosition(uint256 _positionId) external {
        require(positions[_positionId].walletAddress == msg.sender, "msg.sender not position creator");
        require(positions[_positionId].open == true, "Position not open");
        positions[_positionId].open = false;

        if (block.timestamp > positions[_positionId].unlockDate) {
            (bool sent,) = payable(msg.sender).call{value: positions[_positionId].weiStaked}("");
            require(sent, "not sent");
            uint256 amount = positions[_positionId].weiInterest;
            require(farmToken.transfer(msg.sender, amount), "token transfer failed");
        } else {
            (bool sent,) = payable(msg.sender).call{value: positions[_positionId].weiStaked}("");
            require(sent, "not sent");
        }
    }

    receive () external payable{}

    fallback () external payable{}

}