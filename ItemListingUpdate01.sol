// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ItemListing {
    address public owner;

    struct Item {
        string name;
        string description;
        uint256 price;
        uint256 quantity;
    }

    mapping(address => Item[]) private sellerItems;

    event ItemListed(address seller, string name, uint256 price, uint256 quantity);
    event ItemEdited(address seller, uint256 itemId, string name, uint256 price, uint256 quantity);
    event ItemDeleted(address seller, uint256 itemId);
    event ItemPurchased(address buyer, string name, uint256 price, uint256 quantity);

    modifier onlyOwner(address _seller, uint256 _itemId) {
        require(msg.sender == _seller, "Only the owner can perform this action");
        _;
    }

    function listItem(string memory _name, string memory _description, uint256 _price, uint256 _quantity) public {
        Item memory newItem = Item(_name, _description, _price, _quantity);
        sellerItems[msg.sender].push(newItem);
        emit ItemListed(msg.sender, _name, _price, _quantity);
    }

    function editItem(uint256 _itemId, string memory _name, uint256 _price, uint256 _quantity) public onlyOwner(msg.sender, _itemId) {
        require(_itemId < sellerItems[msg.sender].length, "Invalid item ID");
        Item storage item = sellerItems[msg.sender][_itemId];
        item.name = _name;
        item.price = _price;
        item.quantity = _quantity;
        emit ItemEdited(msg.sender, _itemId, _name, _price, _quantity);
    }

    function deleteItem(uint256 _itemId) public onlyOwner(msg.sender, _itemId) {
        require(_itemId < sellerItems[msg.sender].length, "Invalid item ID");
        delete sellerItems[msg.sender][_itemId];
        emit ItemDeleted(msg.sender, _itemId);
    }

    function purchaseItem(address _seller, uint256 _itemId) public {
        require(_itemId < sellerItems[_seller].length, "Invalid item ID");
        Item storage item = sellerItems[_seller][_itemId];
        require(item.quantity > 0, "Item out of stock");
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
}
