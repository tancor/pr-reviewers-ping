<h3> pr-reviewers-ping </h3>
A dart util to ping pull request reviewers and authors of pull requests with failed checks in slack.


<h4>Usage:</h4>

1) Install [Dart](https://dart.dev/get-dart) or [Flutter](https://flutter.dev/docs/get-started/install) on your computer.
2) Clone the repo.
3) Create `pr_reviewers_ping_config.json` at the repo root directory with the following fields:
```
{
  "repoOwner" : "github repo owner name",
  "projectName" : "github project name",
  "githubPat" : "github personal access token to be used for authentification",
  "slackWebhookUrl" : "slack webhook url to be used https://hooks.slack.com/services/...",
  "githubToSlackUsersMap" : {"github-nickname-1":"slack member Id 1", "github-nickname-2":"slack member Id 2"}
}
```

4) run `dart bin/pr_reviewers_ping.dart` from the root directory.

