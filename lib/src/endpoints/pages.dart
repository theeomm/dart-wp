part of '../main.dart';

class PagesEndpoint {
  static const String _name = 'pages';
  final WordPressAPI _api;

  PagesEndpoint(this._api);

  /// [GET] pages from WP pages endpoint
  ///
  /// `/wp/v2/pages`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Page.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parsePages(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
