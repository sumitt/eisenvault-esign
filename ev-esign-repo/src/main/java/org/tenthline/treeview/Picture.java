/*
 * Decompiled with CFR 0_123.
 * 
 * Could not load the following classes:
 *  com.sun.pdfview.PDFFile
 *  com.sun.pdfview.PDFPage
 *  org.alfresco.error.AlfrescoRuntimeException
 *  org.alfresco.service.ServiceRegistry
 *  org.alfresco.service.cmr.model.FileFolderService
 *  org.alfresco.service.cmr.repository.ContentReader
 *  org.alfresco.service.cmr.repository.NodeRef
 *  org.apache.http.ParseException
 *  org.springframework.extensions.webscripts.AbstractWebScript
 *  org.springframework.extensions.webscripts.WebScriptRequest
 *  org.springframework.extensions.webscripts.WebScriptResponse
 */
package org.tenthline.treeview;

import com.sun.pdfview.PDFFile;
import com.sun.pdfview.PDFPage;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Rectangle;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.ImageObserver;
import java.awt.image.RenderedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import javax.imageio.ImageIO;
import org.alfresco.error.AlfrescoRuntimeException;
import org.alfresco.service.ServiceRegistry;
import org.alfresco.service.cmr.model.FileFolderService;
import org.alfresco.service.cmr.repository.ContentReader;
import org.alfresco.service.cmr.repository.NodeRef;
import org.apache.http.ParseException;
import org.springframework.extensions.webscripts.AbstractWebScript;
import org.springframework.extensions.webscripts.WebScriptRequest;
import org.springframework.extensions.webscripts.WebScriptResponse;

public class Picture
extends AbstractWebScript {
    ServiceRegistry service;

    public void setServiceRegistry(ServiceRegistry service) {
        this.service = service;
    }

    public void execute(WebScriptRequest req, WebScriptResponse res) throws IOException {
        try {
            try {
                String[] pages = req.getParameter("pagenumber").split(",");
                int insertAt = Integer.valueOf(pages[0]);
                NodeRef noderefSource = new NodeRef(req.getParameter("sourcenodeRef"));
                ContentReader ctnodeRefSource = this.service.getFileFolderService().getReader(noderefSource);
                FileChannel channel = ctnodeRefSource.getFileChannel();
                MappedByteBuffer buf = channel.map(FileChannel.MapMode.READ_ONLY, 0, channel.size());
                PDFFile pdffile = new PDFFile((ByteBuffer)buf);
                PDFPage page = pdffile.getPage(insertAt);
                Rectangle rect = new Rectangle(0, 0, (int)page.getBBox().getWidth(), (int)page.getBBox().getHeight());
                Image img = page.getImage(220, 250, (Rectangle2D)rect, null, true, true);
                BufferedImage bufferedImage = new BufferedImage(rect.width, rect.height, 1);
                Graphics2D g = bufferedImage.createGraphics();
                g.drawImage(img, 0, 0, null);
                g.dispose();
                ImageIO.write((RenderedImage)bufferedImage, "jpg", res.getOutputStream());
                bufferedImage.flush();
                channel.close();
            }
            catch (IOException e) {
                throw new AlfrescoRuntimeException(e.getMessage(), (Throwable)e);
            }
        }
        catch (ParseException e) {
            e.printStackTrace();
        }
    }
}