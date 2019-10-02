$(document).ready(function() {
						  	
	//for Caching
	var $content = $('#content');
	
	/*----------------------------------------------------------------------*/
	/* Widgets
	/*----------------------------------------------------------------------*/
	$content.find('div.widgets').wl_Widget();

	//WYSIWYG Editor
	$content.find('textarea.html').wl_Editor();

	/*----------------------------------------------------------------------*/
	/* All Form Plugins
	/*----------------------------------------------------------------------*/
	
	//Integers and decimals
	$content.find('input[type=number].integer').wl_Number();
	$content.find('input[type=number].decimal').wl_Number({decimals:2,step:0.5});
	
	//Date and Time fields
	$content.find('input.date, div.date').wl_Date();
	$content.find('input.time').wl_Time();

	//Elastic textareas (autogrow)
	$content.find('textarea[data-autogrow]').elastic();

	//Validation
	$content.find('input[data-regex]').wl_Valid();
	$content.find('input[type=email]').wl_Mail();
	$content.find('input[type=url]').wl_URL();

	//Sliders
	$content.find('div.slider').wl_Slider();

	/*----------------------------------------------------------------------*/
	/* Alert boxes
	/*----------------------------------------------------------------------*/
	
	$content.find('div.alert').wl_Alert();
	
	/*----------------------------------------------------------------------*/
	/* Breadcrumb
	/*----------------------------------------------------------------------*/
	
	$content.find('ul.breadcrumb').wl_Breadcrumb();

	/*----------------------------------------------------------------------*/
	/* Tipsy Tooltip
	/*----------------------------------------------------------------------*/
	
	$content.find('input[title]').tipsy({
		gravity: function(){return ($(this).data('tooltip-gravity') || config.tooltip.gravity); },
		fade: config.tooltip.fade,
		opacity: config.tooltip.opacity,
		color: config.tooltip.color,
		offset: config.tooltip.offset
	});

	/*----------------------------------------------------------------------*/
	/* Dialog trigger buttons
	/* http://revaxarts-themes.com/whitelabel/dialogs_and_buttons.html
	/*----------------------------------------------------------------------*/		
	$('#save').click(function(){
		$.msg("Record has been saved",{header:'Successful'},{live:10000});
						
		// Assign handlers immediately after making the request,
		// and remember the jqxhr object for this request
		//var jqxhr = $.post("index.jsp", function() {					
		//	$.msg("Saving",{header:'Saving'},{live:1000});
		//})
		//.success(function() { $.msg("Record has been saved",{header:'Successful'},{live:3000});})
		//.error(function() { alert("error"); })
		//.complete(function() { $.msg("Record has been saved",{header:'Successful'},{live:10000}) });

		// perform other work here ...
		// Set another completion function for the request above
		//jqxhr.complete(function(){ alert("second complete"); });		
	});

	$('#delete').click(function(){
		$.confirm("Are you sure you want to Delete ?",
		function(){
			var m = $.msg("Confirmed!",{header:'Delete'},{sticky:true});
								
			setTimeout(function(){
					if(m)m.setBody('Deleting....');				
				},1000);
			
			setTimeout(function(){
				if(m)m.close(function(){
					$.alert('This is the Callback function');				  
					});
				},3000);
			},
		function(){
			$.msg("Operation Cancelled");
			});
	});
	
	/*----------------------------------------------------------------------*/
	/* Helpers
	/*----------------------------------------------------------------------*/
	
	//placholder in inputs is not implemented well in all browsers, so we need to trick this		
	$("[placeholder]").bind('focus.placeholder',function() {
		var el = $(this);
		if (el.val() == el.attr("placeholder") && !el.data('uservalue')) {
			el.val("");
			el.removeClass("placeholder");
		}
	}).bind('blur.placeholder',function() {
		var el = $(this);
		if (el.val() == "" || el.val() == el.attr("placeholder") && !el.data('uservalue')) {
			el.addClass("placeholder");
			el.val(el.attr("placeholder"));
			el.data("uservalue",false);
		}else{
		
		}
	}).bind('keyup.placeholder',function() {
		var el = $(this);
		if (el.val() == "") {
			el.data("uservalue",false);
		}else{
			el.data("uservalue",true);
		}
	}).trigger('blur.placeholder');



});



