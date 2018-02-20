(function(){var a=YAHOO.util.Dom,g=YAHOO.util.KeyListener,n=YAHOO.util.Selector;var m=Alfresco.util.encodeHTML,e=Alfresco.util.combinePaths,q=Alfresco.util.hasEventInterest;Alfresco.module.RulesPicker=function(t){Alfresco.module.RulesPicker.superclass.constructor.call(this,t);this.name="Alfresco.module.RulesPicker";if(t!="null"){YAHOO.Bubbling.on("siteChanged",this.resetRules,this);YAHOO.Bubbling.on("containerChanged",this.resetRules,this)}Alfresco.util.ComponentManager.reregister(this);this.options=YAHOO.lang.merge(this.options,{allowedViewModes:[Alfresco.module.DoclibGlobalFolder.VIEW_MODE_SITE,Alfresco.module.DoclibGlobalFolder.VIEW_MODE_REPOSITORY,Alfresco.module.DoclibGlobalFolder.VIEW_MODE_USERHOME,Alfresco.module.DoclibGlobalFolder.VIEW_MODE_SHARED]});return this};var b=Alfresco.module.RulesPicker;YAHOO.lang.augmentObject(b,{MODE_PICKER:"picker",MODE_COPY_FROM:"copy-from",MODE_LINK_TO:"link-to"});YAHOO.extend(Alfresco.module.RulesPicker,Alfresco.module.DoclibGlobalFolder,{setOptions:function k(v){var t={viewMode:Alfresco.module.DoclibGlobalFolder.VIEW_MODE_SITE,extendedTemplateUrl:Alfresco.constants.URL_SERVICECONTEXT+"modules/rules/rules-picker"};if(typeof v.mode!=="undefined"){var u={};u[b.MODE_PICKER]="";u[b.MODE_COPY_FROM]="copy-from";u[b.MODE_LINK_TO]="link-to";t.dataWebScript=u[v.mode]}return Alfresco.module.RulesPicker.superclass.setOptions.call(this,YAHOO.lang.merge(t,v))},onTemplateLoaded:function h(t){Alfresco.util.Ajax.request({url:this.options.extendedTemplateUrl,dataObj:{htmlid:this.id},successCallback:{fn:this.onExtendedTemplateLoaded,obj:t,scope:this},failureMessage:"Could not load 'rules-picker' template:"+this.options.extendedTemplateUrl,execScripts:true})},onExtendedTemplateLoaded:function d(t,u){var v=document.createElement("div");v.setAttribute("style","display:none");v.innerHTML=t.serverResponse.responseText;this.widgets.rulesContainerEl=a.getFirstChild(v);Alfresco.module.RulesPicker.superclass.onTemplateLoaded.call(this,u)},onViewModeChange:function s(t,u){this.widgets.okButton.set("disabled",true);a.get(this.id+"-rulePicker").innerHTML="";Alfresco.module.RulesPicker.superclass.onViewModeChange.call(this,t,u)},onSiteChanged:function i(u,t){this.widgets.okButton.set("disabled",true);a.get(this.id+"-rulePicker").innerHTML="";Alfresco.module.RulesPicker.superclass.onSiteChanged.call(this,u,t)},onNodeClicked:function f(t){Alfresco.logger.debug("RulesPicker_onNodeClicked");Alfresco.module.RulesPicker.superclass.onNodeClicked.call(this,t);this._loadRules()},onOK:function c(D,H){var I=[],B=n.query("input[type=checkbox]",this.id+"-rulePicker"),E;for(var A=0,z=B.length;A<z;A++){E=B[A];if(E.checked){I.push(E.value)}}if(this.options.mode==b.MODE_PICKER){YAHOO.Bubbling.fire("rulesSelected",{ruleNodeRefs:I,eventGroup:this});this.widgets.dialog.hide()}else{var x;if(YAHOO.lang.isArray(this.options.files)){x=this.options.files[0]}else{x=this.options.files}var v=Alfresco.constants.PROXY_URI,t={},C=null,u={};if(this.options.mode==b.MODE_COPY_FROM){C="rulesCopiedFrom";u={nodeRef:x.nodeRef,ruleNodeRefs:I}}else{if(this.options.mode==b.MODE_LINK_TO){v=Alfresco.constants.PROXY_URI+"api/actionQueue";C="rulesLinkedTo";t={actionedUponNode:x.nodeRef,actionDefinitionName:"link-rules",parameterValues:{link_from_node:this.selectedNode.data.nodeRef}};u={nodeRef:x.nodeRef,ruleNodeRefs:this.selectedNode.data.nodeRef}}}var G=function F(J){this.widgets.dialog.hide();this.widgets.feedbackMessage.destroy();Alfresco.util.PopupManager.displayMessage({text:this.msg("message.success")});YAHOO.Bubbling.fire(C,u)};var w=function y(J){this.widgets.okButton.set("disabled",false);this.widgets.cancelButton.set("disabled",false);this.widgets.feedbackMessage.hide();Alfresco.util.PopupManager.displayPrompt({text:this.msg("message.failure")})};this.widgets.feedbackMessage=Alfresco.util.PopupManager.displayMessage({text:this.msg("message.please-wait"),spanClass:"wait",displayTime:0});Alfresco.util.Ajax.jsonPost({url:v,dataObj:t,successCallback:{fn:G,scope:this},failureCallback:{fn:w,scope:this}})}this.widgets.okButton.set("disabled",true);this.widgets.cancelButton.set("disabled",true)},_loadRules:function l(){var x=a.get(this.id+"-rulePicker"),w=this;x.innerHTML="";a.removeClass(x,"");var u=function t(z,A){var K=z.json.data,y=0,B,G,L;for(var C=0,H=K.length;C<H;C++){G=K[C];if(G.owningNode&&G.owningNode.nodeRef==A.parentNodeRef){B=document.createElement("div");L=function E(M){return function(){YAHOO.Bubbling.fire("ruleChanged",{site:M,eventGroup:w})}}(G.shortName);var D=(this.options.mode==b.MODE_COPY_FROM||this.options.mode==b.MODE_PICKER)?'<input type="checkbox" value="'+G.id+'">':"",F="<h4>"+D+"<span>"+m(G.title)+"</span></h4>",J='<span class="description">'+m(G.description)+"</span>",I='<span class="rule">'+F+J+"</span>";B.innerHTML=I;B.onclick=L;A.rulePicker.appendChild(B);y++}}if(B){a.addClass(B,"last")}this.widgets.okButton.set("disabled",y==0)};var v=this.selectedNode.data.nodeRef.replace("://","/");Alfresco.util.Ajax.jsonGet({url:Alfresco.constants.PROXY_URI+"api/node/"+v+"/ruleset/rules",successCallback:{fn:u,scope:this,obj:{rulePicker:x,parentNodeRef:this.selectedNode.data.nodeRef}}});this.widgets.okButton.set("disabled",true)},resetRules:function p(u,t){a.get(this.id+"-rulePicker").innerHTML="";this.widgets.okButton.set("disabled",true)},msg:function o(u){var t=Alfresco.util.message.call(this,this.options.mode+"."+u,this.name,Array.prototype.slice.call(arguments).slice(1));if(t==(this.options.mode+"."+u)){t=Alfresco.util.message.call(this,u,this.name,Array.prototype.slice.call(arguments).slice(1))}if(t==u){t=Alfresco.util.message(u,"Alfresco.module.DoclibGlobalFolder",Array.prototype.slice.call(arguments).slice(1))}return t},_showDialog:function j(){if(this.widgets.rulesContainerEl){a.insertAfter(this.widgets.rulesContainerEl,a.get(this.id+"-treeview").parentNode);a.addClass(this.id+"-dialog","rules-picker");this.widgets.rulesContainerEl=null}a.get(this.id+"-rulePicker").innerHTML="";this.widgets.okButton.set("label",this.msg("button"));this.widgets.okButton.set("disabled",false);this.widgets.cancelButton.set("disabled",false);return Alfresco.module.RulesPicker.superclass._showDialog.apply(this,arguments)}});var r=new Alfresco.module.RulesPicker("null")})();