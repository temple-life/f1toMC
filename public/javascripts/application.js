jQuery(document).ready(function() {
  jQuery.ajaxSetup({ 
    dataType: 'html',
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");
    } 
  });
});

function get_attributes(url, id) {
  if (id.length > 0) {
    $.get(url, {attribute_group_id: id}, function(data) {
      $('#person_attribute').find('option').remove().end().append(data);
      document.getElementById('btn_find_people').disabled = $('#person_attribute').val().length == 0;
    });
  }
  else {
    $('#person_attribute').find('option').remove().end().append("<option>--</option>");
    document.getElementById('btn_find_people').disabled = true;
  }
}

function find_people(frm) {
  
  return false;
}