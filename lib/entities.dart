import 'package:json_annotation/json_annotation.dart';

part 'entities.g.dart';

@JsonSerializable()
class Configuration {
  final String repoOwner;
  final String projectName;
  final String githubPat;
  final Map<String, String> githubToSlackUsersMap;
  final String slackWebhookUrl;

  Configuration({this.repoOwner, this.projectName, this.githubPat, this.githubToSlackUsersMap, this.slackWebhookUrl});

  factory Configuration.fromJson(Map<String, dynamic> json) => _$ConfigurationFromJson(json);
}

@JsonSerializable()
class PrStatus {
  final String state;

  PrStatus({this.state});

  factory PrStatus.fromJson(Map<String, dynamic> json) => _$PrStatusFromJson(json);
}

@JsonSerializable()
class User {
  final String login;

  User({this.login});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonSerializable()
class Label {
  final String name;

  Label({this.name});

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
}

@JsonSerializable()
class Pr {
  @JsonKey(name: 'html_url')
  final String htmlUrl;
  @JsonKey(name: 'requested_reviewers')
  final List<User> requestedReviewers;
  @JsonKey(name: 'user')
  final User author;
  final List<Label> labels;
  final String title;
  final bool draft;
  @JsonKey(name: 'statuses_url')
  final String statusesUrl;

  Pr({this.htmlUrl, this.requestedReviewers, this.labels, this.title, this.draft, this.statusesUrl, this.author});

  factory Pr.fromJson(Map<String, dynamic> json) => _$PrFromJson(json);
}

extension ConfigurationHelpers on Configuration {
  String get pullRequestsUrl => 'https://api.github.com/repos/${repoOwner}/${projectName}/pulls';
  Map<String, String> get authorizationHeaders => {
    'Authorization': 'token ${githubPat}',
  };
}

extension PrHelpers on Pr {
  String get urlForSlack => '<${htmlUrl}|${title}>';
}
