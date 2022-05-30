import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:pr_reviewers_ping/entities.dart';

const _foodEmojis = <String>[
  '🍩',
  '🌮',
  '🥙',
  '🌯',
];

final _random = Random();

class Pinger {
  Pinger({
    required this.token,
  });

  final String token;

  void pingPullRequestReviewers({
    required bool skipNoPrsMessage,
  }) async {
    final configuration = await _fetchConfig();

    final prs = await _fetchPullRequests(configuration);

    final reviewersToPing = <String, List<String>>{};
    final failedChecksPrAuthorsToPing = <String, List<String>>{};

    for (var i = 0; i < prs.length; i++) {
      final pr = prs[i];

      if (pr.labels.map((e) => e.name).contains('on hold') || pr.draft == true) {
        continue;
      }

      final lastStatus = await _fetchLastPrStatus(pr);

      if (lastStatus?.state == 'error') {
        final urls = failedChecksPrAuthorsToPing[pr.author.login] ?? [];
        urls.add(pr.urlForSlack);
        failedChecksPrAuthorsToPing[pr.author.login] = urls;
        continue;
      }

      for (final reviewer in pr.requestedReviewers) {
        final urls = reviewersToPing[reviewer.login] ?? [];

        urls.add(pr.urlForSlack);
        reviewersToPing[reviewer.login] = urls;
      }
    }

    var slackPayload = _slackUsersAndPullRequestsString(reviewersToPing, configuration: configuration);

    if (failedChecksPrAuthorsToPing.isNotEmpty) {
      final failedAuthorsString = _slackUsersAndPullRequestsString(
        failedChecksPrAuthorsToPing,
        configuration: configuration,
      );
      slackPayload += '\n Checks failed ❌:\n$failedAuthorsString';
    }

    if (slackPayload.isNotEmpty) {
      slackPayload += '\n';
    } else if (!skipNoPrsMessage) {
      slackPayload = 'No PRs found. Time to eat some ${_pickRandomFoodEmoji()}';
    } else {
      slackPayload = '';
    }

    if (slackPayload.isEmpty) {
      print('Nothing to send to slack');

      return;
    }

    print(slackPayload);

    final body = json.encode({'text': slackPayload});
    await http.post(
      Uri.parse(configuration.slackWebhookUrl),
      body: body,
    );
  }

  String _slackUsersAndPullRequestsString(
    Map<String, List<String>> usersAndUrls, {
    required Configuration configuration,
  }) =>
      usersAndUrls.keys.fold('', (previousValue, element) {
        final userGithubName = element;
        final userSlackName = configuration.githubToSlackUsersMap[userGithubName];
        previousValue +=
            "${userSlackName?.isNotEmpty == true ? "<@$userSlackName>" : userGithubName}:\n${usersAndUrls[userGithubName]!.join("\n")}\n";

        return previousValue;
      });

  Future<Configuration> _fetchConfig() async {
    final configFile = File(Directory.current.path + Platform.pathSeparator + 'pr_reviewers_ping_config.json');
    final configString = await configFile.readAsString();
    print("Config path:\n${Directory.current.path + Platform.pathSeparator + 'pr_reviewers_ping_config.json'}");

    final configJson = json.decode(configString) as Map<String, dynamic>;
    return Configuration.fromJson(configJson);
  }

  Future<List<Pr>> _fetchPullRequests(Configuration configuration) async {
    final response = await http.get(
      configuration.pullRequestsUrl,
      headers: _authorizationHeaders,
    );

    final prsJsonList = (json.decode(response.body) as List).cast<Map<String, dynamic>>();
    return List<Pr>.from(prsJsonList.map<Pr>((json) => Pr.fromJson(json)));
  }

  Future<PrStatus?> _fetchLastPrStatus(Pr pr) async {
    final statusesResponse = await http.get(
      Uri.parse(pr.statusesUrl),
      headers: _authorizationHeaders,
    );

    final statusesJsonList = (json.decode(statusesResponse.body) as List).cast<Map<String, dynamic>>();
    final statuses = List<PrStatus>.from(statusesJsonList.map<PrStatus>((e) => PrStatus.fromJson(e)));

    return statuses.isNotEmpty == true ? statuses.first : null;
  }

  Map<String, String> get _authorizationHeaders => {
        'Authorization': 'token $token',
      };

  String _pickRandomFoodEmoji() => _foodEmojis[_random.nextInt(_foodEmojis.length)];
}
