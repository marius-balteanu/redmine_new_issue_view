var QuickSubtasksForm = (function (oldSelf, $) {
  var self = oldSelf || function (element) {
    this.root = element;
    this.button = this.createQuickAddButton();
    this.input = this.createQuickAddInput();
    this.form = this.createQuickAddForm();
    this.initialize();
  };

  var def = self.prototype;

  def.validateType = function (content, elements) {
    if (content.error !== null) { return; }
    var element = elements[0];
    var matcher = /^[A-Z][a-zA-Z]*:$/
    if (matcher.test(element)) {
      content.values.tracker = element.slice(0, -1);
    } else {
      content.error = 'Invalid tracker matcher: ' + element;
    }
  };

  def.validateSubject = function (content, elements) {
    if (content.error !== null) { return; }
    var subject = elements.reduce(function(result, value, index, array) {
      var hasEstimation = index >= array.length - 2 && /^[\[~|~]/.test(value);
      if (index === 0 || hasEstimation) { return result; }
      return result + value;
    }, []);
    if (subject.length !== 0) {
      content.values.subject = subject;
    } else {
      content.error = 'Subject can not be blank'
    }
  };

  def.validateAssignee = function (content, elements) {
    if (content.error !== null) { return; }
    var element = elements[elements.length - 2];
    var matcher = /^\[~[a-z]+\.[a-z]+\]$/
    if (matcher.test(element)) {
      content.values.assignee = element.slice(2, -1);
    } else {
      content.error = 'No assignee specified';
    }
  };

  def.validateEstimation = function (content, elements) {
    if (content.error !== null) { return; }
    var element = elements[elements.length - 1];
    var matcher = /^~\d+(\.?\d+)?$/
    if (matcher.test(element)) {
      content.values.estimation = element.slice(1);
    } else {
      content.error = 'No estimation specified';
    }
  };

  def.prepareContent = function (value) {
    var content = { error: null, values: {} }
    var tokens = value.trim().split(/\s+/);
    this.validateType(content, tokens);
    this.validateSubject(content, tokens);
    this.validateAssignee(content, tokens);
    this.validateEstimation(content, tokens);
    return content;
  };

  def.submitQuickAddForm = function (redirect) {
    var content = this.prepareContent(this.input.val());
    if (content.error !== null) {
      alert(content.error);
    } else {
      var parent = window.location.pathname.split('/')[2];
      var data = { data: content.values, parent: parent };
      var request = $.ajax({
        url: '/issues/quick_add',
        method: 'POST',
        data: data,
        dataType: 'JSON'
      });
      request.done(function (response) {
        if (redirect) {
          window.location.href = '/issues/' + response.id;
        } else {
          window.location.reload(true);
        }
      });
      request.fail(function (response) {
        alert(response.responseJSON.error);
      });
    }
  };

  def.createQuickAddInput = function () {
    var placeholder = 'T: Awesome issue subject < type @ to mention and press enter > < type ~1 for a 1 hour estimation >'
    var input = $('<input class="wiki-edit" type="text" placeholder="' + placeholder + '">');
    input.on('keydown', function (event) {
      if (event.which == 27 || event.keyCode == 27) {
        this.form.hide();
        this.button.show();
      }
    }.bind(this));
    input.on('keypress', function (event) {
      if (event.which == 13 || event.keyCode == 13) {
        if (event.ctrlKey) {
          this.submitQuickAddForm(true);
        } else {
          this.submitQuickAddForm(false);
        }
      }
    }.bind(this));
    input.on('blur', function (event) {
      this.form.hide();
      this.button.show();
    }.bind(this));
    return input;
  };

  def.createQuickAddForm = function () {
    var form = $('<span class="quick-add-form"></span>');
    form.append(this.input);
    initMentionInput(this.input);
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
