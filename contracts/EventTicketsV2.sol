pragma solidity ^0.5.0;

contract EventTicketsV2 {

    uint   PRICE_TICKET = 100 wei;
    address payable public owner;
    uint public idGenerator;
    uint public eventID;

    struct Event {
        string description;
        string URL;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    mapping(uint => Event) public events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    modifier onlyOwner {
        require(msg.sender == owner, "owner error");
        _;
    }

    constructor() public{
        owner = msg.sender;
    }

    function addEvent(string memory description, string memory URL, uint tickets) public onlyOwner returns (uint currEventId) {
        events[eventID] = Event({description: description, URL: URL, totalTickets: tickets, sales: 0, isOpen: true});
        uint currentEventId = eventID;
        emit LogEventAdded(description, URL, tickets, currentEventId);
        eventID++; // use safeMath lib
        return currentEventId;
    }

    function readEvent(uint eventId) public view returns (string memory description, string memory URL, uint tickets, uint sales, bool isOpen){
        return (events[eventId].description,
        events[eventId].URL,
        events[eventId].totalTickets,
        events[eventId].sales,
        events[eventId].isOpen);
    }

    function buyTickets(uint _eventId, uint _tickets) public payable {
        require(events[_eventId].isOpen == true &&
            msg.value >= _tickets * PRICE_TICKET &&
            events[_eventId].totalTickets - events[_eventId].sales >= _tickets,
            "buy tickets error"
        );
        events[_eventId].buyers[msg.sender] += _tickets;
        events[_eventId].sales += _tickets;
        emit LogBuyTickets(msg.sender, _eventId, _tickets);
        if(msg.value >= _tickets * PRICE_TICKET) msg.sender.transfer(msg.value - _tickets * PRICE_TICKET);
    }

    function getRefund(uint eventId) public {
        uint tickets = events[eventId].buyers[msg.sender];
        require(tickets > 0, "refund error");
        events[eventId].sales -= tickets;
        emit LogGetRefund(msg.sender, eventId, tickets);
        msg.sender.transfer(tickets * PRICE_TICKET);
    }

    function getBuyerNumberTickets(uint eventId) public view returns (uint numTickets) {
        return events[eventId].buyers[msg.sender];
    }

    function endSale(uint eventId) public onlyOwner {
        events[eventId].isOpen = false;
        emit LogEndSale(owner, events[eventId].sales * PRICE_TICKET, eventId);
        owner.transfer(events[eventId].sales * PRICE_TICKET);
    }
}
