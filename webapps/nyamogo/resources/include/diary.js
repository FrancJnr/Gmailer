<script type='text/javascript'>
	$(document).ready(function() {
		$('#calendar').fullCalendar({
			header: {
				left: 'prev,next,today',
				center: 'title',
				right: 'month,agendaWeek,agendaDay'
			},			
			editable: true,
			weekends: false,

			eventResize: function(event, dayDelta, minuteDelta, revertFunc) {
				if (confirm("Confirm change to save new dates?")) {
					makeRequest("barazaajax?fnct=calresize&id=" + event.id + "&enddate=" + $.fullCalendar.formatDate(event.end, 'yyyy-MM-dd')
						+ "&endtime=" + $.fullCalendar.formatDate(event.end, 'HH:mm:ss'));
				} else {
					revertFunc();
				}
			},

			eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc) {
				if (confirm("Confirm change to save new dates?")) {
					makeRequest("barazaajax?fnct=calmove&id=" + event.id 
						+ "&startdate=" + $.fullCalendar.formatDate(event.start, 'yyyy-MM-dd')
						+ "&starttime=" + $.fullCalendar.formatDate(event.start, 'HH:mm:ss')
						+ "&enddate=" + $.fullCalendar.formatDate(event.end, 'yyyy-MM-dd')
						+ "&endtime=" + $.fullCalendar.formatDate(event.end, 'HH:mm:ss'));
				} else {
					revertFunc();
				}
			},

