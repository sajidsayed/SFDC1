/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  02.9.2012      Anand Sharma               Controller for the PRM_PAN_VPP_Specilaity Component page.
+=========================================================================================================================*/
public class PRM_PAN_VPP_SpecialtyComponentController {

    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainer {get; set;}    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainerSingle {get; set;}
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> objPanLogicalContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
    public PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalContainerSingle {get; set;}    
    public Integer intBlockSize {get; set;}
    
    public PRM_PAN_VPP_SpecialtyComponentController(){
        //intBlockSize = 0;
        //objPanLogicalContainer= new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        objPanLogicalContainerSingle= new PRM_PAN_VPP_PanLogicalDataHelper();
        System.Debug('i m in');
        lstPanLogicalContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>(); 
        lstPanLogicalContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();      
        System.Debug('i m in objPanLogicalContainer '+ objPanLogicalContainer);
          
    }
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> getPanLogicalContainer(){
        lstPanLogicalContainer.clear();
        System.Debug('i m in objPanLogicalContainer get '+ objPanLogicalContainer);
        lstPanLogicalContainer = objPanLogicalContainer;
        //System.Debug('i m in lstPanLogicalContainer ' + lstPanLogicalContainer.size());
        return lstPanLogicalContainer;                
    }
    public List<PRM_PAN_VPP_PanLogicalDataHelper> getPanLogicalContainerSingle(){
        lstPanLogicalContainerSingle.clear();
        lstPanLogicalContainerSingle.add(objPanLogicalContainerSingle);
        System.Debug('i m in lstPanLogicalContainer ' + lstPanLogicalContainerSingle.size());
        return lstPanLogicalContainerSingle;                
    }
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> getobjPanLogicalContainer() {
        return objPanLogicalContainer;
    }
    
    public void setobjPanLogicalContainer(List<PRM_PAN_VPP_PanLogicalDataHelper> objPanLogicalContainer) {
        this.objPanLogicalContainer=objPanLogicalContainer;
    }
    
    /*
    public Integer getBlockSize(){        
        System.Debug('i m in intBlockSize ' + intBlockSize);
        return intBlockSize;                
    }
    */
}