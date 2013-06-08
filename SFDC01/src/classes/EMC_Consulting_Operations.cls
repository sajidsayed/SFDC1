/*==========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  14.01.2013      Anirudh Singh  219167       This class will be used to prcess the detailed product depending upon the
 |                                              trigger invokation.     
 +==============================================================================================================================*/
 
public class EMC_Consulting_Operations {
/*@Method <This method will be used to calculate the Total Competency($) value>
@param <This method takes list<Detailed_Product__c> from BeforeUpdateInsertDetailedProduct Trigger>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/
    public void calculateTotalCompetency(List<Detailed_Product__c> lstDetailedProduct)
    {
        for (Detailed_Product__c detailProdObj :lstDetailedProduct){                          
             if(detailProdObj.Sub_Practice_1_Dollar__c !=null){
                detailProdObj.Total_Competency__c = detailProdObj.Sub_Practice_1_Dollar__c;
                detailProdObj.Is_Total_Competency_Updated__c = true;
             }
             if(detailProdObj.Sub_Practice_1_Dollar__c ==null ){
                detailProdObj.Total_Competency__c = null;
                detailProdObj.Is_Total_Competency_Updated__c = false;
             }
             if(detailProdObj.Sub_Practice_2_Dollar__c !=null){
                if(detailProdObj.Total_Competency__c == null  ){
                   detailProdObj.Total_Competency__c =  detailProdObj.Sub_Practice_2_Dollar__c; 
                } 
                else if(detailProdObj.Total_Competency__c !=null){
                    detailProdObj.Total_Competency__c +=  detailProdObj.Sub_Practice_2_Dollar__c;
                }                  
                detailProdObj.Is_Total_Competency_Updated__c = true;
             }
             if(detailProdObj.Sub_Practice_2_Dollar__c ==null ){
                detailProdObj.Total_Competency__c = detailProdObj.Total_Competency__c;                
             }
             if(detailProdObj.Sub_Practice_3_Dollar__c !=null){
                 if(detailProdObj.Total_Competency__c == null  ){
                   detailProdObj.Total_Competency__c =  detailProdObj.Sub_Practice_3_Dollar__c; 
                }
                else if(detailProdObj.Total_Competency__c !=null){
                    detailProdObj.Total_Competency__c +=  detailProdObj.Sub_Practice_3_Dollar__c;
                }                 
                detailProdObj.Is_Total_Competency_Updated__c = true;
             }
             if(detailProdObj.Sub_Practice_3_Dollar__c ==null ){
                detailProdObj.Total_Competency__c = detailProdObj.Total_Competency__c;                
             }
             if(detailProdObj.Sub_Practice_4_Dollar__c !=null){
                if(detailProdObj.Total_Competency__c == null  ){
                   detailProdObj.Total_Competency__c =  detailProdObj.Sub_Practice_4_Dollar__c; 
                }
               else if(detailProdObj.Total_Competency__c !=null){
                    detailProdObj.Total_Competency__c +=  detailProdObj.Sub_Practice_4_Dollar__c;
                }                 
                detailProdObj.Is_Total_Competency_Updated__c = true;
             }
             if(detailProdObj.Sub_Practice_4_Dollar__c ==null ){
                detailProdObj.Total_Competency__c = detailProdObj.Total_Competency__c;                
             }
             if(detailProdObj.Sub_Practice_5_Dollar__c !=null){
                if(detailProdObj.Total_Competency__c == null  ){
                   detailProdObj.Total_Competency__c =  detailProdObj.Sub_Practice_5_Dollar__c; 
                }
               else if(detailProdObj.Total_Competency__c !=null){
                    detailProdObj.Total_Competency__c +=  detailProdObj.Sub_Practice_5_Dollar__c;
                }                 
                detailProdObj.Is_Total_Competency_Updated__c = true;
             }
             if(detailProdObj.Sub_Practice_5_Dollar__c ==null ){
                detailProdObj.Total_Competency__c = detailProdObj.Total_Competency__c;                
             }
        }
    }
}