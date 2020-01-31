pragma solidity ^0.5.0;

contract EventTickets {

    uint   TICKET_PRICE = 100 wei;
    address payable public owner;

    struct Event {
        string description;
        string URL;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }


    Event myEvent;

    event LogBuyTickets(address purchaser, uint ticketsBought);
    event LogGetRefund(address requester, uint ticketsRefund);
    event LogEndSale(address contractOwner, uint balanceSold);

    modifier onlyOwner() {
        require(owner == msg.sender, "owner error");
        _;
    }

    constructor(string memory _description, string memory _URL, uint _totalTickets) public {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.URL = _URL;
        myEvent.totalTickets = _totalTickets;
        myEvent.sales = 0;
        myEvent.isOpen = true;
    }

    function readEvent()
        public view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.URL, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    function getBuyerTicketCount(address _buyer) public view returns(uint _tickets) {
        return myEvent.buyers[_buyer];
    }

    function buyTickets(uint _ticket) public payable {
        require(myEvent.isOpen == true, "Open Error");
        require(msg.value >= (_ticket * TICKET_PRICE), "Tx value is not sufficient");
        require(myEvent.totalTickets >= _ticket, "Tickets sold out");
        myEvent.sales += _ticket;
        myEvent.buyers[msg.sender] += _ticket;
        myEvent.totalTickets -= _ticket;
        if(msg.value > (_ticket * TICKET_PRICE) ){
            uint change = msg.value - (_ticket * TICKET_PRICE);
            msg.sender.transfer(change);
        }
        emit LogBuyTickets(msg.sender, _ticket);
    }

    function getRefund() public payable returns(uint, uint){
        require(myEvent.buyers[msg.sender] != 0, "registration error");
        uint refund;
        uint refundPrice;

        refund = myEvent.buyers[msg.sender];
        myEvent.totalTickets += refund;
        refundPrice = refund * TICKET_PRICE;
        myEvent.buyers[msg.sender] = 0;

        msg.sender.transfer(refundPrice);

        emit LogGetRefund(msg.sender, refund);
        return (refund, refundPrice);
    }

    function endSale() public onlyOwner{
        myEvent.isOpen = false;
        owner.transfer(address(this).balance);
        emit LogEndSale(owner, address(this).balance);
    }
}
