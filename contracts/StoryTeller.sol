// File: storyTeller/storyTeller_0.0.4_nft_goeril.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract storyTeller is ERC721 {
    //
    uint256 public storyCounter;
    uint256 public startTime;
    uint256 private lastWrittenYear;
    uint256 private endTimestamp;

    //
    //STRUCT
    //
    struct Story {
        uint256 backIncidentId; //incidentId happened 1 year ago & 0 start
        uint256 year; 
        string incident; 
        bool isFinal; //If you choice true, the world line finish by the incident
        address teller;
        //bool isEmpty; 
    }

    //
    //MAPPING
    //
    mapping(uint256 => Story) storyList;

    //
    //EVENT
    //
    event WriteStory(
        uint256 indexed incidentId, 
        uint256 indexed backIncidentId,
        uint256 year, 
        string incident,
        address indexed teller,
        bool isFinal
        );

    //
    //CONSTRUCTOR
    //
    constructor() ERC721("Story", "STRY") {
        startTime = block.timestamp;
        storyCounter = 1;
        endTimestamp = block.timestamp + 30 days;
    }

    //
    //MAIN
    //

    function currentYear() public view returns(uint256) {
        return (block.timestamp - startTime) / 8640;
        } 
        //the function is to return current year
        //8640 = 2.4h * 3600sec(1h)


    function writeStory (
        uint256 _backIncidentId, 
        string memory _incident,
        bool _isFinal
    ) public payable {
        // Stop to mint after 30days
        require(block.timestamp <= endTimestamp, "Minting is no longer available after 30 days");

        // Check if the payment is at least 0.001 MATIC
        require(msg.value >= 0.001 * 10 ** 18, "Minimum payment of 0.001 ETH required");

        require(
            _backIncidentId == 0 || (
                storyList[_backIncidentId].year < currentYear() &&
                !storyList[_backIncidentId].isFinal && _backIncidentId < storyCounter + 1
            ),
            "Invalid_back_story_ID"
        );
        //check whether there is a incident before year


        Story memory newStory = Story({
            backIncidentId: _backIncidentId,
            year: (block.timestamp - startTime) / 8640,
            incident: _incident,
            isFinal: _isFinal,
            teller: msg.sender
        });

        storyCounter++;
        // Mint the NFT with the story data
        _mint(msg.sender, storyCounter);

        storyList[storyCounter] = newStory;

        emit WriteStory(storyCounter -1, _backIncidentId, currentYear(), _incident, msg.sender, _isFinal);
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == 0xfbc853EeF4Ad085Efb60A66f2aAc0fB976af71F6, "Only the owner can withdraw ETH");
        require(amount <= address(this).balance, "Insufficient balance");

        address payable owner = payable(0xfbc853EeF4Ad085Efb60A66f2aAc0fB976af71F6);
        owner.transfer(amount);
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Convert a uint256 value to its decimal string representation
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}


    function mintNFT(uint256 year, string memory incident, uint256 incidentId) internal {
        // Mint the NFT with the data URI
        
    }

    /*
     * Metadata processing.
     */
     
    function tokenURI(uint256 _incidentId) public view override returns (string memory) {
        require(_exists(_incidentId), "ERC721Metadata: URI query for nonexistent token");

        Story memory incident = storyList[_incidentId];
        //year, incidentId, incident
        //#incidentId
        string memory svg = getSVG(incident, _incidentId);
        bytes memory json = abi.encodePacked(
            '{"name": "',
            abi.encodePacked("In ", Strings.toString(incident.year), ", ", incident.incident),
            '", "description": "", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '", "attributes":[{"trait_type": "year", "value":"',
            Strings.toString(incident.year),
            '"},{"trait_type": "backIncidentId", "value":"',
            Strings.toString(incident.backIncidentId),
            '"}]}'
        );
        string memory _tokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(json)
            )
        );
        return _tokenURI;
    }

    function getSVG(Story memory _incident, uint256 _incidentId) private view returns (string memory) {
        // Get the back story using the backIncidentId
        Story memory backStory = getStory(_incident.backIncidentId);
        uint256 backStoryYear = backStory.year;
        string memory incident_color = "#fff";

        if(_incident.isFinal) incident_color = "#de0400";

        return
            string(
                abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300"><path d="M0 0h300v300H0z"/><text fill="#fff" font-family="Times" font-size="8" font-weight="400"><tspan x="10" y="20">',
                abi.encodePacked("YEAR: ", Strings.toString(_incident.year)),
                '</tspan></text><text fill="#fff" font-family="Times" font-size="8" font-weight="400"><tspan x="10" y="40">INCIDENT:',
                '</tspan></text><text fill="#fff" font-family="Times" font-size="8" font-weight="400"><tspan x="10" y="60">',
                abi.encodePacked("After ", getStory(_incident.backIncidentId).incident, "..."),
                '</tspan></text><text fill="',
                incident_color,
                '" font-family="Times" font-size="8" font-weight="400"><tspan x="10" y="80">',
                _incident.incident,
                '</tspan></text><text fill="#fff" font-family="times" font-size="8" font-weight="400"><tspan x="10" y="270">',
                abi.encodePacked("INCIDENT: #", Strings.toString(_incidentId)),
                '</tspan></text><text fill="#fff" font-family="times" font-size="8" font-weight="400"><tspan x="10" y="290">',
                abi.encodePacked("BACKED INCIDENT: #", Strings.toString(_incident.backIncidentId), ", in ", Strings.toString(backStoryYear)), //Strings.toString(_incident.year))の部分をbackIncidentIdのyearにする必要ある
                '</tspan></text></svg>'
                )
            );
    }

    //
    //GET
    //
    function getStory(uint256 _incidentId) public view returns(Story memory) {
        return storyList[_incidentId];
    }

    function getCurrentYear() public view returns(uint256) {
        return (block.timestamp - startTime) / 8640;
    } //actual time setting of Story Teller

    ///
    function getLastWrittenYear() public view returns(uint256) {
        return lastWrittenYear;
    }

    function setLastWrittenYear(uint256 _lastWrittenYear) private {
        lastWrittenYear = _lastWrittenYear;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}