// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/*

                                              !?JJJJJJJJJJJJJJJJJJJJ?7:         
                                            .?J???????????????????????J~        
                                           ^J??????????????????????????J7       
    .                                     ~J???????????????????????????7J?.     
   7G5!.                                 7J???????????????????????????????J:    
   .!PBP7.                             .?J7????????????????????????????????J~   
     .?GBP?:                          :J????????????????????????????????????J7  
       :JGBP?:                       ~J?????????????????????????????????????7J?.
         ^YGGGJ^           .::::::::7J???????????????????????J?????????????????J
          ^GGGGGY^         ?JJ????????????????????????????J?!: :Y??????????????Y
         ^5GGGGGGGY~        ^7J??7?????????????????????J?!:   ~J????????????7J?.
        !PGGGGGGGGGG5!.       .~?J??????????????????J?7^.   ^?J?????????????J7  
       ?GGGGGGGGGGGGGGP?:        :!?J?????????????J7~.    :7J??????????????J!   
     .YGGGGGGGGGGGGGGGGGPJ^        .~?J????????J?~.     .!J???????????????J^    
    ^5GGGGGGGGGGGGGGGGGGGGGY~         :!?J??J?!:       ~J??????????????7J?:     
   !PGGGGGGGGGGGGGGGGGGGGGGGG5!.        .^~~:        ^?J???????????????J7.      
  ?GGGGGGGGGGGGGGGGGGGGGGGGGGGGP?:                 :?J?7??????????????J!        
.JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPJ^              :YJ????????????????7^         
5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGJ              ..................           
5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGY              ..................           
.JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG5!              .JJ????????????????7^         
  ?GGGGGGGGGGGGGGGGGGGGGGGGGGGGG5!.                .!J????????????????J!        
   !PGGGGGGGGGGGGGGGGGGGGGGGGG5!.        :~^.        .7J???????????????J7       
    ^5GGGGGGGGGGGGGGGGGGGGGGP7.       :!Y5PP5?^        :7J??????????????J?:     
     .YGGGGGGGGGGGGGGGGGGGP7.      .!J5PP5555PPY7:       :7J??????????????J^    
       ?GGGGGGGGGGGGGGGGP7.     .~J5PP5555555555P5J~.      ^?J?????????????J!   
        !PGGGGGGGGGGGGP7.    .~?5PP555555555555555PP5?^      ^?J????????????J7  
         ^5GGGGGGGGGP?:   .^?5PP555555555555555555555PPY!:     ^?J???????????J?.
          .?5PPGGGP?:    ~5PP555555PP555555555555555555PP5J~.    ~?J???????????Y
             .!GG?:      .:::::::::^?P55555555555555555555PP57^   .~J??????????J
            .JGJ:                    ~5P555555555555555555555PPY!.  .!J??????J?.
           !PY^                       :YP5555555555555555555555PP5?~. .!J???J7  
           !^                          .JP555555555555555555555555PPY7: .!??~   
                                         7P55555555555555555555555555P5J!.      
                                          ~5P55555555555555555555555555PP5J~.   
                                           ^5P5555555555555555555555555P7.^7J^  
                                            .JP5555555555555555555555P5~        
                                              !Y5PPPPPPPPPPPPPPPPPP55?:  

*/

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./OwnerWithdrawable.sol";

contract Presale is OwnerWithdrawable, ReentrancyGuard{
    using SafeERC20 for IERC20Metadata;
    using SafeMath for uint256;

    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public totalTokensforSale;
    uint256 public rate;
    uint256 public vestingBeginTime;
    uint256 public totalTokensSold;
    uint256 public saleTokenDec;

    address public immutable saleToken;

    struct VestingDetails{
        uint256 vestingPercent;
        uint256 lockingPeriod;
    }

    uint256 public currentRound = 1000;

    mapping (uint256 => VestingDetails) public roundDetails;

    //0: PS1, 1: PS2, 2:INNOVATION, 3: TEAM, 4:MARKETING, 5: SEED
    struct BuyerTokenDetails {
        uint256 totalAmount;
        uint256 []roundsParticipated;
        mapping(uint256 => uint256)tokensPerRound;
        mapping(uint256 => uint256)monthlyVestingClaimed;
        mapping(uint256 => uint256)tokensClaimed;
    }

    mapping(address => BuyerTokenDetails) public buyersAmount;

    constructor(address _saleTokenAddress, uint256[] memory _roundID, uint256[] memory _vestingPercent, uint256[] memory _lockingPeriod) ReentrancyGuard(){
        require(_saleTokenAddress != address(0), "Presale: Invalid Address");
        saleToken = _saleTokenAddress;
        saleTokenDec = IERC20Metadata(saleToken).decimals();
        setRoundDetails(_roundID, _vestingPercent, _lockingPeriod);
    }

    modifier saleStarted(){
    if(preSaleStartTime != 0){
        require(block.timestamp < preSaleStartTime || block.timestamp > preSaleEndTime, "PreSale: Sale has already started!");
    }
        _;
    }

  //modifier to check if the sale is active or not
    modifier saleDuration(){
        require(block.timestamp > preSaleStartTime, "Presale: Sale hasn't started");
        require(block.timestamp < preSaleEndTime, "PreSale: Sale has already ended");
        _;
    }

  //modifier to check if the Sale Duration and Locking periods are valid or not
    modifier saleValid(
    uint256 _preSaleStartTime, uint256 _preSaleEndTime
    ){
        require(block.timestamp < _preSaleStartTime, "PreSale: Invalid PreSale Date!");
        require(_preSaleStartTime < _preSaleEndTime, "PreSale: Invalid PreSale Dates!");
        _;
    }

    function setRoundDetails(uint256[] memory _roundID, uint256[] memory _vestingPercent, 
    uint256[] memory _lockingPeriod)internal{
        require(_roundID.length == _vestingPercent.length, "Redux: Length mismatch");
        require(_lockingPeriod.length == _vestingPercent.length, "Redux: Length mismatch");
        uint256 length = _roundID.length;
        for(uint256 i = 0; i < length; i++){
            roundDetails[_roundID[i]] = VestingDetails(_vestingPercent[i], _lockingPeriod[i]);
        }
    }

    function setSaleTokenParams(
    uint256 _totalTokensforSale, uint256 _rate, uint256 _roundID
    )external onlyOwner saleStarted{
        require(_rate != 0, "PreSale: Invalid Native Currency rate!");
        require(_roundID < 2, "Redux Presale: Round ID should be 0 or 1");
        currentRound = _roundID;
        rate = _rate;
        totalTokensforSale = _totalTokensforSale;
        totalTokensSold = 0;
        IERC20Metadata(saleToken).safeTransferFrom(msg.sender, address(this), totalTokensforSale);
    }

    function setSalePeriodParams(
    uint256 _preSaleStartTime,
    uint256 _preSaleEndTime)
    external onlyOwner saleStarted saleValid(_preSaleStartTime, _preSaleEndTime){
        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;
    }

    function setVestingPeriod() external onlyOwner{
        require(vestingBeginTime == 0, "Redux: Cannot set multiple times");
        vestingBeginTime = block.timestamp;
    }

    // Public view function to calculate amount of sale tokens returned if you buy using "amount" of "token"
    function getTokenAmount(uint256 amount)
        external
        view
        returns (uint256)
    {
        return amount.mul(10**saleTokenDec).div(rate);
    }


    function buyToken(bool _isInnovation) external payable saleDuration{
        uint256 saleTokenAmt;

        saleTokenAmt = (msg.value).mul(10**saleTokenDec).div(rate);
        require((totalTokensSold + saleTokenAmt) < totalTokensforSale, "PreSale: Total Token Sale Reached!");

        // Update Stats
        totalTokensSold = totalTokensSold.add(saleTokenAmt);

        buyersAmount[msg.sender].totalAmount += saleTokenAmt;
        if(_isInnovation) {
          if(buyersAmount[msg.sender].tokensPerRound[2] == 0){
              buyersAmount[msg.sender].roundsParticipated.push(2);
              buyersAmount[msg.sender].monthlyVestingClaimed[2] = roundDetails[2].lockingPeriod-1;
          }
          buyersAmount[msg.sender].tokensPerRound[2] += saleTokenAmt;
        }
        else {
          if(buyersAmount[msg.sender].tokensPerRound[currentRound] == 0){
              buyersAmount[msg.sender].roundsParticipated.push(currentRound);
              buyersAmount[msg.sender].monthlyVestingClaimed[currentRound] = roundDetails[currentRound].lockingPeriod-1;

          }
          buyersAmount[msg.sender].tokensPerRound[currentRound] += saleTokenAmt;
        }
    }

    function getTokensBought(address _user)external view returns(uint256){
        return buyersAmount[_user].totalAmount;
    }

    function getRoundsParticipated(address _user)external view returns(uint256[] memory)
    {
        return buyersAmount[_user].roundsParticipated;
    }

    function getTokensPerRound(address _user, uint256 _roundID)external view returns(uint256){
        return buyersAmount[_user].tokensPerRound[_roundID];
    }


    function getClaimedTokensPerRound(address _user, uint256 _roundID)external view returns(uint256){
        return buyersAmount[_user].tokensClaimed[_roundID];
    }
    function getMonthlyVestingClaimed(address _user, uint256 _roundID)external view returns(uint256){
        return buyersAmount[_user].monthlyVestingClaimed[_roundID];
    }
    function getTotalClaimedTokens(address _user)external view returns(uint256){
        uint256 tokensClaimed;

        for(uint256 i = 0; i<6; i++){
            tokensClaimed += buyersAmount[_user].tokensClaimed[i];
        }
        return tokensClaimed;
    }

    function withdrawToken() external nonReentrant{
        uint256 tokensforWithdraw = getAllocation(msg.sender);
        address user = msg.sender;
        require(tokensforWithdraw > 0, "Redux Token Vesting: No $REDUX Tokens available for claim!");
        
        uint256 timeElapsed = block.timestamp.sub(vestingBeginTime);
        uint256 boost;
        uint256 availableAllocation;
        uint256 availableTokens;

        uint256 round;
        uint256 tokenPerRound;
        uint256 length = buyersAmount[user].roundsParticipated.length;
        for(uint256 i = 0; i < length; i++){
            round = buyersAmount[user].roundsParticipated[i];
            tokenPerRound = buyersAmount[user].tokensPerRound[round];

            if(timeElapsed.div(30*24*60*60) >= roundDetails[round].lockingPeriod){

                boost = timeElapsed.div(30*24*60*60).sub(buyersAmount[user].monthlyVestingClaimed[round]);
                availableAllocation = tokenPerRound.mul(boost).mul(roundDetails[round].vestingPercent).div(100);
                availableTokens = tokenPerRound.sub(buyersAmount[user].tokensClaimed[round]);
    
                buyersAmount[user].tokensClaimed[round] += availableAllocation > availableTokens ? availableTokens : availableAllocation;
                buyersAmount[user].monthlyVestingClaimed[round] = timeElapsed.div(30*24*60*60);

            }
        }

        IERC20Metadata(saleToken).safeTransfer(msg.sender, tokensforWithdraw);

    }

    function getAllocation(address user) public view returns(uint256){

        require(vestingBeginTime != 0, "Redux: Vesting hasn't started");        
        uint256 timeElapsed = block.timestamp.sub(vestingBeginTime);
        uint256 boost;
        uint256 availableAllocation;
        uint256 availableTokens;
        uint256 tokensAlloted;

        uint256 round;
        uint256 tokenPerRound;

        for(uint256 i = 0; i < buyersAmount[user].roundsParticipated.length; i++){
            round = buyersAmount[user].roundsParticipated[i];
            tokenPerRound = buyersAmount[user].tokensPerRound[round];

            if(timeElapsed.div(30*24*60*60) >= roundDetails[round].lockingPeriod){

                boost = timeElapsed.div(30*24*60*60).sub(buyersAmount[user].monthlyVestingClaimed[round]);
                availableAllocation = tokenPerRound.mul(boost).mul(roundDetails[round].vestingPercent).div(100);
                availableTokens = tokenPerRound.sub(buyersAmount[user].tokensClaimed[round]);
                tokensAlloted += availableAllocation > availableTokens ? availableTokens : availableAllocation;

            }
        }
        
        return tokensAlloted;
    }

    function setExternalAllocation(address[] calldata _user, uint256[] calldata _amount, uint256 _roundID)external onlyOwner{

        uint256 totalTokens;
        require(_user.length == _amount.length, "Redux Token Vesting: user & amount arrays length mismatch");
        require(_roundID >2, "Redux: Id should be greater than 1");
        uint256 length = _user.length;
        for(uint256 i = 0; i < length; i+=1){
            buyersAmount[_user[i]].totalAmount += _amount[i];
            if(buyersAmount[_user[i]].tokensPerRound[_roundID] == 0){
                buyersAmount[_user[i]].roundsParticipated.push(_roundID);
                buyersAmount[_user[i]].monthlyVestingClaimed[_roundID] = roundDetails[_roundID].lockingPeriod-1;
            }
            buyersAmount[_user[i]].tokensPerRound[_roundID] += _amount[i];
            totalTokens += _amount[i];
        }
        IERC20Metadata(saleToken).safeTransferFrom(msg.sender, address(this), totalTokens);
    }
}
