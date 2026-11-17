import 'dart:io';

import 'package:io/io.dart';
import 'package:rec_consultoria_mobile/cli/sync_cli_runner.dart';
import 'package:stack_trace/stack_trace.dart';

void main(List<String> args) {
  Chain.capture(
    () async {
      final runner = RecSyncCliRunner();
      final exitCodeValue = await runner.run(args);
      exit(exitCodeValue);
    },
    onError: (Object error, Chain chain) {
      stderr.writeln('Fatal error: $error');
      stderr.writeln(chain.terse);
      exit(ExitCode.software.code);
    },
  );
}
