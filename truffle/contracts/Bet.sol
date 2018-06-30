pragma solidity ^0.4.22;
//pragma experimental ABIEncoderV2;


contract Bet {
  struct Statement{
	address party1;
	address party2;
	address judge;
	bytes32 tweetId;
	uint stake;
	bool confirmed;
  }

  mapping (bytes32 => Statement) public statementsList;
  mapping (address => Statement[]) public statementsListByJudge;

  function getStatementsForJudgeSize(address judge) public constant returns(uint256){
	
	return statementsListByJudge[judge].length;
  }

  function getStatementForJudge(address judge,uint256 index) public view returns(Statement){
	
	return statementsListByJudge[judge][index];
  }

  function createStatement(address party2, address judge, bytes32 tweetId) public payable{
	// add msg.value checks
	statementsList[tweetId] = Statement(msg.sender, party2, judge, tweetId, msg.value,false);
	statementsListByJudge[judge].push(Statement(msg.sender, party2, judge, tweetId, msg.value,false));
  }

  function confirmStatement(bytes32 tweetId) public payable{
	// check it has not been confirmed yet
	require(!statementsList[tweetId].confirmed);
	// check it has enough ether for the bet
	require(msg.value >= statementsList[tweetId].stake);
	// check that it is the correct user
	require(msg.sender == statementsList[tweetId].party2);
	
	//increase the value of the stake
	statementsList[tweetId].stake += msg.value;
	//confirm the bet
	statementsList[tweetId].confirmed = true;
  }

  function judgeSettles(bytes32 tweetId, address _winner) public {
	// confirm bet is confirmed
	require(statementsList[tweetId].confirmed);
	// confirm that the winner _exists_
	require(_winner == statementsList[tweetId].party1 || _winner == statementsList[tweetId].party2);
	//confirm the judge is the one calling the function
	require(msg.sender == statementsList[tweetId].judge);
	
	// transfer the funds to the winner
	_winner.transfer(statementsList[tweetId].stake);
	
	// add tie

	// record the winner for history purposes
	//statementsList[tweetId].winner = _winner;
	// transfer the funds to the winner
	//statementsList[tweetId].winner.transfer(statementsList[tweetId].stake);
  }


}
