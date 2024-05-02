//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "../Voting/UrsaHelper.sol";

/**
 * @title Mock Strategy
 * @author Ursa Finance
 * @notice Contract for testing purposes to simulate what a partner protocol might 
    use this helper contract for. 
 */

contract MockStrategy is UrsaHelper {
    //this strategy consists of:
    //initializing Ursa contracts
    //depositing asset into Ursa market
    //setting voting strategy

    address admin;
    ICERC20 ursaMarket;
    IERC20 underlying;
    bool isInitialized;

    constructor(
        address _staking,
        address _voting,
        address _unitroller,
        address _lens,
        ICERC20 _ursaMarket
    ) {
        admin = msg.sender;
        STAKING = StakingRewardsInterface(_staking);
        VOTING = VotingPowerInterface(_voting);
        UNITROLLER = ComptrollerInterface(_unitroller);
        LENS = LensInterface(_lens);
        ursaMarket = _ursaMarket;
        underlying = IERC20(ursaMarket.underlying());

        LODE.approve(address(STAKING), type(uint256).max);
        underlying.approve(address(ursaMarket), type(uint256).max);
    }

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

    function deposit(uint256 depositAmount) public onlyOwner returns (uint) {
        require(
            underlying.balanceOf(address(this)) >= depositAmount,
            "Insufficient funds"
        );
        uint err = ursaMarket.mint(depositAmount);
        return err;
    }

    function enableCollateral() public onlyOwner returns (uint256[] memory) {
        require(underlying.balanceOf(address(this)) > 0, "No deposits");
        address[] memory markets = new address[](1);
        markets[0] = (address(ursaMarket));
        uint256[] memory err = UNITROLLER.enterMarkets(markets);
        return err;
    }

    function initializeStrategy(uint256 initialDeposit) external onlyOwner {
        setStrategy();
        if (initialDeposit != 0) {
            require(deposit(initialDeposit) == 0, "Deposit Failed");
        }
        uint256[] memory collateralErr = enableCollateral();
        uint256 err = collateralErr[0];
        require(err == 0, "Enable collateral failed");
        isInitialized = true;
    }

    function setStrategy() internal {
        Strategy memory strategy = Strategy(
            "USDC",
            VotingPowerInterface.OperationType.BORROW,
            1e18
        );
        strategies.push(strategy);
    }

    function execute() external onlyOwner {
        require(isInitialized, "Strategy not initialized");
        executeStrategy();
    }
}
