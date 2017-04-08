function getBaseUrl() {
  return window.location.href.match(/^.*\//);
}
$(document).ready(function (){
  $("#submit").on("click", function() {
    $('#collapse_input').collapse('hide');
    $.post(
        getBaseUrl() + "sentence_string", 
        {"string": $("#sentences").val()}, 
        function(data) { fill_table(data) })
  });
});

function fill_table(data){
  $('#truthtable thead').html("")
  $('#truthtable tbody').html("")
  $('#truthtablecard').removeClass("hidden-xl-down")
  $.each(data.header, function(index, value){
    var newhead = ('<th class="sentence_head" id="formula_' + index + '">' + value + '</th>')
    $('#truthtable thead').append(newhead);
    var formula = $("#formula_" + index).get();
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, formula])
  })
  $.each(data.rows, function(r_index, r_value){
    var newrow = "<tr>"
    $.each(r_value, function(c_index, c_value){
      if(c_value.indexOf("T") >= 0){
        tval = true
      }
      else{
        tval = false
      }
      newrow += '<td id="tv_' + r_index + '_' + c_index + '" val="' + tval +'">' + c_value + '</td>'
    })
    newrow += "</tr>"
    $('#truthtable tbody').append(newrow)
  })
}
$(document).on('click', '.sentence_head', function(event){
  col = event.currentTarget
  
  x = parseInt(col.id.match(/\d+/)[0]) + 1
  $.each($("#truthtable tbody td:nth-child(" + x + ")"), function(index, value){
    sel = $('#' + value.id)
    if(value.getAttribute("val")=="true"){
      if(sel.hasClass("table-success")){ sel.removeClass("table-success") }
      else{ sel.addClass("table-success") }
    }
    else{ if(sel.hasClass("table-danger")){ sel.removeClass("table-danger") } 
          else {sel.addClass("table-danger") }}
  })
  
}) 
