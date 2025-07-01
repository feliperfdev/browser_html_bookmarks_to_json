import 'dart:convert';

extension _StringRemoveExtension on String {
  String remove(dynamic toRemove) {
    if (toRemove is List<String>) {
      var result = this;
      for (var value in toRemove) {
        result = result.replaceAll(value, '');
      }
      return result;
    } else if (toRemove is String) {
      return replaceAll(toRemove, '');
    }
    return this;
  }
}

final class HtmlBookmarksToJson {
  /// Remove do mapa todas as chaves cujo valor é null.
  Map<String, dynamic> _cleanupObject(Map<String, dynamic> obj) =>
      Map.from(obj)..removeWhere((key, value) => value == null);

  /// Detecta se uma linha corresponde a uma pasta (<H3>…</H3>).
  bool _isFolder(String item) => RegExp(r'<H3.*>.*</H3>').hasMatch(item);

  /// Detecta se uma linha corresponde a um link (<A>…</A>).
  bool _isLink(String item) => RegExp(r'<A.*>.*</A>').hasMatch(item);

  /// Extrai o texto interno de <H3> ou <A>.
  String? _getTitle(String item) {
    final match = RegExp(r'<(?:H3|A)[^>]*>(.*?)</(?:H3|A)>').firstMatch(item);
    return match?.group(1);
  }

  /// Extrai o atributo ICON="…", se existir.
  String? _getIcon(String item) {
    final match = RegExp(r'ICON="(.+?)"').firstMatch(item);
    return match?.group(1);
  }

  /// Extrai o atributo HREF="…", se existir.
  String? _getUrl(String item) {
    final match = RegExp(r'HREF="([^"]*)"').firstMatch(item);
    return match?.group(1);
  }

  /// Extrai propriedades numéricas (ADD_DATE, LAST_MODIFIED).
  int? _getNumericProperty(String item, String property) {
    final pattern = RegExp('$property="(\\d+)"');
    final match = pattern.firstMatch(item);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Converte a marcação de um link em um Map.
  Map<String, dynamic> _transformLink(String markup) {
    final map = <String, dynamic>{
      'type': 'link',
      'addDate': _getNumericProperty(markup, 'ADD_DATE'),
      'title': _getTitle(markup),
      'icon': _getIcon(markup),
      'url': _getUrl(markup),
    };
    return _cleanupObject(map);
  }

  /// Converte a marcação de uma pasta em um Map (sem filhos).
  Map<String, dynamic> _transformFolder(String markup) {
    final map = <String, dynamic>{
      'type': 'folder',
      'addDate': _getNumericProperty(markup, 'ADD_DATE'),
      'lastModified': _getNumericProperty(markup, 'LAST_MODIFIED'),
      'title': _getTitle(markup),
    };
    return _cleanupObject(map);
  }

  /// Encontra todas as linhas que começam com N níveis de indentação + "<DT>".
  List<String> _findItemsAtIndentLevel(String markup, int level) {
    final indent = level * 4;
    // '^' + N espaços + '<DT>' + todo resto da linha
    final pattern = RegExp(
      r'^\s{' + indent.toString() + r'}<DT>(.*)',
      multiLine: true,
    );
    return pattern.allMatches(markup).map((m) => m.group(0)!).toList();
  }

  /// Filtra apenas os links no nível informado.
  List<String> _findLinks(String markup, int level) {
    final items = _findItemsAtIndentLevel(markup, level);
    return items.where((item) => _isLink(item)).toList();
  }

  /// Agrupa blocos de pasta (linha <DT><H3>… e tudo até a próxima pasta ou fim).
  List<String> _findFolders(String markup, int level) {
    final items = _findItemsAtIndentLevel(markup, level);
    if (items.isEmpty) return [];
    final List<String> folderList = [];
    for (var i = 0; i < items.length; i++) {
      final current = items[i];
      final next = (i + 1) < items.length ? items[i + 1] : null;
      final start = markup.indexOf(current);
      final end = next != null ? markup.indexOf(next) : markup.length;
      if (start >= 0 && end > start) {
        folderList.add(markup.substring(start, end));
      }
    }
    return folderList;
  }

  /// Encontra, num bloco de marcação, todos os filhos (links + pastas).
  List<String> _findChildren(String markup, [int level = 1]) {
    final itemsAtLevel = _findItemsAtIndentLevel(markup, level);
    if (itemsAtLevel.isEmpty) return [];
    final links = _findLinks(markup, level);
    final withoutLinks = markup.remove(links);
    final folders = _findFolders(withoutLinks, level);
    return [...links, ...folders];
  }

  /// Processa um nó (link ou pasta) e retorna o Map correspondente.
  Map<String, dynamic>? _processChild(String child, [int level = 1]) {
    if (_isFolder(child)) {
      return _processFolder(child, level);
    }
    if (_isLink(child)) {
      return _transformLink(child);
    }
    return null;
  }

  /// Processa recursivamente uma pasta, incluindo seus filhos.
  Map<String, dynamic> _processFolder(String folderMarkup, int level) {
    final childrenMarkup = _findChildren(folderMarkup, level + 1);
    final children = childrenMarkup
        .map((c) => _processChild(c, level + 1))
        .where((m) => m != null)
        .cast<Map<String, dynamic>>()
        .toList();
    final map = <String, dynamic>{
      ..._transformFolder(folderMarkup),
      'children': children.isNotEmpty ? children : null,
    };
    return _cleanupObject(map);
  }

  /// Converte o HTML completo de favoritos em JSON.
  /// - [stringify]: se true, retorna String JSON; caso contrário, retorna List<Map>.
  /// - [formatJson]: se true, aplica indentação de [spaces] espaços.
  dynamic _bookmarksToJson(
    String markup, {
    bool stringify = true,
    bool formatJson = false,
    int spaces = 2,
  }) {
    final raw = _findChildren(markup);
    final obj = raw.map((c) => _processChild(c)!).toList();
    if (!stringify) return obj;
    if (formatJson) {
      final encoder = JsonEncoder.withIndent(' ' * spaces);
      return encoder.convert(obj);
    }
    return jsonEncode(obj);
  }

  /// - [stringify]: se true, retorna String JSON; caso contrário, retorna List<Map>.
  /// - [formatJson]: se true, aplica indentação de [spaces] espaços.
  dynamic convert(
    String bookmarksRawHTML, {
    bool stringify = true,
    bool formatJson = false,
    int spaces = 2,
  }) {
    final htmlContent =
        '''
$bookmarksRawHTML
''';

    final json = _bookmarksToJson(
      htmlContent,
      stringify: stringify,
      formatJson: formatJson,
      spaces: spaces,
    );

    return json;
  }
}
