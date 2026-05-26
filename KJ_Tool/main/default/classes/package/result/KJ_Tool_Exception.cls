/* 
*   File: KJ_Tool_Exception.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/13/2026
*   Description: This class acts as the base layer to describe an exception within the framework
*/

public with sharing class KJ_Tool_Exception extends Exception{
    //*-- Constants -------------------------------------------------------------------------------
    public enum Code {
        DEFAULT_CODE,       
        TEST_EXCEPTION
    }
    public enum Level {
        LOW,
        HIGH,
        FATAL
    }

    //*-- Member Variables ------------------------------------------------------------------------
    public Code             code        { get; private set; }
    public Level            level       { get; private set; }
    public String           message     { get; private set; }
    public KJ_Tool_Origin   origin      { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // constructor
    public KJ_Tool_Exception(){
        this.code       = Code.DEFAULT_CODE;
        this.level      = Level.LOW;
        this.message    = '';
        this.origin     = new KJ_Tool_Origin();
    }
    // factory methods
    public static KJ_Tool_Exception build(Code newCode, Level newLevel, String newMessage, KJ_Tool_Origin newOrigin){
        KJ_Tool_Exception newException = new KJ_Tool_Exception();

        newException.code       = newCode       ?? newException.code;
        newException.level      = newLevel      ?? newException.level;
        newException.message    = newMessage    ?? newException.message;
        newException.origin     = newOrigin     ?? newException.origin;

        return newException;
    }

    public static KJ_Tool_Exception low(Code code, String message, KJ_Tool_Origin origin){
        return build(code, Level.LOW, message, origin);
    }
    public static KJ_Tool_Exception low(Code code, String message){
        return low(code, message, null);
    }

    public static KJ_Tool_Exception high(Code code, String message, KJ_Tool_Origin origin){
        return build(code, Level.HIGH, message, origin);
    }
    public static KJ_Tool_Exception high(Code code, String message){
        return high(code, message, null);
    }

    public static KJ_Tool_Exception fatal(Code code, String message, KJ_Tool_Origin origin){
        return build(code, level.FATAL, message, origin);
    }
    public static KJ_Tool_Exception fatal(Code code, String message){
        return fatal(code, message, null);
    }

    // Setters
    public void setCode(Code newCode){
        this.code = newCode ?? this.code;
    } 
    public void setLevel(Level newLevel){
        this.level = newLevel ?? this.level;
    } 
    public override void setMessage(String newMessage){
        this.message = newMessage ?? this.message;
    }
    public void setOrigin(KJ_Tool_Origin newOrigin){
        this.origin = newOrigin ?? this.origin;
    }
}