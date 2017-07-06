trigger UserTrigger on User (After insert, After Update) {
    if(Trigger.isAfter && Trigger.isInsert){
        UserTriggerHandler triggerHandler = new UserTriggerHandler();
        triggerHandler .createPermissionControls(Trigger.new);
    }
}