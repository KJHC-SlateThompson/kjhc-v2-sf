/* 
*   File: KJ_Tool_DataBundle.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/21/2026
*   Description: This class bundles together data entries to make them more trackable.
*/
public with sharing class KJ_Tool_DataBundle {
    //*-- Member Variables ------------------------------------------------------------------------
    public String                  label;
    public List<KJ_Tool_DataEntry> entries;


    //*-- Member Methods --------------------------------------------------------------------------
    public KJ_Tool_DataBundle() {
        this.label = '';
        this.entries = null;
    }

    public KJ_Tool_DataBundle build(String initLabel, List<KJ_Tool_DataEntry> initEntries){
        KJ_Tool_DataBundle newDataBundle = new KJ_Tool_DataBundle;

        newDataBundle.label = initLabel;
        newDataBundle.entries = initEntries;

        return newDataBundle;
    }
    public KJ_Tool_DataBundle build(List<KJ_Tool_DataEntry> initEntries){
        return build(null, initEntries);
    }
    public KJ_Tool_DataBundle build(String initLabel, KJ_Tool_DataEntry initEntry){
        List<KJ_Tool_DataEntry> newDataBundle = new KJ_Tool_DataEntry
        return build(null, );
    }


}