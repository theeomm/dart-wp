part of '../main.dart';

class MediaEndpoint {
  static const String _name = 'media';
  final WordPressAPI _api;

  MediaEndpoint(this._api);

  /// [GET] media from WP media endpoint
  ///
  /// `/wp/v2/media`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Media.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parseMedia(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
