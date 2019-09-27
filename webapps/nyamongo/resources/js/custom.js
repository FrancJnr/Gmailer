$(document).ready(function() {
	$("#panelbar").kendoPanelBar({
		expandMode: "single"
	});
});

$(document).ready(function() {
	$(".tabstrip").kendoTabStrip({
		animation:      {
			open: {
				effects: "fadeIn"
			}
		}                                        
	});
});

$(document).ready(function() {
    $(".treeview").kendoTreeView();
});

$(document).ready(function() {
	$(".datepicker").kendoDatePicker({
		format: "dd/MM/yyyy"
	});
});

$(document).ready(function() {
	$(".timepicker").kendoTimePicker({
		format: "hh:mm tt"
	});
});

$(document).ready(function() {
	$(".datetimepicker").kendoTimePicker({
		format: "hh:mm tt"
	});
});

$(document).ready(function() {
	$(".combobox").width(400).kendoComboBox();
});

$(document).ready(function() {
	$(".formcombobox").width(250).kendoComboBox();
});

$(document).ready(function() {
	$(".fnctcombobox").kendoComboBox();
});

$(document).ready(function() {
	$(".numerictextbox").kendoNumericTextBox();
});

function myClientWin(file, window) {
	childWindow=open(file,window,'resizable=no,width=920,height=590,toolbar=yes,scrollbars=no');
	if (childWindow.opener == null) childWindow.opener = self;
}

function updateField(valueid, valuename) {
	document.getElementsByName(valueid)[0].value = valuename;
}

$(document).ready(function() {
	$("#files").kendoUpload({
		async: {
			saveUrl: "putbarazafiles",
			autoUpload: true
		}
	});
});




