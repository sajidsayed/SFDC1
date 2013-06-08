@istest
public class PRM_AssignOwnershipToDistributionVAR_TC{

    public static testmethod void method(){
    
    PRM_AssignOwnershipToDistributionVAR obj1=new PRM_AssignOwnershipToDistributionVAR();
    obj1.reassignOwner();
    obj1.cancel();
    obj1.getuserDetails();
    obj1.runsortAction();
    // obj1.sortListUsers();
    }
    
}