import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class CategoryNode {
  final String key;
  final String name;
  final List<CategoryNode> children;

  CategoryNode({
    required this.key,
    required this.name,
    this.children = const [],
  });
}

final categoriesProvider = FutureProvider<List<CategoryNode>>((ref) async {
  final dio = Dio();
  const url = 'https://dev.opentripmap.org/en/catalog.tree.json';

  try {
    final res = await dio.get(url);
    if (res.statusCode != 200) return [];

    final data = res.data;
    if (data is! List && data is! Map) return [];

    List<dynamic> top;
    if (data is List) {
      top = data;
    } else if (data is Map && data['children'] is List) {
      top = data['children'] as List;
    } else if (data is Map) {
      top = [data];
    } else {
      top = [];
    }

    List<CategoryNode> parseList(List<dynamic> list) {
      final out = <CategoryNode>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final key =
            (item['k'] ?? item['key'] ?? item['id'] ?? item['code'])
                ?.toString() ??
            (item['name'] ?? item['n'])?.toString() ??
            '';
        final name =
            (item['n'] ?? item['name'] ?? item['title'])?.toString() ?? key;

        List<dynamic>? childrenRaw;
        for (final candidate in [
          'children',
          'c',
          'subs',
          'sub',
          'childrenList',
        ]) {
          if (item[candidate] is List) {
            childrenRaw = item[candidate] as List<dynamic>;
            break;
          }
        }

        final children = childrenRaw != null
            ? parseList(childrenRaw)
            : <CategoryNode>[];
        if (key.isEmpty && name.isEmpty) continue;
        out.add(CategoryNode(key: key, name: name, children: children));
      }
      return out;
    }

    final parsed = parseList(top);
    return parsed;
  } catch (e) {
    return [];
  }
});
