// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Randomizer is VRFConsumerBaseV2 {
    //отримує рандомне число і робить перевірки
    VRFCoordinatorV2Interface immutable COORDINATOR;

    //11060
    uint64 s_subscriptionId;

    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    uint32 numWords = 1;

    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    uint256[] public requestIds;

    uint256 public lastRequestId;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);


    //coord 0x8103b0a8a00be2ddc778e6e7eaa21791cd364625
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625) {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );

        s_subscriptionId = subscriptionId;
    }

    function requestRandomWords() external returns (uint requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        requestIds.push(requestId);

        lastRequestId = requestId;

        emit RequestSent(requestId, numWords);

        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");

        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");

        RequestStatus memory request = s_requests[_requestId];

        return (request.fulfilled, request.randomWords);
    }
}
