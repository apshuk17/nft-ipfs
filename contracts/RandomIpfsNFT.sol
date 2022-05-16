// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomIpfsNFT is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable i_vrfCoordinatorV2;
    bytes32 public immutable i_gasLane;
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callbackGasLimit;

    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;
    uint256 public MAX_CHANCE_VALUE = 100;

    mapping(uint256 => address) public s_requestIdToSender;
    uint256 public s_tokenCounter;
    string[3] public s_dogTokenUris;

    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris) ERC721("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoordinator) {
        // Contract
        i_vrfCoordinatorV2 = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;
        // 0 st. bernard
        // 1 pug
        // 2 shiba inu
    }

    // Mint a random puppy
    function requestDoggie() public returns (uint256 requestId) {
        requestId = i_vrfCoordinatorV2.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        s_requestIdToSender[requestId] = msg.sender;
    }

    // callback function
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // address of the dog owner
        address dogOwner = s_requestIdToSender[requestId];

        // assign tokenId to this NFT
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter += 1;

        // moddedRng
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;

        // get Breed
        uint256 breed = getBreedFromRng(moddedRng);

        // safe mint the token id
        _safeMint(dogOwner, newTokenId);

        // set the tokenUri
        _setTokenURI(newTokenId, s_dogTokenUris[breed]);

    }

    function getChanceArray() public view returns (uint256[3] memory) {
        // 0 - 9 = st. bernard
        // 10 -29 = pug
        // 30 - 99 = shiba inu 
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getBreedFromRng(uint256 moddedRng) public view returns (uint256) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();

        for(uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
                return i;
            }
            cumulativeSum += chanceArray[i]; 
        }
    }

}