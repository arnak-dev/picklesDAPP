// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPicklesToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
}

contract PicklesProfile {
    address public owner;
    IPicklesToken public token;
    address public treasury;

    uint256 public activationFee = 100 * 1e18;
    uint256 public referrerShare = 70;
    uint256 public burnShare = 20;
    uint256 public treasuryShare = 10;

    mapping(address => bool) public isProfileActive;
    mapping(address => address) public referrer;
    mapping(string => address) public usernameToAddress;
    mapping(address => string) public addressToUsername;

    event ProfileActivated(address indexed user, address indexed referrer);

    constructor(address _token, address _treasury) {
        owner = msg.sender;
        token = IPicklesToken(_token);
        treasury = _treasury;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setUsername(string memory username) external {
        require(bytes(username).length > 0, "Username required");
        require(usernameToAddress[username] == address(0), "Username taken");

        usernameToAddress[username] = msg.sender;
        addressToUsername[msg.sender] = username;
    }

    function activateProfile(string memory refUsername) external {
        require(!isProfileActive[msg.sender], "Already activated");
        require(token.transferFrom(msg.sender, address(this), activationFee), "Transfer failed");

        address ref = usernameToAddress[refUsername];
        if (ref == address(0)) {
            ref = treasury;
        }

        uint256 refAmount = (activationFee * referrerShare) / 100;
        uint256 burnAmount = (activationFee * burnShare) / 100;
        uint256 treasuryAmount = activationFee - refAmount - burnAmount;

        token.transfer(ref, refAmount);
        token.transfer(treasury, treasuryAmount);
        token.burn(burnAmount);

        isProfileActive[msg.sender] = true;
        referrer[msg.sender] = ref;

        emit ProfileActivated(msg.sender, ref);
    }

    function updateActivationFee(uint256 newFee) external onlyOwner {
        activationFee = newFee;
    }

    function updateShares(uint256 refShare, uint256 burn, uint256 tShare) external onlyOwner {
        require(refShare + burn + tShare == 100, "Invalid total");
        referrerShare = refShare;
        burnShare = burn;
        treasuryShare = tShare;
    }

    function updateTreasury(address newTreasury) external onlyOwner {
        treasury = newTreasury;
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        token.transfer(owner, amount);
    }
}
