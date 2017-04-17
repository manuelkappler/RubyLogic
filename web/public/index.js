$(document).ready(function (){
    $('.article_expand').on("click", function(event){ 
        link = event.currentTarget.id.match(/(.*)_expand_link/)[1]
        teaser = '#' + link + '_teaser'
        main = '#' + link + '_content'
        if($(teaser).hasClass('hidden-xl-down')){
            $(teaser).removeClass('hidden-xl-down')
            $(main).addClass('hidden-xl-down')
            $('#' + event.currentTarget.id).html("Show more >>")
        }
        else{
            $(teaser).addClass('hidden-xl-down')
            $(main).removeClass('hidden-xl-down')
            $('#' + event.currentTarget.id).html("<< Show less")
        }
    });
})
