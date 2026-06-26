/**
 * Test coverage for AccountTrigger and AccountTriggerHandler.
 * Verifies that inserting Accounts creates related Contact, Opportunity, and Case records.
 */
@IsTest
private class AccountTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {
        // Insert is deferred to individual test methods to isolate trigger execution.
    }

    // ─── Positive: single record ──────────────────────────────────────────────

    @IsTest
    static void shouldCreateRelatedRecords_WhenSingleAccountInserted() {
        // Given
        Account account = new Account(Name = 'Single Test Account');

        // When
        Test.startTest();
        insert account;
        Test.stopTest();

        // Then
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :account.Id];
        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :account.Id];
        List<Case> cases = [SELECT Id, AccountId FROM Case WHERE AccountId = :account.Id];

        Assert.areEqual(1, contacts.size(), 'Expected 1 Contact created for the Account');
        Assert.areEqual(1, opps.size(), 'Expected 1 Opportunity created for the Account');
        Assert.areEqual(1, cases.size(), 'Expected 1 Case created for the Account');
    }

    @IsTest
    static void shouldSetCorrectContactFields_WhenAccountInserted() {
        // Given / When
        Account account = new Account(Name = 'Field Test Account');
        Test.startTest();
        insert account;
        Test.stopTest();

        // Then
        Contact contact = [SELECT LastName, AccountId FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        Assert.areEqual(account.Name, contact.LastName, 'Contact LastName should match Account Name');
        Assert.areEqual(account.Id, contact.AccountId, 'Contact should be linked to the Account');
    }

    @IsTest
    static void shouldSetCorrectOpportunityFields_WhenAccountInserted() {
        // Given / When
        Account account = new Account(Name = 'Opp Test Account');
        Test.startTest();
        insert account;
        Test.stopTest();

        // Then
        Opportunity opp = [SELECT Name, StageName, CloseDate, AccountId FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
        Assert.areEqual(account.Name + ' - Opportunity', opp.Name, 'Opportunity Name should include Account Name');
        Assert.areEqual('Prospecting', opp.StageName, 'Opportunity StageName should be Prospecting');
        Assert.isTrue(opp.CloseDate >= Date.today(), 'CloseDate should be a future date');
        Assert.areEqual(account.Id, opp.AccountId, 'Opportunity should be linked to the Account');
    }

    @IsTest
    static void shouldSetCorrectCaseFields_WhenAccountInserted() {
        // Given / When
        Account account = new Account(Name = 'Case Test Account');
        Test.startTest();
        insert account;
        Test.stopTest();

        // Then
        Case c = [SELECT Subject, Status, Origin, AccountId FROM Case WHERE AccountId = :account.Id LIMIT 1];
        Assert.areEqual(account.Name + ' - Case', c.Subject, 'Case Subject should include Account Name');
        Assert.areEqual('New', c.Status, 'Case Status should be New');
        Assert.areEqual('Web', c.Origin, 'Case Origin should be Web');
        Assert.areEqual(account.Id, c.AccountId, 'Case should be linked to the Account');
    }

    // ─── Positive: bulk (251+ records) ───────────────────────────────────────

    @IsTest
    static void shouldCreateRelatedRecords_WhenBulkAccountsInserted() {
        // Given
        List<Account> accounts = TestDataFactory.createAccounts(251, false);

        // When
        Test.startTest();
        insert accounts;
        Test.stopTest();

        // Then
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE AccountId IN :accountIds];
        Integer oppCount = [SELECT COUNT() FROM Opportunity WHERE AccountId IN :accountIds];
        Integer caseCount = [SELECT COUNT() FROM Case WHERE AccountId IN :accountIds];

        Assert.areEqual(251, contactCount, 'Expected 1 Contact per Account (251 total)');
        Assert.areEqual(251, oppCount, 'Expected 1 Opportunity per Account (251 total)');
        Assert.areEqual(251, caseCount, 'Expected 1 Case per Account (251 total)');
    }

    // ─── Negative: empty list passed directly to handler ─────────────────────

    @IsTest
    static void shouldNotCreateRecords_WhenEmptyListPassedToHandler() {
        // Given
        AccountTriggerHandler handler = new AccountTriggerHandler();

        // When
        Test.startTest();
        handler.onAfterInsert(new List<Account>());
        Test.stopTest();

        // Then — no DML exception thrown and counts remain zero
        Integer contactCount = [SELECT COUNT() FROM Contact];
        Integer oppCount = [SELECT COUNT() FROM Opportunity];
        Integer caseCount = [SELECT COUNT() FROM Case];

        Assert.areEqual(0, contactCount, 'No Contacts should be created for empty input');
        Assert.areEqual(0, oppCount, 'No Opportunities should be created for empty input');
        Assert.areEqual(0, caseCount, 'No Cases should be created for empty input');
    }

    @IsTest
    static void shouldNotThrow_WhenNullListPassedToHandler() {
        // Given
        AccountTriggerHandler handler = new AccountTriggerHandler();

        // When / Then — no exception expected
        Test.startTest();
        try {
            handler.onAfterInsert(null);
        } catch (Exception e) {
            Assert.fail('Handler should handle null input gracefully, but threw: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
