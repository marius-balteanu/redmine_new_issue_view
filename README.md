# Redmine New Issue View

Overrides for redmine templates and methods that make issue tracking a better
experience

# Install

Clone the plugin and restart redmine
```
git clone git@github.com:sdwolf/redmine_new_issue_view.git
```

# Run tests

Make sure you have the testing gems plugin:
```
git clone git@github.com:sdwolf/redmine_testing_gems.git
bundle install
```

Then run
```
rake redmine:plugins:test NAME=redmine_new_issue_view
```

To view test coverage go to `plugins/redmine_new_issue_view/tmp/coverage`
and open `index.html` in a browser
