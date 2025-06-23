import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys the SimpleDEX contract using the deployer account and
 * constructor arguments set to the token addresses
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deploySimpleDEX: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Direcciones de los tokens A y B (debes proporcionar las direcciones de estos tokens en la red)
  const tokenAAddress = "0xD8C3034cb722Abf2F5b27486563008A22E2aCC15"; // Dirección de Token A
  const tokenBAddress = "0xC359ea8ebAB26c6eB4Eb8f554D1621Ab6bBb8f7C"; // Dirección de Token B

  // Desplegar el contrato SimpleDEX
  await deploy("SimpleDEX", {
    from: deployer,
    args: [tokenAAddress, tokenBAddress], // Argumentos del constructor (direcciones de los tokens)
    log: true,
    autoMine: true, // Opcional: hace que el despliegue sea más rápido en redes locales
  });

  // Obtener la instancia del contrato desplegado
  const simpleDEX = await hre.ethers.getContract<Contract>("SimpleDEX", deployer);
  console.log("👋 SimpleDEX contract deployed at:", simpleDEX.address);
};

export default deploySimpleDEX;

// Tags para ejecutar este despliegue en particular
deploySimpleDEX.tags = ["SimpleDEX"];
