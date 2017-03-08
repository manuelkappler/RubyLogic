MathJax.Hub.Config({
  jax: ["input/TeX","output/HTML-CSS"],
  displayAlign: "left"
});

function getBaseUrl() {
  return window.location.href.match(/^.*\//);
}

function get_laws(id){
    $('#availablelaws button').remove();
    $.get(getBaseUrl() + "get_laws/" + id, function(data){
        var lawdiv = $("#availablelaws");
        $.each(data, function(index, value){
            if (value == true){
              lawdiv.append('<button class="law_item btn-lg btn-success" id="' + index + '"> ' + index +'</button>');
              }
            else{
              var law = index
              $.each(value, function(index, value){
                lawdiv.append('<button class="law_item btn-lg btn-success" id="' + law + '_' + index + '"> ' + law + ': ' + value +'</button>');
              })
            }
        });
    })
    $('#select_law').css('visibility', 'visible');
}


function refresh_proof_table(data){
    $('#prooftable tbody tr').remove();
    $.each(data, function(index, value){
        var newrow = ('<tr><td>' + value[0] + '</td><td> <span id="proofrow' + index + '">' + value[1] + '</span></td><td><span id="lawrow' + index + '">' + value[2] + '</span></td><td>' + value[3] + '</td></tr>');
        $('#prooftable tbody').append(newrow)
        var proofspan = $("#proofrow" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, proofspan]);
        var lawspan = $("#lawrow" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, lawspan]);
    });
}

function refresh_next_step(data){
    $('#workingon').html("")
    var dimen = 12 / (data.premises.length + data.conclusion.length + 1);
    $.each(data.premises, function(index, value){
        var premise_separator = index + 1 < data.premises.length ? ', ' : ''
        var new_element = '<div class="wff col-md-' + dimen + '" id="premise' + index + '"> \\(' + value + '\\)' + premise_separator + '</div>';
        $('#workingon').append(new_element);
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('#workingon_element' + index).get()]);
    });
    $('#workingon').append('<div class="implication_separator col-md-' + dimen + '">\\(\\models\\)</div>')
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('.implication_separator').get()]);
    $.each(data.conclusion, function(index,value){
        var new_element = '<div class="wff col-md-' + dimen + '" id="conclusion' + index + '"> \\(' + value + '\\) </div>';
        $('#workingon').append(new_element);
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('#workingon_conclusion' + index).get()]);
    })
    $('#select_component').css('visibility', 'visible');
}



$(document).ready(function (){
    $("#submit").on("click", function() {
        $('.done').css("display", "none");
        $('.done #message').html("")
        $('.next_step').css("display", "inline");
        $.post(
            getBaseUrl() + "formula_string", 
            {"premises": $("#premises").val(), "conclusion": $("#conclusion").val()}, 
            function(data){
                if(data.message == "more"){
                    refresh_proof_table(data.proof);
                    refresh_next_step(data.next_step);
                }
                else{
                    refresh_proof_table(data.proof);
                    $('.next_step').css("display", "none");
                    $('.done').css("display", "inline");
                    if(data.message == "valid"){
                      $('.done #message').html("<div>You are done. The implication is valid. </div>")
                    }
                    else{
                      $('.done #message').html("<div>You are done. The implication is invalid. Counterexample:  " + data.counterexample + "</div>")
                    }
                }
                $('#select_law').css("visibility", "hidden")
                $('#availablelaws').html("")
            })
    });
});

$(document).on('click', '.law_item', function(event) {
    $.post(
        getBaseUrl() + "apply_law",
        {"law": $(this).attr("id"), "element": $('.wff.selected').attr("id")},
        function(data){
            if(data.message == "more"){
                refresh_proof_table(data.proof);
                refresh_next_step(data.next_step);
            }
            else{
                refresh_proof_table(data.proof);
                $('.next_step').css("display", "none");
                $('.done').css("display", "inline");
                if(data.message == "valid"){
                  $('.done').append("<div>You are done. The implication is valid. </div>")
                }
                else{
                  $('.done').append("<div>You are done. The implication is invalid. Counterexample:  " + data.counterexample + "</div>")
                }
            }
            $('#select_law').css("visibility", "hidden")
            $('#availablelaws').html("")
        }
    );
});

$(document).on('click', '.wff', function(event) {
    $('.wff.selected').removeClass("selected")
    $(this).addClass("selected")
    get_laws($(this).closest('.wff').attr("id"))
});
