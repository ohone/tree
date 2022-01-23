import "openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Resources is ERC1155{
    address private owner;
    mapping (address=>bool) authorizedAddresses;
    
    constructor() ERC1155("")
    {
        authorizedAddresses[msg.sender] = true;
    }

    function isAuthorized(address addr) external view returns(bool) {
        return authorizedAddresses[addr];
    }

    function addApprovedAddress(address addr) external onlyAuth {
        authorizedAddresses[addr] = true;
    }

    function mintWood(address to, uint256 amount) external onlyAuth {
        _mint(to, 0, amount, "");
    }

    modifier onlyAuth(){
        require(authorizedAddresses[msg.sender] == true, "Sender not authorized.");
        _;
    }
}