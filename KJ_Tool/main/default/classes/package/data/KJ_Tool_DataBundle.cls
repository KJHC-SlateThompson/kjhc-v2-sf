/* 
*   File: KJ_Tool_DataBundle.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/21/2026
*   Description: This class bundles together data entries to make them more trackable.
*/
public with sharing class KJ_Tool_DataBundle {
    //*-- Member Variables ------------------------------------------------------------------------
    public String                  label   { get; private set; }
    public List<KJ_Tool_DataEntry> entries { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Constructors & Factory methods
    public KJ_Tool_DataBundle() {
        this.label      = '';
        this.entries    = new List<KJ_Tool_DataEntry>();
    }

    public static KJ_Tool_DataBundle build(List<KJ_Tool_DataEntry> initEntries){
        KJ_Tool_DataBundle newDataBundle = new KJ_Tool_DataBundle();
        newDataBundle.entries = initEntries ?? newDataBundle.entries;
        
        return newDataBundle;
    }
    public static KJ_Tool_DataBundle build(KJ_Tool_DataEntry initEntry){
        return build(new List<KJ_Tool_DataEntry>{ initEntry });
    }
    public KJ_Tool_DataBundle withLabel(String initLabel){
        this.label = initLabel ?? this.label;
        return this;
    }


    // Mutator methods
    public void add(KJ_Tool_DataEntry newEntry){
        this.entries.add(newEntry);
    }

    // Read only methods
    public KJ_Tool_DataEntry getFirst(){
        return this.entries.getFirst();
    }
    public KJ_Tool_DataEntry getLast(){
        return this.entries.getLast();
    }
    public KJ_Tool_DataEntry getByLabel(string targetLabel){
        for(KJ_Tool_DataEntry entry : this.entries){
            if(entry.label == targetLabel){
                return entry;
            }
        }
        return null;
    }
}