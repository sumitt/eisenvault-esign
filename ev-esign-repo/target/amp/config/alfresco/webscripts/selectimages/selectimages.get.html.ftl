<link rel="stylesheet" href="/share/css/aristo/Aristo.css">

	<!--
		<script src="http://code.jquery.com/jquery-1.9.1.js" type="text/javascript"></script>
		<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js" type="text/javascript"></script>
	-->

<script src="/share/js/jquery.cookie.js" type="text/javascript"></script>
<script src="/share/js/jquery.dynatree.min.js" type="text/javascript"></script>
<link href="/share/css/ui.dynatree.css" rel="stylesheet" type="text/css">

<style type="text/css">
	#containment-wrapper-select-file {width: 200px; height:250px; border:2px solid #ccc; float: left; padding: 5px; top:30px; left:350px;}
</style>

<script language="Javascript">
	$(document).ready(function () {
		
		$("#tree").dynatree({
			title: "Lazy loading sample",
			fx: { height: "toggle", duration: 200 },
			autoFocus: false,
			initAjax: {
				url: Alfresco.constants.PROXY_URI+"treeview",
				data: { mode: "funnyMode" }
			},

			onActivate: function(node) {
				var key = node.data.key;
				var title = node.data.title;
				$('#nodeRef').val(key);
				$('#nodeRef').data('file',title);
				//$("#tbfiles").text(title);
				$("#filedescription").html(title);
			},
			
			onLazyRead: function(node){
				node.appendAjax({
				url: Alfresco.constants.PROXY_URI+"treeview",
				data: {key: node.data.key, mode: "funnyMode"},
				debugLazyDelay: 750
				});
			}
		});
		
		if($('#nodeRef').data('file')){
			//$('#filediv').addClass("ui-state-highlight").html("Selected " + $('#nodeRef').data('file'));
			$("#tbfiles").text($('#nodeRef').data('file'));
		}

		//#E3EBEC
	 });
</script>

<div id="containment-wrapper-select-file" class="ui-widget-content">
	<div id="tree" style="width: 200px; height:240px;">
	</div>
</div>