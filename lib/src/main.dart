import 'package:dio/dio.dart';
import 'package:wordpress_api/src/constants.dart';
import 'package:wordpress_api/src/helpers.dart';
import 'package:wordpress_api/src/models.dart';
import 'package:wordpress_api/src/utils.dart';

part 'endpoints/application_passwords.dart';
part 'endpoints/categories.dart';
part 'endpoints/comments.dart';
part 'endpoints/job_listings.dart';
part 'endpoints/media.dart';
part 'endpoints/pages.dart';
part 'endpoints/posts.dart';
part 'endpoints/search.dart';
part 'endpoints/tags.dart';
part 'endpoints/taxonomies.dart';
part 'endpoints/users.dart';

class WordPressAPI {
  /// WordPress website base url
  String site;

  /// Initialize a custom dio instance.
  ///
  /// Useful if you want to customize `Dio`
  final Dio _dio;

  /// WooCommerce API credentials
  final WooCredentials? wooCredentials;

  WordPressAPI(
    this.site, {
    this.wooCredentials,
    Dio? dio,
  }) : _dio = dio ??= Dio();

  // GET DATA FROM CUSTOM ENDPOINT //
  /// Retrieves data from a given endpoint and resturns a [WPResponse]
  Future<WPResponse> fetch(
    /// Provide an API endpoint
    String endpoint, {
    /// REST API namespace
    String namespace = wpNamespace,

    /// Additional wordpress arguments
    Map<String, dynamic>? args,
  }) async {
    final uri = await _discover(site);

    //***************************** */
    // Remove any starting '/' if any
    //****************************** */
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    if (uri.contains('?') && endpoint.contains('?')) {
      endpoint = endpoint.replaceAll('?', '&');
    }

    // NAMESPACE DISCOVERY
    // Check if the provided namespace has a trailing `/`
    if (namespace.endsWith('/')) {
      namespace = namespace.substring(0, namespace.length - 1).toLowerCase();
    }

    // Set [Dio] base Url
    _dio.options.baseUrl = uri;

    // **********************************************
    //  SET WOOCOMMERCE CREDENTIALS
    // **********************************************
    if (wooCredentials != null) {
      // _dio.options.queryParameters ??= {};
      _dio.options.queryParameters.addAll({
        'consumer_key': wooCredentials!.consumerKey,
        'consumer_secret': wooCredentials!.consumerSecret
      });
    }

    //******************************************* */
    // FETCH REQUESTED DATA AND RETURN WP A RESPONSE
    //******************************************* */
    try {
      int? total, totalPages;
      final res = await _dio.get(
        '/$namespace/$endpoint',
        queryParameters: args,
      );

      if (res.headers.value('x-wp-total') != null) {
        total = int.tryParse(res.headers.value('x-wp-total')!);
        totalPages = int.tryParse(res.headers.value('x-wp-totalpages')!);
      }

      return WPResponse(
        data: res.data,
        meta: WPMeta(
          total: total,
          totalPages: totalPages,
        ),
        statusCode: res.statusCode!,
      );
    } on DioException catch (e) {
      WPUtils.logger.e(e.message);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

// WP Standard Endpoints
  ApplicationPasswordsEndpoint get applicationPasswords =>
      ApplicationPasswordsEndpoint(this);
  PostsEndpoint get posts => PostsEndpoint(this);
  PagesEndpoint get pages => PagesEndpoint(this);
  MediaEndpoint get media => MediaEndpoint(this);
  CategoriesEndpoint get categories => CategoriesEndpoint(this);
  CommentsEndpoint get comments => CommentsEndpoint(this);
  UsersEndpoint get users => UsersEndpoint(this);
  SearchEndpoint get search => SearchEndpoint(this);
  TaxonomiesEndpoint get taxonomies => TaxonomiesEndpoint(this);
  TagsEndpoint get tags => TagsEndpoint(this);

// WP Plugins Endpoints
  /// Job Listings endpoints provided by `[WP Job Manager]` plugin
  ///
  /// `/wp/v2/job-listings`
  JobListingsEndpoint get jobs => JobListingsEndpoint(this);
}

/// Wordpress `REST API Discovery` from Link Header
Future<String> _discover(String site) async {
  String siteUrl = site.trim();
  final Dio dio = Dio(
    BaseOptions(
      contentType: 'application/json',
      headers: {
        'accept': 'application/json',
      },
    ),
  );

  if (!site.startsWith('http')) {
    siteUrl = 'http://$site'.toLowerCase();
  }

  try {
    final res = await dio.head(siteUrl);
    // : Change logger to comment. Used only to debug
    // WPUtils.logger.i("HEADER: ${res.headers}");
    if (res.headers['link'] != null) {
      final link = res.headers['link']!.first.split(';').first;
      return link.substring(1, link.length - 1);
    }
    return '$siteUrl/wp-json';
  } catch (e) {
    WPUtils.logger.e(e);
    rethrow;
  }
}
