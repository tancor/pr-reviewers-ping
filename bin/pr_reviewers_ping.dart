import 'package:pr_reviewers_ping/pinger.dart' as pr_reviewers_ping;

void main(List<String> arguments) {
  pr_reviewers_ping.Pinger().pingPullRequestReviewers();
}
