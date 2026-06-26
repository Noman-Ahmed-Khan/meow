/**
 * Trigger for the Account object.
 * Delegates all logic to AccountTriggerHandler.
 */
trigger AccountTrigger on Account(after insert) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }
}
