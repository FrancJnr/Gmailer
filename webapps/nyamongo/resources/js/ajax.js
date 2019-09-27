function makeRequest(url) {
	var httpRequest;

	if (window.XMLHttpRequest) { // Mozilla, Safari, ...
		httpRequest = new XMLHttpRequest();
	} else if (window.ActiveXObject) { // IE
		try {
			httpRequest = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}

	if (!httpRequest) {
		alert('Giving up : Cannot create an XMLHTTP instance');
		return false;
	}

	httpRequest.onreadystatechange = function() { processReq(httpRequest); };
	httpRequest.open('GET', url, true);
	httpRequest.send('');
}

function processReq(httpRequest) {
	var xmlDoc;

	if (httpRequest.readyState == 4) {		
		document.getElementById("ajaxDiv").innerHTML = httpRequest.responseText;
	}
}



