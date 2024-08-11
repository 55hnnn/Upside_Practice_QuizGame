# Intro
`Quiz.t.sol` 파일에 구현된 테스트케이스를 통과하도록 `Quiz.sol`에 컨트랙트를 구현하자.
문제에서 제공해준 `Quiz.sol`의 내용은 다음과 같다.

Quiz.sol
```solidity
pragma solidity ^0.8.13;

contract Quiz{
	// 퀴즈 내용에 대한 구조체
	struct Quiz_item {
		uint id;
		string question;
		string answer;
		uint min_bet;
		uint max_bet;
	}
	
	mapping(address => uint256)[] public bets;
	uint public vault_balance;
	
	// 기본 제공 퀴즈
	contructor() {
		Quiz_item memory q;
		q.id = 1;
		q.question = "1+1=?";
		q.answer = "2";
		q.min_bet = 1 ether;
		q.max_bet = 2 ether;
		addQuiz(q);
	}
	
	function addQuiz(Quiz_item memory q) public {}
	function getAnswer(uint quizId) public view returns (string memory){}
	function getQuiz(uint quizId) public view returns (Quiz_item memory){}
	function getQuizNum() public view returns (uint){}
	function betToPlay(uint quizId) public payable {}
	function solveQuiz(uint quizId, string memory ans) public returns (bool) {}
	function claim() public {}
}
```
# 함수 구현
## addQuiz(q)
```solidity
mapping(uint => Quiz_item) public quiz_items;

function addQuiz(Quiz_item memory q) public {
	require(msg.sender != address(1), "invalid address");
	quiz_items[q.id] = q;
	bets.push();
}
```
`addQuize(q)`함수는 `q`구조체에 따라 퀴즈를 추가해 주어야 한다. 따라서 `q.id`에 따라 `Quiz_item`을 저장할 수 있도록 `mapping`을 구현하고, 추가된 퀴즈에 대해 베팅을 할 수 있도록 `bets.push()`를 진행해 준다.
## getAnswer(quizId)
```solidity
function getAnswer(uint quizId) public view returns (string memory){
	Quiz_item memory q = quiz_items[quizId];
	return q.answer;
}
```
`getAnswer(quizId)`함수는 `quizId`에 따라 퀴즈의 정답을 리턴해주면 된다.
## getQuiz(quizId)
```solidity
function getQuiz(uint quizId) public view returns (Quiz_item memory) {
	Quiz_item memory q = quiz_items[quizId];
	q.answer = "";
	return q;
}
```
`getQuiz(quizId)`함수는 `quizId`에 따라 퀴즈의 정보를 리턴해주면 된다. 단, 퀴즈의 정답을 그대로 반환하면 안된다.
## getQuizNum()
```solidity
function getQuizNum() public view returns (uint){
	return bets.length;
}
```
`getQuizNum()`함수는 현재 퀴즈의 개수를 리턴해주면 된다. 여기선 퀴즈를 추가할 때 마다 `bets` 배열의 길이를 늘렸으므로, `bets.length`를 반환해주면 된다.
## betToPlay(quizId)
```solidity
function betToPlay(uint quizId) public payable {
	require(quizId-1 < bets.length, "Invalid quiz ID");
	Quiz_item memory q = quiz_items[quizId];
	require(msg.value >= q.min_bet && msg.value <= q.max_bet, "Bet amount out of range");
  
	bets[quizId-1][msg.sender] += msg.value;
}
```
`betToPlay(quizId)`함수는 `quizId`에 유저가 베팅한 금액을 세팅해준다. 이때, 유저는 유효한 퀴즈번호와 `min`, `max` 범위 내의 금액을 베팅해주어야 한다.
## solveQuiz(quizId, ans)
```solidity
uint private reward;
function solveQuiz(uint quizId, string memory ans) public returns (bool) {
	Quiz_item memory q = quiz_items[quizId];
	bool isCorrect = keccak256(abi.encodePacked(q.answer)) == keccak256(abi.encodePacked(ans));
	if (isCorrect) {
		reward = bets[quizId-1][msg.sender];
		bets[quizId-1][msg.sender] = 0;
	}
	else {
		vault_balance += bets[quizId-1][msg.sender];
		bets[quizId-1][msg.sender] = 0;
	}
	return isCorrect;
}
```
`solveQuiz(quizId, ans)`함수는 `quizId`의 답안 `ans`을 전달받아 채점을 수행한다.
정답일 경우 `reward`에, 오답일 경우 `vault_balance`에 베팅금액이 옮겨지며, 정답 여부를 리턴한다.
## claim()
```solidity
function claim() public {
	uint totalClaim = reward;
	require(totalClaim > 0, "No winnings to claim");
	payable(msg.sender).call{value:totalClaim * 2}("");
}
```
`claim()`함수는 정답을 맞춘 유저가 베팅한 금액의 2배를 수령할 수 있도록 한다.
보상받을 금액이 없으면 revert를 발생시킨다.
## fallback()
```solidity
fallback() external payable {
	vault_balance += msg.value;
}
```
`fallback()`함수를 통해 컨트랙트의 잔고를 관리한다.
# Quiz.sol
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
	struct Quiz_item {
		uint id;
		string question;
		string answer;
		uint min_bet;
		uint max_bet;
	}
	mapping(address => uint256)[] public bets;
	uint public vault_balance;
	  
	mapping(uint => Quiz_item) public quiz_items;
	uint private reward;
	  
	constructor () {
		Quiz_item memory q;
		q.id = 1;
		q.question = "1+1=?";
		q.answer = "2";
		q.min_bet = 1 ether;
		q.max_bet = 2 ether;
		addQuiz(q);
	}
	  
	function addQuiz(Quiz_item memory q) public {
		require(msg.sender != address(1), "invalid address");
		quiz_items[q.id] = q;
		bets.push();
	}
	  
	function getAnswer(uint quizId) public view returns (string memory){
		Quiz_item memory q = quiz_items[quizId];
		return q.answer;
	}
	  
	function getQuiz(uint quizId) public view returns (Quiz_item memory) {
		Quiz_item memory q = quiz_items[quizId];
		q.answer = "";
		return q;
	}
	  
	function getQuizNum() public view returns (uint){
		return bets.length;
	}
	
	function betToPlay(uint quizId) public payable {
		require(quizId-1 < bets.length, "Invalid quiz ID");
		Quiz_item memory q = quiz_items[quizId];
		require(msg.value >= q.min_bet && msg.value <= q.max_bet, "Bet amount out of range");
	  
		bets[quizId-1][msg.sender] += msg.value;
	}
	  
	function solveQuiz(uint quizId, string memory ans) public returns (bool) {
		Quiz_item memory q = quiz_items[quizId];
		bool isCorrect = keccak256(abi.encodePacked(q.answer)) == keccak256(abi.encodePacked(ans));
		if (isCorrect) {
			reward = bets[quizId-1][msg.sender];
			bets[quizId-1][msg.sender] = 0;
		} 
		else {
			vault_balance += bets[quizId-1][msg.sender];
			bets[quizId-1][msg.sender] = 0;
		}
		return isCorrect;
	}
	  
	function claim() public {
		uint totalClaim = reward;
		require(totalClaim > 0, "No winnings to claim");
		payable(msg.sender).call{value:totalClaim * 2}("");
	}
	
	fallback() external payable {
		vault_balance += msg.value;
	}
}
```
