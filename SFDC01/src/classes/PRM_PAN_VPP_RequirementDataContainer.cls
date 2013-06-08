/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     	DESCRIPTION                               
 |  ====            =========       ======     	===========  
 |  02.9.2012       Anand Sharma                Data container for Pan Records: Requirements
+=========================================================================================================================*/
public class PRM_PAN_VPP_RequirementDataContainer {
    public String RequirementName {get; set;}
    public String SubRequirementName {get; set;}
    public Boolean IsHeader {get; set;}
    public List<PRM_PAN_VPP_BlockResultDataContainer> BlockResult {get; set;}
}