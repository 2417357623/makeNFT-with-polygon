// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract PinaDemo is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    mapping(uint256 =>uint256) public tokenIdToLevels;

    constructor(address initialOwner)
        ERC721("pinaDemo", "PP")
        Ownable(initialOwner)
    {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        tokenIdToLevels[tokenId] = 0;
        //不同的tokenId有不同的url，这里的url不是参数传递的，也就是我在铸造的时候，按照写好的逻辑，依次铸造相应的nft。
        //url就是把一个json文件存储起来的url地址。json里的image可以是像这里一样写在json里的，不需要从外部存储读取的。也可以是通过ifps在外部分布式存储的url的
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function generateCharacter(uint256 tokenId) public view returns (string memory){
        
        //use encode to transfer from string to byte then to base64,and splice url and finally turn into string
        bytes memory svg = abi.encodePacked(    '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
    '<text x="50" y="50" font-family="Arial" font-size="24" fill="black">',getLevels(tokenId),'</text>',
    '</svg>' ); 

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

   function getTokenURI(uint256 tokenId) public view returns (string memory) {
    // 使用 Strings.toString() 将数字转为字符串
    string memory json = string(
        abi.encodePacked(
            '{',
            '"name": "Chain Battles #', Strings.toString(tokenId), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
            '}'
        )
    );

    // 将 JSON 数据编码为 Base64
    string memory encodedJson = Base64.encode(bytes(json));

    // 返回完整的 `data` URI
    return string(
        abi.encodePacked("data:application/json;base64,", encodedJson)
    );
    }

    function getLevels(uint256 tokenId) public view returns(string memory){
        uint256 levels = tokenIdToLevels[tokenId];
        return Strings.toString(levels);
    }

    function train(uint256 tokenId) public{
        require(ownerOf(tokenId) != address(0),"please use an existing Token");
        require(ownerOf(tokenId) == msg.sender,"you must be the owner of the token");
        uint256 currentLevel = tokenIdToLevels[tokenId];
        tokenIdToLevels[tokenId] = currentLevel +1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}