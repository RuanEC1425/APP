import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import '../data/mock_repository.dart';

/// CLI Runner para inspecionar e exportar os dados do aplicativo Mobile
/// (`rec_consultoria_mobile`) para sincronização com o painel Web do professor.
class RecSyncCliRunner extends CommandRunner<int> {
  final StringSink outSink;
  final StringSink errSink;

  RecSyncCliRunner({StringSink? out, StringSink? err})
    : outSink = out ?? stdout,
      errSink = err ?? stderr,
      super(
        'rec_sync_cli',
        'Utilitario CLI de sincronizacao Mobile <-> Web da REC Consultoria Online.\n'
            'Para executar via Dart: dart run bin/rec_sync_cli.dart <comando> [opcoes].',
      ) {
    addCommand(_SummaryCommand(outSink));
    addCommand(_ExportCommand(outSink, errSink));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final code = await runCommand(parse(args));
      return code ?? ExitCode.success.code;
    } on UsageException catch (e) {
      errSink.writeln(e.message);
      errSink.writeln(e.usage);
      return ExitCode.usage.code;
    }
  }
}

class _SummaryCommand extends Command<int> {
  final StringSink outSink;

  _SummaryCommand(this.outSink);

  @override
  final String name = 'summary';

  @override
  final String description =
      'Lista o resumo dos alunos, treinos feitos, dieta e anamneses para sincronizacao.';

  @override
  Future<int> run() async {
    final students = MockRepository.buildInitialStudents();
    final posts = MockRepository.buildInitialCommunityPosts();

    outSink.writeln('=== REC Consultoria Mobile · Resumo de Sincronizacao ===');
    outSink.writeln('Alunos sincronizados: ${students.length}');
    for (final s in students) {
      final ingested = s.totalIngestedNutrients;
      outSink.writeln(
        '- [${s.id}] ${s.name} (${s.plan} | ${s.objective}) -> '
        'Peso: ${s.currentWeightKg}kg/${s.targetWeightKg}kg | '
        'Treinos feitos: ${s.completedSessions.length} | '
        'Calorias: ${ingested.calories.toStringAsFixed(0)}/${s.dailyTargetNutrients.calories.toStringAsFixed(0)} kcal | '
        'Agua: ${s.waterTracker.consumedMl}/${s.waterTracker.targetMl} ml',
      );
    }
    outSink.writeln('Posts na Comunidade: ${posts.length}');
    return ExitCode.success.code;
  }
}

class _ExportCommand extends Command<int> {
  final StringSink outSink;
  final StringSink errSink;

  _ExportCommand(this.outSink, this.errSink) {
    argParser
      ..addOption(
        'student',
        abbr: 's',
        defaultsTo: '1',
        help:
            'ID do aluno para exportar (ex: 1=Elizangela, 2=Maycon, 3=Carlos).',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help:
            'Caminho opcional de arquivo JSON para salvar o pacote de sincronizacao.',
      );
  }

  @override
  final String name = 'export';

  @override
  final String description =
      'Exporta o pacote JSON completo de um aluno pronto para o painel Web do professor.';

  @override
  Future<int> run() async {
    final studentIdStr = argResults?['student'] as String? ?? '1';
    final studentId = int.tryParse(studentIdStr);
    if (studentId == null) {
      throw UsageException(
        'O parametro --student deve ser um numero inteiro valido.',
        usage,
      );
    }

    final students = MockRepository.buildInitialStudents();
    final matches = students.where((s) => s.id == studentId).toList();
    if (matches.isEmpty) {
      errSink.writeln('Erro: Aluno com ID $studentId nao encontrado.');
      return ExitCode.data.code;
    }

    final target = matches.first;
    final payload = {
      'schemaVersion': '1.0.0',
      'student': target.toSyncJson(),
      'communityFeed': MockRepository.buildInitialCommunityPosts()
          .map((p) => p.toJson())
          .toList(),
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

    final outputPath = argResults?['output'] as String?;
    if (outputPath != null && outputPath.trim().isNotEmpty) {
      final file = File(outputPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonString);
      outSink.writeln(
        'Pacote de sincronizacao de ${target.name} salvo em: ${file.path}',
      );
    } else {
      outSink.writeln(jsonString);
    }

    return ExitCode.success.code;
  }
}
