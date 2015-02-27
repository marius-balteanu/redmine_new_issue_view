$(document).ready(function(){
  $( "div.issue-section .collapsable h3, .collapsable-arrow" ).on({
    click: function() {
      $(this).parent().toggleClass('closed');
    }
  });

  var bottom_comment_button = $('.bottom_page_buttons .add_comment_button');
  var bottom_page_contaier = $('.bottom_page_contaier');
  var bottom_cancel_button = $('.bottom_cancel_button');

  bottom_cancel_button.click(function(event){
    event.preventDefault();
    bottom_page_contaier.hide();
  });

  bottom_comment_button.click(function(event) {
    event.preventDefault();
    bottom_page_contaier.show();
  });
});

function fix_buttons_panel() {
  if (!(/\/issues\/\d+/).test($(location).attr('pathname'))) { return; }
  var pnl = $('.js-issue-header');
  if (pnl.length == 0) { return; }
  var btn_form = $('#button_action_form');
  var menu = $('#top-menu');
  var menu_height = (menu.css('position') == 'fixed') ? menu.height : 0
  var offset = pnl.offset().top - menu_height;


  $(window).on('scroll resize', function () {
    set_buttons_panel_location(pnl, offset, menu_height, btn_form);
  }).trigger("scroll");

  $(document.body).on('click', '.cancel_from_button', function () {
    set_buttons_panel_location(pnl, offset, menu_height, btn_form);
    return false;
  });

  $(document.body).on('click', '.lu_button', function () {
    $('html,body').animate({ scrollTop: 0 }, 100);
  });
}
function set_buttons_panel_location (panel, offset, menu_height, btn_form) {
  if ($(window).scrollTop() - offset > 0 && !btn_form.is(':visible')) {
    content = $('#content');
    nxt = panel.next('.issue');
    panel.addClass('lb_fixed').css({ left: content.offset().left, top: menu_height, width: content.outerWidth() - 6, paddingTop: 5, paddingLeft: 3, paddingRight: 3 });
    nxt.css({ marginTop: panel.height() });
  } else {
    panel.removeClass("lb_fixed").css({ top: 'auto', width: 'auto', paddingTop: 0, paddingLeft: 0, paddingRight: 0 });
    panel.next().css({ marginTop: 0 });
  }
}
