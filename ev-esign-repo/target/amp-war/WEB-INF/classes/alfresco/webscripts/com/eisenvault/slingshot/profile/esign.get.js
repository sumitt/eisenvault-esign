/**
 * User Profile - User esign GET method
 * 
 * Returns a user esign image in the format specified by the thumbnailname, or the "esign" preset if omitted.
 * 
 * @method GET
 */

function getPlaceholder(thumbnailName)
{
   // Try and get the place holder resource for a png esign.
   var phPath = thumbnailService.getMimeAwarePlaceHolderResourcePath(thumbnailName, "images/png");
   if (phPath == null)
   {
      // 404 since no thumbnail was found
      status.setCode(status.STATUS_NOT_FOUND, "Thumbnail was not found and no place holder resource set for '" + thumbnailName + "'");
      return;
   }
   
   return phPath;
}

function main()
{
   var userName = url.templateArgs.username,
       thumbnailName = url.templateArgs.thumbnailname || "esign",
       esignNode;
   
   // If there is no store type, store id or id on the request then this WebScript has most likely been requested
   // for a user with no esign image so we will just return the placeholder image.
   if (userName == null && url.templateArgs.store_type == null && url.templateArgs.store_id == null && url.templateArgs.id == null)
   {
      // If there is no userName or nodeRef data then we want to return the browser cacheable placeholder...
      model.contentPath = getPlaceholder(thumbnailName);
      model.allowBrowserToCache = "true";
      return;
   }
   else if (url.templateArgs.store_type == null && url.templateArgs.store_id == null && url.templateArgs.id == null)
   {
      // There is no nodeRef data but there is a username... this should return the user image that needs revalidation
      var person = people.getPerson(userName);
      if (person == null)
      {
         // Stream the placeholder image
         model.contentPath = getPlaceholder(thumbnailName);
         return;
      }
      else
      {
         // Retrieve the esign NodeRef for this person, if there is one.
         var esignAssoc = person.assocs["cm:esign"];
         if (esignAssoc != null)
         {
            esignNode = esignAssoc[0];
         }
      }
   }
   else if (userName == null)
   {
      // There is no user name but there is nodeREf data... this should return the image that CAN be cached by the browser
      model.allowBrowserToCache = "true";
      esignNode = search.findNode(url.templateArgs.store_type + "://" + url.templateArgs.store_id + "/" + url.templateArgs.id);
      if (esignNode == null)
      {
         // Stream the placeholder image if the esign node cannot be found.
         model.contentPath = getPlaceholder(thumbnailName);
         return;
      }
   }
   
   // Get the thumbnail for the esign...
   if (esignNode != null)
   {
      // Get the thumbnail
      var thumbnail = esignNode.getThumbnail(thumbnailName);
      if (thumbnail == null || thumbnail.size == 0)
      {
         // Remove broken thumbnail
         if (thumbnail != null)
         {
            thumbnail.remove();
         }
         
         // Force the creation of the thumbnail
         thumbnail = esignNode.createThumbnail(thumbnailName, false);
         if (thumbnail != null)
         {
            model.contentNode = thumbnail;
            return;
         }
      }
      else
      {
         // Place the details of the thumbnail into the model, this will be used to stream the content to the client
         model.contentNode = thumbnail;
         return;
      } 
   }
   
   // Stream the placeholder image
   model.contentPath = getPlaceholder(thumbnailName);
}

main();