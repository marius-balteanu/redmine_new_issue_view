var QuickSubtasksForm = (function (oldSelf, $) {
  var self = oldSelf || function (element) {
    this.root = element;
    this.buttons = this.createQuickAddButtons();
    this.input = this.createQuickAddInput();
    this.form = this.createQuickAddForm();
    this.initialize();
  };

  var def = self.prototype;

  def.validateType = function (content, elements) {
    if (content.error !== null) { return; }
    var element = elements[0];
    var matcher = /^([a-zA-Z]*:).*$/;
    var matched = matcher.exec(element);
    if (matched !== null) {
      var tracker = matched[1];
      content.values.tracker = tracker.slice(0, -1);
      if (tracker !== element) {
        elements.splice(1, 0, element.slice(tracker.length));
      }
    } else {
      content.error = 'Invalid tracker matcher: ' + element;
    }
  };

  def.validateSubject = function (content, elements) {
    if (content.error !== null) { return; }
    var subject = elements.reduce(function(result, value, index, array) {
      var hasEstimation = index >= array.length - 2 && /^[\[~|~]/.test(value);
      if (index === 0 || hasEstimation) { return result; }
      return result + ' ' + value;
    }, []);
    if (subject.length !== 0) {
      content.values.subject = subject;
    } else {
      content.error = 'Subject can not be blank';
    }
  };

  def.validateAssigneeAndEstimation = function (content, elements) {
    var last = elements[elements.length - 1];
    var secondLast = elements[elements.length -2];
    var assigneeMatcher = /^\[~[a-z]+\.[a-z]+\]$/;
    var estimationMatcher = /^~(\d+(\.?\d+)?)\s?h?$/;
    if (assigneeMatcher.test(secondLast)) {
      content.values.assignee = secondLast.slice(2, -1);
    }
    else if (assigneeMatcher.test(last)) {
      content.values.assignee = last.slice(2, -1);
    }
    if (estimationMatcher.test(secondLast)) {
      content.values.estimation = estimationMatcher.exec(secondLast)[1];
    }
    else if (estimationMatcher.test(last)) {
      content.values.estimation = estimationMatcher.exec(last)[1];
    }
  };

  def.prepareContent = function (value) {
    var content = { error: null, values: {} }
    var tokens = value.trim().split(/\s+/);
    this.validateType(content, tokens);
    this.validateSubject(content, tokens);
    this.validateAssigneeAndEstimation(content, tokens);
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
    var input = $('<input class="wiki-edit" type="text">');
    input.on('keydown', function (event) {
      if (event.which == 27 || event.keyCode == 27) {
        this.form.hide();
        this.buttons.show();
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
      if (input.val().length === 0) {
        this.form.hide();
        this.buttons.show();
      }
    }.bind(this));
    return input;
  };

  def.createQuickAddForm = function () {
    var form = $('<span class="quick-add-form"></span>');
    var help = $('<span class="fa fa-question"></span>')
    var span = $('<span></span>');
    form.append(help);
    span.append(this.input);
    form.append(span);
    initMentionInput(this.input);
    form.hide();
    return form
  };

  def.createQuickAddButtons = function () {
    var content = $('<span class="quick-subtasks"><i class="fa fa-plus-circle"></i>Quickly add: </span>');
    var children = JSON.parse($('#available-children').val());
    $.each(children, function (index, value) {
      var matcher = value[0].toLowerCase() + ': ';
      var button = $('<a href="#" data-matcher="' + matcher + '">' + value + ' </a>');
      button.on('click', function (event) {
        event.preventDefault();
        this.buttons.hide();
        this.form.show();
        this.input.val($(event.target).data('matcher'));
        this.input.focus();
      }.bind(this));
      content.append(button);
    }.bind(this));
    return content;
  };

  def.initialize = function () {
    this.root.append(this.buttons);
    this.root.append(this.form);
  };

  return self;
}(QuickSubtasksForm, $));


$(function(){
  if ($('#button_panel').length) {
    addBottomCommentButton();
  }

  var canHaveChildren = $('#can-have-children').val() === 'true';
  var subtaskPartial = $('#issue_tree');
  if (canHaveChildren) {
    if (subtaskPartial.length !== 0) {
      var subtasksForm = new QuickSubtasksForm(subtaskPartial);
      var bootstrapTooltip = $.fn.tooltip.noConflict();
      $( document ).tooltip({
        items: '.quick-add-form span.fa-question',
        position: {
          my: "left bottom+25"
        },
        content: function() {
          return "<strong>Syntax format</strong>: (type of tracker initial): Issue subject (@ to assign) (~1 for a 1 hour estimation)";
        }
      });
    }
  } else {
    subtaskPartial.next('hr').remove();
    subtaskPartial.remove();
  }


});

function addBottomCommentButton(){
  var commentButton = '<input type="submit" id="bottom_comment" class="button" value="Add Comment">';
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
