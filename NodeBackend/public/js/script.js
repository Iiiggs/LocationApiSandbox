$(document).ready(function(){
	function doPoll(){
    	$.get('/data', function(data) {
        	// alert(data.count)
        	if($('#count').text() != data.count)
        	{
        		$('#count').fadeOut(300, function() {
        			 $(this).text(data.count).fadeIn(500)
        		})
        	}

        	if($('#avg-alt').text() != data.avgAlt)
        	{
        		$('#avg-alt').fadeOut(300, function() {
        			 $(this).text(data.avgAlt).fadeIn(500)
        		})
        	}

        	if($('#avg-speed').text() != data.avgSpeed)
        	{
        		$('#avg-speed').fadeOut(300, function() {
        			 $(this).text(data.avgSpeed).fadeIn(500)
        		})
        	}

        	if($('#avg-loc-acc').text() != data.avgLocAcc)
        	{
        		$('#avg-log-acc').fadeOut(300, function() {
        			 $(this).text(data.avgLocAcc).fadeIn(500)
        		})
        	}
        	setTimeout(doPoll,5000);
    	});
	}

	doPoll()
})