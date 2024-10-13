part of '../main.dart';

class PostsEndpoint {
  static const String _name = 'posts';
  final WordPressAPI _api;

  PostsEndpoint(this._api);

  /// `[GET]` posts from WP posts endpoint
  ///
  /// `/wp/v2/posts`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Post.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parsePosts(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
