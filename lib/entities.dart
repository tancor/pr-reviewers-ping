import 'package:json_annotation/json_annotation.dart';

part 'entities.g.dart';

@JsonSerializable()
class Configuration {
  final String repoOwner;
  final String projectName;
  final Map<String, String> githubToSlackUsersMap;
  final String slackWebhookUrl;

  Configuration({
    required this.repoOwner,
    required this.projectName,
    required this.githubToSlackUsersMap,
    required this.slackWebhookUrl,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => _$ConfigurationFromJson(json);
}

@JsonSerializable()
class PrStatus {
  final String state;

  PrStatus({
    required this.state,
  });

  factory PrStatus.fromJson(Map<String, dynamic> json) => _$PrStatusFromJson(json);
}

@JsonSerializable()
class User {
  final String login;

  User({
    required this.login,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonSerializable()
class Label {
  final String name;

  Label({
    required this.name,
  });

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

  Pr({
    required this.htmlUrl,
    required this.requestedReviewers,
    required this.labels,
    required this.title,
    required this.draft,
    required this.statusesUrl,
    required this.author,
  });

  factory Pr.fromJson(Map<String, dynamic> json) => _$PrFromJson(json);
}

extension ConfigurationHelpers on Configuration {
  Uri get pullRequestsUrl => Uri.parse('https://api.github.com/repos/$repoOwner/$projectName/pulls');
}

extension PrHelpers on Pr {
  String get urlForSlack => '<$htmlUrl|$title>';
}
