<link rel="stylesheet" href="/share/css/aristo/Aristo.css">

<!--
	<script src="http://code.jquery.com/jquery-1.9.1.js" type="text/javascript"></script>
	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js" type="text/javascript"></script>
-->

<script src="/share/js/jquery.cookie.js" type="text/javascript"></script>
<script src="/share/js/jquery.dynatree.min.js" type="text/javascript"></script>
<link href="/share/css/ui.dynatree.css" rel="stylesheet" type="text/css">

<style type="text/css">
	.draggable { width: 40px; height: 5px; padding: 2px; float: left; margin: 0 2px 2px 0; }
	#containment-wrapper {width: 200px; height:250px; border:2px solid #ccc; float: right; padding: 0px;}
	.bt-select {font-size:12px;}
	#mouse-xy {
		width: 150px;
		border: 1px solid black;
		padding: 10px;
		background-color: white;
	}
</style>

<script language="Javascript">
	$(document).ready(function () {
		$( "#mouse-capture" ).draggable({
			containment: "#containment-wrapper", scroll: false,
			stop: function(e) {
				var postition = $( "#mouse-capture" ).position();
				var valueX = parseInt((postition.left - 309) * (520/154));
				var valueY = parseInt((postition.top - 9) * (820/240));
				$('#cordinate_x').val(valueX);
				$('#cordinate_y').val((valueY - 820) * -1);
			}
		});
		
		$('#mouse-capture').mousemove(function(e){  
			//$('#mouse-xy').html("X: " + e.pageX + " Y: " + e.pageY);
		});
		
		$('#selectfile').click(function(){
			$.ajax({
				url: Alfresco.constants.PROXY_URI+'selectimages',
				cache: false,
				success: function (data) {
					$('#selectfiles').html(data).dialog("open");
				},
			});
		});
		
		$('#pagenumber').change(function(){
			$('#containment-wrapper').css("background-image", "url("+Alfresco.constants.PROXY_URI+"picture?"+$('#frm1').serialize()+")");
		});

		if($('#selectfiles').length == 0){
			$( '<div id="selectfiles"/>' ).appendTo(document.body);
			$( "#selectfiles" ).dialog({
			  autoOpen: false,
			  height:400,
			  width:530,
			  draggable: false,
			  modal: true,
			  buttons: {
				"Ok": function() {
				  $(this).dialog( "close" );
				},
				Cancel: function() {
				  $(this).dialog( "close" );
				  //$('#nodeRef').data('file','');
				  //$('#nodeRef').val('');
				  //$("#filedescription").html('');
				}
			  }
			});
		}
	 });
	 //#E3EBEC
</script>

<div id="containment-wrapper">
	<div id="mouse-capture" style="font-size:10px;" class="draggable ui-widget-content">-</div>
</div>

<!--
 <div id="mouse-xy"></div>
-->

<form id="frm1" action="" class="bt-select" >
	<input type="hidden" name="nodeRef" id="nodeRef" value=""/>
	<input type="hidden" name="sourcenodeRef" id="sourcenodeRef" value=""/>
	<input type="hidden" name="ticket" id="ticket" value="${ticket}"/>
	<table style="font-size:11px;">
		<#--<tr>
			<td>Page Number:</td>
			<td><input type="text" id="pagenumber" name="pagenumber" size="2" value="1"></td>
		</tr>
		<tr>
			<td>X Value From Bottom left:</td>
			<td><input type="text" id="cordinate_x" name="cordinate_x" size="2"></td>
		</tr>
		<tr>
			<td>Y Value From Bottom left:</td>
			<td><input type="text" id="cordinate_y" name="cordinate_y" size="2"></td>
		</tr>-->
		<tr>
			<td>Select file:</td>
			<td><input type="button" id="selectfile" value="Find"/></td>
		</tr>
		<tr>
			<td id="filedescription" colspan="2"></td>
		</tr>
	</table>
</form>