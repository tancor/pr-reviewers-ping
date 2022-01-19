import 'package:pr_reviewers_ping/pinger.dart' as pr_reviewers_ping;

void main(List<String> arguments) {
  final skipNoPrsMessage = arguments.contains('--skip_no_prs_message');
  pr_reviewers_ping.Pinger().pingPullRequestReviewers(skipNoPrsMessage: skipNoPrsMessage);
}
