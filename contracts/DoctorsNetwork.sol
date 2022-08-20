//SPDX-License-Identifier:UNLICIENSED
pragma solidity ^0.8.9;

contract DoctorsNetwork {

    struct Doctor{
      uint256 id;
      string doc_name;
      string doc_contact;
      string doc_specialisation;
      string doc_address;
      address addr;
      bool isApproved;
    }
   
     struct PatientReport{
         string description;
         string fileUrl;
         address requestedDoctor;
         uint approvalCount;
         mapping(address => bool) approvals;
         bool verified;   
     }
    
     address public admin;
     uint256 public index;
     address[] public doctorList;

     mapping(address=>bool) public network_doctors;
     mapping(address => Doctor) doctors;
     mapping(address => bool) internal isDoctor;

     uint public numPatientReportCount;
     uint public doctorsCount = 0;
     mapping(uint => PatientReport) public patientReports;

     modifier onlyAdmin() {
        require(admin == msg.sender, "Only Admin has permission to do this action.");
        _;
    } 

     modifier authorisedDoctor(){
         require(network_doctors[msg.sender] == true,"Only doctors in the network can perform this action.");
         _;
     }

     modifier onlyDoctor(){
        require(isDoctor[msg.sender] ,"Only Doctors have access.");
        _;
    }

     constructor(){
       admin = msg.sender;
       network_doctors[msg.sender] = true;
       doctorsCount++;
     }

     function setAdmin(address _addr) public onlyAdmin returns(bool success){
        require(msg.sender!= _addr,"Already admin.");
        admin = _addr;
        return true;
    }

     //Doctors to register to the network
     function registerToNetwork() public  returns(bool success){
       require(network_doctors[msg.sender]!= true,"Already registered to network.");
       network_doctors[msg.sender] = true;
       doctorsCount++;
       return true;
     }

     function verifyReport() public authorisedDoctor{
      
       PatientReport storage pr = patientReports[index];

       require(pr.requestedDoctor!= msg.sender,"Cannot verify your own report.");

       pr.approvals[msg.sender] = true;
       pr.approvalCount++;

     } 
     
     function createPatientReport(string memory description,string memory fileLink) public authorisedDoctor {
         PatientReport storage p = patientReports[numPatientReportCount++];
         p.description = description;
         p.fileUrl = fileLink;
         p.verified = false;
         p.approvalCount = 0;
         p.requestedDoctor = msg.sender;

     }

     function finalizeReport() public {
       PatientReport storage pr = patientReports[index];

       require(pr.requestedDoctor == msg.sender,"Only the creator of report can finalise it.");
       require(!pr.verified);
       require(pr.approvalCount > (doctorsCount/2));

       pr.verified = true;
     }

     //Admin to add new doctors
    function addDoctor(
        string memory _doc_name,
        string memory _doc_contact,
        string memory _doc_specialisation,
        string memory _doc_address,
        address _doc_addr
        ) public onlyAdmin returns(bool){
        require(!isDoctor[_doc_addr],"Already a registered Doctor.");
        doctorList.push(_doc_addr);
        index = index + 1;
        isDoctor[_doc_addr] = true;
        doctors[_doc_addr] = Doctor(index,_doc_name,_doc_contact,_doc_specialisation,_doc_address,_doc_addr,true);
        return true;
    }
    
    function getDoctorById(uint256 _id) public view returns(
        uint256 id,
        string memory _doc_name,
        string memory _doc_contact,
        string memory _doc_specialisation,
        string memory _doc_address,
        address _doc_addr,
        bool isVerified
        ){
        uint256 i = 0;
        for(;i<doctorList.length;i++){
            if(doctors[doctorList[i]].id == _id){
                break;
            }
        }
        require(doctors[doctorList[i]].id == _id ,"Doctor ID doesn't exist.");
        Doctor memory temp = doctors[doctorList[i]];
        return(temp.id,temp.doc_name,temp.doc_contact,temp.doc_specialisation,temp.doc_address,temp.addr,temp.isApproved);
    }

    function getDoctorByAddress(address _addr) public view returns(
        uint256 id,
        string memory _doc_name,
        string memory _doc_contact,
        string memory _doc_specialisation,
        string memory _doc_address,
        address _doc_addr,
        bool isVerified){
        require(doctors[_addr].isApproved ,"Doctor is not approved.");
        Doctor memory temp = doctors[_addr];
        return(temp.id,temp.doc_name,temp.doc_contact,temp.doc_specialisation,temp.doc_address,temp.addr,temp.isApproved);
    }
}