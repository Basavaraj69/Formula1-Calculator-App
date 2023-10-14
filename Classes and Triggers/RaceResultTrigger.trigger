trigger RaceResultTrigger on Race_Result__c (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // Call the handlerAfterInsert method for new records
            RaceResultTriggerHandler.handlerAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            // Call the handlerAfterUpdate method for updated records
            RaceResultTriggerHandler.handlerAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            // Call the handlerAfterDelete method for deleted records
            RaceResultTriggerHandler.handlerAfterDelete(Trigger.old);
        }
    }
}
