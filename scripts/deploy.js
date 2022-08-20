const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const DoctorsNetwork = await hre.ethers.getContractFactory("DoctorsNetwork");
  const doctorsNetwork = await DoctorsNetwork.deploy();

  const PatientMedicalFile = await hre.ethers.getContractFactory("PatientMedicalFile");
  const patientMedicalFile = await PatientMedicalFile.deploy();

  await doctorsNetwork.deployed();
  console.log("doctorsNetwork deployed to:", doctorsNetwork.address);

  await patientMedicalFile.deployed();
  console.log("patientMedicalFile deployed to:", patientMedicalFile.address);

  fs.writeFileSync('./config.js', `
  export const docNetAddress = "${doctorsNetwork.address}"
  export const ptMedAddress = "${patientMedicalFile.address}"
  `)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });