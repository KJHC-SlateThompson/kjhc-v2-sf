/* 
*   File: KJ_Model_Contact.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/2/2026
*   Description: This class is built to act as a code interface for the Contact object
*/

public with sharing class KJ_Model_Contact {
    //*-- Constants -----------------------------------------------------------------------------

    //*-- Member Variables ----------------------------------------------------------------------
    //Record
    public Id           recordId            { get; private set; }
    public Id           recordTypeId        { get; private set; }

    //Vitals
    public String name { get; private set; }
    public Id accountId { get; private set; }
    public String accountName { get; private set; }
    public String role { get; private set; }
    public Sector sector { get; private set; }
    public String notes { get; private set; }

    //Commercial Info
    public String department { get; private set; }

    //Contact Methods
    public ContactMethod contactMethodPreference { get; private set; }
    public Boolean doNotCall { get; private set; }
    public Boolean emailOptOut { get; private set; }
    public String phone { get; private set; }
    public String secondPhone { get; private set; }
    public String email { get; private set; }
    public String secondEmail { get; private set; }
    public String mailingStreet { get; private set; }
    public String mailingCity { get; private set; }
    public String mailingState { get; private set; }
    public String mailingPostalCode { get; private set; }
    public String mailingCountry { get; private set; }

    //Metadata
    public Id           ownerId             { get; private set; }
    public Id           createdById         { get; private set; }
    public Id           lastModifiedById    { get; private set; }
    public RecordOrigin recordOrigin        { get; private set; }
    public String       originRecordId      { get; private set; }
    public Datetime     originCreatedDate   { get; private set; }



    //*-- Member Methods ------------------------------------------------------------------------
}