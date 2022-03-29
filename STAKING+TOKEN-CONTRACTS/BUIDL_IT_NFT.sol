// SPDX-License-Identifier: MIT

//no need for us to reinvent the wheel, this contract from the hashlips repois great for our purpose with a little tweaking
// Amended by Macguyver
/**
    !Disclaimer!

    please review this code on your own before using any of
    the following code for production.
    The developer will not be responsible or liable for all loss or 
    damage whatsoever caused by you participating in any way in the 
    experimental code, whether putting money into the contract or 
    using the code for your own project.
*///okokokokok!
/// lets get it to 8.11...
pragma solidity ^0.8.11; //done!

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BuidlITNFT is Ownable, ERC721  {
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private supply;

  string public uriPrefix = "";
  string public uriSuffix = ".json";
  string public hiddenMetadataUri;  ///// do we need to hide metadata??? can we use this functionality for something else??
  
  uint256 public cost = 135 ether;  ////doesnt need 0000 x 18 here but does once launched to change on polygon at this moment = $250
  uint256 public maxSupply = 100;  //total NFTS v1 legacy THIS CONTRACT 29/march/2022 one hundred 100
  uint256 public maxMintAmountPerTx = 1;  // max mint per wallet transaction

  bool public paused = true;
  bool public revealed = false;

    struct BuidlIT_User {
        uint8 id;
        string nick;
        string glb;
        string extra;
        string extra1;
    }
    
    mapping (address => BuidlIT_User) users;
    address[] public userAccts;
    

    constructor() ERC721("BuidlIT NFT", "IT") {
        setHiddenMetadataUri("https://buidlit.parallelshift.space/img/logo.jpg");
       
    }

    function setBuidlIT_User(uint _nick, string memory _glb, string memory _extra, string memory _extra1) public {
        
        users[msg.sender].id = 0;
        users[msg.sender].nick = _nick;
        users[msg.sender].glb = _glb;
        users[msg.sender].extra = _extra;
        users[msg.sender].extra1 = _extra1;
        
        userAccts.push(_address) -1;
    }
    
    function getBuidlIT_Users() view public returns(address[] memory) {
        return userAccts;
    }
    
    function getBuidlIT_User(address _address) view public returns (uint, string memory, string memory) {
        return (users[_address].nick, users[_address].glb, users[_address].extra, users[_address].extra1);
    }
    
    function countBuidlIT_Users() view public returns (uint) {
        return userAccts.length;
    } 


    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid");
        require(supply.current() + _mintAmount <= maxSupply, "Max exceeded!");
        _;
    }

    function totalSupply() public view returns(uint256) {
        return supply.current();
    }

    function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
        require(!paused, "paused!");
        require(msg.value >= cost * _mintAmount, "funds!");
        _mintLoop(msg.sender, _mintAmount);
    }

    function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
        _mintLoop(_receiver, _mintAmount);
    }

    function walletOfOwner(address _owner)
    public
    view
    returns(uint256[] memory)
    {
    uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }

            currentTokenId++;
        }

        return ownedTokenIds;
    }

    function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns(string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

    string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
            : "";
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{ value: address(this).balance } ("");///good example of call function to reaplace in other contracts 
        require(os);
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    function _baseURI() internal view virtual override returns(string memory) {
        return uriPrefix;
    }
}
