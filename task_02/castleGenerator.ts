player.onChat("cas", function () {
    castleWallGeneration()
});


let PlayerDistance = 15

function castleWallGeneration() {

    // first floor
    floorGeneration(28, 18, -1, COBBLESTONE, { x: 0, y: 0, z: 0 });
    // ringGeneration(24, 10, 4, MANGROVE_WOOD)
    // ringGeneration(28, 18, 4, MANGROVE_WOOD)
    // floorGeneration(28, 18, 4, PLANKS_DARK_OAK, { x: 0, y: 0, z: 0 });

    // floorGeneration(22, 8, 4, AIR, { x: 1, y: 0, z: 0 });

    // second floor
    // PlayerDistance = 11

    // ringGeneration(24, 10, 5, MANGROVE_WOOD)
    // ringGeneration(28, 18, 5, MANGROVE_WOOD)

    // floorGeneration(28, 18, 4, PLANKS_DARK_OAK, { x: 0, y: 0, z: 0 });
    // floorGeneration(22, 8, 4, AIR, { x: 1, y: 0, z: 0 });



    // finishing

    PlayerDistance = 7
    ringGeneration(24, 10, 2, LOG_OAK)
    ringGeneration(28, 18, 2, LOG_OAK)

    // towers
    generateTower(4, -8, 10, 2, BIRCH_WOOD);     
    // generateTower(-2 + 27, -9, 8, 2, BIRCH_WOOD);
    // generateTower(-2, 9, 8, 2, BIRCH_WOOD);
    // generateTower(-2 + 27, 9, 8, 2, BIRCH_WOOD);

}


function generateTower(
    baseX: number,
    baseZ: number,
    height: number,
    radius: number,
    blockType: any
) {
    for (let x = -radius; x <= radius; x++) {
        for (let z = -radius; z <= radius; z++) {
            for (let y = 0; y < height; y++) {
                blocks.place(blockType, pos(baseX + x, y - PlayerDistance, baseZ + z));
            }
        }
    }
}


function floorGeneration(
    X_size: number,
    Y_size: number,
    floorY: number,
    floorType: any,
    offset: any
) {
    const start = pos(
        2 + offset.x, 
        floorY - PlayerDistance,
        -Y_size / 2 - 1
    );

    const end = pos(
        1 + X_size + offset.x,
        floorY - PlayerDistance,
        Y_size / 2
    );

    blocks.fill(floorType, start, end);
}


function ringGeneration(
    X_size: number,
    Y_size: number,
    height: number,
    material: any
) {
    verticalWallGeneration(X_size, Y_size, height, Y_size / 2, material)
    verticalWallGeneration(X_size, Y_size, height, -1 * (Y_size / 2 + 1), material)

    horizontalWallGeneration(X_size, Y_size, height, 2, material);
    horizontalWallGeneration(X_size, Y_size, height, 1 + X_size, material);
}

function verticalWallGeneration(
    X_size: number,
    Y_size: number,
    height: number,
    offset: number,
    material: any
) {
    for (let x = 0; x < X_size; x++) {
        for (let y = 0; y < height; y++) {
            blocks.place(material, pos(x + 2, y - PlayerDistance, offset));
        }
    }
}

function horizontalWallGeneration(
    X_size: number,
    Y_size: number,
    height: number,
    offsetX: number,
    material: any
) {
    for (let z = 0; z < Y_size; z++) {
        for (let y = 0; y < height; y++) {
            blocks.place(material, pos(offsetX, y - PlayerDistance, z - (Y_size / 2)));
        }
    }
}