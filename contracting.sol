// SPDX-License-Identifier: MIT License

pragma solidity 0.8.15;

contract contracting {
    uint public StartDayOfProject;
    uint16 public LengthOfProject;
    uint public CostOfProject;
    uint public CostOfLoss;
    uint AllCosts = CostOfProject + CostOfLoss;
    uint Percentage = (AllCosts/100)*5;
    uint FinalCosts = AllCosts - Percentage;
    uint PercentageOfPlatform = (Percentage/5)*4;
    uint PercentageOfjudge = (Percentage/5)*1;
    address payable Employer;
    address payable Emploee;
    address payable judge;
    address public Owner;

    enum Status{
        notstarted,paid,started,finished,suspended,failed
    }
    Status CurrentStatus ;
    constructor(address payable _Employer , address payable _Emploee , address payable _judge , uint16 _LenghtOfProject , uint _CostOfProject , uint _CostOfLoss){
        Employer=_Employer;
        Emploee=_Emploee;
        judge=_judge;
        LengthOfProject = _LenghtOfProject;
        CostOfProject=_CostOfProject;
        CostOfLoss=_CostOfLoss;
        CurrentStatus = Status.notstarted;
        Owner = msg.sender;
    }
    function pay() public payable returns(string memory){
        require (msg.sender==Employer);
        require (msg.value==CostOfProject);
        require (CurrentStatus==Status.notstarted);
        CurrentStatus = Status.paid;
        return "Cost Of Project Paid Successfully";
    }
    function start() public payable returns(string memory){
        require (msg.sender==Emploee);
        require (msg.value==CostOfLoss);
        require (CurrentStatus==Status.paid);
        CurrentStatus = Status.started;
        StartDayOfProject = block.timestamp;
        judge.transfer(PercentageOfjudge);
        payable(Owner).transfer(PercentageOfPlatform);
        return "Cost Of Project Loss Paid Successfully";
    }
    function ConfirmProject (bool confirm) public returns(string memory){
        require (msg.sender==Employer);
        require (CurrentStatus==Status.started);
        if (block.timestamp >= StartDayOfProject-(LengthOfProject*84600)){
            if (confirm == true){
                CurrentStatus = Status.finished;
                Emploee.transfer(FinalCosts);
            }
            else{
                CurrentStatus = Status.suspended;
            }
        }
            else{
                return "DeadLine Is Not Over";
            }
            return "Project Stutus Updated Successfully";
    }
   function Judgement (bool JudgeComment) public returns(string memory){
        require (msg.sender==judge);
        require (CurrentStatus==Status.suspended);
        if (JudgeComment == true){
            CurrentStatus = Status.finished;
            Emploee.transfer((FinalCosts));
        }
        else{
            CurrentStatus = Status.failed;
            Employer.transfer((FinalCosts));
        }
        return "Project Stutus Updated Successfully";
    }
    function getstutus () public view returns(Status){
        return CurrentStatus;
    }
}