/*=====================================================================================
Name         WR       Description
Prasad             This trigger is used for Partner Location  Latitude and Longitude
                   Defect Fix. 
Anil Sure    1824    Adjusted the address to fetch the correct longitude and Lattitude 
Arif        178002   Fixed an issue which came across due to Upgrade in Google Map API Version.
=======================================================================================*/
public class PRM_MapLocation {
   @Future(callout=true)
    public static void getLatitudenLongitude(Set<Id> locationIds){
        List<Partner_Location__c> locations= [Select p.Account__c, City__c, 
                    Country__c,Postal_Code__c, State_Province__c, 
                    Street__c, p.Id, p.Latitude__c, p.Longitude__c, 
                    p.Name from Partner_Location__c p  
                    where 
                    Id in :locationIds];
                    
        System.debug('locations '+locations);            
     
        for(Partner_Location__c locs:locations){
              
               System.debug('locs.State_Province__c  '+locs.State_Province__c  );
               String street=locs.Street__c==null?'':locs.Street__c+',';
               System.debug('Street  '+street);   
               String city=locs.City__c==null?'':locs.City__c+',' ;
                System.debug('City  '+city);   
               String state=locs.State_Province__c ==null?'':locs.State_Province__c +' '; 
                System.debug('State  '+state);   
               String PostalCode=locs.Postal_Code__c ==null?'':locs.Postal_Code__c+',';
                System.debug('Postal Code  '+PostalCode);   
               String Country=locs.Country__c==null?'':locs.Country__c;
               String address;
               address= street.trim()+city.trim()+state+PostalCode.trim()+Country.trim();
              /*Added by Anil
              //If address found with '#',remove '#' and updating the address*/
               String pattern= '#';
                 if(address.contains(pattern))
                    {
                     address = address.replaceAll(pattern, '');                     
                 }
               System.debug('address  '+address.trim());             
                 
               Map<String,Double>latlangmap;
               try{
                   integer attempt=0; 
                   while(true){
                       latlangmap = getLatLong(getLocationResponse(address));
                       if(latlangmap.get('lattitude')!=0.0 && latlangmap.get('longitude')!=0.0 ){
                           break;
                       }
                       attempt=attempt+1;
                       if(attempt==1){
                           address=street+','+city+','+state+','+Country;
                       }else if(attempt==2){
                           address=street+','+city+','+Country;
                       }else if(attempt==3){
                           address=street+','+city+','+PostalCode+','+Country;
                       }else{
                           break;
                       }                       
                   }
                   locs.Latitude__c=latlangmap.get('lattitude');
                   locs.Longitude__c=latlangmap.get('longitude');
                   System.debug('lat long '+locs.Latitude__c+'  '+locs.Longitude__c);
               }catch(Exception e){
                    System.debug('Exception occured while fetching lat/long'+e);           
               }
        }
        update locations;
                     
    }
    
    public static String getLocationResponse(String address){
        //String address='"1600 Amphitheatre Parkway, Mountain View, CA"';
        HttpRequest req = new HttpRequest();
        
      //  Map<String,CustomSettingDataValueMap__c> googleMapApi = CustomSettingDataValueMap__c.getall();
      //  String googleMapsGeoKey = googleMapApi.get('GoogleMapGeoCodeAPIKey').DataValue__c;
            
            //Added by Anil
            //Replacing all spaces with '+'
            
               String pattern1 = ' ';
               if(address.contains(pattern1))
                {
                   address = address.trim().replaceAll(pattern1, '+');
               }
               System.debug('address after update ==========>>>> '+address);
		//commented by Arif(178002)
       // req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false&&key='+googleMapsGeoKey);
        req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
        req.setMethod('GET');
        Http h = new Http();
        HTTPResponse res = h.send(req);
        system.debug('res.getBody()-------->' +res.getBody());
        return res.getBody();
    }
    
    public static  Map<String,Double> getLatLong(string jsonResponse){

            Map<String,Double> latlong =new Map<String,Double>();
            
            String pattern1 = '[}]';
            String pattern2 = '["]';
            String pattern3 = '[,]';
            String strippedString;
            strippedString = jsonResponse.replaceAll(pattern1, '');
            strippedString = strippedString.replaceAll(pattern2, '');
            strippedString = strippedString.replaceAll(pattern3, '');
                          
            if(strippedString.indexOf('ZERO_RESULTS')!=-1){
                
                latlong.put('lattitude',0.0);
                latlong.put('longitude',0.0);
            
                return latlong ;
            } 
             
            String s1='geometry';
            String s4='location_type';
            integer geometry_start=strippedString.indexOf(s1);
            integer geometry_end=strippedString.indexOf(s4);
            if(geometry_start != -1 && geometry_end != -1){
	            String geo_occr=strippedString.substring(geometry_start,geometry_end);
	            system.debug('geo_occr-------->' +geo_occr);
	            String s2='lat';
	            String s3='lng';
	            integer lat_occr=geo_occr.indexOf(s2);
	            integer lon_occr=geo_occr.indexOf(s3);
	            String lattitude=geo_occr.substring(lat_occr+5,lon_occr);
	            lattitude = lattitude.replaceAll(' ','');
	            system.debug('lattitude-------->' +lattitude);
	            String longitude=geo_occr.substring(lon_occr+5,lon_occr+20);
	            longitude = longitude.replaceAll(' ','');
	            system.debug('longitude-------->' +longitude);
	            System.debug(lattitude);
	            System.debug(longitude);
	            
	            latlong.put('lattitude',Double.valueOf(lattitude));
	            latlong.put('longitude',Double.valueOf(longitude));
            }else{
            	latlong.put('lattitude',0.0);
	            latlong.put('longitude',0.0);
            }    
            
            return latlong ;
    }
}