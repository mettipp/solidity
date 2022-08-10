// SPDX-License-Identifier: MIT License
pragma solidity 0.8.15;
contract Lottory{
    uint CostOfTicket;
    uint TimeOfStart;
    uint TimeOfEnd;
    uint WholeMoney;
    uint8 PercentageOfOwner;
    uint PrizeOfOwner;
    uint WholePrize;
    uint TicketCount;
    address public Owner;
    uint RandomNumber;
    constructor(uint _TimeOfEnd , uint _CostOfTicket , uint8 _PercentageOfOwner){
        TimeOfStart=block.timestamp;
        Owner=msg.sender;
        TimeOfEnd = block.timestamp + (_TimeOfEnd*86400);
        CostOfTicket = _CostOfTicket;
        PercentageOfOwner = _PercentageOfOwner;
    }
    struct Ticket{
        uint TicketId;
        bool Win;
        address TicketOwner;
    }
    mapping (uint => Ticket) TicketMap;
    Ticket [] Tickets;

    event Buy(address indexed _AddressOfBuyer , uint _TicketCode);
    event Winning(address indexed _AddressOfWinner , uint _Prize);

    function BuyTicket(uint _NumberOfTicket) public payable returns(string memory){
        require (block.timestamp <= TimeOfEnd , "The Lottory Is Ended , Please Wait Til Next Event!" );
        require (msg.value == _NumberOfTicket*CostOfTicket , "Your Balance Is Not Efiicient!");
        for (uint i=1 ; i<= _NumberOfTicket ; i++){
            TicketCount ++;
            TicketMap[TicketCount]=Ticket(TicketCount,false,msg.sender);
            Tickets.push(Ticket(TicketCount,false,msg.sender));
            WholeMoney += CostOfTicket;
            emit Buy(msg.sender,TicketCount);
        }
        return "Your Ticket Bought Successfuly!";
    }
    function ShowAllTickets() public view returns(Ticket [] memory){
        return Tickets;
    }
    function StartLottory() public returns(string memory){
        require (block.timestamp >= TimeOfEnd , "The Lottory Is Not Ended , yet!" );
        require (msg.sender == Owner , "Your Are Not Owner!");
        PrizeOfOwner = (WholeMoney/100)*PercentageOfOwner;
        WholePrize = WholeMoney - PrizeOfOwner;
        address WinnerAddress = TicketMap[RandomNumber].TicketOwner;
        payable(WinnerAddress).transfer(WholePrize);
        payable(Owner).transfer(PrizeOfOwner);
        emit Winning(WinnerAddress , WholePrize);
    }
       function ChooseRandom () private{
        uint RandomNumber =  uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty))) / TicketCount;
    }
 
}