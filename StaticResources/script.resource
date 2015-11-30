	$.getScript( "https://www.nissanusa.com/AppGateway/nissan_global_navigation.js?baseURL=www.nissanusa.com&secure=true", function( data, textStatus, jqxhr ) {
        console.log( "Load was performed." );
    });

$(function(){
    
    /*presentation*/
    if($('.presentation__img').length > 0){
        $(".presentation__img img").elevateZoom({
            cursor: "crosshair",
            easing : true
        });
    }

    /*home*/
   $('.js_popup').on('click', function(){

       var image = new Image();
       image.src = $(this).find('img').attr("src");

       $('.popup__img').css({
           'width': image.naturalWidth,
           'height': image.naturalHeight
       }).append("<img src="+ image.src +">");

       $('.popup').fadeIn();
   });

	$('.js_close').on('click', function(){
        $('.popup').fadeOut(function(){
            $('.popup__img > img').remove();
        });
    });

    /*faq*/
     var trigger = true;
    $('.question__title').on('click', function(){

        if(trigger){
            trigger = false;

            var $point = $(this).find('i');

            $point.hasClass('active') ? $point.removeClass('active') : $point.addClass('active');

			console.log($point);

            $(this).next().slideToggle(150, 'linear', function(){
                trigger = true;
            });
        }
    });



})