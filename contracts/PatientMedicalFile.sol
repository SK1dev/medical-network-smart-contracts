//SPDX-License-Identifier:UNLICIENSED
pragma solidity ^0.8.9;

contract PatientMedicalFile {
    
    struct Records{
        string hospital_name;
        string reason;
        string admittedOn;
        string dischargedOn;
        string ipfs;
    }
    
    struct Patient{
        uint256 id;
        string name;
        string phone;
        string gender;
        string dob;
        string bloodgroup;
        string allergies;
        Records[]  records;
        address addr;
    }
    
    uint256 public patient_index = 0;
    
    address[] private patientList;
    mapping(address => mapping(address=>bool)) isAuth;
    mapping(address => Patient) patients;
    mapping(address => bool) isPatient;

    function addPatient(
        string memory _name,
        string memory _phone,
        string memory _gender,
        string memory _dob,
        string memory _bloodgroup,
        string memory _allergies) public {
        require(!isPatient[msg.sender],"Patient account already exists");
        patientList.push(msg.sender);
        patient_index = patient_index + 1;
        isPatient[msg.sender]=true;
        isAuth[msg.sender][msg.sender]=true;
        patients[msg.sender].id=patient_index;
        patients[msg.sender].name=_name;
        patients[msg.sender].phone=_phone;
        patients[msg.sender].gender=_gender;
        patients[msg.sender].dob=_dob;
        patients[msg.sender].bloodgroup=_bloodgroup;
        patients[msg.sender].allergies=_allergies;
        patients[msg.sender].addr=msg.sender;
    }

    function addRecord(
        address _addr,
        string memory _hname,
        string memory _reason,
        string memory _admittedOn,
        string memory _dischargedOn,
        string memory _ipfs
        ) public{
        require(isPatient[_addr],"User is not registered");
        require(isAuth[_addr][msg.sender],"No permission to add Records");
        patients[_addr].records.push(Records(_hname,_reason,_admittedOn,_dischargedOn,_ipfs));
        
    }

    //Get patient details - only by the patient and authorised doctor
    function getPatientDetails(address _addr) public view returns(
        string memory _name,
        string memory _phone,
        string memory _gender,
        string memory _dob,
        string memory _bloodgroup,
        string memory _allergies
        ){
        require(isAuth[_addr][msg.sender],"No permission to get records");
        require(isPatient[_addr],"No patients found at the given address");
        Patient memory tmp = patients[_addr];
        return (tmp.name,tmp.phone,tmp.gender,tmp.dob,tmp.bloodgroup,tmp.allergies);
    }


    //Get patient records - only by the patient and authorised doctor
    function getPatientRecords(address _addr) public view returns(
        string[] memory _hname,
        string[] memory _reason,
        string[] memory _admittedOn,
        string[] memory _dischargedOn,
        string[] memory ipfs
        ){
        require(isAuth[_addr][msg.sender],"No permission to get records");
        require(isPatient[_addr],"Patient not signed in to our network");
        require(patients[_addr].records.length>0,"Patient record doesn't exist");
        string[] memory Hname = new string[](patients[_addr].records.length);
        string[] memory Reason = new string[](patients[_addr].records.length);
        string[] memory AdmOn = new string[](patients[_addr].records.length);
        string[] memory DisOn = new string[](patients[_addr].records.length);
        string[] memory IPFS = new string[](patients[_addr].records.length);
        for(uint256 i=0;i<patients[_addr].records.length;i++){
            Hname[i]=patients[_addr].records[i].hospital_name;
            Reason[i]=patients[_addr].records[i].reason;
            AdmOn[i]=patients[_addr].records[i].admittedOn;
            DisOn[i]=patients[_addr].records[i].dischargedOn;
            IPFS[i]=patients[_addr].records[i].ipfs;
        }
        return(Hname,Reason,AdmOn,DisOn,IPFS);
    }

    //Add authorisation based on address
    function addAuth(address _addr) public returns(bool success){
        require(!isAuth[msg.sender][_addr],"Already authorised.");
        require(msg.sender != _addr,"Can't add yourself");
        isAuth[msg.sender][_addr] = true;
        return true;
    }
    
    //Revoke authorisation  based on address
    function revokeAuth(address _addr) public returns(bool success) {
        require(msg.sender!=_addr,"Cant remove yourself");
        require(isAuth[msg.sender][_addr],"Already Not Authorised");
        isAuth[msg.sender][_addr] = false;
        return true;
    }
    
    //Add authorisation from both address sides 
    function addAuthFromTo(address _from,address _to) public returns(bool success) {
        require(!isAuth[_from][_to],"Already Auth!");
        require(_from!=_to,"Cannot add same person");
        require(isAuth[_from][msg.sender],"You don't have permission to access");
        require(isPatient[_from],"User Not Registered yet");
        isAuth[_from][_to] = true;
        return true;
    }
    
    //Revoke authorisation from both address sides 
    function removeAuthFromTo(address _from,address _to) public returns(bool success) {
        require(isAuth[_from][_to],"Already No Auth!");
        require(_from!=_to,"Cannot remove same person");
        require(isAuth[_from][msg.sender],"You do not have permission to access");
        require(isPatient[_from],"User not registered yet");
        isAuth[_from][_to] = false;
        return true;
    }
}
    