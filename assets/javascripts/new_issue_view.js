var QuickSubtasksForm = (function (oldSelf, $) {
  var self = oldSelf || function (element) {
    this.root = element;
    this.button = this.createQuickAddButton();
    this.input = this.createQuickAddInput();
    this.form = this.createQuickAddForm();
    this.initialize();
  };

  var def = self.prototype;

  def.submitQuickAddForm = function () {
    var content = this.input.val();
    var parent = window.location.pathname.split('/')[2];
    var data = { issue: { data: content, parent: parent } };
    var request = $.ajax({
      url: '/issues/quick_add',
      method: 'POST',
      data: data,
      dataType: 'JSON'
    });
    request.done(function (response) {
      location.reload(true);
    });
    request.fail(function (response) {
      console.log(response);
    });
  };

  def.createQuickAddInput = function () {
    var input = $('<input type="text">');
    input.on('keypress', function (event) {
      this.submitQuickAddForm();
    }.bind(this));
    return input;
  };

  def.createQuickAddForm = function () {
    var form = $('<div></div>');
    form.append(this.input);
    form.append(this.createCancelButton());
    form.hide();
    return form
  };

  def.createQuickAddButton = function () {
    var button = $('<a href="#">Quick Add</a>');
    button.on('click', function (event) {
      event.preventDefault();
      this.button.hide();
      this.form.show();
      this.input.focus();
    }.bind(this));
    return button;
  };

  def.createCancelButton = function () {
    var button = $('<a href="#">X</a>');
    button.on('click', function (event) {
      event.preventDefault();
      this.form.hide();
      this.button.show();
    }.bind(this));
    return button;
  };

  def.initialize = function () {
    this.root.first().find('.contextual a').remove();
    this.root.after(this.button);
    this.root.after(this.form);
  };

  return self;
}(QuickSubtasksForm, $));


$(function(){
  if ($('#button_panel').length) {
    addBottomCommentButton();
  }

  var subtaskPartial = $('#issue_tree');
  if (subtaskPartial.length !== 0) {
    var subtasksForm = new QuickSubtasksForm(subtaskPartial);
  }
});

function addBottomCommentButton(){
  var commentButton = '<input type="button" id="bottom_comment" class="button" value="Add Comment">';
  var commentDiv = '<div id="bottom_comment_block"></div>';

  $("body.controller-issues.action-show #content div.issue ~ div.contextual").prev().before(commentButton).before(commentDiv);

  $(document.body).on('click', '#bottom_comment', function () {
    var fastButton = $("a.lu_button.lb_btn_comment");
    var button_id = fastButton.attr('data-button-id');
    var issue_id = fastButton.attr('data-issue-id');

    $('#bottom_comment_block').load('/lu_buttons/' + button_id + '/form/' + issue_id, function(){
      $("#bottom_comment").hide();
    });
  });

  $(document.body).on('click', 'div#bottom_comment_block #lu_form_cancel_btn', function () {
      $("#bottom_comment").show();
      $("div#bottom_comment_block #in_issue_form").remove();
  });
}
