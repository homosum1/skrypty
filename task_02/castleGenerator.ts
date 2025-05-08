player.onChat("cas", function () {
    castleWallGeneration()
});


let PlayerDistance = 15

function castleWallGeneration() {
    generateMoat(28, 24);

    // first floor
    floorGeneration(28, 18, -1, COBBLESTONE, { x: 0, y: 0, z: 0 });    
    ringGeneration(24, 10, 4, MANGROVE_WOOD)
    ringGeneration(28, 18, 4, MANGROVE_WOOD)
    floorGeneration(28, 18, 4, PLANKS_DARK_OAK, { x: 0, y: 0, z: 0 });

    floorGeneration(22, 8, 4, AIR, { x: 1, y: 0, z: 0 });

    // second floor
    PlayerDistance = 11

    ringGeneration(24, 10, 5, MANGROVE_WOOD)
    ringGeneration(28, 18, 5, MANGROVE_WOOD)

    floorGeneration(28, 18, 4, PLANKS_DARK_OAK, { x: 0, y: 0, z: 0 });
    floorGeneration(22, 8, 4, AIR, { x: 1, y: 0, z: 0 });

    generateGate(GLOWSTONE);
    generateBridge(PLANKS_SPRUCE, OAK_FENCE);

    // finishing
    PlayerDistance = 7
    ringGeneration(24, 10, 2, LOG_OAK)
    ringGeneration(28, 18, 2, LOG_OAK)
    generateStaircase();

    // towers
    generateTower(4, -8, 8, 2, PLANKS_OAK);     
    generateTower(27, -8, 8, 2, PLANKS_OAK);
    generateTower(4, 7, 8, 2, PLANKS_OAK);
    generateTower(27, 7, 8, 2, PLANKS_OAK);

}

function generateStaircase() {
    const startX = 2 + 14;
    const startY = -PlayerDistance - 4 - 4; 
    const startZ = -1;
    const height = 9;

    for (let i = 0; i < height; i++) {
        const x = startX + i;
        const y = startY + i;

        blocks.place(STONE_BRICK_STAIRS, positions.create(x, y, startZ));
        blocks.place(STONE_BRICK_STAIRS, positions.create(x, y, startZ+1));

        blocks.place(LOG_OAK, positions.create(x, y, startZ - 1));
        blocks.place(LOG_OAK, positions.create(x, y, startZ + 2));

    }

    const doorX = startX + height;
    const doorY = startY + height;

    blocks.place(OAK_DOOR, positions.create(doorX, doorY, startZ));
    blocks.place(OAK_DOOR, positions.create(doorX, doorY, startZ + 1));
}


function generateMoat(castleWidth: number, castleDepth: number) {
    const moatThickness = 2;

    const startX = 2 - moatThickness;
    const endX = 1 + castleWidth + moatThickness;

    const startZ = -Math.floor(castleDepth / 2) - moatThickness;
    const endZ = Math.floor(castleDepth / 2) + moatThickness;

    const Yposition = -PlayerDistance - 3;
    const waterY = Yposition + 1;

    for (let x = startX; x <= endX; x++) {
        for (let z = startZ; z <= endZ; z++) {
            const inXRange = x >= 2 && x <= 2 + castleWidth - 1;
            const inZRange = z >= -Math.floor(castleDepth / 2) && z <= Math.floor(castleDepth / 2);

            const isOuterRing = !(inXRange && inZRange);

            if (isOuterRing) {
                blocks.place(AIR, pos(x, Yposition, z));
                blocks.place(AIR, pos(x, Yposition + 1, z));
                blocks.place(WATER, pos(x, waterY, z));
            }
        }
    }
}


function generateGate(
    material: any
) {
    const gateX = 2
    const height = 5
    const width = 4

    const y_offset = 4

    const startZ = - Math.floor(width / 2) - 1;
    const endZ = Math.floor(width / 2);

    for (let z = startZ; z <= endZ; z++) {
        for (let y = 0; y < height; y++) {
            blocks.place(AIR, pos(gateX, y - PlayerDistance - y_offset, z));
        }
    }

    for (let z = startZ; z <= endZ; z++) {
        for (let y = 0; y < height; y++) {
            const isEdgeZ = z === startZ || z === endZ;
            const isEdgeY = y === 0 || y === height - 1;
            const isBottom = y === 0;
            const isSide = isEdgeZ;
            const isMiddleBottom = isBottom && !isSide;

            if (!isMiddleBottom && (isEdgeY || isEdgeZ)) {
                blocks.place(IRON_BARS, pos(gateX, y - PlayerDistance - y_offset, z));
            }
        }
    }

    blocks.place(material, pos(gateX, height - PlayerDistance - y_offset, startZ - 1));
    blocks.place(material, pos(gateX, height - PlayerDistance - y_offset, endZ + 1));
}

function generateBridge(material: any, fenceMaterial: any) {
    const width = 2;
    const length = 6;
    const startX = 2;

    const y_offset = 5 ;

    const startZ = -Math.floor(width / 2) - 1;
    const endZ = Math.floor(width / 2);
    const baseY = -PlayerDistance - y_offset;

    for (let z = startZ; z <= endZ; z++) {
        for (let l = 1; l <= length; l++) {
            const x = startX - l;

            blocks.place(material, pos(x, baseY, z));
            blocks.place(fenceMaterial, pos(x, baseY + 1, startZ ));
            blocks.place(fenceMaterial, pos(x, baseY + 1, endZ ));
        }
    }
}

function generateTower(
    baseX: number,
    baseZ: number,
    height: number,
    radius: number,
    blockType: any
) {
    // core
    for (let x = -radius; x <= radius; x++) {
        for (let z = -radius; z <= radius; z++) {
            const isEdge =
                x === -radius || x === radius ||
                z === -radius || z === radius;

            if (isEdge) {
                for (let y = 0; y < height; y++) {
                    blocks.place(blockType, pos(baseX + x, y - PlayerDistance, baseZ + z));
                }
            }
        }
    }

    // windows
    const windowY = Math.floor(height / 2) - 1;

    blocks.place(AIR, pos(baseX, windowY - PlayerDistance, baseZ - radius));
    blocks.place(OAK_FENCE, pos(baseX, windowY + 1 - PlayerDistance, baseZ - radius));
    blocks.place(AIR, pos(baseX, windowY + 2 - PlayerDistance, baseZ - radius));

    blocks.place(AIR, pos(baseX, windowY - PlayerDistance, baseZ + radius));
    blocks.place(OAK_FENCE, pos(baseX, windowY + 1 - PlayerDistance, baseZ + radius));
    blocks.place(AIR, pos(baseX, windowY + 2 - PlayerDistance, baseZ + radius));

    blocks.place(AIR, pos(baseX - radius, windowY - PlayerDistance, baseZ));
    blocks.place(OAK_FENCE, pos(baseX - radius, windowY + 1 - PlayerDistance, baseZ));
    blocks.place(AIR, pos(baseX - radius, windowY + 2 - PlayerDistance, baseZ));

    blocks.place(AIR, pos(baseX + radius, windowY - PlayerDistance, baseZ));
    blocks.place(OAK_FENCE, pos(baseX + radius, windowY + 1 - PlayerDistance, baseZ));
    blocks.place(AIR, pos(baseX + radius, windowY + 2 - PlayerDistance, baseZ));

    // finishing
    const topY = height - PlayerDistance;

    blocks.place(blockType, pos(baseX - radius, topY, baseZ - radius));
    blocks.place(blockType, pos(baseX + radius, topY, baseZ - radius));
    blocks.place(blockType, pos(baseX - radius, topY, baseZ + radius));
    blocks.place(blockType, pos(baseX + radius, topY, baseZ + radius));
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