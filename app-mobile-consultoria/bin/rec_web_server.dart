import 'dart:io';

import 'package:args/args.dart';

const Map<String, String> _mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json; charset=utf-8',
};

String _contentTypeFor(String path) {
  final lower = path.toLowerCase();
  for (final entry in _mimeTypes.entries) {
    if (lower.endsWith(entry.key)) {
      return entry.value;
    }
  }
  return 'application/octet-stream';
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('host', abbr: 'H', defaultsTo: '0.0.0.0')
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('dir', abbr: 'd', defaultsTo: 'build/web');

  final parsed = parser.parse(arguments);
  final host = parsed['host'] as String;
  final port = int.tryParse(parsed['port'] as String) ?? 8080;
  final webDir = Directory(parsed['dir'] as String);

  if (!webDir.existsSync()) {
    stderr.writeln(
      'Erro: diretorio "${webDir.path}" nao encontrado. Execute "flutter build web --release --no-wasm-dry-run" antes.',
    );
    exitCode = 1;
    return;
  }

  final server = await HttpServer.bind(host, port);
  stdout.writeln('REC Consultoria Web Server ativo em http://$host:$port');
  stdout.writeln('Localhost: http://localhost:$port');

  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.address.startsWith('169.254.')) {
        stdout.writeln('Rede (${iface.name}): http://${addr.address}:$port');
      }
    }
  }

  await for (final request in server) {
    final rawPath = request.uri.path;
    final sanitized = rawPath == '/' ? '/index.html' : rawPath;
    final relativePath = sanitized.startsWith('/')
        ? sanitized.substring(1)
        : sanitized;

    // Bloqueia path traversal
    if (relativePath.contains('..')) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      continue;
    }

    var file = File('${webDir.path}${Platform.pathSeparator}$relativePath');
    if (!file.existsSync() || FileSystemEntity.isDirectorySync(file.path)) {
      file = File('${webDir.path}${Platform.pathSeparator}index.html');
    }

    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      continue;
    }

    request.response.headers.set('Content-Type', _contentTypeFor(file.path));
    request.response.headers.set('Cache-Control', 'no-cache');
    await request.response.addStream(file.openRead());
    await request.response.close();
  }
}
