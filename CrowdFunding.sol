//SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribuiton;
    uint deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    struct Request{
        string description;
        address payable recepient;
        uint value;
        uint completed;
        uint noOfVoters;
        mapping(address=>uint) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _target,uint _deadline){
         target=_target;
         deadline=block.timestamp+_deadline;
         minimumContribuiton=100 wei;
         manager=msg.sender;
    }
    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed.");
        require(msg.value >=minimumContribuiton,"Minimum Contribution is not met.");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        //if same contributors again contributing 
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target," Your are not elligible for the refund.");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only Manger can call this function");
        _;  
    }
    function createRequests(string memory _description,address payable _recipient,uint  _value)public onlyManager(){
        Request storage newRequest =requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recepient=_recipient;
        newRequest.value=_value;
        newRequest.completed=0;
        newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be the contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==0," You have already voted");
        thisRequest.voters[msg.sender]=1;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo)public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==0,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
        thisRequest.recepient.transfer(thisRequest.value);
        thisRequest.completed=1;
    }
}