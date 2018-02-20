/**
 * DocumentList and DocumentActions (details page) email actions
 * 
 * Adding action event handlers to Alfresco.doclib.Actions, which is picked up
 * by both Alfresco.DocumentList and Alfresco.DocumentActions
 * 
 * Note. this file must be loaded before document-actions.js and documentlist.js
 * 
 * @author ecmstuff.blogspot.com
 */
(function() {
	var $div = '';
	YAHOO.Bubbling.fire("registerAction", {
		actionName : "onActionAddImagesToPdfFiles",
		fn : function mycompany_onActionAddImagesToPdfFiles(file) {
			var ticket = '';
			var obj = this;
			obj.modules.actions.genericAction({
				success : {
					message: obj.msg("message.addimages.success", file.displayName, Alfresco.constants.USERNAME)
				},
				failure : {
					message : obj.msg("message.addimages.failure",
							file.displayName, Alfresco.constants.USERNAME)
				},
				webscript : {
					name : "handlefile?sourcenodeRef=" + file.nodeRef,
					stem : Alfresco.constants.PROXY_URI,
					method : Alfresco.util.Ajax.GET
				},
				config : {}
			});
		}
	});
})();