MathJax.Hub.Config({
  jax: ["input/TeX","output/HTML-CSS"],
  "HTML-CSS": {scale: 115},
  displayAlign: "left"
});

function getBaseUrl() {
  return window.location.href.match(/^.*\//);
}

function reset_all(){
    $('#input_title_block').removeClass("bg-primary card-inverse");
    $('#input_title_block').addClass("bg-default");
    $('#input').removeClass("card-primary");
    $('#input').addClass("card-default");
    $('#submit').removeClass("btn-primary");
	$('#error_display').html("")
	$('#error_display').addClass("hidden-xl-down");
}

$(document).ready(function (){
	$('#extension').focus()
    $("#submit").on("click", function() {
        var post_request = $.post(
            getBaseUrl() + "extension_submit", 
            {"extension": $("#extension").val()})
        post_request.done(function(data) { 
			reset_all()
			$('#collapse_input').collapse('hide');
			create_graph(data) });
		post_request.fail(function(jqXHR, message, error) { 
			$('#error_display').empty()
			$('#error_display').removeClass("hidden-xl-down")
			$('#error_display').append("<span> " + jqXHR.responseText + "</span>")
		});
	});
	$('#collapse_input').on('show.bs.collapse', function(event){
		toggle_input_colors(event)
	});
	$('#collapse_input').on('hide.bs.collapse', function(event){
		toggle_input_colors(event)
	});
	$('#extension').keypress(function (e) {
		if (e.which == 13) {
			$('#submit').click()
		}
	})
});

function toggle_input_colors(e){
	if(e.type == "hide"){
		$('#input_title_block').removeClass('card-inverse bg-primary')
		$('#input_title_block').addClass('card-default')
	}
	else{
		$('#input_title_block').addClass('card-inverse bg-primary')
		$('#input_title_block').removeClass('card-default')
	}

}


function create_graph(data){
  console.log(data)

  var graph_id = "default"

  $('#graph').removeClass("hidden-xl-down")
  $('#graph_holder').html("")

  // number of variables, rows, etc.
  var n_dots = Object.keys(data.ids).length;
  if(n_dots > 6){ var n_rows = 3}
  else{ if(n_dots > 1){ var n_rows = 2} else{ var n_rows = 1}};
  var dots_per_row = Math.ceil(n_dots / n_rows);
  console.log("n_rows with logarithm: ", Math.max(1, Math.ceil(Math.log(n_dots) / Math.log(2))))
  console.log(n_rows + '=' + dots_per_row);

  var width = parseInt(d3.select('#graph_holder').style('width'), 10);

  var radius = 15
  var y_margin = 80 + radius
  var x_margin = 10 + radius

  var x_spacing = (width - x_margin * 2 - dots_per_row * radius) / dots_per_row
  var y_spacing = radius * 12
  var height = (n_rows - 1) * y_spacing + y_margin * 2;

  var color = d3.scaleOrdinal(d3.schemeCategory20);

  var svg = d3.select("#graph_holder").append("svg")
      .attr("width", width)
      .attr("height", height);

  // Try to apply arrows here
  // 
  svg.append("svg:defs").selectAll("marker")
    .data(["end"])      // Different link/path types can be defined here
  .enter().append("svg:marker")    // This section adds in the arrows
    .attr("id", String)
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 15)
    .attr("refY", -1.5)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
  .append("svg:path")
    .attr("d", "M0,-5L10,0L0,5");

  svg.append("svg:defs").selectAll("marker")
    .data(["highlight"])      // Different link/path types can be defined here
  .enter().append("svg:marker")    // This section adds in the arrows
    .attr("id", String)
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 15)
    .attr("refY", -1.5)
    .attr("markerWidth", 3)
    .attr("markerHeight", 3)
    .attr("orient", "auto")
  .append("svg:path")
    .attr("d", "M0,-5L10,0L0,5");

  var nodes = $.map(data.ids, function(index, value){
      return {"size": radius, "label": value, "has_self": index.has_self}
  });

  var cur_row = 0
  var cur_position = 0
  var dots_in_this_row = dots_per_row
  $.each(nodes, function(index, value){
    console.log(index, value)
    // new row if > dots_per_row
    if(cur_position > dots_per_row - 1){ cur_position = 0; cur_row += 1; if(nodes.length - index > dots_per_row){ dots_in_this_row = dots_per_row }else{ dots_in_this_row = nodes.length - index}}
    // how many total on this row? (nodes.length - index) % dots_per_row
    cx = (cur_position + 1) * width / (dots_in_this_row + 1)
    cy = y_margin + cur_row * y_spacing 
    if(cx < width / 2){ orient_labels_x = -1 }else{if(cx > width / 2){orient_labels_x = 0.5} else {orient_labels_x = -0.2}}
    if(cy < height / 2){ orient_labels_y = -0.5 }else{if(cy > height / 2){orient_labels_y = 1} else {orient_labels_y = -0.5}}
    node = svg.append("circle")
      .attr("r", value.size)
      .attr("cx", cx)
      .attr("cy", cy)
      .attr("fill", color(value.label))
      .attr("id", "node_" + graph_id + "_" + value.label)
    svg.append("text")
      .attr("x", cx + orient_labels_x * radius * 4)
      .attr("y", cy + orient_labels_y * radius * 4)
      .attr("font-size", "30pt")
      .text(value.label );
    $('#node_' + graph_id + '_' + value.label).click(function(event){
        $('.' + value.label + '_links').toggleClass("highlight_from")
        $('.' + "links_" + value.label).toggleClass("highlight_to")
        $('.' + "link").not("." + value.label + "_links").not(".links_" + value.label).toggleClass("non_highlighted")
    })
    cur_position += 1;


  });

  var links = $.map(data.links, function(targets, source){
    return $.map(targets, function(i, t){
      return {"source": source, "target": i}});
    });


  $.each(links, function(index, value){
    console.log(value)
    source_node = $('#node_' + graph_id + "_" + value.source)
    target_node = $('#node_' + graph_id + "_" + value.target)
    console.log(source_node, target_node)
    sx = source_node.attr("cx")
    sy = source_node.attr("cy")
    tx = target_node.attr("cx")
    ty = target_node.attr("cy")
    dist = Math.sqrt((sx - tx) ** 2 + (sy - ty) ** 2) 
    console.log(dist)
    if(sx == tx && sy == ty){
      tx = parseFloat(tx) + 0.01
      ty = parseFloat(ty) + 0.01
      if(sx < width / 2){ orient_loops_x = 45 }else{if(sx > width / 2){orient_loops_x = 1} else {orient_loops_x = -45}}
      if(sy < height / 2){ orient_loops_y = 4 }else{if(sy > height / 2){orient_loops_y = 4} else {orient_loops_y = 1}}
      orient = orient_loops_x * orient_loops_y
      svg.append("path")
        .attr("d", "M" + sx + "," + sy + "A" + 1.5 * radius + "," + 1.5 * radius + " " + orient + " 1,1 " + tx + "," + ty)
        .attr("class", "link self_referenced " + value.source + "_links links_" + value.target)
    }
    else{
    svg.append("path")
      .attr("d", "M" + sx + "," + sy + "A" + dist + "," + dist + " 0 0,1 " + tx + "," + ty)
      .attr("class", "link " + value.source + "_links links_" + value.target)
      .attr("marker-end", "url(#end)");
    }
  })
  /*
   * 

        .attr("d", function(d) { 
          var dx = d.target.x - d.source.x;
          var dy = d.target.y - d.source.y;
          var dr = Math.sqrt(dx * dx + dy * dy)
          return "M" + 
            d.source.x + "," + d.source.y + "A" + 
            dr + "," + dr + " 0 0,1 " +
            d.target.x + "," + d.target.y;})


  var simulation = d3.forceSimulation()
      .force("link", d3.forceLink().id(function(d){return d.label;}).distance(50).strength(0.1))
      .force("charge", d3.forceManyBody().strength(-50).distanceMin(10))
      .force("center", d3.forceCenter(width / 2, height / 2));

  function createGraph(error, graph){
    if(error) throw error;
    console.log("createGraph links", graph.links)

    var link = svg.append("g")
          .attr("class", "links")
        .selectAll("path")
        .data(graph.links)
        .enter().append("path")
          .attr("class","link")
          .attr("marker-end", "url(#end)");

    var node = svg.append("g")
        .attr("class", "nodes")
      .selectAll("circle")
      .data(graph.nodes)
      .enter().append("circle")
        .attr("r", function(d) { return d.size })
        .attr("fill", function(d) { return color(d.label); })
        .attr("stroke", function(d) { if(d.has_self == 'T'){ return "green" } else{return color(d.label)}})
        .attr("stroke-width", function(d) { return d.size / 2})
        .attr("class", "node")
        .call(d3.drag()
            .on("start", dragstarted)
            .on("drag", dragged)
            .on("end", dragended));

    var text = svg.append("g")
      .attr("class", "labels")
    .selectAll("g")
      .data(graph.nodes)
    .enter().append("g");
    
    text.append("text")
      .attr("x", function(d) { return d.size + 5})
      .attr("y", "0.31em") 
      .text(function(d) { return d.label });

    node.on("click", function(d){
      console.log("clicked", d.label)});

    node.append("title")
      .text(function(d) { return d.label; });
    

    simulation
      .nodes(graph.nodes)
      .on("tick", ticked);

    simulation.force("link")
      .distance(30)
      .links(graph.links);

    function ticked(){
      link
        .attr("d", function(d) { 
          var dx = d.target.x - d.source.x;
          var dy = d.target.y - d.source.y;
          var dr = Math.sqrt(dx * dx + dy * dy)
          return "M" + 
            d.source.x + "," + d.source.y + "A" + 
            dr + "," + dr + " 0 0,1 " +
            d.target.x + "," + d.target.y;})

      node
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });

      text
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")";})
    
    };
  }


  function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }

  function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
  }

  function dragended(d) {

    if (!d3.event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }

  graph_data = {"nodes": nodes, "links": links}

  createGraph(false, graph_data)
  */
}
