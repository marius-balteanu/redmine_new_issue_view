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
    var help = $('<span class="help"><strong>Syntax format</strong>: (issue type first letter): Issue subject (@ to assign) (~ to add estimation)</span>');
    form.append(this.input);
    form.append(help);
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
    block =  $('<div/>').addClass('quick-add-block');
    block.append(this.buttons);
    block.append(this.form);
    this.root.append(block);
  };

  return self;
}(QuickSubtasksForm, $));


$(function(){
  var canHaveChildren = $('#can-have-children').val() === 'true';
  var subtaskPartial = $('#issue_tree');
  if (canHaveChildren) {
    if (subtaskPartial.length !== 0) {
      var subtasksForm = new QuickSubtasksForm(subtaskPartial);
    }
  } else {
    subtaskPartial.next('hr').remove();
    subtaskPartial.remove();
  }

});
