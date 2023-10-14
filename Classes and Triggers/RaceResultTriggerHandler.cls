public class RaceResultTriggerHandler {
    public static void handlerAfterInsert(List<Race_Result__c> newRaceResults) {
        List<Driver__c> driversToUpdate = new List<Driver__c>();
        
        // Step 1: Initialize a list to store Driver__c records to be updated
        
        for (Race_Result__c raceResult : newRaceResults) {
            // Step 2: Loop through the newRaceResults
            
            if (raceResult.Driver__c != null) {
                // Step 3: Check if the race result is associated with a driver
                
                // Step 4: Calculate the new points based on the newly inserted race result
                Integer newPoints = calculatePoints(raceResult);
                
                // Step 5: Query the existing Driver record to get the current points
                Driver__c existingDriver = [SELECT Points_Earned__c FROM Driver__c WHERE Id = :raceResult.Driver__c];
                
                // Step 6: Extract the current points from the existing Driver record and convert it to an integer
                Integer currentPoints = existingDriver.Points_Earned__c.intValue();
                
                // Step 7: Add the new points to the existing points to calculate the total points
                Integer totalPoints = currentPoints + newPoints;
                
                // Step 8: Create a new Driver__c object with the updated total points
                Driver__c driver = new Driver__c(Id = raceResult.Driver__c, Points_Earned__c = totalPoints);
                
                // Step 9: Add the updated driver record to the driversToUpdate list
                driversToUpdate.add(driver);
            }
        }
        
        // Step 10: Check if there are any driver records to update
        if (!driversToUpdate.isEmpty()) {
            // Step 11: Perform a bulk update to update the Driver records
            update driversToUpdate;
        }
    }

    public static void handlerAfterUpdate(List<Race_Result__c> newRaceResults, Map<Id, Race_Result__c> oldRaceResultsMap) {
        List<Driver__c> driversToUpdate = new List<Driver__c>();
        
        // Step 1: Initialize a list to store Driver__c records to be updated
        
        for (Race_Result__c raceResult : newRaceResults) {
            // Step 2: Loop through the newRaceResults
            
            if (raceResult.Driver__c != null && oldRaceResultsMap.containsKey(raceResult.Id)) {
                // Step 3: Check if the race result is associated with a driver and if it exists in oldRaceResultsMap
                
                // Step 4: Get the old race result from oldRaceResultsMap
                Race_Result__c oldRaceResult = oldRaceResultsMap.get(raceResult.Id);
                
                // Step 5: Check if relevant fields (Position, Fastest_Lap, DNF) have changed
                if (raceResult.Position__c != oldRaceResult.Position__c ||
                    raceResult.Fastest_Lap__c != oldRaceResult.Fastest_Lap__c ||
                    raceResult.DNF__c != oldRaceResult.DNF__c) {
                        
                        // Step 6: Calculate the new points based on the updated race result
                        Integer newPoints = calculatePoints(raceResult);
                        
                        // Step 7: Calculate the old points based on the old race result
                        Integer oldPoints = calculatePoints(oldRaceResult);
                        
                        // Step 8: Calculate the difference in points
                        Integer pointDifference = newPoints - oldPoints;
                        
                        // Step 9: Query the existing Driver record to get the current points
                        Driver__c existingDriver = [SELECT Points_Earned__c FROM Driver__c WHERE Id = :raceResult.Driver__c];
                        Integer currentPoints = existingDriver.Points_Earned__c.intValue();
                        
                        // Step 10: Calculate the total points based on the point difference
                        Integer totalPoints = currentPoints + pointDifference;
                        
                        // Step 11: Create a new Driver__c object with the updated total points
                        Driver__c driver = new Driver__c(Id = raceResult.Driver__c, Points_Earned__c = totalPoints);
                        
                        // Step 12: Add the updated driver record to the driversToUpdate list
                        driversToUpdate.add(driver);
                    }
            }
        }
        
        // Step 13: Check if there are any driver records to update
        if (!driversToUpdate.isEmpty()) {
            // Step 14: Perform a bulk update to update the Driver records
            update driversToUpdate;
        }
    }

  
    public static void handlerAfterDelete(List<Race_Result__c> deletedRaceResults) {
        // Create a set to store Driver__c record Ids affected by deleted race results
        Set<Id> driverIds = new Set<Id>();
        
        // Create a map to store current points of drivers (Map<Driver Id, Decimal Points>)
        Map<Id, Decimal> driverPointsMap = new Map<Id, Decimal>(); 
        
        // Step 1: Identify driverIds affected by deleted race results
        for (Race_Result__c raceResult : deletedRaceResults) {
            if (raceResult.Driver__c != null) {
                driverIds.add(raceResult.Driver__c);
            }
        }
        
        // Step 2: Query and store current points of affected drivers
        if (!driverIds.isEmpty()) {
            for (Driver__c driver : [SELECT Id, Points_Earned__c FROM Driver__c WHERE Id IN :driverIds]) {
                driverPointsMap.put(driver.Id, driver.Points_Earned__c);
            }

            // Step 3: Iterate through deleted Race_Result__c records
            for (Race_Result__c raceResult : deletedRaceResults) {
                if (raceResult.Driver__c != null && driverPointsMap.containsKey(raceResult.Driver__c)) {
                    // Step 4: Calculate the points to subtract
                    Decimal existingPoints = driverPointsMap.get(raceResult.Driver__c);
                    Decimal subtractedPoints = calculatePoints(raceResult);
                    
                    // Step 5: Subtract points from the existing points
                    Decimal totalPoints = existingPoints - subtractedPoints;
                    
                    // Step 6: Update the Driver__c object with the new points
                    Driver__c driver = new Driver__c(Id = raceResult.Driver__c, Points_Earned__c = totalPoints);
                    driverPointsMap.put(driver.Id, totalPoints);
                }
            }

            // Step 7: Update the Driver records with the modified points
            List<Driver__c> driversToUpdate = new List<Driver__c>();
            for (Id driverId : driverPointsMap.keySet()) {
                driversToUpdate.add(new Driver__c(Id = driverId, Points_Earned__c = driverPointsMap.get(driverId)));
            }
            
            // Step 8: Perform a bulk update to update the Driver records
            if (!driversToUpdate.isEmpty()) {
                update driversToUpdate;
            }
        }
    }
  




    public static Integer calculatePoints(Race_Result__c raceResult) {
        Integer points = 0;
        Integer position = Integer.valueOf(raceResult.Position__c);

        if (position == 1) {
            points = 25;
        } else if (position == 2) {
            points = 18;
        } else if (position == 3) {
            points = 15;
        } else if (position == 4) {
            points = 12;
        } else if (position == 5) {
            points = 10;
        } else if (position == 6) {
            points = 8;
        } else if (position == 7) {
            points = 6;
        } else if (position == 8) {
            points = 4;
        } else if (position == 9) {
            points = 2;
        } else if (position == 10) {
            points = 1;
        }

        if (raceResult.Fastest_Lap__c && position <= 10) {
            points += 1;
        }

        if (raceResult.DNF__c) {
            points = 0;
        }

        return points;
    }

   
}
