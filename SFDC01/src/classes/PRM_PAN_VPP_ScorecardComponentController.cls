/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  02.9.2012      Anand Sharma               Controller for the PRM_PAN_VPP_Scorecard Component page.
+=========================================================================================================================*/
public class PRM_PAN_VPP_ScorecardComponentController {
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainer {get; set;}
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainerSingle {get; set;}
    
    public PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalContainer {get; set;}
    //public PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalContainerSingle {get; set;}
    
    public PRM_PAN_VPP_ScorecardComponentController(){
        objPanLogicalContainer= new PRM_PAN_VPP_PanLogicalDataHelper();
        //objPanLogicalContainerSingle= new PRM_PAN_VPP_PanLogicalDataHelper();
        System.Debug('i m in');
        lstPanLogicalContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        //lstPanLogicalContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        System.Debug('i m in objPanLogicalContainer '+ objPanLogicalContainer);
        
    }
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> getPanLogicalContainer(){
        lstPanLogicalContainer.clear();
        lstPanLogicalContainer.add(objPanLogicalContainer);
        System.Debug('i m in lstPanLogicalContainer ' + lstPanLogicalContainer.size());
        lstPanLogicalContainerSingle = getSingleDisplayResult(lstPanLogicalContainer);
        return lstPanLogicalContainer;
                
    }
    
    /*public List<PRM_PAN_VPP_PanLogicalDataHelper> getPanLogicalContainerSingle(){
        System.Debug('i m in lstPanLogicalContainerSingle' + lstPanLogicalContainerSingle);
        lstPanLogicalContainerSingle = getSingleDisplayResult(lstPanLogicalContainer);
        return lstPanLogicalContainerSingle;
                
    }
    */
    private List<PRM_PAN_VPP_PanLogicalDataHelper> getSingleDisplayResult(List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainer){
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        PRM_PAN_VPP_BlockResultDataContainer objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
        if(lstPanLogicalContainer.size() >0){
            /**/
            for(PRM_PAN_VPP_PanLogicalDataHelper objSDC: lstPanLogicalContainer){
                objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
                lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
                objTemp.Level = objSDC.Level;
                objTemp.CurrentTargetTier = objSDC.CurrentTargetTier;
                objTemp.CurrentTheater = objSDC.CurrentTheater;
                if(objSDC.lstRequirementResults != null){                               
                    for(PRM_PAN_VPP_RequirementDataContainer objRAD:objSDC.lstRequirementResults){
                        objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
                        objRADTemp.RequirementName = objRAD.RequirementName;
                        lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                        if(objRAD.BlockResult != null){
                            for(PRM_PAN_VPP_BlockResultDataContainer objBRC: objRAD.BlockResult){
                                objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
                                objtempBRC.BlockName = objBRC.BlockName;
                                objtempBRC.BlockDisplayName = objBRC.BlockDisplayName;
                                objtempBRC.HeaderStatus = objBRC.HeaderStatus;
                                objtempBRC.Result = objBRC.Result;
                                lstTempBRC.add(objtempBRC);                     
                            }
                        }
                        objRADTemp.BlockResult = lstTempBRC;
                        lstTemp.add(objRADTemp);
                        break;
                    }
                }
                objTemp.lstRequirementResults = lstTemp;
                lstTempContainerSingle.add(objTemp);
                break;
            }
            
        }
        return lstTempContainerSingle;
    }
}