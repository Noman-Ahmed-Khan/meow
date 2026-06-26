/**
 * Handles Account trigger logic.
 * On after insert, creates one related Contact, Opportunity, and Case per Account.
 */
public with sharing class AccountTriggerHandler {

    /**
     * Executes after-insert logic for a list of new Accounts.
     * Creates one Contact, one Opportunity, and one Case per Account in bulk.
     *
     * @param newAccounts List of newly inserted Account records
     */
    public void onAfterInsert(List<Account> newAccounts) {
        if (newAccounts == null || newAccounts.isEmpty()) {
            return;
        }

        List<Contact> contactsToInsert = new List<Contact>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        List<Case> casesToInsert = new List<Case>();

        for (Account account : newAccounts) {
            contactsToInsert.add(buildContact(account));
            opportunitiesToInsert.add(buildOpportunity(account));
            casesToInsert.add(buildCase(account));
        }

        insertRecords(contactsToInsert, 'Contact');
        insertRecords(opportunitiesToInsert, 'Opportunity');
        insertRecords(casesToInsert, 'Case');
    }

    // ─── Private helpers ─────────────────────────────────────────────────────

    private Contact buildContact(Account account) {
        return new Contact(
            LastName = account.Name,
            AccountId = account.Id
        );
    }

    private Opportunity buildOpportunity(Account account) {
        return new Opportunity(
            Name = account.Name + ' - Opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
    }

    private Case buildCase(Account account) {
        return new Case(
            Subject = account.Name + ' - Case',
            AccountId = account.Id,
            Status = 'New',
            Origin = 'Web'
        );
    }

    /**
     * Performs a  DML insert and logs any per-record failures.
     *
     * @param records List of SObjects to 
     * @param objectLabel Label used in error messages for identification
     */
    private void insertRecords(List<SObject> records, String objectLabel) {
        if (records.isEmpty()) {
            return;
        }

        List<Database.SaveResult> results = Database.insert(records, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error error : results[i].getErrors()) {
                    System.debug(
                        LoggingLevel.ERROR,
                        objectLabel + ' insert failed for index ' + i + ': ' + error.getMessage()
                    );
                }
            }
        }
    }
}
