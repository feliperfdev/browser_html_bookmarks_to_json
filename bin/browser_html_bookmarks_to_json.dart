import 'dart:convert';

/// Extensão para remover substrings (String) ou uma lista de substrings (List<String>).
extension StringRemoveExtension on String {
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

/// Remove do mapa todas as chaves cujo valor é null.
Map<String, dynamic> cleanupObject(Map<String, dynamic> obj) =>
    Map.from(obj)..removeWhere((key, value) => value == null);

/// Detecta se uma linha corresponde a uma pasta (<H3>…</H3>).
bool isFolder(String item) => RegExp(r'<H3.*>.*</H3>').hasMatch(item);

/// Detecta se uma linha corresponde a um link (<A>…</A>).
bool isLink(String item) => RegExp(r'<A.*>.*</A>').hasMatch(item);

/// Extrai o texto interno de <H3> ou <A>.
String? getTitle(String item) {
  final match = RegExp(r'<(?:H3|A)[^>]*>(.*?)</(?:H3|A)>').firstMatch(item);
  return match?.group(1);
}

/// Extrai o atributo ICON="…", se existir.
String? getIcon(String item) {
  final match = RegExp(r'ICON="(.+?)"').firstMatch(item);
  return match?.group(1);
}

/// Extrai o atributo HREF="…", se existir.
String? getUrl(String item) {
  final match = RegExp(r'HREF="([^"]*)"').firstMatch(item);
  return match?.group(1);
}

/// Extrai propriedades numéricas (ADD_DATE, LAST_MODIFIED).
int? getNumericProperty(String item, String property) {
  final pattern = RegExp('$property="(\\d+)"');
  final match = pattern.firstMatch(item);
  return match != null ? int.tryParse(match.group(1)!) : null;
}

/// Converte a marcação de um link em um Map.
Map<String, dynamic> transformLink(String markup) {
  final map = <String, dynamic>{
    'type': 'link',
    'addDate': getNumericProperty(markup, 'ADD_DATE'),
    'title': getTitle(markup),
    'icon': getIcon(markup),
    'url': getUrl(markup),
  };
  return cleanupObject(map);
}

/// Converte a marcação de uma pasta em um Map (sem filhos).
Map<String, dynamic> transformFolder(String markup) {
  final map = <String, dynamic>{
    'type': 'folder',
    'addDate': getNumericProperty(markup, 'ADD_DATE'),
    'lastModified': getNumericProperty(markup, 'LAST_MODIFIED'),
    'title': getTitle(markup),
  };
  return cleanupObject(map);
}

/// Encontra todas as linhas que começam com N níveis de indentação + "<DT>".
List<String> findItemsAtIndentLevel(String markup, int level) {
  final indent = level * 4;
  // '^' + N espaços + '<DT>' + todo resto da linha
  final pattern = RegExp(
    r'^\s{' + indent.toString() + r'}<DT>(.*)',
    multiLine: true,
  );
  return pattern.allMatches(markup).map((m) => m.group(0)!).toList();
}

/// Filtra apenas os links no nível informado.
List<String> findLinks(String markup, int level) {
  final items = findItemsAtIndentLevel(markup, level);
  return items.where((item) => isLink(item)).toList();
}

/// Agrupa blocos de pasta (linha <DT><H3>… e tudo até a próxima pasta ou fim).
List<String> findFolders(String markup, int level) {
  final items = findItemsAtIndentLevel(markup, level);
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
List<String> findChildren(String markup, [int level = 1]) {
  final itemsAtLevel = findItemsAtIndentLevel(markup, level);
  if (itemsAtLevel.isEmpty) return [];
  final links = findLinks(markup, level);
  final withoutLinks = markup.remove(links);
  final folders = findFolders(withoutLinks, level);
  return [...links, ...folders];
}

/// Processa um nó (link ou pasta) e retorna o Map correspondente.
Map<String, dynamic>? processChild(String child, [int level = 1]) {
  if (isFolder(child)) {
    return processFolder(child, level);
  }
  if (isLink(child)) {
    return transformLink(child);
  }
  return null;
}

/// Processa recursivamente uma pasta, incluindo seus filhos.
Map<String, dynamic> processFolder(String folderMarkup, int level) {
  final childrenMarkup = findChildren(folderMarkup, level + 1);
  final children = childrenMarkup
      .map((c) => processChild(c, level + 1))
      .where((m) => m != null)
      .cast<Map<String, dynamic>>()
      .toList();
  final map = <String, dynamic>{
    ...transformFolder(folderMarkup),
    'children': children.isNotEmpty ? children : null,
  };
  return cleanupObject(map);
}

/// Converte o HTML completo de favoritos em JSON.
/// - [stringify]: se true, retorna String JSON; caso contrário, retorna List<Map>.
/// - [formatJson]: se true, aplica indentação de [spaces] espaços.
dynamic bookmarksToJson(
  String markup, {
  bool stringify = true,
  bool formatJson = false,
  int spaces = 2,
}) {
  final raw = findChildren(markup);
  final obj = raw.map((c) => processChild(c)!).toList();
  if (!stringify) return obj;
  if (formatJson) {
    final encoder = JsonEncoder.withIndent(' ' * spaces);
    return encoder.convert(obj);
  }
  return jsonEncode(obj);
}

/// Exemplo de uso:
void main() {
  // Aqui você pode ler o conteúdo do arquivo HTML exportado pelo navegador.
  final htmlContent = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1622476800" LAST_MODIFIED="1622476900">Barra de Favoritos</H3>
    <DL><p>
        <DT><A HREF="https://exemplo.com" ADD_DATE="1622476810">Exemplo</A>
    </DL><p>
</DL><p>
''';

  final json = bookmarksToJson(
    htmlContent,
    stringify: true,
    formatJson: true,
    spaces: 2,
  );
  print(json);
}
