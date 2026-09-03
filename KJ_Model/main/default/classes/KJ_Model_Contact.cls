/*
*   File: KJ_Model_Contact.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/2/2026
*   Description: This class is built to act as a code interface for the Contact object
*/

public with sharing class KJ_Model_Contact {

    //*-- 1. Constants -----------------------------------------------------------------------------

    //*--    1.1 Field Groupings -------------------------------------------------------------------
    public static final List<SObjectField> VITAL_DATA = new List<SObjectField>{
        Contact.Id,
        Contact.RecordTypeId,
        Contact.FirstName,
        Contact.LastName,
        Contact.AccountId,
        Contact.Role__c,
        Contact.Contact_Sector__c
    };
    public static final List<SObjectField> NOTES_DATA = new List<SObjectField>{
        Contact.Contact_Notes__c
    };
    public static final List<SObjectField> COMMERCIAL_DATA = new List<SObjectField>{
        Contact.Department
    };
    public static final List<SObjectField> CONTACT_DATA = new List<SObjectField>{
        Contact.Contact_Method_Preference__c,
        Contact.DoNotCall,
        Contact.HasOptedOutOfEmail,
        Contact.Phone,
        Contact.Second_Phone__c,
        Contact.Email,
        Contact.Second_Email__c
    };
    public static final List<SObjectField> LOCATION_DATA = new List<SObjectField>{
        Contact.MailingStreet,
        Contact.MailingCity,
        Contact.MailingState,
        Contact.MailingPostalCode,
        Contact.MailingCountry
    };
    public static final List<SObjectField> METADATA_DATA = new List<SObjectField>{
        Contact.OwnerId,
        Contact.CreatedById,
        Contact.LastModifiedById,
        Contact.Record_Origin__c,
        Contact.Origin_Record_Id__c,
        Contact.Origin_Created_Date__c
    };

    // Parent-object fields the model reads but that no SObjectField on Contact can express.
    // Callers building SOQL append these paths alongside getFields().
    public static final List<String> PARENT_FIELD_PATHS = new List<String>{
        'Account.Name'
    };

    //*--    1.2 Type Defaults ---------------------------------------------------------------------
    private static final String                               DEFAULT_TEXT                      = null;
    private static final Decimal                              DEFAULT_NUMBER                    = null;
    private static final Date                                 DEFAULT_DATE                      = null;
    private static final Datetime                             DEFAULT_DATETIME                  = null;
    private static final Boolean                              DEFAULT_FLAG                      = false;
    private static final KJ_Model_Picklist.Sector             DEFAULT_SECTOR                    = KJ_Model_Picklist.Sector.UNKNOWN;
    private static final KJ_Model_Picklist.ContactMethod      DEFAULT_CONTACT_METHOD_PREFERENCE = KJ_Model_Picklist.ContactMethod.UNKNOWN;
    private static final KJ_Model_Picklist.RecordOrigin       DEFAULT_ORIGIN                    = KJ_Model_Picklist.RecordOrigin.UNKNOWN;

    //*--    1.3 Object Reference ------------------------------------------------------------------
    // Statically records the SObject type of the object modeled by the class
    public static final SObjectType SOBJECT_TYPE = Contact.SObjectType;


    //*-- 2. Member Variables ----------------------------------------------------------------------

    // Record
    public Id                               recordId                    { get; private set; }
    public Id                               recordTypeId                { get; private set; }

    // Vitals
    public String                           firstName                   { get; private set; }
    public String                           lastName                    { get; private set; }
    public Id                               accountId                   { get; private set; }
    public String                           accountName                 { get; private set; }
    public String                           role                        { get; private set; }
    public KJ_Model_Picklist.Sector         sector                      { get; private set; }
    public String                           notes                       { get; private set; }

    // Commercial Info
    public String                           department                  { get; private set; }

    // Contact Methods
    public KJ_Model_Picklist.ContactMethod  contactMethodPreference     { get; private set; }
    public Boolean                          doNotCall                   { get; private set; }
    public Boolean                          emailOptOut                 { get; private set; }
    public String                           phone                       { get; private set; }
    public String                           secondPhone                 { get; private set; }
    public String                           email                       { get; private set; }
    public String                           secondEmail                 { get; private set; }

    // Location
    public String                           mailingStreet               { get; private set; }
    public String                           mailingCity                 { get; private set; }
    public String                           mailingState                { get; private set; }
    public String                           mailingPostalCode           { get; private set; }
    public String                           mailingCountry              { get; private set; }

    // Metadata
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

        Map<String, Object> source = initRecord.getPopulatedFieldsAsMap();

        // Record
        newModel.recordId                = (Id)      read(source, Contact.Id)                           ?? newModel.recordId;
        newModel.recordTypeId            = (Id)      read(source, Contact.RecordTypeId)                 ?? newModel.recordTypeId;

        // Vitals
        newModel.firstName               = (String)  read(source, Contact.FirstName)                    ?? newModel.firstName;
        newModel.lastName                = (String)  read(source, Contact.LastName)                     ?? newModel.lastName;
        newModel.accountId               = (Id)      read(source, Contact.AccountId)                    ?? newModel.accountId;
        newModel.accountName             =           readParentName(source)                             ?? newModel.accountName;
        newModel.role                    = (String)  read(source, Contact.Role__c)                      ?? newModel.role;
        newModel.sector                  = KJ_Model_Picklist.mapToSector((String) read(source, Contact.Contact_Sector__c));
        newModel.notes                   = (String)  read(source, Contact.Contact_Notes__c)             ?? newModel.notes;

        // Commercial Info
        newModel.department              = (String)  read(source, Contact.Department)                   ?? newModel.department;

        // Contact Methods
        newModel.contactMethodPreference = KJ_Model_Picklist.mapToContactMethod((String) read(source, Contact.Contact_Method_Preference__c));
        newModel.doNotCall               = (Boolean) read(source, Contact.DoNotCall)                    ?? newModel.doNotCall;
        newModel.emailOptOut             = (Boolean) read(source, Contact.HasOptedOutOfEmail)           ?? newModel.emailOptOut;
        newModel.phone                   = (String)  read(source, Contact.Phone)                        ?? newModel.phone;
        newModel.secondPhone             = (String)  read(source, Contact.Second_Phone__c)              ?? newModel.secondPhone;
        newModel.email                   = (String)  read(source, Contact.Email)                        ?? newModel.email;
        newModel.secondEmail             = (String)  read(source, Contact.Second_Email__c)              ?? newModel.secondEmail;

        // Location
        newModel.mailingStreet           = (String)  read(source, Contact.MailingStreet)                ?? newModel.mailingStreet;
        newModel.mailingCity             = (String)  read(source, Contact.MailingCity)                  ?? newModel.mailingCity;
        newModel.mailingState            = (String)  read(source, Contact.MailingState)                 ?? newModel.mailingState;
        newModel.mailingPostalCode       = (String)  read(source, Contact.MailingPostalCode)            ?? newModel.mailingPostalCode;
        newModel.mailingCountry          = (String)  read(source, Contact.MailingCountry)               ?? newModel.mailingCountry;

        // Metadata
        newModel.ownerId                 = (Id)      read(source, Contact.OwnerId)                      ?? newModel.ownerId;
        newModel.createdById             = (Id)      read(source, Contact.CreatedById)                  ?? newModel.createdById;
        newModel.lastModifiedById        = (Id)      read(source, Contact.LastModifiedById)             ?? newModel.lastModifiedById;
        newModel.recordOrigin            = KJ_Model_Picklist.mapToRecordOrigin((String) read(source, Contact.Record_Origin__c));
        newModel.originRecordId          = (String)  read(source, Contact.Origin_Record_Id__c)          ?? newModel.originRecordId;
        newModel.originCreatedDate       = (Date)    read(source, Contact.Origin_Created_Date__c)       ?? newModel.originCreatedDate;

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

    //*--    3.2 Static Field Ops ------------------------------------------------------------------
    public static List<SObjectField> getFields(){
        List<SObjectField> allFields = new List<SObjectField>();
        allFields.addAll(VITAL_DATA);
        allFields.addAll(NOTES_DATA);
        allFields.addAll(COMMERCIAL_DATA);
        allFields.addAll(CONTACT_DATA);
        allFields.addAll(LOCATION_DATA);
        allFields.addAll(METADATA_DATA);
        return allFields;
    }

    //*--    3.3 Internal --------------------------------------------------------------------------
    private static void put(Contact targetRecord, SObjectField targetField, Object targetValue){
        if(targetValue != null) { targetRecord.put(targetField, targetValue); }
    }

    // Reading a field the caller never queried throws an SObjectException, so build() works off the
    // populated-field map rather than the record. An absent field reads as null and falls through to
    // whatever the constructor already set.
    private static Object read(Map<String, Object> sourceFields, SObjectField targetField){
        return sourceFields.get(String.valueOf(targetField));
    }

    // Account.Name lives on the parent, one map deeper. Same guard applies at both levels: an
    // unqueried parent, or a parent queried without Name, reads as null instead of throwing.
    private static String readParentName(Map<String, Object> sourceFields){
        Account parentRecord = (Account) sourceFields.get('Account');
        if(parentRecord == null) { return null; }

        return (String) parentRecord.getPopulatedFieldsAsMap().get('Name');
    }


    //*-- 4. Instance Methods ----------------------------------------------------------------------

    //*--    4.1 Constructor -----------------------------------------------------------------------
    public KJ_Model_Contact() {
        // Record
        this.recordId                = null;
        this.recordTypeId            = null;

        // Vitals
        this.firstName               = DEFAULT_TEXT;
        this.lastName                = DEFAULT_TEXT;
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

        // Location
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

    //*--    4.2 Conversion ------------------------------------------------------------------------
    public Contact toRecord(){
        Contact newRecord = new Contact();

        // Record
        put(newRecord, Contact.Id,                           this.recordId);
        put(newRecord, Contact.RecordTypeId,                 this.recordTypeId);

        // Vitals — Name omitted, not writeable; it is composed from FirstName and LastName.
        //          accountName omitted, it belongs to the parent Account.
        put(newRecord, Contact.FirstName,                    this.firstName);
        put(newRecord, Contact.LastName,                     this.lastName);
        put(newRecord, Contact.AccountId,                    this.accountId);
        put(newRecord, Contact.Role__c,                      this.role);
        put(newRecord, Contact.Contact_Sector__c,            KJ_Model_Picklist.mapToString(this.sector));
        put(newRecord, Contact.Contact_Notes__c,             this.notes);

        // Commercial Info
        put(newRecord, Contact.Department,                   this.department);

        // Contact Methods
        put(newRecord, Contact.Contact_Method_Preference__c, KJ_Model_Picklist.mapToString(this.contactMethodPreference));
        put(newRecord, Contact.DoNotCall,                    this.doNotCall);
        put(newRecord, Contact.HasOptedOutOfEmail,           this.emailOptOut);
        put(newRecord, Contact.Phone,                        this.phone);
        put(newRecord, Contact.Second_Phone__c,              this.secondPhone);
        put(newRecord, Contact.Email,                        this.email);
        put(newRecord, Contact.Second_Email__c,              this.secondEmail);

        // Location
        put(newRecord, Contact.MailingStreet,                this.mailingStreet);
        put(newRecord, Contact.MailingCity,                  this.mailingCity);
        put(newRecord, Contact.MailingState,                 this.mailingState);
        put(newRecord, Contact.MailingPostalCode,            this.mailingPostalCode);
        put(newRecord, Contact.MailingCountry,               this.mailingCountry);

        // Metadata — CreatedById and LastModifiedById omitted, not writeable
        put(newRecord, Contact.OwnerId,                      this.ownerId);
        put(newRecord, Contact.Record_Origin__c,             KJ_Model_Picklist.mapToString(this.recordOrigin));
        put(newRecord, Contact.Origin_Record_Id__c,          this.originRecordId);
        put(newRecord, Contact.Origin_Created_Date__c,       this.originCreatedDate);

        return newRecord;
    }

    //*--    4.3 Setters ---------------------------------------------------------------------------
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
    public KJ_Model_Contact setFirstName(String initFirstName){
        this.firstName = initFirstName ?? this.firstName;
        return this;
    }
    public KJ_Model_Contact setLastName(String initLastName){
        this.lastName = initLastName ?? this.lastName;
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

    // Location
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
