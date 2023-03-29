// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable receipent;
        uint value;
        bool compeleted;
        uint noOfVoters;
        mapping(address=>bool) voters;

    }
    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target,uint _deadline){
        target = _target;
        deadline =block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager =msg.sender;
    }
    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value >= minimumContribution,"Minimum Contribution is not met");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp > deadline && raisedAmount < target,"not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender == manager,"only manager can call");
        _;
    }
    function createRequests(string memory _description,address payable _receipent,uint _value) public onlyManager{
       Request storage newRequest = requests[numRequests];
       numRequests++;
       newRequest.description=_description;
              newRequest.receipent=_receipent;
       newRequest.value=_value;

       newRequest.compeleted=false;

       newRequest.noOfVoters=0;

    }
    function voteRequest(uint _requestNo)public{
        require(contributors[msg.sender]>0,"you must be a contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"you have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
       require(raisedAmount>=target);
       Request storage thisRequest=requests[_requestNo];
       require(thisRequest.compeleted==false,"the request has been compeleted"); 
       require(thisRequest.noOfVoters > noOfContributors/2,"majority not suppoerted");
       thisRequest.receipent.transfer(thisRequest.value);
       thisRequest.compeleted = true;
    }
}