// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract GBTest is Ownable, ERC721A, ReentrancyGuard {
    using Strings for uint256;
    uint256 public constant MAX_SUPPLY = 8999;
    uint256 public currMint = 0;
    uint256 public teamMint = 0;
    uint256 public constant MAX_PUBLIC_MINT = 1;
    uint256 public constant MAX_WHITELIST_MINT = 3;
    uint256 public constant PUBLIC_SALE_PRICE = .1 ether;
    uint256 public constant WHITELIST_SALE_PRICE = .05 ether;

    string private  baseTokenUri;
    string public   placeholderTokenUri;
    mapping(address => bool) public whitelist;

    bool public revealed;
    bool public pubSale;
    bool public wlSale;
    bool public pause;
    bytes32 private merkle;

    constructor() ERC721A("GB", "GMB") {

    }

    modifier callerIsUser() {
    require(tx.origin == msg.sender, "Contracts not allowed to mint!");
    _;
  }

    function pubMint(uint256 qty) external payable callerIsUser {
        require(pubSale, "Sale not started!");
        require(!pause, "Sale paused");
        require(totalSupply() < MAX_SUPPLY);
        require(qty <= 20);
        require(msg.value >= (qty * PUBLIC_SALE_PRICE), "Insufficient ETH");
        _safeMint(msg.sender, qty);
        currMint += qty;
        wrongAmount(qty * PUBLIC_SALE_PRICE);
    }

    function wlMint(uint256 qty) external payable callerIsUser {
        require(wlSale, "Sale not started!");
        require(!pause, "Sale paused");
        require(totalSupply() < MAX_SUPPLY);
        require(qty <= 5);
        require(whitelist[msg.sender], "Not whitelisted");
        require(msg.value >= (qty * WHITELIST_SALE_PRICE), "Insufficient ETH");
        require(numberMinted(msg.sender) + qty <= 5);
        _safeMint(msg.sender, qty);
        currMint += qty;
        wrongAmount(qty * WHITELIST_SALE_PRICE);
    }

    function wrongAmount(uint256 amt) private {
        if (msg.value > amt) {
            payable(msg.sender).transfer(msg.value - amt);
        }
    }
    string private _baseTokenURI;

  function whitelistAdd(address[] memory list) external onlyOwner {
    //require(list.length == 2000);
    for(uint i = 0; i < list.length; i++) {
      whitelist[list[i]] = true;
    }
  }

  function teamAllocation(uint256 qty) external onlyOwner {
    require(totalSupply() + qty <= 200);
    teamMint += 200;
    _safeMint(msg.sender, qty);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function withdrawMoney() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  // function setOwnersExplicit(uint256 quantity) external onlyOwner nonReentrant {
  //   _setOwnersExplicit(quantity);
  // }

  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }

function pauseSale() external onlyOwner{
        pause = !pause;
    }

    function wlSaleSwitch() external onlyOwner{
        wlSale = !wlSale;
    }

    function pubSaleSwitch() external onlyOwner{
        pubSale = !pubSale;
    }

    function toggleReveal() external onlyOwner{
        revealed = !revealed;
    }

  function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
  {
    return _ownershipOf(tokenId);
  }
