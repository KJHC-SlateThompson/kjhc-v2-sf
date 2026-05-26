/* 
*   File: KJ_Tool_DataEntry.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/21/2026
*   Description: This class structures the lowest unit of data within the codebase
*/
public with sharing class KJ_Tool_DataEntry {
    //*-- Constants -------------------------------------------------------------------------------
    public enum DataType{
        UNKNOWN
    }

    //*-- Member Variables ------------------------------------------------------------------------
    public String   label       { get; private set; }
    public DataType dataType    { get; private set; }
    public Object   value       { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Constructors & Factory Methods
    public KJ_Tool_DataEntry(){
        this.label      = '';
        this.dataType   = DataType.UNKNOWN;
        this.value      = null;
    }

    public static KJ_Tool_DataEntry build(String initLabel, DataType initDataType, Object initValue){
        KJ_Tool_DataEntry newDataEntry = new KJ_Tool_DataEntry();

        newDataEntry.label      = initLabel     ?? newDataEntry.label;
        newDataEntry.dataType   = initDataType  ?? newDataEntry.dataType;
        newDataEntry.value      = initValue     ?? newDataEntry.value;
    
        return newDataEntry;
    }
    public static KJ_Tool_DataEntry build(DataType initDataType, Object initValue){
        return build(null, initDataType, initValue);
    }
    public static KJ_Tool_DataEntry build(Object initValue){
        return build(null, DataType.UNKNOWN, initValue);
    }
}