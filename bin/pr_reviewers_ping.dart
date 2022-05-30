import 'package:args/args.dart';
import 'package:pr_reviewers_ping/pinger.dart' as pr_reviewers_ping;

const _tokenArgument = 'token';
const _skipNoPrsMessageArgument = 'skip_no_prs_message';

void main(List<String> arguments) {
  final parser = ArgParser();

  parser.addOption(_tokenArgument, mandatory: true);
  parser.addFlag(_skipNoPrsMessageArgument);

  final results = parser.parse(arguments);

  final skipNoPrsMessage = results[_skipNoPrsMessageArgument] as bool;
  final token = results[_tokenArgument] as String;

  pr_reviewers_ping.Pinger(token: token).pingPullRequestReviewers(skipNoPrsMessage: skipNoPrsMessage);
}
