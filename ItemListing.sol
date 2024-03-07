// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ItemListing {
    struct Item {
        string name;
        string description;
        uint256 price;
        uint256 quantity;
    }

    // Mapping to store the relationship between sellers and their listed items
    mapping(address => Item[]) private sellerItems;

    // Function to create a new item listing
    function createItem(string memory _name, string memory _description, uint256 _price, uint256 _quantity) public {
        Item memory newItem = Item(_name, _description, _price, _quantity);
        sellerItems[msg.sender].push(newItem);
    }

    // Function to get the total number of items listed by a seller
    function getSellerItemCount(address _seller) public view returns (uint256) {
        return sellerItems[_seller].length;
    }

    // Function to get the details of a specific item listed by a seller
    function getItemDetails(address _seller, uint256 _itemId) public view returns(string memory, string memory, uint256, uint256) {
        require(_itemId < sellerItems[_seller].length, "Invalid item ID");
        Item memory item = sellerItems[_seller][_itemId];
        return (item.name, item.description, item.price, item.quantity);
    }
}

