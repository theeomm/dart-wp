part of '../main.dart';

class SearchEndpoint {
  static const String _name = 'search';
  final WordPressAPI _api;

  SearchEndpoint(this._api);

  /// [GET] search results from WP search endpoint
  ///
  /// `/wp/v2/search`
  Future search({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Search.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parseSearches(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
