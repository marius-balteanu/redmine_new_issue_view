$(document).ready(function(){
  if ($('#button_panel').length) {
    addBottomCommentButton();
  }

  var parentTaskField = $('#issue_parent_issue_id');
  var parentTask = parentTaskField.val();

  parentTaskField.select2({
    ajax: {
      url: "/autocomplete/parents",
      dataType: 'json',
      quietMillis: 250,
      data: function (params) {
        return {
          project_id: window.project_id, // search term
          term: params,
          scope: 'tree'
        };
      },
      results: function (data, page) {
        var myResults = [];
        $.each(data, function (index, item) {
            var issues = [];
            $.each (item, function(issue_index, issue) {
              issues.push({
                'id': issue.  id,
                'text': '<span class="id"> #' + issue.id + ': </span>' + issue.subject + ' <span class="status">' + issue.name + '</span>'
              });
            });
            myResults.push({
                'text': index,
                'children': issues
            });
        });
        return {results: myResults};
      },
      cache: true
    },
    initSelection: function(element, callback) {
      callback({id: parentTask, text: parentTask });
    },
    escapeMarkup: function (markup) { return markup; },
    allowClear: true,
    width: '200',
    dropdownAutoWidth: true,
    minimumInputLength: 1,
    placeholder: "None"
  })
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
