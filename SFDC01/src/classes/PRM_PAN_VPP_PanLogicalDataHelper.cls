/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     	DESCRIPTION                               
 |  ====            =========       ======     	===========  
 |  02.9.2012       Anand Sharma                Data container for Pan Records
+=========================================================================================================================*/
public class PRM_PAN_VPP_PanLogicalDataHelper {
    public String Level {get; set;}
    public String CurrentTargetTier {get; set;}
    public String CurrentLogicalBlock {get; set;}
    public String CurrentTheater {get; set;}
    public List<PRM_PAN_VPP_RequirementDataContainer> lstRequirementResults {get; set;} 
}