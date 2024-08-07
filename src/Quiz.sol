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
        vault_balance += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quiz_items[quizId];
        bool isCorrect = keccak256(abi.encodePacked(q.answer)) == keccak256(abi.encodePacked(ans));
        if (isCorrect) {
            reward = bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
        } else {
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
        }
        return isCorrect;
    }

    function claim() public {
        uint totalClaim = reward;
        for (uint i = 0; i < bets.length; i++) {
            totalClaim += bets[i][msg.sender];
            bets[i][msg.sender] = 0;
        }
        require(totalClaim > 0, "No winnings to claim");
        payable(msg.sender).transfer(totalClaim * 2);
    }
    fallback() external payable {
        vault_balance += msg.value;
    }
}
