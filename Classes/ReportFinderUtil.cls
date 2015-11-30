public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    Pagereference pr = new Pagereference('/servlet/servlet.ReportList');
    Dom.Document doc = getDomDocumentFromPageReference(pr);
    Dom.Xmlnode root = doc.getRootElement();
    Dom.Xmlnode reportNode = getReportNode(root, reportName);
    if (reportNode != null){
      String val = reportNode.getChildElement('id', null).getText();
      if(val != null)
        return val;
    }
    return '00O';
  }
   
  private Dom.Xmlnode getReportNode(Dom.Xmlnode root, String reportName){
    Dom.Xmlnode wantedNode;
    For(Dom.Xmlnode child: root.getChildElements()){
        if(child.getAttribute('name', null)==reportName){
         return child;
      }
    }   
    return null;
  }
  
  Private Dom.Document getDomDocumentFromPageReference(PageReference pr){
    Dom.Document dom = new Dom.Document();
    String domString = null;
    Blob content = null;
    try {
        if (pr != null) {
            content = pr.getContent();
            if (content != null) {
                domString = content.toString();
            }
        }
    } catch(Exception e) {
    }
    
    if (domString != null) {
        dom.load(domString);
    }
    
    return dom;
  }
  
}