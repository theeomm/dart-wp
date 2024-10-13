part of '../main.dart';

class UsersEndpoint {
  static const String _name = 'users';
  final WordPressAPI _api;

  UsersEndpoint(this._api);

  /// [GET] users from WP users endpoint
  ///
  /// `/wp/v2/users`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: User.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parseUsers(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
