pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

contract DelanceAuctionContract {

    mapping(uint => Auction) private auctions;
    uint private nextAuctionId = 1;
    mapping(uint => Offer) private offers;
    uint private nextOfferId = 1;
    mapping(address => uint[]) private userAuctions;
    mapping(address => uint[]) private userOffers;

    struct Auction {
        uint id;
        address payable seller;
        string name;
        string description;
        uint min;
        uint end;
        uint bestOfferId;
        uint[] offerIds;
    }

    struct Offer {
        uint id;
        uint auctionId;
        address payable buyer;
        uint price;    
    }

    modifier auctionExists(uint _auctionId){
        require(_auctionId > 0 && _auctionId < nextAuctionId, 'auction does not exist');
        _;
    }

// allow seller to create auctions    

    function createAuction(
        string calldata _name, 
        string calldata _description, 
        uint _min, 
        uint _duration)
     external {
        require(_min > 0, '_min must be > 0');
        require(_duration > 86400 && _duration < 864000, '_duration must be comprised of more than 86400ms');
        uint[] memory offerIds = new uint[](0);

        auctions[nextId] = Auction(
            nextAuctionId, 
            msg.sender,
            _name, 
            _description, 
            _min, 
            now + _duration,
            0,
            offerIds
            );
        userAuctions[msg.sender].push(nextAuctionId);
        nextAuctionId++;
    }

// Allow buyers make an offer for an auction

    function createOffer(uint _auctionId) external payable AuctionExists(_auctionId) { 
        Auction storage auction = auctions[_auctionId];
        Offer storage bestOffer = offers[auction.bestOfferId];
        require(now < auction.end, 'Auction has expired');
        require(msg.value >= auction.min && msg.value > bestOffer.price, 'msg.value must be superior to auction min and bestOffer');
        auction.bestOfferId = nextOfferId;
        auction.offerIds.push(nextOfferId);
        offers[nextOfferId] = Offer(nextOfferId, _auctionId, msg.sender, msg.value);
        userOffers[msg.sender].push(nextOfferId);
        nextOfferId++;
    }

// Allow buyer and seller to trade after auction's end.    

    function trade(uint _auctionId) external auctionExists(_auctionId){
        Auction storage auction = auctions[_auctionId];
        Offer storage bestOffer = offers[auction.bestOfferId];
        require(now > auction.end, 'Auction has expired', 'auction is still active');

        for(uint i = 0; i < auction.offerIds.length; i++){
            uint offerId = auction.offerIds[i];
            if(offerId != auction.bestOfferId){
                Offer storage offer = offers[offerId];
                offers.buyer.transfer(offer.price);
            }
        }
        auction.seller.transfer(bestOffer.price);
    }

// Getter function for Auctions

    function getAuctions() view external returns(Auction[] memory){
        Auction[] memory _auctions = new Auction[](nextAuctionId - 1);
        for(uint i = 0; i < nextAuctionId + 1; i++){
            _auctions[i-1] = auctions[i];
        }
        return _auctions; 
    }

// Getter function for user Auctions

    function getUserAuctions(address _user) view external returns(Auction[] memory){
        uint[] storage userAuctionIds = userAuctions[_user];
        Auction[] memory _auctions = new Auction[](userAuctionIds.length);
        for(uint i = 0; i < userAuctionsIds.length; i++){
            uint auctionId = userAuctionIds[i];
            _auctions[i] = auctions[auctionId];
        }
        return _auctions;
    }

// Getter function for user Offers

    function getUserOffers(address _user) view external returns(Offer[] memory){
        uint[] storage userOfferIds = userOffers[_user];
        Offer[] memory _offers = new Offer[](userOfferIds.length);
        for(uint i = 0; i < userOffersIds.length; i++){
            uint offerId = userOfferIds[i];
            _offers[i] = offers[offerId];
        }
        return _auctions;
    }

    // To Do: admin, best offer transaction, banning users, require registration of users. 
}
