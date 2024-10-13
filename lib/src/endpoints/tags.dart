part of '../main.dart';

class TagsEndpoint {
  static const String _name = 'tags';
  final WordPressAPI _api;

  TagsEndpoint(this._api);

  /// [GET] tags from WP tags endpoint
  ///
  /// `/wp/v2/tags`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Tag.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parseTags(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
