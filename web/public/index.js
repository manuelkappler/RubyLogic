MathJax.Hub.Config({
  jax: ["input/TeX","output/HTML-CSS"],
  "HTML-CSS": {scale: 115},
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
            console.log(index);
            lawdiv.append('<button class="law_item btn-lg btn-success" id="' + index + '"> ' + value +'</button>');
        });
    })
    $('#select_law').css('visibility', 'visible');
}


function refresh_proof_table(data){
    console.log(data)
    $('#prooftable tbody tr').remove();
    $.each(data, function(index, value){
        var rowid = "proofrow"+index
        var newrow = ('<tr id="' + rowid + '"><td>' + value[0] + '</td><td> <span id="proofspan' + index + '">' + value[1] + '</span></td><td><span id="lawspan' + index + '">' + value[2] + '</span></td><td>' + value[3] + '</td></tr>');
        $('#prooftable tbody').append(newrow);
        console.log(value[3]);
        console.log(value[3] == "✔");
        if(value[3] == "✔"){ $('#' + rowid).addClass("bg-success")};
        if(value[3] == "✘"){ $('#' + rowid).addClass("bg-danger")};
        var proofspan = $("#proofspan" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, proofspan]);
        var lawspan = $("#lawspan" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, lawspan]);
    });
}

function refresh_next_step(data){
    var field = $('#workingon')
    field.html('<p></p>');
    $.each(data.premises, function(index, value){
        var premise_separator = index + 1 < data.premises.length ? ', ' : ''
        field.append('<span class="wff" id="premise' + index + '"> \\(' + value + '\\)' + premise_separator + '</span>');
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('#premise' + index).get()]);
    });
    field.append('<span class="implication_separator">\\(\\models\\)</span>')
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('.implication_separator').get()]);
    field.append('<span class="wff" id="conclusion"> \\(' + data.conclusion + '\\) </span>')
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('#conclusion').get()]);
    $('#select_component').css('visibility', 'visible');
}


function reset_all(){
    $('#input').removeClass("panel-primary");
    $('#input').addClass("panel-default");
    $('#submit').removeClass("btn-primary");
    $('#done_message').html("");
    $('#proof').removeClass("hidden");
    $('#done').addClass("hidden");
    $('#done').removeClass("panel-danger");
    $('#done').removeClass("panel-success");
    $('#next_step').addClass("hidden");
}

$(document).ready(function (){
    $("#submit").on("click", function() {
        reset_all()
        $('#collapse_input').collapse('hide');
        $.post(
            getBaseUrl() + "formula_string", 
            {"premises": $("#premises").val(), "conclusion": $("#conclusion").val()}, 
            function(data) { respond_to_data(data) })
    });
});

function respond_to_data(data){
    console.log(data)
        if(data.message == "more"){
            $('#next_step').removeClass("hidden");
            $('#next_step').addClass("panel-primary");
            refresh_proof_table(data.proof);
            refresh_next_step(data.next_step);
        }
        else{
            refresh_proof_table(data.proof);
            $('#next_step').addClass("hidden");
            $('#done').removeClass("hidden");
            if(data.message == "valid"){
                $('#done').addClass("panel-success")
                $('#done_message').html('<p class="lead panel-body">You are done. The implication is valid. <span class="glyphicon glyphicon-ok" align="right"></span> </p>')
            }
            else{
                $('#done').addClass("panel-danger")
                $('#done_message').html('<p class="lead panel-body">You are done. The implication is invalid. <span class="glyphicon glyphicon-remove" align="right"></span><br> Counterexample:  ' + data.counterexample + '</p>')
            }
        }
        $('#select_law').css("visibility", "hidden")
        $('#availablelaws').html("")
}

$(document).on('click', '.law_item', function(event) {
    $.post(
        getBaseUrl() + "apply_law",
        {"law": $(this).attr("id"), "element": $('.wff.selected').attr("id")},
        function(data){
            respond_to_data(data)
        }
    );
});

$(document).on('click', '.wff', function(event) {
    $('.wff.selected').removeClass("selected")
    $(this).addClass("selected")
    get_laws($(this).closest('.wff').attr("id"))
});
