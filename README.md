# Tree

'game' with resource accumulation / crafting / 

## Items

### Ownable: Tree

Game starts with `Tree` ERC721 distribution. Each `Tree` can be chopped down (burnt) to recieve an amount of `Wood` (see below) proportional to the age of the tree when chopped.

### Resource: Wood

Retrieved by chopping down a `Tree`. Fungible ERC1155.

### Resource: Stone

Not sure how stone is going to be aquired yet.

### Tool: Axe

Some amount of `Stone` + `Wood`.

Has durability eroded with each use. Empty durability causes burn.

Has some utility TBD.

Semi-fungible ERC1155 (each axe may have different durability).

## Build

### requirements
- forge https://github.com/gakonst/foundry/tree/master/forge
- npm

### how to

`npm i` install npm dependencies

`forge build` run build

`forge test` run tests