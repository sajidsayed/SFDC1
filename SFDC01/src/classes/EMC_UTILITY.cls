public class EMC_UTILITY {

    // utility function that will convert a collection of strings into a character delimited string.
    public static String ListAsString(List <String> collection, String seperator) {
        String returnVal = '';
        
        if (collection != null) {
            if (collection.size() > 0) {
                for (String value : collection) {
                    returnVal += value + seperator + ' ';
                }
                returnVal = returnVal.substring(0, (returnVal.length() - 2));       
            }
        }
        return returnVal; 
    }
    
    //@ future
    public static void logErrors(List <EMCException> errs) {
        
        // declare local vars
        List <EMC_Exception__c> errorsToInsert = new List <EMC_Exception__c>();
        
        for (EMCException err : errs) {
            errorsToInsert.add(
                new EMC_Exception__c(Process_Id__c = err.ProcessId, 
                    Affected_Records__c = ListAsString(err.AffectedRecords, ';'),  
                    Messages__c = err.getMessage()));
        }
        insert errorsToInsert;  
    }

    // utility function to generate a random integer of a specified length
    public static Integer generateRandomInt(Integer numDigits) {
        Integer num = (Math.random() * Math.pow(10, numDigits)).intValue();
        System.debug('Random Num: ' + num); 
        return num;
    }
    
    // utility function to generate a random string of a specified length
    public static String generateRandomString(Integer numChars) {
        
        //declare local vars
        String randomNumString = '';
        String returnVal = '';
        List <String> charArray = new String [] {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','-','$','#','!','@','+','=','%'};
        
        // determine how many random number strings we need 
        System.debug('Number of requested characters: ' + numChars);
        
        // generate the requisite random number strings
        for (Integer x = 0; x < 100; x++) {
            // generate a random number
            String tempStr = String.valueOf(Math.random());
            System.debug('Generated random number string: ' + tempStr);
            
            // take all of the digits to the right of the decimal point
            randomNumString += tempStr.substring(2);
            //System.debug('Running random number string: ' + randomNumString);
             
            // determine if we have enough characters
            if (randomNumString.length() >= numChars) {
                System.debug('Number string has ' + randomNumString.length() + ' chars and is long enough');
                x = 101;
            }
        }
        // trim the string if we ran over
        if (randomNumString.length() > numChars) {
            System.debug('Generated string is too long.  Trimming...');
            randomNumString = randomNumString.substring(0,numChars);
            System.debug('Trimming complete.  Requested Length: ' + numChars + '; Actual Length: ' + randomNumString.length());
            System.debug('Final Random Number String: ' + randomNumString);
        }
        
        // build the random character string
        for (Integer x = 0; x < randomNumString.length(); x++) {
        
            // declare local vars
            String currentNum = '';
            String newChar = '';
            String randomNum = String.valueOf(Math.random());
            Integer ndxMultiplier = 0;
        
            // get a handle on the current character
            currentNum = randomNumString.substring(x,x+1);
            //System.debug('Current number char is: ' + currentNum);
            
            // get the multiplier from the new random number string
            for (Integer y = 2; y < randomNum.length(); y++) {
                ndxMultiplier = Integer.valueOf(randomNum.substring(y,y+1));
                if (ndxMultiplier < 8) {
                    newChar = charArray[ndxMultiplier * Integer.valueOf(currentNum)];
                    y = randomNum.length();
                }
            }
            returnVal += newChar; 
        }
        System.debug('Generated Random String: ' + returnVal);
        
        // return the random character string
        return returnVal;
    }
  
}