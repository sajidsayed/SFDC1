/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 30-July-09  Deepak Kapoor               Delete_Recordstatus will be used to send the status back of the
                                     deleted installbase object record.                
 | 
   4 June 10  Arif                    Adding this class in new package
 |                                 
 +===========================================================================*/
global class Delete_Record_Status{

    webservice String id; // SFDC ID of record
    webservice boolean isSucess; // Deletion Success
    webservice String keycol;
    webservice String errorDescription;

    public void setId(String ids){
        id=ids;
    }

    public void setIssucess(boolean issuc){
        issucess=issuc;
    }

    public String getId(){
        return this.id;
    }

    public boolean getIssucess(){
        return this.Issucess;
    }
       public void setKeycol(String ids){
        this.keycol=ids;
    }

    public String getKeycol(){
        return this.keycol;
    }
    public String getErrorDescription(){
        return this.errorDescription;
    }
    public void setErrorDescription(String description){
        this.errorDescription=description;
    }




}