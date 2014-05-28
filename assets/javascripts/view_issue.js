$(document).ready(function(){
  $( "div.issue-section .collapsable h3, .collapsable-arrow" ).on({
    click: function() {
      $(this).parent().toggleClass('closed');
    }
  });
});