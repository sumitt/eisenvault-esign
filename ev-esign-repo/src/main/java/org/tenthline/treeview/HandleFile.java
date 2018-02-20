package org.tenthline.treeview;

import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfStamper;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.parser.PdfReaderContentParser;
import com.itextpdf.text.pdf.parser.TextMarginFinder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.List;

import org.alfresco.error.AlfrescoRuntimeException;
import org.alfresco.model.ContentModel;
import org.alfresco.service.ServiceRegistry;
import org.alfresco.service.cmr.model.FileExistsException;
import org.alfresco.service.cmr.model.FileFolderService;
import org.alfresco.service.cmr.model.FileInfo;
import org.alfresco.service.cmr.repository.ChildAssociationRef;
import org.alfresco.service.cmr.repository.ContentReader;
import org.alfresco.service.cmr.repository.ContentWriter;
import org.alfresco.service.cmr.repository.NodeRef;
import org.alfresco.service.cmr.repository.NodeService;
import org.alfresco.service.cmr.security.AuthenticationService;
import org.alfresco.service.cmr.security.PersonService;
import org.apache.http.ParseException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.springframework.extensions.webscripts.WebScriptRequest;
import org.springframework.extensions.webscripts.WebScriptResponse;
import org.alfresco.service.namespace.QName;

import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class HandleFile extends org.springframework.extensions.webscripts.AbstractWebScript
{
  ServiceRegistry service;
  
  protected NodeService nodeService;
  
  protected AuthenticationService authenticationService;
  
  protected PersonService personService;
  
  final QName ASPECT_SIGN_POSITION = QName.createQName("http://www.eisenvault.net/model/esign/1.0", "signPosition");
  
  final QName POSITION_Y = QName.createQName("http://www.eisenvault.net/model/esign/1.0", "yPosition");
  
  private static final DateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
  
  NodeRef esignImageNodeRef = null;

public HandleFile() {}
  
  public void setServiceRegistry(ServiceRegistry service)
  {
    this.service = service;
  }
  
  public void execute(WebScriptRequest req, WebScriptResponse res) throws IOException
  {
    try {
      PDDocument pdf = null;
      InputStream is = null;
      InputStream cis = null;
      File tempDir = null;
      File tempFile = null;
      ContentWriter writer = null;
      NodeRef savefolder = null;
      String namefile = null;
      String namefilefinal = null;
      
      try
      {
    	  int insertAt;
        
        //int x = Integer.valueOf(req.getParameter("cordinate_x")).intValue();
        int x = 10;
        //int y = Integer.valueOf(req.getParameter("cordinate_y")).intValue();
        Integer y = new Integer(0);
        NodeRef noderefSource = new NodeRef(req.getParameter("sourcenodeRef"));
        String currentUserName = authenticationService.getCurrentUserName();
        NodeRef personRef = personService.getPerson(currentUserName);
        List<ChildAssociationRef> personChildAssos = nodeService.getChildAssocs(personRef);
        if (personChildAssos.size() == 0)
        	esignImageNodeRef = null;
        System.out.println("noderefAvatarSize: "+personChildAssos.size());
        for(int i=0; i < personChildAssos.size(); i++){
        	System.out.println("noderefAvatarTypeQNameLocalName: "+personChildAssos.get(i).getTypeQName().getLocalName());
        	if (personChildAssos.get(i).getTypeQName().getLocalName().equals("preferenceESignImage")){
	        	System.out.println("My for loop is running");
	        	esignImageNodeRef = personChildAssos.get(i).getChildRef();
        	}
        }
        //NodeRef noderef = new NodeRef(req.getParameter("nodeRef"));
        //NodeRef noderef = personChildAssos.get(1).getChildRef();
        ContentReader ctnodeRef = service.getFileFolderService().getReader(esignImageNodeRef);
        ContentReader ctnodeRefSource = service.getFileFolderService().getReader(noderefSource);
        is = ctnodeRefSource.getContentInputStream();
        cis = ctnodeRef.getContentInputStream();
        byte[] imagebytes = new byte[50000];
        cis.read(imagebytes);
        File alfTempDir = org.alfresco.util.TempFileProvider.getTempDir();
        tempDir = new File(alfTempDir.getPath() + File.separatorChar + noderefSource.getId());
        tempDir.mkdir();
        String fileName = "";
        if (!service.getNodeService().getParentAssocs(noderefSource).isEmpty()) {
          ChildAssociationRef ref = (ChildAssociationRef)service.getNodeService().getParentAssocs(noderefSource).get(0);
          savefolder = ref.getParentRef();
        }
        if (!fileName.equals("")) {
          tempFile = new File(alfTempDir.getPath() + File.separatorChar + noderefSource.getId() + File.separatorChar + fileName + ".pdf");
        }
        else {
          namefile = service.getFileFolderService().getFileInfo(noderefSource).getName();
          List<FileInfo> files = service.getFileFolderService().listFiles(savefolder);
          for (int i = 1; i <= 10000; i++) {
            String[] splittedname = namefile.split("[.]");
            namefilefinal = splittedname[0] + "-" + i + "." + splittedname[1];
            for (FileInfo file : files) {
              if (file.getName().equals(namefilefinal)) {
                break;
              }
            }
            break;
          }
          tempFile = new File(alfTempDir.getPath() + File.separatorChar + noderefSource.getId() + File.separatorChar + namefilefinal);
        }
        tempFile.createNewFile();
        Image image = Image.getInstance(imagebytes);
        PdfReader pdfReader = new PdfReader(is);
        PdfReaderContentParser parser = new PdfReaderContentParser(pdfReader);
        PdfStamper pdfStamper = new PdfStamper(pdfReader, new FileOutputStream(tempFile));
        TextMarginFinder finder = new TextMarginFinder();
        PdfContentByte content;
        y = (Integer)nodeService.getProperty(noderefSource, POSITION_Y);
        if(y == null || y<=10){
        	pdfStamper.insertPage(pdfReader.getNumberOfPages() + 1, pdfReader.getPageSize(1));
        	System.out.println("Page Size is Height: "+pdfReader.getPageSize(1).getHeight());
        	System.out.println("Page Size is Top: "+pdfReader.getPageSize(1).getTop());
        	y = 800;
        	if(!nodeService.hasAspect(noderefSource, ASPECT_SIGN_POSITION))
        		nodeService.addAspect(noderefSource, ASPECT_SIGN_POSITION, null);
        }
        insertAt = pdfReader.getNumberOfPages();
        content = pdfStamper.getUnderContent(insertAt);
        content = pdfStamper.getOverContent(insertAt);
        //image.scalePercent(5.0F);
        image.scaleAbsolute(125.0F, 60.0F);
        //image.scaleAbsolute(325.0F, 360.0F);
        image.setAbsolutePosition(x, y);
        String firstName = nodeService.getProperty(personRef, ContentModel.PROP_FIRSTNAME).toString();
        String lastName = nodeService.getProperty(personRef, ContentModel.PROP_LASTNAME).toString();
        Date date = new Date();
        String signInfoLabel = "Signed by "+firstName+" "+lastName+" on "+dateFormat.format(date);
        BaseFont bf = BaseFont.createFont();
        content.beginText();
        content.setTextRenderingMode(PdfContentByte.TEXT_RENDER_MODE_FILL_STROKE);
        //content.setLineWidth(1.5f);
        //content.setRGBColorStroke(0xFF, 0x00, 0x00);
        //content.setRGBColorFill(0xFF, 0xFF, 0xFF);
        content.setFontAndSize(bf, 12);
        //content.setTextMatrix(cosinus, sinus, -sinus, cosinus, 50, 324);
        content.setTextMatrix(x+150, y+20);
        content.showText(signInfoLabel);
        content.endText();
        //content.restoreState();
        y = y-80;
        nodeService.setProperty(noderefSource, POSITION_Y, y);
        content.addImage(image);
        /*for (int i = 0; i < pages.length; i++) {
          insertAt = Integer.valueOf(pages[i]).intValue();
          //parser.processContent(insertAt, finder);
          //System.out.println("finder="+finder);
          content = pdfStamper.getUnderContent(insertAt);
          content = pdfStamper.getOverContent(insertAt);
          //System.out.println("finder X="+parser.processContent(insertAt, finder).getLlx());
          //System.out.println("finder Y="+parser.processContent(insertAt, finder).getLly());
          //content.rectangle(finder.getLlx(), finder.getLly(),finder.getWidth(), finder.getHeight());
          image.scalePercent(50.0F);
          image.setAbsolutePosition(x, y);
          content.addImage(image);
        }*/
        pdfStamper.close();
        pdfReader.close();
        for (File file : tempDir.listFiles()) {
          try {
            if (file.isFile())
            {
              //NodeRef destinationNode = createDestinationNode(file.getName(), savefolder, noderefSource);
              
              writer = service.getContentService().getWriter(noderefSource, org.alfresco.model.ContentModel.PROP_CONTENT, true);
              
              writer.setEncoding(ctnodeRef.getEncoding());
              
              writer.setMimetype("application/pdf");
              
              writer.putContent(file);
              
              file.delete();
            }
          } catch (FileExistsException e) {
            throw new AlfrescoRuntimeException("Failed to process file.", e);
          }
        }
      }
      catch (IOException e) {
        throw new AlfrescoRuntimeException(e.getMessage(), e);
      } catch (DocumentException e1) {
        e1.printStackTrace();
      } finally {
        if (pdf != null) {
          try {
            pdf.close();
          } catch (IOException e) {
            throw new AlfrescoRuntimeException(e.getMessage(), e);
          }
        }
        if (is != null) {
          try {
            is.close();
          } catch (IOException e) {
            throw new AlfrescoRuntimeException(e.getMessage(), e);
          }
        }
        if (tempDir != null) {
          tempFile.delete();
          tempDir.delete();
        }
      }
      res.getWriter().write("File has been generated sucecessfully.");
    }
    catch (ParseException e)
    {
      e.printStackTrace();
    }
  }
  

  private NodeRef createDestinationNode(String filename, NodeRef destinationParent, NodeRef target)
  {
    NodeService nodeService = service.getNodeService();
    FileInfo fileInfo = null;
    
    fileInfo = service.getFileFolderService().create(destinationParent, filename, nodeService.getType(target));
    


    NodeRef destinationNode = fileInfo.getNodeRef();
    
    return destinationNode;
  }
  
  public void setNodeService(NodeService nodeService) {
		this.nodeService = nodeService;
  }

  public void setAuthenticationService(AuthenticationService authenticationService) {
		this.authenticationService = authenticationService;
  }

  public void setPersonService(PersonService personService) {
	    this.personService = personService;
  }

  
  
}
