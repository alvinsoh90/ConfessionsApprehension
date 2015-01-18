<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.reader.xls.*" %>
<%@ page import="com.search.lucene.LuceneSearch" %>
<%@ page import="com.search.lucene.Multiplier" %>

<!DOCTYPE html>
<html lang='en'>
<head>
	<meta charset='utf-8'> <title>Welcome to Confessions Apprehension!</title>
	<script src='js/d3.min.js' type='text/javascript'></script>
	<script src='js/jquery-1.10.2.min.js' type='text/javascript'></script>
	<link href='css/style.css' rel='stylesheet' type='text/css' /> 
	<script src='js/crossfilter.js' type='text/javascript'></script>
	<script src='js/dc.js' type='text/javascript'></script>
	<script src='js/bootstrap.min.js' type='text/javascript'></script>
	<link href='css/bootstrap.min.css' rel='stylesheet' type='text/css' /> 
	<link href='css/dc.css' rel='stylesheet' type='text/css' />
	<style type="text/css"></style> 
</head>

<body>

	<div id="tagcloudx" style="background:#EBEBEB;float:left">
		<form id="searchForm" method="post" action="HiddenQueryServlet">
			<span style=padding-left:170px;height:30px;width:200px" id="buttons">	
				<input type="text" name="query" class="query" style="margin-top:20px" />
				<input type="image" src="images/search.png" alt="submit" width=30px height="30px" style="margin-top:15px" />
			</span>
		</form>
	</div>
<div class="clear"></div>

<h4>Number of Posts Across Time</h4>

<div id='linegraph' style='font: 12px sans-serif;'></div>

<div class="clear"></div>
 
<!-- Unused button. 
<div>
   	<button id="reset">Reset!</button>
</div>
 -->
 
<div class="clear"></div>

<div class='' style='font: 12px sans-serif;'>
	<div class='row'>
		<div class='span12'>
			<table class='table table-hover' id='dc-table-graph'> <thead>
				<tr class='header'> <th>Timestamp</th> <th>Message</th> <th>Number of Comments</th> <th>Number of Likes</th>
          		</tr>
        	</thead>
      		</table>
       	</div>
  	</div>
</div>
<div class="clear"></div>



<script>
	
	// EMPTY CHART
	$( document ).ready(function() {
		
	});
	
	
	
	// SEARCH QUERY AND FILL THE CHART!
	//var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
	
	var form = $('#searchForm');
	
	var indexSkipArray = [];
	var queriedDataArray = [];
	var resetDataArray = [];
	var pathArray = [];
	var dotsArray = [];
	var labelArray = [];
	var labelBackgroundArray = [];
	var yMaxArray = [];
	
	// 8 Colors!
	var colors = ['#A5AC61', '#E0D842', '#4D5E8F', '#4F93B7', '#56A388', '#A05798', '#D37699', '#B88C71'];
	var colorIndex = 0;
	// 6 Colors!
	//var colors = ['#4D9CC7', '#71BF42', '#F0CF43', '#FDA947', '#FC302D', '#6B2683'];
	//var random_color = colors[Math.floor(Math.random() * colors.length)];
	var nextLabelXPos = 0;
	
	
	// INITIALISING THE SIZE OF THE GRAPH
	var margin = {top: 30, right: 20, bottom: 30, left: 50}, 
	width = 800 - margin.left - margin.right,
	height = 270 - margin.top - margin.bottom;
					
	// INITIALISING THE X AND Y AXES
	var xScale = d3.time.scale()
					.range([0, width]);
	var yScale = d3.scale.linear()
					.range([height, 0]); 

	//var xAxis = d3.svg.axis().scale(x)
	//	.orient("bottom").ticks(5)
	//var yAxis = d3.svg.axis().scale(y)
	//	.orient("left").ticks(5);
	
	var xAxis = d3.svg.axis()
		.scale(xScale)
		.orient("bottom")
		.ticks(d3.time.months, 1)
	  	.tickFormat(d3.time.format("%b"));
		
	var yAxis = d3.svg.axis()
		.scale(yScale)
		.orient("left").ticks(10);
	
	// define the y scale  (vertical)
	/*
	var yScale = d3.scale.linear()
	        .range([height - padding, padding]);   // map these top and bottom of the chart


	var xScale =  d3.scale.linear()
	        .range([padding, width - padding]);   // map these sides of the chart, in this case 100 and 600

	*/
	
	// INITIALISING THE LINE DATA
	// datetime vs. numberofposts from the QueryServlet
	var valueline = d3.svg.line() 
		.x(function(d) { return xScale(d.datetime); }) 
		.y(function(d) { return yScale(parseInt(d.numberofposts)); });

	var path = null;
	var dots = null;
 
	// PREP the <div> with id #linegraph for the SVG
	var svg = d3.select("#linegraph").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	// TOOL TIP!
	var div = d3.select("#linegraph").append("div") 
		.attr("class", "tooltip") 
		.style("opacity", 0);

	
	
	// Functions() for the grid lines
	function make_x_axis() { 
		return d3.svg.axis()
        .scale(xScale)
        .orient("bottom")
        .ticks(10)
	}
	function make_y_axis() { 
		return d3.svg.axis()
        .scale(yScale)
        .orient("left")
        .ticks(10)
	}
	
	// INITIALISING THE DATETIME FORMAT
	var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
	
	// Set the axis limits! (the range of the data should lie in this)
	var resetData; 
	var queriedData;
	//x.domain(d3.extent(data, function(d) { return d.datetime; }));
	//y.domain([0, d3.max(data, function(d) { return d.numberofposts; })]);
	var axisData = [
	                {"datetime": "2013-01-01 00:00:00",   "numberofposts": 0},
	                {"datetime": "2013-11-30 23:59:59",    "numberofposts": 10},
	            	];
	xScale.domain(d3.extent(axisData, function(d) { return parseDate(d.datetime); }));
	yScale.domain([0, d3.max(axisData, function(d) { return d.numberofposts; })]);
	
	// Drawing the grid lines
	svg.append("g")
        .attr("class", "grid")
        .attr("transform", "translate(0," + height + ")")
        .call(make_x_axis()
            .tickSize(-height, 0, 0)
            .tickFormat("")
        )
    svg.append("g")
        .attr("class", "grid")
        .call(make_y_axis()
            .tickSize(-width, 0, 0)
            .tickFormat("")
        )
    
    svg.append("g") // Add the X Axis .attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")") .call(xAxis);

	svg.append("g")
		.attr("class", "yaxis")
		.call(yAxis);
	
	form.submit(function () {
		//alert("Hola!");
		$.ajax({
			type: form.attr('method'),
			url: form.attr('action'),
			data: form.serialize(),
			success: function (allData) {
				data = allData.jsonForLineGraph;
				var query = $('.query').val();
				
				//xlimits = d3.extent(data, function(d) { return d.datetime; });
				
				//yScale.domain([0,d3.max(data, function(d) { return d.numberofposts; })])  // redraw as percentage outstanding
				//alert(d3.max(data, function(d) { return d.numberofposts; }));
				
				// RESIZE THE Y AXIS IF NEEDED!
				var yMax = d3.max(data, function(d) { return parseInt(d.numberofposts); });
				yMaxArray.push(yMax);
				
				var newYMaxArray = [];
				for (var i = 0; i < yMaxArray.length; i++){
					console.log(indexSkipArray.indexOf(i));
					if (indexSkipArray.indexOf(i) == -1) {
						newYMaxArray.push(yMaxArray[i]);	
					}
					
				}
				
				var currentYMax = d3.max(newYMaxArray);
				console.log("Current Y Max is " + currentYMax);
				
				if (currentYMax > 10){
					yScale.domain([0,currentYMax]); // Fit the inputs i.e. 150 hits into that graph
					// REDRAW ALL THE LINES TO PROPER Y AXIS AND SCALE
				} else {
					yScale.domain([0,10]);
				}
				
				// now redraw the line
			    for (var i = 0; i < queriedDataArray.length; i++){
			    	if (indexSkipArray.indexOf(i) == -1){
			    		scaleLine(i);
			    	}
			    }
				
				/*
				valueline.y(function(d) {
			    	
			                return yScale(d/yMaxMaxMax); });
			    
			     svg.selectAll(".lines")
			                .transition()
			                .duration(500)
			                .ease("linear")
			          .attr("d", valueline);
				*/
				
				
				//yAxis.ticks(150); // Don't change number of ticks
				
				svg.select(".yaxis")
	            	.transition().duration(1500).ease("sin-in-out")  // https://github.com/mbostock/d3/wiki/Transitions#wiki-d3_ease
	            	.call(yAxis);
				
				//---------------
				// USING THE DATA
				//---------------
				queriedData = data
				queriedDataArray.push(queriedData);
				
				resetData = data;
				resetDataArray.push(resetData);
				data.forEach(function(d) {
					d.datetime = parseDate(d.datetime);
					d.numberofposts = d3.round(+d.numberofposts,0);
					//alert(d.datetime);
					//alert(d.numberofposts);
				});
				//yAxis.ticks(d3.max(data, function(d) { return d.numberofposts; }));
				//y.domain([0, d3.max(data, function(d) { return d.numberofposts; })]);
				
				// Mouseover data format: 12 Jan 2013
				//var formatTime = d3.time.format("%e %b %Y");
				var formatTime = d3.time.format("%b %Y");
				
				//var chosen_color = colors[Math.floor(Math.random() * colors.length)];
				var chosen_color = colors[colorIndex];
				colorIndex += 1;
				if (colorIndex >= 7){
					colorIndex = 0;
				}
				
				// Dotting it
				dots = svg.selectAll("dot")
		        	.data(data)
				    .enter().append("circle")
				    .attr("r", 3.5)
					.style("fill", function(d) { // <== Add these
						if (d.numberofposts <= 0) {
							return "transparent"
						} // <== Add these 
						else { 
							return chosen_color 
						} // <== Add these
						;})
					.attr("cx", function(d) { return xScale(d.datetime); }) 
					.attr("cy", function(d) { return yScale(d.numberofposts); })
					.on("mouseover", function(d) {
			            div
			            	.transition()
			            	.duration(200)
							.style("opacity", .9);
			       		
			       		div.html(formatTime(d.datetime) + "<br/><span style='color:#006699'>" + query + "</span><br/>"  + d.numberofposts + " post(s)!")
							.style("left", (d3.event.pageX) + "px")
							.style("top", (d3.event.pageY - 28) + "px");
							//.style("left", (d3.event.pageX) + "px")
			                //.style("top", (d3.event.pageY - 28) + "px");
			            })
	
					.on("mouseout", function(d) { div.transition()
			                .duration(500)
			                .style("opacity", 0);
					});
			        
				dotsArray.push(dots);
				
				// ADD THE LINE PATH!
				
				path = svg.append("path") // Add the valueline path.
				.attr("d", valueline(data))
				.attr("stroke", chosen_color);

				pathArray.push(path);
				// ANIMATE IT!
		    	var totalLength = path.node().getTotalLength();
		    
			    path
			      .attr("stroke-dasharray", totalLength + " " + totalLength) // Make it invisible
			      .attr("stroke-dashoffset", totalLength) // counting from the end, where to start? (at point t)
			      .transition()
			      .duration(1000)
			      .ease("linear")
			      .attr("stroke-dashoffset", 0);
			    
			    
			    // ----------------
			    // Text Labels!
			    //-----------------
			    //var query_pixels = query.getComputedTextLength();
			    
			    var textWidth = query.length * 7;
			    
			    var rect = svg.append('rect')
			    	.attr('width', textWidth + 10 + 10)
                	.attr('height', 25)
                	.attr('x', nextLabelXPos)
                	.attr('y', -30)
                	.style('fill', chosen_color) //fill
                	.attr('stroke', chosen_color) //outline
                	.attr('id', 'q' + (pathArray.length-1)) // q1, q2, q3
                	.attr('onclick', 'removeLine(' + (pathArray.length-1) + ')');
			    labelBackgroundArray.push(rect);
			    
				var text = svg.append('text').text(query)
                	.attr('x', nextLabelXPos + 10)
                	.attr('y', -15)
                	.attr('fill', 'white')
					.attr('id', 't' + (pathArray.length-1)) // t1, t2, t3
					.attr('onclick', 'removeLine(' + (pathArray.length-1) + ')');
				labelArray.push(text);
				
				nextLabelXPos = nextLabelXPos + textWidth + 30;
			} //end of AJAX
		});
	 
		return false;
	});
	
	function scaleLine(numberIndex){
		queriedData = queriedDataArray[Number(numberIndex)];
		queriedData.forEach(function(d) {
			d.datetime = d.datetime;
			d.numberofposts = +d.numberofposts;
		});

		// ANIMATE IT TO SCALE!
		path = pathArray[Number(numberIndex)];
		path
			.datum(queriedData)
			.transition()
			.duration(1000)
			.ease("exp-out")
			.attr("class", "line")
			.attr("d", valueline);
	
		// REMOVE THE DOTS!
		dots = dotsArray[Number(numberIndex)];
		dots
			.transition()
			.duration(500)
			.attr("cy", function(d) { return yScale(d.numberofposts); });
		
	}
	
	function removeLine(numberIndex){
		indexSkipArray.push(Number(numberIndex));
		//console.log("Before splice: " + yMaxArray);
		//console.log("Index of splice: " + Number(numberIndex));
		//yMaxArray.splice(Number(numberIndex), 1);
		//console.log("After splice: " + yMaxArray);
		
		var newYMaxArray = [];
		for (var i = 0; i < yMaxArray.length; i++){
			console.log(indexSkipArray.indexOf(i));
			if (indexSkipArray.indexOf(i) == -1) {
				newYMaxArray.push(yMaxArray[i]);	
			}
			
		}
		
		resetData = resetDataArray[Number(numberIndex)];
		resetData.forEach(function(d) {
			d.datetime = d.datetime;
			d.numberofposts = 0;
		});

		// ANIMATE IT FLAT!
		path = pathArray[Number(numberIndex)];
		path
			.datum(resetData)
			.transition()
			.duration(1000)
			.ease("exp-out")
			.attr("class", "line")
			.attr("d", valueline)
			.remove();
	
		// REMOVE THE DOTS!
		dots = dotsArray[Number(numberIndex)];
		dots.remove();
		
		// REMOVE THE LABEL!
		//var text = labelArray.push[Number(numberIndex)];
		//text.remove();
		
		//var text = d3.select("#t" + Number(numberIndex));
		$("#t" + Number(numberIndex)).fadeOut(300, function() { 
			$(this).remove(); 
		});
		//alert(labelBackgroundArray[Number(numberIndex)].attr("width"));
		
		var shiftDistance = $("#q" + Number(numberIndex)).attr("width");

		//rect.remove();
		$("#q" + Number(numberIndex)).fadeOut(300, function() { 
			$(this).remove(); 
		});
		
		// SHIFT ALL TO THE LEFT!
		for (var i = (Number(numberIndex)+1); i < labelArray.length; i++){
			var textLabel = labelArray[i];
			//alert(textLabel.attr("x"));
			var background = labelBackgroundArray[i];
			//alert(background.attr("x"));
			var currentPosText = textLabel.attr("x");
			var currentPosBg = background.attr("x");
			textLabel.transition().attr("x", currentPosText - shiftDistance - 10);
			background.transition().attr("x", currentPosBg - shiftDistance - 10);
		}
		//resetDataArray = resetDataArray.splice(Number(numberIndex), 1);
		//pathArray = pathArray.splice(Number(numberIndex), 1);
		//dotsArray = dotsArray.splice(Number(numberIndex), 1);
		//labelBackgroundArray = labelBackgroundArray.splice(Number(numberIndex), 1);
		//labelArray = labelArray.splice(Number(numberIndex), 1);
		
		nextLabelXPos = nextLabelXPos - shiftDistance - 10;
		
		// RESCALE ALL OTHER LINES!
		var currentYMax = d3.max(newYMaxArray);
		console.log("Current newYMax = " + currentYMax);
		if (currentYMax == undefined){
			yScale.domain([0,10]);
		} else if (currentYMax > 10){
			console.log("resizing the y-axis")
			yScale.domain([0,currentYMax]); // Fit the inputs i.e. 150 hits into that graph
			// REDRAW ALL THE LINES TO PROPER Y AXIS AND SCALE
		} else {
			yScale.domain([0,10]);
		}
		
		svg.select(".yaxis")
    		.transition().duration(1500).ease("sin-in-out")  // https://github.com/mbostock/d3/wiki/Transitions#wiki-d3_ease
    		.call(yAxis);
		
		//previousYMax = currentYMax;
		
		// now redraw the line
	    for (var i = 0; i < queriedDataArray.length; i++){
	    	if (indexSkipArray.indexOf(i) == -1){
	    		scaleLine(i);
	    	}
	    }
		
		
	}
	
	/* Deprecated!
	$(document).delegate('#reset', 'click' ,function(){    
		
		
		//var resetData = [
		//                {"datetime": xlimits[0],   "numberofposts": 0},
		//                {"datetime": xlimits[1],    "numberofposts": 0},
		//            	];
		
		while (resetDataArray.length > 0){
			resetData = resetDataArray.pop();
			resetData.forEach(function(d) {
				d.datetime = d.datetime;
				d.numberofposts = 0;
			});

			// ANIMATE IT FLAT!
			path = pathArray.pop();
			path
				.datum(resetData)
				.transition()
				.duration(1000)
				.ease("exp-out")
				.attr("class", "line")
				.attr("d", valueline)
				.remove();
		
			// REMOVE THE DOTS!
			dots = dotsArray.pop();
			dots.remove();
		}
		

		
	});
	*/
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*

	// Create the dc.js chart objects & link to div
	var dataTable = dc.dataTable("#dc-table-graph"); // load data from a csv file
	d3.tsv("data/smuconfessions.txt", function (data) { // format our data
		
		var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
		//var parseDate = d3.time.format("%d-%b-%y").parse;
		//var dtgFormat = d3.time.format("%Y-%m-%dT%H:%M:%S");
		
		//post_id	message	comment_num	likes	datetime
		data.forEach(function(d) {
			d.post_id = d.post_id;
			d.message = d.message;
			//d.datetrimmed = parseDate(d.date.substr(0,10) + " " + d.date.substr(11,8);
			d.comment_num = d.comment_num;
			d.likes = d.likes;
			d.datetime = parseDate(d.datetime);
		});

		// Run the data through crossfilter and load our 'facts'
		var facts = crossfilter(data);
		
		
		// Create dataTable dimension
		var timeDimension = facts.dimension(function (d) { 
			return d.datetime;
		});
		
		dataTable.width(960).height(800)
			.dimension(timeDimension)
			.group(function(d) { return "Confessions Table!" })
			.size(10)
			.columns([
				//function(d) { return d.post_id; }, 
				function(d) { return d.datetime; },
				function(d) { return d.message ; }, 
				function(d) { return d.comment_num; },
				function(d) { return d.likes; },
			])
			.sortBy(function(d){ return d.datetime; }).order(d3.descending);

		// Render the Charts
		dc.renderAll();
	});
	*/



</script>








</body>
</html>