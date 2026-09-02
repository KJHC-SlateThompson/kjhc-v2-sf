/*
*   File: KJ_Model_Contact.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/2/2026
*   Description: This class is built to act as a code interface for the Contact object
*/

public with sharing class KJ_Model_Contact {
    //*-- 1. Constants -----------------------------------------------------------------------------
    // Type Defaults
    private static final String                               DEFAULT_TEXT                      = null;
    private static final Decimal                              DEFAULT_NUMBER                    = null;
    private static final Date                                 DEFAULT_DATE                      = null;
    private static final Datetime                             DEFAULT_DATETIME                  = null;
    private static final Boolean                              DEFAULT_FLAG                      = false;
    private static final KJ_Model_Picklist.Sector             DEFAULT_SECTOR                    = KJ_Model_Picklist.Sector.UNKNOWN;
    private static final KJ_Model_Picklist.ContactMethod      DEFAULT_CONTACT_METHOD_PREFERENCE = KJ_Model_Picklist.ContactMethod.UNKNOWN;
    private static final KJ_Model_Picklist.RecordOrigin       DEFAULT_ORIGIN                    = KJ_Model_Picklist.RecordOrigin.UNKNOWN;

    // Static/Constant Object Information
    public static final SObjectType SOBJECT_TYPE = Contact.SObjectType; // Statically records the SObject type of the object modeled by the class

    //*-- 2. Member Variables ----------------------------------------------------------------------
    //Record
    public Id                               recordId                    { get; private set; }
    public Id                               recordTypeId                { get; private set; }

    //Vitals
    public String                           name                        { get; private set; }
    public Id                               accountId                   { get; private set; }
    public String                           accountName                 { get; private set; }
    public String                           role                        { get; private set; }
    public KJ_Model_Picklist.Sector         sector                      { get; private set; }
    public String                           notes                       { get; private set; }

    //Commercial Info
    public String                           department                  { get; private set; }

    //Contact Methods
    public KJ_Model_Picklist.ContactMethod  contactMethodPreference     { get; private set; }
    public Boolean                          doNotCall                   { get; private set; }
    public Boolean                          emailOptOut                 { get; private set; }
    public String                           phone                       { get; private set; }
    public String                           secondPhone                 { get; private set; }
    public String                           email                       { get; private set; }
    public String                           secondEmail                 { get; private set; }
    public String                           mailingStreet               { get; private set; }
    public String                           mailingCity                 { get; private set; }
    public String                           mailingState                { get; private set; }
    public String                           mailingPostalCode           { get; private set; }
    public String                           mailingCountry              { get; private set; }

    //Metadata
    public Id                               ownerId                     { get; private set; }
    public Id                               createdById                 { get; private set; }
    public Id                               lastModifiedById            { get; private set; }
    public KJ_Model_Picklist.RecordOrigin   recordOrigin                { get; private set; }
    public String                           originRecordId              { get; private set; }
    public Date                             originCreatedDate           { get; private set; }


    //*-- 3. Static Methods ------------------------------------------------------------------------

    //*--    3.1 Factories -------------------------------------------------------------------------
    public static KJ_Model_Contact build(Contact initRecord){
        KJ_Model_Contact newModel = new KJ_Model_Contact();
        if(initRecord == null) { return newModel; }

        Contact source = new Contact();
        source.putAll(initRecord);

        // Record
        newModel.recordId                = source.Id                        ?? newModel.recordId;
        newModel.recordTypeId            = source.RecordTypeId              ?? newModel.recordTypeId;

        // Vitals
        newModel.name                    = source.Name                      ?? newModel.name;
        newModel.accountId               = source.AccountId                 ?? newModel.accountId;
        newModel.accountName             = readParentName(initRecord)       ?? newModel.accountName;
        newModel.role                    = source.Role__c                   ?? newModel.role;
        newModel.sector                  = KJ_Model_Picklist.mapToSector(source.Contact_Sector__c);
        newModel.notes                   = source.Contact_Notes__c          ?? newModel.notes;

        // Commercial Info
        newModel.department              = source.Department                ?? newModel.department;

        // Contact Methods
        newModel.contactMethodPreference = KJ_Model_Picklist.mapToContactMethod(source.Contact_Method_Preference__c);
        newModel.doNotCall               = source.DoNotCall                 ?? newModel.doNotCall;
        newModel.emailOptOut             = source.HasOptedOutOfEmail        ?? newModel.emailOptOut;
        newModel.phone                   = source.Phone                     ?? newModel.phone;
        newModel.secondPhone             = source.Second_Phone__c           ?? newModel.secondPhone;
        newModel.email                   = source.Email                     ?? newModel.email;
        newModel.secondEmail             = source.Second_Email__c           ?? newModel.secondEmail;
        newModel.mailingStreet           = source.MailingStreet             ?? newModel.mailingStreet;
        newModel.mailingCity             = source.MailingCity               ?? newModel.mailingCity;
        newModel.mailingState            = source.MailingState              ?? newModel.mailingState;
        newModel.mailingPostalCode       = source.MailingPostalCode         ?? newModel.mailingPostalCode;
        newModel.mailingCountry          = source.MailingCountry            ?? newModel.mailingCountry;

        // Metadata
        newModel.ownerId                 = source.OwnerId                   ?? newModel.ownerId;
        newModel.createdById             = source.CreatedById               ?? newModel.createdById;
        newModel.lastModifiedById        = source.LastModifiedById          ?? newModel.lastModifiedById;
        newModel.recordOrigin            = KJ_Model_Picklist.mapToRecordOrigin(source.Record_Origin__c);
        newModel.originRecordId          = source.Origin_Record_Id__c       ?? newModel.originRecordId;
        newModel.originCreatedDate       = source.Origin_Created_Date__c    ?? newModel.originCreatedDate;

        return newModel;
    }
    public static KJ_Model_Contact build(){
        return build(null);
    }

    public static List<KJ_Model_Contact> buildAll(List<Contact> initRecords){
        List<KJ_Model_Contact> newModels = new List<KJ_Model_Contact>();
        if(initRecords == null) { return newModels; }

        for(Contact record : initRecords){
            newModels.add(build(record));
        }

        return newModels;
    }

    public static Map<Id, KJ_Model_Contact> buildAllById(List<Contact> initRecords){
        Map<Id, KJ_Model_Contact> newModels = new Map<Id, KJ_Model_Contact>();
        if(initRecords == null) { return newModels; }

        for(Contact record : initRecords){
            if(record.Id == null) { continue; }
            newModels.put(record.Id, build(record));
        }

        return newModels;
    }

    //*--    3.2 Internal --------------------------------------------------------------------------
    // Account.Name sits on the parent, so putAll cannot launder it the way it does own-object fields.
    // The populated-field map reports only what the caller actually queried, which keeps an unqueried
    // parent from throwing an SObjectException here.
    private static String readParentName(Contact initRecord){
        Object parentRecord = initRecord.getPopulatedFieldsAsMap().get('Account');
        if(parentRecord == null) { return null; }

        Account parentSource = new Account();
        parentSource.putAll((Account) parentRecord);
        return parentSource.Name;
    }


    //*-- 4. Instance Methods ----------------------------------------------------------------------

    //*--    4.1 Constructor -----------------------------------------------------------------------
    public KJ_Model_Contact() {
        // Record
        this.recordId                = null;
        this.recordTypeId            = null;

        // Vitals
        this.name                    = DEFAULT_TEXT;
        this.accountId               = null;
        this.accountName             = DEFAULT_TEXT;
        this.role                    = DEFAULT_TEXT;
        this.sector                  = DEFAULT_SECTOR;
        this.notes                   = DEFAULT_TEXT;

        // Commercial Info
        this.department              = DEFAULT_TEXT;

        // Contact Methods
        this.contactMethodPreference = DEFAULT_CONTACT_METHOD_PREFERENCE;
        this.doNotCall               = DEFAULT_FLAG;
        this.emailOptOut             = DEFAULT_FLAG;
        this.phone                   = DEFAULT_TEXT;
        this.secondPhone             = DEFAULT_TEXT;
        this.email                   = DEFAULT_TEXT;
        this.secondEmail             = DEFAULT_TEXT;
        this.mailingStreet           = DEFAULT_TEXT;
        this.mailingCity             = DEFAULT_TEXT;
        this.mailingState            = DEFAULT_TEXT;
        this.mailingPostalCode       = DEFAULT_TEXT;
        this.mailingCountry          = DEFAULT_TEXT;

        // Metadata
        this.ownerId                 = null;
        this.createdById             = null;
        this.lastModifiedById        = null;
        this.recordOrigin            = DEFAULT_ORIGIN;
        this.originRecordId          = null;
        this.originCreatedDate       = DEFAULT_DATE;
    }

    //*--    4.2 Setters ---------------------------------------------------------------------------
    // Record
    public KJ_Model_Contact setRecordId(Id initRecordId){
        this.recordId = initRecordId ?? this.recordId;
        return this;
    }
    public KJ_Model_Contact setRecordTypeId(Id initRecordTypeId){
        this.recordTypeId = initRecordTypeId ?? this.recordTypeId;
        return this;
    }

    // Vitals
    public KJ_Model_Contact setName(String initName){
        this.name = initName ?? this.name;
        return this;
    }
    public KJ_Model_Contact setAccountId(Id initAccountId){
        this.accountId = initAccountId ?? this.accountId;
        return this;
    }
    public KJ_Model_Contact setAccountName(String initAccountName){
        this.accountName = initAccountName ?? this.accountName;
        return this;
    }
    public KJ_Model_Contact setRole(String initRole){
        this.role = initRole ?? this.role;
        return this;
    }
    public KJ_Model_Contact setSector(KJ_Model_Picklist.Sector initSector){
        this.sector = initSector ?? this.sector;
        return this;
    }
    public KJ_Model_Contact setNotes(String initNotes){
        this.notes = initNotes ?? this.notes;
        return this;
    }

    // Commercial Info
    public KJ_Model_Contact setDepartment(String initDepartment){
        this.department = initDepartment ?? this.department;
        return this;
    }

    // Contact Methods
    public KJ_Model_Contact setContactMethodPreference(KJ_Model_Picklist.ContactMethod initContactMethodPreference){
        this.contactMethodPreference = initContactMethodPreference ?? this.contactMethodPreference;
        return this;
    }
    public KJ_Model_Contact setDoNotCall(Boolean initDoNotCall){
        this.doNotCall = initDoNotCall ?? this.doNotCall;
        return this;
    }
    public KJ_Model_Contact setEmailOptOut(Boolean initEmailOptOut){
        this.emailOptOut = initEmailOptOut ?? this.emailOptOut;
        return this;
    }
    public KJ_Model_Contact setPhone(String initPhone){
        this.phone = initPhone ?? this.phone;
        return this;
    }
    public KJ_Model_Contact setSecondPhone(String initSecondPhone){
        this.secondPhone = initSecondPhone ?? this.secondPhone;
        return this;
    }
    public KJ_Model_Contact setEmail(String initEmail){
        this.email = initEmail ?? this.email;
        return this;
    }
    public KJ_Model_Contact setSecondEmail(String initSecondEmail){
        this.secondEmail = initSecondEmail ?? this.secondEmail;
        return this;
    }
    public KJ_Model_Contact setMailingStreet(String initMailingStreet){
        this.mailingStreet = initMailingStreet ?? this.mailingStreet;
        return this;
    }
    public KJ_Model_Contact setMailingCity(String initMailingCity){
        this.mailingCity = initMailingCity ?? this.mailingCity;
        return this;
    }
    public KJ_Model_Contact setMailingState(String initMailingState){
        this.mailingState = initMailingState ?? this.mailingState;
        return this;
    }
    public KJ_Model_Contact setMailingPostalCode(String initMailingPostalCode){
        this.mailingPostalCode = initMailingPostalCode ?? this.mailingPostalCode;
        return this;
    }
    public KJ_Model_Contact setMailingCountry(String initMailingCountry){
        this.mailingCountry = initMailingCountry ?? this.mailingCountry;
        return this;
    }

    // Metadata
    public KJ_Model_Contact setOwnerId(Id initOwnerId){
        this.ownerId = initOwnerId ?? this.ownerId;
        return this;
    }
    public KJ_Model_Contact setRecordOrigin(KJ_Model_Picklist.RecordOrigin initRecordOrigin){
        this.recordOrigin = initRecordOrigin ?? this.recordOrigin;
        return this;
    }
    public KJ_Model_Contact setOriginRecordId(String initOriginRecordId){
        this.originRecordId = initOriginRecordId ?? this.originRecordId;
        return this;
    }
    public KJ_Model_Contact setOriginCreatedDate(Date initOriginCreatedDate){
        this.originCreatedDate = initOriginCreatedDate ?? this.originCreatedDate;
        return this;
    }

}
