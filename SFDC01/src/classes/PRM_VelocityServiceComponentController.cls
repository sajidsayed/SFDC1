/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  06/03/2012    Suman B                           Controller for Velocity Service Component.
 |  20-Jul-2012     Anand Sharma                     Distributor profile ID, the Revenue fields will be displayed as blank to that user profile     
 +=======================================================================================================*/

public class PRM_VelocityServiceComponentController {

    public List<Velocity_Rule_Results__c> SpecialityList = new List<Velocity_Rule_Results__c>();
    public boolean ServiceResourceLabel;
    public List<Velocity_Rule_Results__c> getSpecialityList() {
        return SpecialityList;
    }
    
    public void setSpecialityList(List<Velocity_Rule_Results__c> SpecialityList) {
        this.SpecialityList=SpecialityList;
    }

    public boolean getServiceResourceLabel() {
        return ServiceResourceLabel;
    }
    
    public void setServiceResourceLabel(boolean ServiceResourceLabel) {
        this.ServiceResourceLabel = ServiceResourceLabel;
    }
    
    public Boolean isRevenueVisible {public get; public set;}

}