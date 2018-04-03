pragma solidity ^0.4.18; 

contract Voting {

    address owner;                  // The address of the owner. Set in 'Ballot()'
    bool    optionsFinalized;       // Whether the owner can still add voting options.
    string  ballotName;             // The ballot name.
    uint    registeredVoterCount;   // Total number of voter addresses registered.
    uint    ballotEndTime;          // End time for ballot after which no changes can be made. (seconds since 1970-01-01)

    struct Voter {
    address voterAddress;
    uint tokensBought;
    uint[] tokensUsedPerCandidate;
    bool voted;
    bool isEligibleToVote;
    uint votedFor;
    }

    struct VotingOption
    {
        string name;    // Name of this voting option
        uint voteCount; // Number of accumulated votes.
        address[] voters; // Keep track of addresses that selected this option
    }

    /*
    * Modifier to only allow the owner/voter to call a function.
    */
    modifier onlyOwner {
        require(msg.sender == owner)
        _;
    }

    modifier onlyVoter  {
      require(voterInfo[msg.sender].voterAddress != 0);
      _;
    }

 mapping (address => Voter) public voterInfo;
 mapping (bytes32 => uint) public votesReceived;
 bytes32[] public candidateList;
 VotingOption[] public votingOptions; // dynamically sized array of 'VotingOptions'
 uint public totalTokens; 
 uint public balanceTokens;
 uint public tokenPrice;

 function Voting(uint _tokens, uint _pricePerToken, bytes32[] _candidateNames, string _ballotName, uint _ballotEndTime) public {

  require(now < _ballotEndTime);
  owner = msg.sender
  candidateList = _candidateNames;
  totalTokens = _tokens;
  balanceTokens = _tokens;
  tokenPrice = _pricePerToken;
  optionsFinalized = false;
  ballotName = _ballotName;
  registeredVoterCount = 0;
  ballotEndTime = _ballotEndTime;
 }

 function addVotingOption(string _votingOptionName) onlyOwner {
        require(now < ballotEndTime);
        require(optionsFinalized == false);    // Check we are allowed to add options.
        votingOptions.push(VotingOption({
            name: _votingOptionName,
            voteCount: 0,
            voters: []
        }));
  }

  /*
    *  Call this once all options have been added, this will stop further changes
    *  and allow votes to be cast.
    *  NOTE: this can only be called by the ballot owner.
    */
    function finalizeVotingOptions() onlyOwner
    {
        require(now < ballotEndTime);
        require(votingOptions.length > 2);
        optionsFinalized = true;    // Stop the addition of any more options.
    }
  
 function buy() payable public returns (uint) {
  uint tokensToBuy = msg.value / tokenPrice;
  require(tokensToBuy <= balanceTokens);
  voterInfo[msg.sender].voterAddress = msg.sender;
  voterInfo[msg.sender].tokensBought += tokensToBuy;
  balanceTokens -= tokensToBuy;
  return tokensToBuy;
 }

 function giveRightToVote(address _voter) onlyOwner {
        require(now < ballotEndTime);
        voters[_voter].isEligibleToVote = true;
        registeredVoterCount += 1;      // Increment registered voters.
 }

 function vote(bytes32 candidate, uint votesInTokens) {
        // leaving egalitarian for now... will incorporate weighted (token based) voting later
        require(now < ballotEndTime);
        require(optionsFinalized == true);       // If the options are not finalized, we cannto vote.
        uint votingOptionIndex = indexOfCandidate(candidate);
        require(votingOptionIndex != uint(-1))

        Voter voter = voters[msg.sender];   // Get the Voter struct for this sender.
        require(voter.isEligibleToVote == true);

        if(voter.voted == true) // If the voter has already voted then we need to remove their prev vote choice.
            votingOptions[voter.votedFor].voteCount -= 1;

        voter.voted = true;
        voter.votedFor = votingOptionIndex;

        votingOptions[votingOptionIndex].voteCount += 1;
        votingOptions[voters]
    }

 function totalVotesFor(bytes32 candidate) view public returns (uint) {
  return votesReceived[candidate];
 }

 function totalTokensUsed(uint[] _tokensUsedPerCandidate) private pure returns (uint) {
  uint totalUsedTokens = 0;
  for(uint i = 0; i < _tokensUsedPerCandidate.length; i++) {
   totalUsedTokens += _tokensUsedPerCandidate[i];
  }
  return totalUsedTokens;
 }

 function indexOfCandidate(bytes32 candidate) view public returns (uint) {
  for(uint i = 0; i < candidateList.length; i++) {
   if (candidateList[i] == candidate) {
    return i;
   }
  }
  return uint(-1);
 }

 function tokensSold() view public returns (uint) {
  return totalTokens - balanceTokens;
 }

 function voterDetails(address user) view public returns (uint, uint[]) {
  return (voterInfo[user].tokensBought, voterInfo[user].tokensUsedPerCandidate);
 }

 function transferTo(address account) public {
  account.transfer(this.balance);
 }

 function allCandidates() view public returns (bytes32[]) {
  return candidateList;
 }

 function getBallotName() returns (string) {
        return ballotName;
 }

 function getVotingOptionsLength() returns (uint) {
        return votingOptions.length;
 }

 function getRegisteredVoterCount() returns (uint) {
        return registeredVoterCount;
 }

    
 function getVotingOptionsName(uint _index) returns (string) {
        return votingOptions[_index].name;
 }

 function getVotingOptionsVoteCount(uint _index) returns (uint) {
        return votingOptions[_index].voteCount;
 }

 function getOptionsFinalized() returns (bool) {
        return optionsFinalized;
 }

 function getBallotEndTime() returns (uint) {
        return ballotEndTime;
 }
}

    
