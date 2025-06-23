import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Despliega el contrato "TokenA" usando la cuenta deployer.
 *
 * @param hre HardhatRuntimeEnvironment
 */
const deployTokenA: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts(); // Cuenta deployer configurada en hardhat.config.ts
  const { deploy } = hre.deployments;

  // Despliega el contrato TokenA
  const tokenADeployment = await deploy("TokenA", {
    from: deployer,
    args: [], // El constructor no requiere argumentos
    log: true,
    autoMine: true, // Facilita el minado automático en redes locales
  });

  console.log(`🚀 TokenA desplegado en: ${tokenADeployment.address}`);
};

export default deployTokenA;

deployTokenA.tags = ["TokenA"];
