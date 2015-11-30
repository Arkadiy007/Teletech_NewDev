/**********************************************************************
Name: SSSCsvReaderTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for SSSCsvReader
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class SSSCsvReaderTests { 
	 static testmethod void testSplitCsvSimple(){
    String line = 'abc,efg'; 
    String[] splitted = new SSSCsvReader(line).readLine();
    System.assertEquals(2, splitted.size()); 
    
    System.assertEquals('efg', splitted[1]);
    System.assertEquals('abc', splitted[0]);
  }
  
  static testmethod void testSplitCsvEOL(){
    String line = 'abc,';
    String[] splitted = new SSSCsvReader(line).readLine();
    System.assertEquals(2, splitted.size()); 
    
    System.assertEquals('', splitted[1]);
    System.assertEquals('abc', splitted[0]);
  }
  
  static testmethod void testSplitCsvQuotedSimple(){
    String line = '"abc,def"';
    String[] splitted = new SSSCsvReader(line).readLine();
    System.assertEquals('abc,def', splitted[0]);
  }
    
  static testmethod void testSplitCsvQuoted(){
    String line = '"abc,def",gh"i,"jk""l",""';
    String[] splitted = new SSSCsvReader(line).readLine();
    System.assertEquals(4, splitted.size()); 
    
    System.assertEquals('gh"i', splitted[1]);
    System.assertEquals('abc,def', splitted[0]);
    System.assertEquals('jk"l', splitted[2]);
    System.assertEquals('', splitted[3]);    
  }
  
  
  static testmethod void testSplitCsvQuotedWithNewLine(){
    String line = '"abc,def\nBoo\nBoo",Test';
    SSSCsvReader reader = new SSSCsvReader(line);
    String[] splitted = reader.readLine();
    System.assertEquals('abc,def\nBoo\nBoo', splitted[0]);
    System.assertEquals('Test', splitted[1]);
    System.assertEquals(null, reader.readLine());
  }
  
  static testmethod void testSplitCsvQuotedWithEOT(){
    String line = '"abc,def\nBoo';
    SSSCsvReader reader = new SSSCsvReader(line);
    String[] splitted = reader.readLine();
    System.assertEquals('abc,def\nBoo', splitted[0]);    
    System.assertEquals(null, reader.readLine());    
  }
  
  static testmethod void testTabDelim(){
    String line = 'abc\tdef';
    SSSCsvReader reader = new SSSCsvReader(line, '\t');
    String[] splitted = reader.readLine();
    System.assertEquals('abc', splitted[0]);
  }
  
  static testmethod void testEmptyStrings(){
    String line = ',,,,';
    SSSCsvReader reader = new SSSCsvReader(line);
    String[] splitted = reader.readLine();
    System.assertEquals(5, splitted.size());
    for(String s: splitted){
      System.assertEquals('', s);
    }
  }
  
  static testmethod void testEmptyString(){
    String line = '';
    SSSCsvReader reader = new SSSCsvReader(line);
    String[] splitted = reader.readLine();
    System.assertEquals(1, splitted.size());
    System.assertEquals('', splitted[0]);
  }
}