import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Resources is ERC1155{
    constructor()
        ERC1155("")
        {

        }

    function mintWood(address to, uint256 amount) external {
        _mint(to, 0, amount, "");
    }
}