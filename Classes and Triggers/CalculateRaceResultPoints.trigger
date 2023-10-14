trigger CalculateRaceResultPoints on Race_Result__c (before insert, before update, before delete) {
    // List to hold Race_Result__c records to update
    List<Race_Result__c> raceResultsToUpdate = new List<Race_Result__c>();
    
    // Iterate through the newly inserted Race_Result__c records
    for (Race_Result__c RaceResult : Trigger.new) {
        // Calculate points using the calculatePoints() method (implement this method)
        Integer points = raceResultTriggerHandler.calculatePoints(RaceResult);
        
        // Update the Points_Earned__c field in the Race_Result__c record
        RaceResult.Points_Earned__c = points;
               
}
}
