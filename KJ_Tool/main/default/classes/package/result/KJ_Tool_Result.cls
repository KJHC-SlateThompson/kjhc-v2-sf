/* 
*   File: KJ_Tool_Result.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/22/2026
*   Description: This class is built to provide a universal format for returning results

*/
public with sharing class KJ_Tool_Result {
    //*-- Member Variables ------------------------------------------------------------------------
    public Boolean  isSuccess   { get; private set; }
    public String   message     { get; private set; }

    public List<KJ_Tool_Exception>  exceptions  { get; private set; }
    public Boolean                  hasFatals   { get; private set; }
    public Boolean                  hasHighs    { get; private set; }
    public Boolean                  hasLows     { get; private set; }

    public KJ_Tool_Origin           origin      { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // constructor
    public KJ_Tool_Result(){
        this.isSuccess  = true;
        this.message    = '';

        this.exceptions = new List<KJ_Tool_Exception>();
        this.hasFatals  = false;
        this.hasHighs   = false;
        this.hasLows    = false;

        this.origin     = new KJ_Tool_Origin();
    }

    // factory methods
    public static KJ_Tool_Result build(Boolean isSuccess){
        KJ_Tool_Result newResult = new KJ_Tool_Result();
        newResult.isSuccess = isSuccess ?? newResult.isSuccess;

        return newResult;
    }
    public KJ_Tool_Result withMessage(String initMessage){
        this.message = initMessage ?? this.message;
        return this;
    }
    public KJ_Tool_Result withExceptions(List<KJ_Tool_Exception> initList){
        this.exceptions = initList ?? this.exceptions;
        this.updateFlags();
        return this;
    }
    public KJ_Tool_Result withException(KJ_Tool_Exception initException){
        this.exceptions.add(initException);
        this.updateFlags();
        return this;
    }
    public KJ_Tool_Result withOrigin(KJ_Tool_Origin initOrigin){
        this.origin = initOrigin ?? this.origin;
        return this;
    }

    // mutators
    public void markSuccessful(){
        this.isSuccess = true;
    }
    public void markUnsuccessful(){
        this.isSuccess = false;
    }
    public void setMessage(String newMessage){
        this.message = newMessage ?? this.message;
    }
    public void setOrigin(KJ_Tool_Origin newOrigin){
        this.origin = newOrigin ?? this.origin;
    }
    public void addException(KJ_Tool_Exception e){
        if(e == null) { return; }

        exceptions.add(e);
        this.applyLevelFlag(e.level);
        
    }
    public void addExceptions(List<KJ_Tool_Exception> newExceptions){
        if(newExceptions == null) { return; }
        
        for(KJ_Tool_Exception e : newExceptions){
            this.addException(e);
        }
    }

    private void applyLevelFlag(KJ_Tool_Exception.Level level){
        switch on level {
            when FATAL { this.isSuccess = false; this.hasFatals = true; }
            when HIGH  { this.isSuccess = false; this.hasHighs = true; }
            when LOW   { this.hasLows = true; } // LOW records, never resurrects success
        }
    }
    private void updateFlags(){
        for(KJ_Tool_Exception e : exceptions){
            this.applyLevelFlag(e.level);
        }
        if (this.hasFatals || this.hasHighs){
            this.isSuccess = false;
        }
    }
}