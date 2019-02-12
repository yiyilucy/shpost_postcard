ready = ->
  $('#start_date_start_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#end_date_end_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#stamp_issue_at').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
  $('#bill_issue_at').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
  $('#price_price_date').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
$(document).ready(ready)
$(document).on('page:load', ready)