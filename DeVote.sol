/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//version 18.05.27

pragma solidity ^0.4.20;
contract DeVote{
    
    struct Comment{
        address poster;
        string comment;
    }
    
    struct Option{
        string description;
        uint votes;
    }
    
    struct Vote{
        string topic;
        uint endTime; 
        uint votesRequiredForQuorum;
        uint votesCasted;
        uint optionCount;
        mapping (uint => Option) options;
        uint commentCount;
        mapping (uint => Comment) comments;
        mapping (address => uint) votes;
        bool binding;
    }
    
    struct Voter{
        string name;
        uint tokens;
        uint participation;
        
    }
    
    uint totalTokens;
    uint totalParticipation;
    uint numVotes;

    address provider;
    address chairperson;
    
    //Vote scratchVote;
    
    mapping (uint => Vote) votes;

    mapping (address => Voter) voters;
   
    modifier chairpersonOnly{
        require(msg.sender == chairperson);
        _;
    }
    
    modifier providerOnly{
        require (msg.sender == provider);
        _;
    }
    
    event VoteConstruction(string topic, uint endTime, uint votesRequiredForQuorum, bool binding );
    event OptionAdded(uint numOptions, string description);
    event VoteDeployed(uint numVotes, string topic, uint endTime, uint votesRequiredForQuorum );
    event VoterAdded(address addr, string name, uint tokens);
    event tokensAllocated(address recipient, uint amount);
    event CommentPosted(uint voteNum, string comment);
    event VoteCasted(address voter, uint voteNum, uint optionNum);

    
    function DeVote(address provider_, address chairperson_) public {
        chairperson = chairperson_;
        provider = provider_;
    }
    
    function allocateTokens(address recipient, uint amount) public providerOnly{
        voters[recipient].tokens += amount;
        emit tokensAllocated(recipient, amount);
    }
    
    function initVote(string topic_ , uint endTime_, uint votesRequired_, bool binding) public chairpersonOnly{
        
        votes[numVotes].topic = topic_;
        votes[numVotes].endTime = endTime_;
        votes[numVotes].votesRequiredForQuorum = votesRequired_;
        votes[numVotes].votesCasted = 0;
        votes[numVotes].binding = binding;
        
        emit VoteConstruction(votes[numVotes].topic, votes[numVotes].endTime, votes[numVotes].votesRequiredForQuorum, votes[numVotes].binding );

    }
    
    function getChairperson() public constant returns (address){
        return chairperson;
    }
    
    function addOption(string option) public chairpersonOnly{
       
        votes[numVotes].options[votes[numVotes].optionCount] = Option(option, 0);
        votes[numVotes].optionCount += 1;
        emit OptionAdded(votes[numVotes].optionCount, option);

    } 
    
    function deployVote() public chairpersonOnly{
        emit VoteDeployed(numVotes, votes[numVotes].topic, votes[numVotes].endTime, votes[numVotes].votesRequiredForQuorum );
        numVotes += 1;
    }
    
    function getVoteCount() public constant returns (uint) {
        return numVotes;
    }
    
    function addVoter(address addr, string name, uint tokens) public providerOnly{
        voters[addr].name = name;
        voters[addr].tokens = tokens;
        emit VoterAdded(addr,  name,  tokens);
    }
    
    function getVoterName(address addr) public constant returns (string) {
        return voters[addr].name;
    }
    
    function getVoterTokens(address addr) public constant returns (uint) {
        return voters[addr].tokens;
    }
    function getVoterParticipation(address addr) public constant returns (uint) {
        return voters[addr].participation;
    }
    
    function getCommentCount(uint voteNum) public constant returns (uint){
        return votes[voteNum].commentCount;
    }
    
    function getComment(uint voteNum, uint commentNum)public constant returns (string){
        return votes[voteNum].comments[commentNum].comment;
    }
    
    //TODO: restrict who can post comments..
    function postComment(uint voteNum, string comment )public{
        votes[voteNum].comments[votes[voteNum].commentCount] = Comment(msg.sender, comment);
        votes[voteNum].commentCount += 1;
        emit CommentPosted(voteNum, comment);
    }
    
    function getOptionCount(uint voteNum) public constant returns (uint){
        return votes[voteNum].optionCount;
    }
    
    function getOptionDescription(uint voteNum, uint optionNum) public constant returns (string){
        return votes[voteNum].options[optionNum].description;
    }
    
    function getVoteTopic(uint voteNum) public constant returns (string){
        return votes[voteNum].topic;
    }
    
    function getVoteEndTime(uint voteNum) public constant returns (uint){
        return votes[voteNum].endTime; 
    }
    
    function getVotesForQuorum(uint voteNum) public constant returns (uint){
        return votes[voteNum].votesRequiredForQuorum;
    }
    
    function getVotesCasted(uint voteNum) public constant returns (uint){
        return votes[voteNum].votesCasted;
    }
    
    function getVoteBinding(uint voteNum) public constant returns (bool){
        return votes[voteNum].binding;
    }
    
    function tallyVotesForOption(uint voteNum, uint option)public constant returns (uint){
        votes[voteNum].options[option].votes;
    }
    
    function vote(uint voteNum, uint optionNum) public {
        require(voters[msg.sender].tokens > 0);
        require(votes[voteNum].endTime > now);
        
        votes[voteNum].options[optionNum].votes += 1;
        votes[voteNum].votes[msg.sender] = optionNum;
        votes[voteNum].votesCasted += 1;
        voters[msg.sender].tokens -= 1;
        voters[msg.sender].participation += 1;
        
        emit VoteCasted(msg.sender, voteNum, optionNum);
    }
    
    function getNow() public constant returns (uint){
        return now;
    }
}
