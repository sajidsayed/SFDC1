/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  21/01/2011    Ashwini Gowda                     Controller for Velocity Component. 
 |  20-Jul-2012     Anand Sharma                     Distributor profile ID, the Revenue fields will be displayed as blank to that user profile   
 +=======================================================================================================*/
public class PRM_VPP_VelocityComponentController {
    
    public String Speciality {public get; public set;}
    public List<Velocity_Rule_Results__c> SpecialityList = new List<Velocity_Rule_Results__c>();
    public List<Velocity_Rule_Results__c> getSpecialityList() {
        return SpecialityList;
    }
    
    public void setSpecialityList(List<Velocity_Rule_Results__c> SpecialityList) {
        this.SpecialityList=SpecialityList;
    }
    public Boolean isRevenueVisible {public get; public set;}
    public String specialityComplianceStatus {public get; public set;}
    public String emcSpecialityStatus {public get; public set;}
  
}