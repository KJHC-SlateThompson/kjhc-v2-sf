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

    public KJ_Tool_Origin           origin      { get; private Set; }

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
    public static KJ_Tool_Result build(Boolean isSuccess, String message, List<KJ_Tool_Exception> exceptions, KJ_Tool_Origin origin){
        KJ_Tool_Result newResult = new KJ_Tool_Result();

        newResult.isSuccess     = isSuccess     ?? newResult.isSuccess;
        newResult.message       = message       ?? newResult.message;
        newResult.exceptions    = exceptions    ?? newResult.exceptions;
        newResult.origin        = origin        ?? newResult.origin;

        newResult.updateFlags();

        return newResult;
    }
    public static KJ_Tool_Result build(Boolean isSuccess, String message, KJ_Tool_Exception e, KJ_Tool_Origin origin){
        return build(isSuccess, message, new List<KJ_Tool_Exception>{e}, origin);
    }
    public static KJ_Tool_Result build(Boolean isSuccess, String message, List<KJ_Tool_Exception> exceptions){
        return build(isSuccess, message, exceptions, null);
    }
    public static KJ_Tool_Result build(Boolean isSuccess, String message, KJ_Tool_Exception e){
        return build(isSuccess, message, new List<KJ_Tool_Exception>{e}, null);
    }
    public static KJ_Tool_Result build(Boolean isSuccess, String message){
        return build(isSuccess, message, null, null);
    }
    public static KJ_Tool_Result build(Boolean isSuccess, List<KJ_Tool_Exception> exceptions){
        return build(isSuccess, null, exceptions, null);
    }
    public static KJ_Tool_Result build(String message, List<KJ_Tool_Exception> exceptions){
        return build(null, message, exceptions, null);
    }
    public static KJ_Tool_Result build(Boolean isSuccess, KJ_Tool_Exception e){
        return build(isSuccess, null, new List<KJ_Tool_Exception>{e}, null);
    }
    public static KJ_Tool_Result build(String message, KJ_Tool_Exception e){
        return build(null, message, new List<KJ_Tool_Exception>{e}, null);
    }
    public static KJ_Tool_Result build(Boolean isSuccess){
        return build(isSuccess, null, null, null);
    }
    public static KJ_Tool_Result build(List<KJ_Tool_Exception> exceptions){
        return build(null, null, exceptions, null);
    }
    public static KJ_Tool_Result build(KJ_Tool_Exception e){
        return build(null, null, new List<KJ_Tool_Exception>{e}, null);
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
    public void addExcepetion(KJ_Tool_Exception e){
        if(e != null){
            exceptions.add(e);
            this.updateFlags();
        }
    }
    public void setOrigin(KJ_Tool_Origin newOrigin){
        this.origin = newOrigin ?? this.origin;
    }

    public void updateFlags(){
        for(e : exceptions){
            switch on e.level {
                when FATAL  { isSuccess = false;    hasFatals = true;   }
                when HIGH   { isSuccess = false;    hasHighs = true;    }
                when LOW    { isSuccess = true;     hasLows = true;     }
            }
        }
        if (hasFatals || hasHighs){
            isSuccess == false;
        }
    }
}