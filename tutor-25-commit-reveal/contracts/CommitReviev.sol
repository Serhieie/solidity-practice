// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract CommitReviev {
address[] public candidates = [
    0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199,
    0xdD2FD4581271e230360230F9337D5c0430Bf44C0,
    0xbDA5747bFD65F08deb54cb465eB87D40e51B197E
];

mapping(address => bytes32)public commits;
mapping(address => uint)public votes;
bool voatingStoped;
bytes32 public test;


//has at frontend
function commitVoute(bytes32 _hashedVoute) external {
require(!voatingStoped, "Voating was stopped");
require(commits[msg.sender] == bytes32(0));
commits[msg.sender] = _hashedVoute;
}

function revealVote(address _candidate , bytes32 _secret) external {
    require(voatingStoped, "Voating should be stopped");

    // не працює ця частина
    bytes32 commit = keccak256(abi.encodePacked(_candidate,_secret, msg.sender ));
    test = commit;
    require(commit == commits[msg.sender]);

    delete commits[msg.sender];
    votes[_candidate] += 1;
}

//only Owner
function stopVoating()external {
require(!voatingStoped, "Voating was stopped");
voatingStoped = true;
}
// v6:
//bytes32 = ethers.encodeBytes32String(text)
//'0x7365637265740000000000000000000000000000000000000000000000000000'
//text = ethers.decodeBytes32String(bytes32)
//ethers.solidityPackedKeccak256(["address", 'bytes32', 'address'],[])


//ethers.solidityPackedKeccak256(["address", 'bytes32', 'address'],['0xdD2FD4581271e230360230F9337D5c0430Bf44C0','0x7365637265740000000000000000000000000000000000000000000000000000','0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266']) 

//результат виклику
//'0x5f4cfd74c008d920c1bca416be3fac04d9e578a0eb88c03bc519d8d7fa5d06f5'



//під копотом виклик цього 
//keccak256(abi.encodePacked())
}
