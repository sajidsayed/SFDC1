/*=====================================================================================================================================

History 
30th Jul 12  Kaustav Debnath    Initial creation for Partner Info WS integration between eBusiness and SFDC
                                along with the location updates upon account updates of eBiz lead admin                                 

======================================================================================================================================*/
global class PartnerInfoHeader {
    webservice string text_field01 {get; set;}                  //used for eBusiness SFDC integration partner account sfdc 18 digit id
    webservice string text_field02{get; set;}                   //used for eBusiness SFDC integration partner account name
    webservice string text_field03{get; set;}                   //used for eBusiness SFDC integration partner account partnership overview
    webservice string text_field04{get; set;}                   //used for eBusiness SFDC integration company description
    webservice string text_field05{get; set;}                   //used for eBusiness SFDC integration account lead admin email
    webservice string text_field06{get; set;}                   //used for eBusiness SFDC integration account business focus
    webservice string text_field07{get; set;}                   //used for eBusiness SFDC integration account industry verticals
    webservice string text_field08{get; set;}                   //used for eBusiness SFDC integration account product focus
    webservice string text_field09{get; set;}                   //used for eBusiness SFDC integration account eBusiness enabled
    webservice string text_field10{get; set;}                   //used for eBusiness SFDC integration Integration Log record sfdc 18 digit id
    webservice blob blob_field01{get; set;}                     //used for eBusiness SFDC integration company logo
    webservice List<LocationHeader> locationHeaderObj {get;set;}//used for eBusiness SFDC integration location header 
    webservice boolean queryMore{get; set;}                     // set to true if more rows to fetch otherwise false 
   
}