import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'pr_reviewers_ping.g.dart';

void pingPullRequestReviewers() async {
  final configFile = File(Directory.current.path + Platform.pathSeparator + 'pr_reviewers_ping_config.json');
  final configString = await configFile.readAsString();

  final configJson = json.decode(configString) as Map<String, dynamic>;
  final configuration = Configuration.fromJson(configJson);
  final response = await http.get(
    'https://api.github.com/repos/${configuration.repoOwner}/${configuration.projectName}/pulls',
    headers: {
      'Authorization': 'token ${configuration.githubPat}',
    },
  );

  final prsJsonList = (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  final prs = List<Pr>.from(prsJsonList.map<Pr>((x) => Pr.fromJson(x)));
  final usersToPing = <String, List<String>>{};
  final failedChecksUsersToPing = <String, List<String>>{};

  for (var i = 0; i < prs.length; i++) {
    final pr = prs[i];

    if (pr.labels.map((e) => e.name).contains('on hold') || pr.draft == true) {
      continue;
    }

    final statusesResponse = await http.get(
      pr.statusesUrl,
      headers: {
        'Authorization': 'token ${configuration.githubPat}',
      },
    );

    final statusesJsonList = (json.decode(statusesResponse.body) as List).cast<Map<String, dynamic>>();
    final statuses = List<PrStatus>.from(statusesJsonList.map<PrStatus>((e) => PrStatus.fromJson(e)));
    final lastStatus = statuses.first;

    if (lastStatus.state == 'error') {
      final urls = failedChecksUsersToPing[pr.author.login] ?? [];
      urls.add('<${pr.htmlUrl}|${pr.title}>');
      failedChecksUsersToPing[pr.author.login] = urls;
      continue;
    }

    pr.requestedReviewers.forEach((reviewer) {
      final urls = usersToPing[reviewer.login] ?? [];

      urls.add('<${pr.htmlUrl}|${pr.title}>');
      usersToPing[reviewer.login] = urls;
    });
  }

  var slackPayload = '';
  usersToPing.forEach((key, value) {
    slackPayload += "<@${configuration.githubToSlackUsersMap[key] ?? key}>:\n${value.join("\n")}\n";
  });

  if (failedChecksUsersToPing.isNotEmpty) {
    slackPayload += '\n Checks failed ❌:\n';

    failedChecksUsersToPing.forEach((key, value) {
      slackPayload += "<@${configuration.githubToSlackUsersMap[key] ?? key}>:\n${value.join("\n")}\n";
    });
  }

  slackPayload += '\n';

  print('$slackPayload');

  // final body = json.encode({'text': '$slackPayload'});
  // await http.post(
  //   configuration.slackWebhookUrl,
  //   body: body,
  // );
}

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
