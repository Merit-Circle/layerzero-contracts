const setTrustedRemote = require("./setTrustedRemote")
const setMinDstGas = require("./setMinDstGas")
const setCustomAdapterParams = require("./setCustomAdapterParams")

module.exports = async function ({ localContract, remoteContract, targetNetwork, minGas: minDstGas }, hre) {
    let minGas = minDstGas
    if (!minGas) {
        if (TOKEN_CONFIG[targetNetwork] && TOKEN_CONFIG[targetNetwork][remoteContract] && TOKEN_CONFIG[targetNetwork][remoteContract].minGas) {
            minGas = TOKEN_CONFIG[targetNetwork][remoteContract].minGas
        } else {
            minGas = targetNetwork.startsWith("beam") ? 10000000 : 100000
        }
    }

    console.log("\nsetting trusted remote...\n")
    await setTrustedRemote(
        {
            localContract,
            remoteContract,
            targetNetwork,
        },
        hre
    )

    console.log("\nsetting min gas...\n")
    await setMinDstGas(
        {
            contract: localContract,
            packetType: 0,
            targetNetwork,
            minGas,
        },
        hre
    )

    await setMinDstGas(
        {
            contract: localContract,
            packetType: 1,
            targetNetwork,
            minGas,
        },
        hre
    )

    console.log("\nsetting custom adapter params...\n")
    await setCustomAdapterParams(
        {
            contract: localContract,
        },
        hre
    )
}
