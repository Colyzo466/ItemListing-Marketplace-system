// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library MarketplaceReports {
    struct SalesReport {
        address seller;
        string itemName;
        uint256 price;
        uint256 quantitySold;
    }

    struct PurchaseHistory {
        address buyer;
        string itemName;
        uint256 price;
        uint256 quantityPurchased;
    }

function generateSalesReport(address itemListingAddress) internal view returns (SalesReport[] memory) {
    ItemListing itemListing = ItemListing(itemListingAddress); // Change memory to storage
    uint256 totalItems = itemListing.getSellerItemCount(address(this));
    SalesReport[] memory salesReports = new SalesReport[](totalItems);

    for (uint256 i = 0; i < totalItems; i++) {
        (string memory name, , uint256 price, uint256 quantity) = itemListing.getItemDetails(address(this), i);
        salesReports[i] = SalesReport(address(this), name, price, quantity);
    }

    return salesReports;
}

    function generatePurchaseHistory(ItemListing itemListing, address buyer) internal  view returns (PurchaseHistory[] memory) {
        uint256 totalItems = itemListing.getSellerItemCount(buyer);
        PurchaseHistory[] memory purchaseHistories = new PurchaseHistory[](totalItems);

        for (uint256 i = 0; i < totalItems; i++) {
            (string memory name, , uint256 price, uint256 quantity) = itemListing.getItemDetails(buyer, i);
            purchaseHistories[i] = PurchaseHistory(buyer, name, price, quantity);
        }

        return purchaseHistories;
    }
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
}

contract ItemListing is Ownable {
    using MarketplaceReports for ItemListing;

    uint256 public listingFee;
    mapping(address => Item[]) private sellerItems;

    struct Item {
        string name;
        string description;
        uint256 price;
        uint256 quantity;
    }

    event ItemListed(address seller, string name, uint256 price, uint256 quantity);
    event ItemEdited(address seller, uint256 itemId, string name, uint256 price, uint256 quantity);
    event ItemDeleted(address seller, uint256 itemId);
    event ItemPurchased(address buyer, string name, uint256 price, uint256 quantity);

    constructor(uint256 _fee) {
        listingFee = _fee;
    }

    function listItem(string memory _name, string memory _description, uint256 _price, uint256 _quantity) public payable {
        require(msg.value == listingFee, "Listing fee must be paid");

        Item memory newItem = Item(_name, _description, _price, _quantity);
        sellerItems[msg.sender].push(newItem);
        emit ItemListed(msg.sender, _name, _price, _quantity);
    }

    function editItem(uint256 _itemId, string memory _name, uint256 _price, uint256 _quantity) public onlyOwner {
        require(_itemId < sellerItems[msg.sender].length, "Invalid item ID");
        Item storage item = sellerItems[msg.sender][_itemId];
        item.name = _name;
        item.price = _price;
        item.quantity = _quantity;
        emit ItemEdited(msg.sender, _itemId, _name, _price, _quantity);
    }

    function deleteItem(uint256 _itemId) public onlyOwner {
        require(_itemId < sellerItems[msg.sender].length, "Invalid item ID");
        delete sellerItems[msg.sender][_itemId];
        emit ItemDeleted(msg.sender, _itemId);
    }

    function purchaseItem(address _seller, uint256 _itemId) public payable {
        require(_itemId < sellerItems[_seller].length, "Invalid item ID");
      
        Item storage item = sellerItems[_seller][_itemId];
        require(item.quantity > 0, "Item out of stock");
        require(msg.value >= item.price, "Insufficient funds");

        item.quantity--;
        emit ItemPurchased(msg.sender, item.name, item.price, 1);
    }

    function getSellerItemCount(address _seller) public view returns (uint256) {
        return sellerItems[_seller].length;
    }

    function getItemDetails(address _seller, uint256 _itemId) public view returns (string memory, string memory, uint256, uint256) {
        require(_itemId < sellerItems[_seller].length, "Invalid item ID");
        Item memory item = sellerItems[_seller][_itemId];
        return (item.name, item.description, item.price, item.quantity);
    }

    function generateSalesReport() public view returns (MarketplaceReports.SalesReport[] memory) {
        return MarketplaceReports.generateSalesReport(address(this));
    }

    function generatePurchaseHistory(address _buyer) public view returns (MarketplaceReports.PurchaseHistory[] memory) {
        return MarketplaceReports.generatePurchaseHistory(this, _buyer);
    }
}

