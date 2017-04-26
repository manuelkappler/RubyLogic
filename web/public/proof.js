MathJax.Hub.Config({
  jax: ["input/TeX","output/HTML-CSS"],
  "HTML-CSS": {scale: 115},
  displayAlign: "left"
});

function getBaseUrl() {
  return window.location.href.match(/^.*\//);
}

function get_laws(id){
    $('#availablelaws').html("");
    $.get(getBaseUrl() + "get_laws/" + id, function(data){
        var lawdiv = $("#availablelaws");
        console.log(data)
        $.each(data, function(index, value){
            console.log(index, value);
            lawdiv.append('<button class="law_item btn-lg btn-success" id="' + index + '"> ' + value +'</button>');
        });
    })
    $('#select_law').removeClass("hidden-xl-down")
    $("html, body").animate({ scrollTop: $(document).height() }, "slow");
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
        if(value[3] == "✔"){ $('#' + rowid).addClass("table-success")};
        if(value[3] == "✘"){ $('#' + rowid).addClass("table-danger")};
        var proofspan = $("#proofspan" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, proofspan]);
        var lawspan = $("#lawspan" + index).get();
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, lawspan]);
    });
    $("html, body").animate({ scrollTop: $(document).height() }, "slow");
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
    $('#select_component').removeClass("hidden-xl-down");
    $("html, body").animate({ scrollTop: $(document).height() }, "slow");
}


function reset_all(){
    $('#input_title_block').removeClass("bg-primary card-inverse");
    $('#input_title_block').addClass("bg-default");
    $('#input').removeClass("card-primary");
    $('#input').addClass("card-default");
    $('#submit').removeClass("btn-primary");
    $('#done_message').html("");
    $('#proof').removeClass("hidden-xl-down");
    $('#done').addClass("hidden-xl-down");
    $('#done_title').removeClass("bg-danger");
    $('#done_title').removeClass("bg-success");
    $('#next_step').addClass("hidden-xl-down");
    $('#error_display').html("")
    $('#error_display').addClass("hidden-xl-down");
}

$(document).ready(function (){
	$('#premises').focus()
    $("#submit").on("click", function() {
        var post_request = $.post(
            getBaseUrl() + "formula_string", 
            {"premises": $("#premises").val(), "conclusion": $("#conclusion").val()})
        post_request.done(function(data) { 
			reset_all()
			$('#collapse_input').collapse('hide');
			respond_to_data(data) });
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
	$('#conclusion').keypress(function (e) {
		if (e.which == 13) {
			$('#submit').click()
		}
	})
	$('#premises').keypress(function (e) {
		if (e.which == 13) {
			$('#conclusion').focus()
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
	

function respond_to_data(data){
    console.log(data)
        if(data.message == "more"){
            $('#next_step').removeClass("hidden-xl-down");
            $('#next_step').addClass("panel-primary");
            refresh_proof_table(data.proof);
            refresh_next_step(data.next_step);
        }
        else{
            refresh_proof_table(data.proof);
            $('#next_step').addClass("hidden-xl-down");
            $('#done').removeClass("hidden-xl-down");
            if(data.message == "valid"){
                $('#done_title').addClass("bg-success")
                $('#done_message').html('<p class="lead card-body">You are done. The implication is valid. <span class="glyphicon glyphicon-ok" align="right"></span> </p>')
            }
            else{
                $('#done_title').addClass("bg-danger")
                $('#done_message').html('<p class="lead card-body">You are done. The implication is invalid. <span class="glyphicon glyphicon-remove" align="right"></span><br> </p><p class="lead card-body"><span id="counterexample"> Counterexample:</span><span id="ce_formula">' + data.counterexample + '</span></p>')
                MathJax.Hub.Queue(["Typeset", MathJax.Hub, $('#ce_formula').get()]);
            }
        }
        $('#select_law').addClass("hidden-xl-down")
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

