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

    public static KJ_Tool_DataEntry build(Object initValue){
        KJ_Tool_DataEntry newDataEntry = new KJ_Tool_DataEntry();
        newDataEntry.value = initValue ?? newDataEntry.value;
        return newDataEntry;
    }
    public KJ_Tool_DataEntry withDataType(DataType initDataType){
        this.dataType = initDataType ?? this.dataType;
        return this;
    }
    public KJ_Tool_DataEntry withLabel(String initLabel){
        this.label = initLabel ?? this.label;
        return this.
    }
}