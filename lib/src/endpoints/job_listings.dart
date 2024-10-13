part of '../main.dart';

class JobListingsEndpoint {
  static const String _name = 'job-listings';
  final WordPressAPI _api;

  JobListingsEndpoint(this._api);

  /// [GET] job listings from `WP Job Manager` endpoint
  ///
  /// `/wp/v2/job-listings`
  Future<WPResponse> fetch({int? id, Map<String, dynamic>? args}) async {
    try {
      if (id != null) {
        final WPResponse res = await _api.fetch('$_name/$id', args: args);
        return WPResponse(
          statusCode: res.statusCode,
          data: Job.fromMap(res.data),
          meta: res.meta,
        );
      }
      final WPResponse res = await _api.fetch(_name, args: args);
      return WPResponse(
        statusCode: res.statusCode,
        data: parseJobs(res.data),
        meta: res.meta,
      );
    } catch (e) {
      rethrow;
    }
  }
}
