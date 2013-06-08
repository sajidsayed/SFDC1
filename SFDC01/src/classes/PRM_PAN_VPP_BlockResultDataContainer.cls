/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     	DESCRIPTION                               
 |  ====            =========       ======     	===========  
 |  02.9.2012       Anand Sharma                Data container for Pan Records: Block 
+=========================================================================================================================*/
public class PRM_PAN_VPP_BlockResultDataContainer {
    public String BlockName {get; set;}
    public String BlockDisplayName {get; set;}
    public String Status {get; set;}
    public String HeaderStatus {get; set;}
    public Boolean isVelocityResult {get; set;}
    public List<Velocity_Rule_Results__c> Result {get; set;}
}