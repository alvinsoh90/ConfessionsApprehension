<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.reader.xls.*" %>
<%@ page import="com.search.lucene.LuceneSearch" %>
<%@ page import="com.search.lucene.Multiplier" %>

<!DOCTYPE html>
<html lang='en'>
<head>
	<meta charset='utf-8'> <title>Welcome to Confessions Apprehension!</title>
	
	<!-- Javascripts -->
	<script src='js/d3.min.js' type='text/javascript'></script>
	<script src='js/jquery-1.10.2.min.js' type='text/javascript'></script>
	<link href='css/style.css' rel='stylesheet' type='text/css' /> 
	<script src='js/crossfilter.js' type='text/javascript'></script>
	<script src='js/dc.js' type='text/javascript'></script>
	<script src='js/bootstrap.min.js' type='text/javascript'></script>
	<script type="text/javascript" src="domtab.js"></script>
	<script src='js/jquery.dataTables.min.js' type='text/javascript'></script>
	
	<script type="text/javascript">
		document.write('<style type="text/css">');  
		document.write('div.domtab div{display:none;}<');
		document.write('/s'+'tyle>');  
	</script>	
	<script src="d3.layout.cloud.js"></script>
	
	<!-- CSS -->
	<link href='css/bootstrap.min.css' rel='stylesheet' type='text/css' /> 
	<link href='css/dc.css' rel='stylesheet' type='text/css' />
	<link href='css/jquery.dataTables.css' rel='stylesheet' type='text/css' />
	<link href='css/domtab.css' rel='stylesheet' type='text/css' />
	<style type="text/css"></style> 
</head>

<body>

	<div id="tagcloud" style="background:#EBEBEB;float:left">
		<form id="searchForm" method="post" action="QueryServlet">
			<span style=padding-left:170px;height:30px;width:200px" id="buttons">	
				<input type="text" name="query" class="query" style="margin-top:20px" />
				<input type="image" src="images/search.png" alt="submit" width=30px height="30px" style="margin-top:15px" />
				<div class="bubblingG">
				<span id="bubblingG_1">
				</span>
				<span id="bubblingG_2">
				</span>
				<span id="bubblingG_3">
				</span>
				</div>
			</span>
		</form>
	</div>
	
	<!-- HIDDEN FORM -->
	<div style="display:none">
		<form id="searchFormHidden" method="post" action="HiddenQueryServlet">
			<span style=padding-left:170px;height:30px;width:200px" id="buttons">	
				<input type="text" name="hiddenquery" class="hiddenquery" style="margin-top:20px" />
				<input type="image" src="images/search.png" alt="submit" width=30px height="30px" style="margin-top:15px" />
			</span>
		</form>
	</div>

	<div id="others" style="background:#FFFFFF;float:right">
		<div class="domtab" style="margin-top:20px;margin-left:10px">
			<ul class="domtabs">
			  <li><a href="#linegraph">Line Graph</a></li>
			  <li><a href="#wordtree" style="background:#F2F2F2">Word Tree</a></li>
			</ul>
		</div>
		
		<div><a name="linegraph" id="linegraph">
			<div class="clear"></div>
			<h4>Number of Posts Across Time</h4>
			<div class="clear"></div>
			<div id='linegraph' style='font: 12px sans-serif;' ></div>
		</a></div>
		 
		<div>
		<a name="wordtree" id="wordtree" >
			<div id="wordtree">
				<div id="viz"></div>
			</div>
		</a>
		</div>
	</div>


<!-- LINE GRAPH -->
<div class="clear"></div>


<!-- Unused button. 
<div>
   	<button id="reset">Reset!</button>
</div>
 -->
<div class="dataTableContainer"></div> 
<div class="clear"></div>



<!-- LINE GRAPH STARTS HERE -->


<script>
	var oTable;
	// EMPTY CHART
	$( document ).ready(function() {
		$(".bubblingG").hide();
		oTable = $('#dataTable').dataTable();
	});
	
	
	// SEARCH QUERY AND FILL THE CHART!
	//var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
	
	var form = $('#searchForm');
	var hiddenform = $("#searchFormHidden");
	
	var everyConfessionMap = {};
	
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
	width = 650 - margin.left - margin.right,
	height = 470 - margin.top - margin.bottom;
					
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
		.y(function(d) { return yScale(d.numberofposts); });
	        
	var path = null;
	var dots = null;
 
	// PREP the <div> with id #linegraph for the SVG
	var svglg = d3.select("#linegraph").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	// BRUSHING INITIAL
	var brush = d3.svg.brush()
    	.x(xScale)
    	.extent([new Date(2013, 1, 1), new Date(2013, 11, 31)])
    	.on("brushend", brushended);
	
	var gBrush = svglg.append("g")
    	.attr("class", "brush")
    	.call(brush)
    	.call(brush.event);
	
	gBrush.selectAll("rect")
    	.attr("height", height);
	
	// INITIALISING THE DATETIME FORMAT
	var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
	
	
	var dateLimits = brush.extent();
	var datatableData;
	
	function brushended() {
	  if (!d3.event.sourceEvent) return; // only transition after input
	  
	  oTable = $('#dataTable').dataTable();
	  //console.log(oTable);
	  //alert(brush.extent());
	  dateLimits = brush.extent();
	  
	  	//console.log(dateLimits[0]);
		//console.log(dateLimits[1]);
	  
	  if (dateLimits[0].getDate() == dateLimits[1].getDate() && dateLimits[0].getMonth() == dateLimits[1].getMonth()){
		  // Nothing selected, so reset filters
		  //console.log("Reset Filters!");
		  $.fn.dataTableExt.afnFiltering.push(
				  function( oSettings, aData, iDataIndex ) {
					return true;
				}
			);
		  // Draw!
		  oTable = $('#dataTable').dataTable();
		  //oTable.fnClearTable();
		  //oTable.fnDraw();
		  oTable.fnDraw();
		  
	  } else {
		 // console.log("Filtering!");
		  // Filter the datatable
		  $.fn.dataTableExt.afnFiltering.push(
				function( oSettings, aData, iDataIndex ) {
					var iMin = dateLimits[0].UTC();
					var iMax = dateLimits[1].UTC();
					var iVersion = parseDate(aData[4]).UTC();
					
					//console.log(iMin);
					//console.log(iMax);
					//console.log(iVersion);
					
					if ( iMin == "" && iMax == "" )
					{
						return true;
					}
					else if ( iMin == "" && iVersion < iMax )
					{
						return true;
					}
					else if ( iMin < iVersion && "" == iMax )
					{
						return true;
					}
					else if ( iMin < iVersion && iVersion < iMax )
					{
						return true;
					}
					return false;
				}
			);
		  oTable = $('#dataTable').dataTable();
		  oTable.fnDraw();
	  }
	  
	  /*
	  var extent0 = brush.extent(),
	      extent1 = extent0.map(d3.time.day.round);

	  // if empty when rounded, use floor & ceil instead
	  if (extent1[0] >= extent1[1]) {
	    extent1[0] = d3.time.day.floor(extent0[0]);
	    extent1[1] = d3.time.day.ceil(extent0[1]);
	  }

	  d3.select(this).transition()
	      .call(brush.extent(extent1))
	      .call(brush.event);
	  */
	}
	
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
	
	
	// Set the axis limits! (the range of the data should lie in this)
	var resetData; 
	//x.domain(d3.extent(data, function(d) { return d.datetime; }));
	//y.domain([0, d3.max(data, function(d) { return d.numberofposts; })]);
	var axisData = [
	                {"datetime": "2013-01-01 00:00:00",   "numberofposts": 0},
	                {"datetime": "2013-11-30 23:59:59",    "numberofposts": 10},
	            	];
	xScale.domain(d3.extent(axisData, function(d) { return parseDate(d.datetime); }));
	yScale.domain([0, d3.max(axisData, function(d) { return d.numberofposts; })]);
	
	// Drawing the grid lines
	svglg.append("g")
        .attr("class", "grid")
        .attr("transform", "translate(0," + height + ")")
        .call(make_x_axis()
            .tickSize(-height, 0, 0)
            .tickFormat("")
        )
    svglg.append("g")
        .attr("class", "grid")
        .call(make_y_axis()
            .tickSize(-width, 0, 0)
            .tickFormat("")
        )
    
    svglg.append("g") // Add the X Axis .attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")") .call(xAxis);

	svglg.append("g")
		.attr("class", "yaxis")
		.call(yAxis);
	
	var wordlistData = null;
	var map = {};
	var arr = new Array();
	var hash = {};
	var wordlist = "";
	var multiplier = 0.0;
	
	var wordcloud = null;
	
	hiddenform.submit(function() {

		$.ajax({
			type: hiddenform.attr('method'),
			url: hiddenform.attr('action'),
			data: hiddenform.serialize(),
			success: function (allData) {
				var data = null;
				var query = $('.hiddenquery').val();
				
				// STEP 3: LINE GRAPH!
				data = allData.jsonForLineGraph;
				
				//xlimits = d3.extent(data, function(d) { return d.datetime; });
				
				// RESIZE THE Y AXIS IF NEEDED!
				var yMax = d3.max(data, function(d) { return parseInt(d.numberofposts); });
				yMaxArray.push(yMax);
				
				var newYMaxArray = [];
				for (var i = 0; i < yMaxArray.length; i++){
					//console.log(indexSkipArray.indexOf(i));
					if (indexSkipArray.indexOf(i) == -1) {
						newYMaxArray.push(yMaxArray[i]);	
					}
					
				}
				
				var currentYMax = d3.max(newYMaxArray);
				//console.log("Current Y Max is " + currentYMax);
				
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
				
				svglg.select(".yaxis")
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
				dots = svglg.selectAll("dot")
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
				
				path = svglg.append("path") // Add the valueline path.
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
			    
			    var rect = svglg.append('rect')
			    	.attr('width', textWidth + 10 + 10)
                	.attr('height', 25)
                	.attr('x', nextLabelXPos)
                	.attr('y', -30)
                	.style('fill', chosen_color) //fill
                	.attr('stroke', chosen_color) //outline
                	.attr('id', 'q' + (pathArray.length-1)) // q1, q2, q3
                	.attr('onclick', 'removeLine(' + (pathArray.length-1) + ')');
			    labelBackgroundArray.push(rect);
			    
				var text = svglg.append('text').text(query)
                	.attr('x', nextLabelXPos + 10)
                	.attr('y', -15)
                	.attr('fill', 'white')
					.attr('id', 't' + (pathArray.length-1)) // t1, t2, t3
					.attr('onclick', 'removeLine(' + (pathArray.length-1) + ')');
				labelArray.push(text);
				
				nextLabelXPos = nextLabelXPos + textWidth + 30;
			}
		}); //end of AJAX
		return false;
	});
	
	
	
	form.submit(function () {
		$(".bubblingG").show();
		$.ajax({
			type: form.attr('method'),
			url: form.attr('action'),
			data: form.serialize(),
			success: function (allData) {
				$(".bubblingG").hide();
				var data = null;
				var query = $('.query').val();
				
				
				
				
				datatableData = allData.jsonForDataTable;
				var mapData = allData.jsonForWordCloudMap;
				var arrData = allData.jsonForWordCloudArr;
				var hashData = allData.jsonForWordCloudHash;
				var likeData = allData.jsonForWordCloudLikes;
				wordlistData = allData.jsonForWordCloudWordList;
				var multiplierData = allData.jsonForWordCloudMultiplier;
				
				// STEP 0: Data Table!
				drawTable(query);
				
				// STEP 1: WORD CLOUD!
				map = {};
				arr = new Array();
				hash = {};
				likes = {};
				wordlist = "";
				multiplier = multiplierData;
				
				
				everyConfessionMap[query] = datatableData;
				
				
				mapData.forEach(function(d) {
					map[d.mapKey] = d.mapValue;
					//alert(d.datetime);
					//alert(d.numberofposts);
				});
				
				mapData.forEach(function(d) {
					map[d.mapKey] = d.mapValue;
					//alert(d.datetime);
					//alert(d.numberofposts);
				});
				
				arrData.forEach(function(d) {
					arr[Number(d.arrKey)] = d.arrValue;
					//alert(d.datetime);
					//alert(d.numberofposts);
				}); 
				
				hashData.forEach(function(d) {
					hash[d.hashKey] = d.hashValue;
					//alert(d.datetime);
					//alert(d.numberofposts);
				}); 
				
				likeData.forEach(function(d) {
					likes[d.likesKey] = d.likesValue;
				});
				//console.log(map);
				//console.log(arr);
				//console.log(hash);
				
				//var tempWordList = wordlistData.replace("\"","");
				//tempWordList = tempWordList.replace(" ","");
				wordlist = wordlistData.split(",");
				//console.log(wordlist);
				
				// STEP 1: WORD CLOUD!
				d3.layout.cloud().size([600, 550])
			      .words(wordlist.map(function(d) {   //72 words
			    	  return {text: d, size: map["\"" + d + "\""] * multiplier};
			      }))
			      .padding(5)
			      .rotate(function() { return ~~0; })  // words are all horizontal
			      .font("Impact")
			      .fontSize(function(d) { return d.size; })
			      .on("end", draw)
			      .start();
			
			  function draw(words) {
				  
				if (wordcloud == null){
					wordcloud = d3.select("#tagcloud").append("svg");
				}  else {
					wordcloud.remove();
					wordcloud = d3.select("#tagcloud").append("svg");
					
				}
				  
				wordcloud
			        .attr("width", 650)
			        .attr("height", 600)
			      	.append("g")
			        .attr("transform", "translate(325,280)")
			      	.selectAll("text")
			        .data(words)
			      	.enter().append("text")
			        .style("font-size", function(d) { return d.size + "px"; })
			        .style("font-family", "Impact")
			        //.style("fill", function(d, i) { return fill(i); })   //returns the colour base on the code
			        //.style("fill", function(d) { return hash[d.text]; })
			        .style("fill", function(d) { return d3.rgb(155-likes[d.text], 155-likes[d.text], 255-likes[d.text]); })
			        .attr("text-anchor", "middle")
			        .attr("transform", function(d) {
			          return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
			        })
			        .text(function(d) { 
			        	return d.text; 
			        })
			        .attr("title", function(d, i) {
			        	return "Posts: " + hash[d.text];
			        })
			        .on("mouseover", function() {
			        	document.body.style.cursor="pointer";
			        })
			        .on("mouseout", function() {
			        	document.body.style.cursor="default";
			        })
			        .on("click", function(d) {
			        	getChoice(d.text);
			        })
			        .on("hover", function(d) {
			        	return hash[d];
			        });
			  	}
				
				
				
				// STEP 3: LINE GRAPH!
				data = allData.jsonForLineGraph;
				
				//xlimits = d3.extent(data, function(d) { return d.datetime; });
				
				// RESIZE THE Y AXIS IF NEEDED!
				var yMax = d3.max(data, function(d) { return parseInt(d.numberofposts); });
				yMaxArray.push(yMax);
				
				var newYMaxArray = [];
				for (var i = 0; i < yMaxArray.length; i++){
					//console.log(indexSkipArray.indexOf(i));
					if (indexSkipArray.indexOf(i) == -1) {
						newYMaxArray.push(yMaxArray[i]);	
					}
					
				}
				
				var currentYMax = d3.max(newYMaxArray);
				//console.log("Current Y Max is " + currentYMax);
				
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
				
				svglg.select(".yaxis")
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
				dots = svglg.selectAll("dot")
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
				
				path = svglg.append("path") // Add the valueline path.
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
			    
			    var rect = svglg.append('rect')
			    	.attr('width', textWidth + 10 + 10)
                	.attr('height', 25)
                	.attr('x', nextLabelXPos)
                	.attr('y', -30)
                	.style('fill', chosen_color) //fill
                	.attr('stroke', chosen_color) //outline
                	.attr('id', 'q' + (pathArray.length-1)) // q1, q2, q3
                	.attr('onclick', 'removeLine(' + (pathArray.length-1) + ')');
			    labelBackgroundArray.push(rect);
			    
				var text = svglg.append('text').text(query)
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
			//console.log(indexSkipArray.indexOf(i));
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
		//console.log("Current newYMax = " + currentYMax);
		if (currentYMax == undefined){
			yScale.domain([0,10]);
		} else if (currentYMax > 10){
			//console.log("resizing the y-axis")
			yScale.domain([0,currentYMax]); // Fit the inputs i.e. 150 hits into that graph
			// REDRAW ALL THE LINES TO PROPER Y AXIS AND SCALE
		} else {
			yScale.domain([0,10]);
		}
		
		svglg.select(".yaxis")
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
	
	function drawTable(query){
		var relevantConfessions = everyConfessionMap[query];
		//console.log(relevantConfessions);
		$('.dataTableContainer').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="dataTable"></table>' );
		$('#dataTable').dataTable( {
			"bFilter": false,
			"bInfo": false,
			"bProcessing": true,
	        "aaData": datatableData.aaData,
	        "aoColumns": [
	            { "sTitle": "Date & Time", "sWidth": "10%" },
	            { "sTitle": "Message", "sWidth": "50%" },
	            { "sTitle": "Number of Likes", "sWidth": "5%" },
	            { "sTitle": "Number of Comments", "sClass": "center", "sWidth": "5%" },
	            { "sTitle": "Link", "sClass": "center", "sWidth": "20%" }
	        ],
	        "bAutoWidth": false // Disable the auto width calculation
	    } );   
	}
	
		


	
	
	
	
	
	
	var searchText;
    var userChoice;
    
    //function to get the search text of the user.
    function getChoice(d){
        searchText = " " + d;
        $('.hiddenquery').val(""+ d);
        $( '#searchFormHidden' ).trigger( "submit" );
        
        d3.select("#viz").html('');
        loadwordtree();
    };
    
    //function to add words to the word tree based on the child message and the parent.
    function convertToWordTree(message, parentArr){
        var messageArr = message.trim().split(" ");
        
        //iterate through to find first word
        var nodeExist = false;
        var childrenArr;
        
        //loop through the parent array if the array is not empty.
        //check if the word in the message exist. if yes, set nodeExist as true and assign the children of the particular parent node into the childrenArr.
        if (parentArr.length != 0){
            for (var i = 0; i< parentArr.length; i++){
                if (parentArr[i].name == messageArr[0]){
                    nodeExist = true;
                    childrenArr = parentArr[i].children;
                }
            }
        }
        
        //if node does not exist in parent, create a new node with parent as the word and children as empty array.
        //Add the new node created into the parent node and instantiate the childrenArr to the empty array created in the new node.
        if (!nodeExist) {
            var newNode = {
                name: messageArr[0],
                children: []
            };
            parentArr[parentArr.length] = newNode;
            childrenArr = newNode.children;
        }
        
        //remove the first word
        var firstWord = message.trim().indexOf(" ");
        
        //do recursive calls 
        if (firstWord != -1){
            //continue to remove the word and recursively call themself
            //pass in childrenArr instead because the childrenArr is the parent now instead.
            message = message.trim().substring(firstWord+1);
            convertToWordTree(message, childrenArr);
        }
    };
    
    function loadwordtree(){
        //Filter confessions
       	 var confessionsArr = [];
         var length = arr.length;
         
         for (var i = 0; i < length; i++) {
             var message = arr[i];
             if (typeof(message) != "undefined") {
	             //Remove the header and footer to get only the content of the message
	             var startLocation = message.toLowerCase().indexOf("========== ");
	             var endLocation = message.toLowerCase().lastIndexOf("==========");
	             var mainmessage = message.substring();
	             
	             if (startLocation >= 0 && endLocation >= 0) {
	             	mainmessage = message.substring(startLocation+11, endLocation-1);
	             }
	             mainmessage = " " + mainmessage;
	             if (mainmessage.toLowerCase().indexOf(searchText)>=0){
	                 var searchTxtLocation = mainmessage.toLowerCase().indexOf(searchText)
	                 var childmessage = mainmessage.substring(searchTxtLocation, mainmessage.length);
	                 convertToWordTree(childmessage, confessionsArr);
	             }
             }
         }
         
for(var i=0; i<confessionsArr.length; i++){
            //Creating svg canvas
	var svg = d3.select("#viz").append("svg:svg");
	
	svg.append("svg:g")
		.attr("transform", "translate(40,0)"); //shift everything to right
	
	
	//Creating tree canvas
	var tree = d3.layout.tree();
	tree.nodeSize([20,120]);
				
	//Preparing data for tree layout. Convert data into array of nodes
	var nodes = tree.nodes(confessionsArr[i]);
	
	function trimX(node, parentAmt){
		if(!node.children || node.children == undefined || node.children.length ==0) return;
		for(var k=0; k<node.children.length; k++){
			var trimAmt = 90 - node.name.length*7 + parentAmt;
			node.children[k].y -= (trimAmt>0?trimAmt:0);
			trimX(node.children[k], trimAmt);
		}
	}
	
		trimX(nodes[0], 0);
	
	//Link the nodes together
	var links = tree.links(nodes);
	
	
	//console.log(confessionsArr);
	var min = 9999;
	for(var i = 0; i< nodes.length; i++){
		if(nodes[i].x<min) min = nodes[i].x;
	}
	var diagonal = d3.svg.diagonal()
					.projection(function(d) { 
						return [d.y, d.x-min+50]; 
					}); // change x and y (for the left to right tree)
	
	//console.log(min);
	var pathlink = svg.selectAll("pathlink")
					.data(links)
					.enter().append("svg:path")
					.style("stroke", "#FAC039")
					.attr("class", "link")
					.attr("d", diagonal);
	
	var node = svg.selectAll("g.node")
				.data(nodes)
				.enter().append("svg:g")
				.attr("transform", function(d){
					return "translate(" + (d.y+5) + "," + (d.x -min + 50) + ")"; 
				});
	
	//Add dot to each node
	//node.append("svg:circle")
		//.attr("r", 3.5);
	
	//place name attribute left or right depending on children
		node.append("svg:text")
			.attr("dx", function(d){
				return 15;
			})
			.attr("dy", 3)
			.attr("text-anchor", "start")
			.text(function(d){
				return d.name;
			})
			.style("font-size", 18)
		    .style("font-family", "Arial");
			
	    	svg.attr("height", ((min)*-1 + 50)*2);
		}
    };

</script>








</body>
</html>