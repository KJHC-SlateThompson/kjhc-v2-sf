// accountPkgPipelineTest.apex - Slate Thompson (Slate@kintyjones.com)
// Walks one Account through: query -> model -> package -> controller -> engine. Read-only.

// Creates a list of fields on the account object
List<String> fields = new List<String>();
for(SObjectField field : KJ_Model_Account.getFields()){
    fields.add(String.valueOf(field));
}

// Queries an account record. This gives an org accurate account record to make sure these internal processes still line up with the org model
List<Account> records = Database.query('SELECT ' + String.join(fields, ', ') + ' FROM Account LIMIT 1');
if(records.isEmpty()){
    KJ_Tool_Logger.warn('No Accounts in this org.');
    return;
}

// Builds Account and package
KJ_Model_Account model = KJ_Model_Account.build(records[0]);

KJ_Tool_Package pkg = KJ_Tool_Package.build(
    KJ_Tool_DataBundle.build(KJ_Tool_DataEntry.build(model).withLabel('Account'))
).withLabel('Account Package');

// Sends package to controller
KJ_Dispatch_Account.receive(pkg);

KJ_Tool_Logger.debug('Account : ' + model.name);
KJ_Tool_Logger.debug('Success : ' + pkg.result.isSuccess);
KJ_Tool_Logger.debug('Message : ' + pkg.result.message);

// Empty bundle should report MISSING_DATA, not a routing failure.
KJ_Tool_Package empty = KJ_Dispatch_Account.receive(KJ_Tool_Package.build());
KJ_Tool_Logger.debug('Empty   : ' + empty.result.exceptions[0].code);
