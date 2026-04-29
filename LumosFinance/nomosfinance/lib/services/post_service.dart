import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/post_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';


class PostService {
  final _authService = AuthService();

  Future<List<Post>> getPosts({String? query}) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) return [];

    final uri = Uri.parse('${ApiConstants.baseUrl}/posts').replace(
      queryParameters: query != null && query.isNotEmpty
          ? {'search': query}
          : null,
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List listData = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> && decoded['data'] is List
                ? decoded['data']
                : []);
      return listData
          .map((data) => Post.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> savePost(Post post) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) return false;

    final isUpdate = post.id != null;
    final url = isUpdate
        ? '${ApiConstants.baseUrl}/posts/${post.id}'
        : '${ApiConstants.baseUrl}/posts';

    late final http.Response response;
    if (isUpdate) {
      response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(post.toJson()),
      );
    } else {
      response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(post.toJson()),
      );
    }
    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  }

  Future<bool> deletePost(int id) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) return false;

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/posts/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<dynamic>> getCategorias() async {
  final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/categorias'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erro ao carregar categorias');
  }
}
}

