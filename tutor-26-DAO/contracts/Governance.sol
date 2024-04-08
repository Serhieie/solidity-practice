// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governance {

     struct ProposalVote {
        uint againstVotes;
        uint forVoates;
        uint abstainVotes; 
        mapping(address => bool)hasVoted;
    }
    struct Proposal {
        uint voatingStarts;
        uint voatingEnds;
        bool executing; 
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => ProposalVote) public proposalVotes;

    IERC20 public token;
    uint public constant VOATING_DELAY = 10;
    uint public constant VOATING_DURATION = 60;

    enum ProposalState { Pending, Active,  Succeeded, Defeated, Executed}

    constructor(IERC20 _token){
        token = _token;
    }

    function propose(
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        string calldata _description
    ) external  returns(bytes32){
        require(token.balanceOf(msg.sender) > 0, "Not enough tokens");
        bytes32 propossalId = generatePropossalId(_to,_value,_func,_data, keccak256(bytes(_description)));
        require(proposals[propossalId].voatingStarts == 0, "proposal already exist");
        proposals[propossalId] = Proposal({
            voatingStarts: block.timestamp + VOATING_DELAY,
            voatingEnds: block.timestamp + VOATING_DELAY + VOATING_DURATION,
            executing:false
        });
        return propossalId;
    }

    function vote(bytes32 _proposalId, uint8 _voteType) external{
        require(state(_proposalId) == ProposalState.Active, "Invalid state");
        uint votingPower = token.balanceOf(msg.sender);
        require(votingPower > 0, "not enough token");
        ProposalVote storage proposalVote = proposalVotes[_proposalId];
        require(!proposalVote.hasVoted[msg.sender], "already voted");

        if(_voteType == 0){
            proposalVote.abstainVotes += votingPower;
        } else if (_voteType == 1){
                   proposalVote.forVoates += votingPower;
        }else {
            proposalVote.abstainVotes +=  votingPower;
        }
        proposalVote.hasVoted[msg.sender] = true;

    }

    function state(bytes32 proposalId) public view returns (ProposalState) {
    Proposal storage proposal = proposals[proposalId];
    ProposalVote storage proposalVote = proposalVotes[proposalId];

    require(proposal.voatingStarts > 0, "Proposal doesn't exist");

    if (proposal.executing) {
        return ProposalState.Executed;
    }

    if (block.timestamp >= proposal.voatingStarts &&
     block.timestamp < proposal.voatingEnds) {
        return ProposalState.Active;
    }

    if(proposalVote.forVoates > proposalVote.againstVotes){
        return ProposalState.Succeeded;
    } else {
        return ProposalState.Defeated;
    }
}


function execute(        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        bytes32  _descriptionHash) external returns(bytes memory){
    bytes32 proposalId = generatePropossalId(_to,_value,_func,_data, _descriptionHash);
            require(state(proposalId) == ProposalState.Succeeded, "Invalid state");

             Proposal storage proposal = proposals[proposalId];

             proposal.executing = true;
        

             bytes memory data;
             if(bytes(_func).length > 0){
                data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
             } else {
                data = _data;
             }

                 (bool success, bytes memory response) = _to.call{value: _value}(data);
                 require(success, "tx failed");
                 return response;

        }



    function generatePropossalId(   
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        bytes32  _descriptionHash) internal pure returns(bytes32){
            return keccak256(abi.encode(_to,_value,_func,_data, _descriptionHash));
        }

}