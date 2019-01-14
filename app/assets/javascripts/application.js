// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require wice_grid
//= require autocomplete-rails


//= require twitter/bootstrap
//= require turbolinks
//= require_tree .


$(document).on("page:load ready", function(){
    $("#stamps_detail_btn, #coins_detail_btn, #bills_detail_btn").click(function(){
        $(this).parents('tr').next('.extra-row').slideToggle("fast");
        return false;
    });

    
});

function ajaxcommodities() {
	$('#p_commodity_name').bind('railsAutocomplete.select', function(event, data){
		var cid = "#"+data.item.obj+"_commodity_id";
		$(cid).val(data.item.id);

	});
}

var ready;
$(document).ready(ready);
$(document).on('page:load', ready);
