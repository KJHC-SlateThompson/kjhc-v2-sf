/* 
*   File: KJ_Model_Picklist.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/2/2026
*   Description: This class provides a proxy for picklist values via enums, and methods for mapping and stringification.
*/

public with sharing class KJ_Model_Picklist {
    //*-- Sector ----------------------------------------------------------------------------------
    public enum Sector {
        RESIDENTIAL,
        COMMERCIAL,
        UNKNOWN
    }
    public static Sector mapToSector(String sectorValue){
        if(String.isBlank(sectorValue)) { return Sector.UNKNOWN; }
        switch on sectorValue.toUpperCase() {
            when 'RESIDENTIAL'  { return Sector.RESIDENTIAL; }
            when 'COMMERCIAL'   { return Sector.COMMERCIAL; }
            when else           { return Sector.UNKNOWN; }
        }
    }
    public static String mapToString(Sector sectorValue){
        switch on sectorValue {
            when RESIDENTIAL    { return 'Residential'; }
            when COMMERCIAL     { return 'Commercial'; }
            when else           { return null; }
        }
    }

    //*-- Territory -------------------------------------------------------------------------------
    public enum Territory {
        NWA,
        RIVER_VALLEY,
        UNKNOWN
    }
    public static Territory mapToTerritory(String territoryValue){
        if(String.isBlank(territoryValue)) { return Territory.UNKNOWN; }
        switch on territoryValue.toUpperCase() {
            when 'NWA'          { return Territory.NWA; }
            when 'RIVER VALLEY' { return Territory.RIVER_VALLEY; }
            when else           { return Territory.UNKNOWN; }
        }
    }
    public static String mapToString(Territory territoryValue){
        switch on territoryValue {
            when NWA            { return 'NWA'; }
            when RIVER_VALLEY   { return 'River Valley'; }
            when else           { return null; }
        }
    }

    //*-- Record Origin --------------------------------------------------------------------------
    public enum RecordOrigin {
        FIELDPULSE,
        QBO,
        GRAVITY_FORMS,
        LSA,
        MANUAL,
        UNKNOWN
    }
    public static RecordOrigin mapToRecordOrigin(String originValue){
        if(String.isBlank(originValue)) { return RecordOrigin.UNKNOWN; }
        switch on originValue.toUpperCase() {
            when 'FIELDPULSE'       { return RecordOrigin.FIELDPULSE; }
            when 'QBO'              { return RecordOrigin.QBO; }
            when 'GRAVITY FORMS'    { return RecordOrigin.GRAVITY_FORMS; }
            when 'LSA'              { return RecordOrigin.LSA; }
            when 'MANUAL'           { return RecordOrigin.MANUAL; }
            when else               { return RecordOrigin.UNKNOWN; }
        }
    }
    public static String mapToString(RecordOrigin originValue){
        switch on originValue {
            when FIELDPULSE     { return 'FieldPulse'; }
            when QBO            { return 'QBO'; }
            when GRAVITY_FORMS  { return 'Gravity Forms'; }
            when LSA            { return 'LSA'; }
            when MANUAL         { return 'Manual'; }
            when else           { return null; }
        }
    }

    //*-- Account Status ---------------------------------------------------------------------------
    public enum AccountStatus { 
        UNKNOWN,
        LEAD,
        CURRENT_CUSTOMER, 
        LOST 
    }
    public static AccountStatus mapToAccountStatus(String statusValue){
        if(String.isBlank(statusValue)) { return AccountStatus.UNKNOWN; }
        switch on statusValue.toUpperCase() {
            when 'LEAD'              { return AccountStatus.LEAD; }
            when 'CURRENT CUSTOMER'  { return AccountStatus.CURRENT_CUSTOMER; }
            when 'LOST'              { return AccountStatus.LOST; }
            when else                { return AccountStatus.UNKNOWN; }
        }
    }
    public static String mapToString(AccountStatus statusValue){
        switch on statusValue {
            when LEAD               { return 'Lead'; }
            when CURRENT_CUSTOMER    { return 'Current Customer'; }
            when LOST               { return 'Lost'; }
            when else               { return null; }
        }
    }

    //*-- Contact Method --------------------------------------------------------------------------
    public enum ContactMethod {
        PHONE,
        EMAIL,
        UNKNOWN
    }
    public static ContactMethod mapToContactMethod(String contactMethodValue) {
        if(String.isBlank(contactMethodValue)) { return ContactMethod.UNKNOWN; }
        switch on contactMethodValue.toUpperCase() {
            when 'PHONE'    { return ContactMethod.PHONE; }
            when 'EMAIL'    { return ContactMethod.EMAIL; }
            when else    { return ContactMethod.UNKNOWN; }
        }
    }
    public static String mapToString(ContactMethod contactMethodValue) {
        switch on contactMethodValue {
            when PHONE    { return 'Phone'; }
            when EMAIL    { return 'Email'; }
            when else     { return null; }
        }
    }
}