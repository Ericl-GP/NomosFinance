import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/post_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- IMPORTANTE PARA A WEB
import 'package:image_picker/image_picker.dart'; // <-- IMPORTANTE PARA O XFILE



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

Future<bool> savePost(Post post, {XFile? imagem}) async {
  final token = await _authService.getToken();
  if (token == null || token.isEmpty) return false;

  final isUpdate = post.id != null;
  final url = isUpdate
      ? '${ApiConstants.baseUrl}/posts/${post.id}'
      : '${ApiConstants.baseUrl}/posts';

  print('DEBUG Flutter - savePost: isUpdate=$isUpdate, url=$url, imagem=${imagem?.path}');

  try {
    // 📷 SE TEM IMAGEM → MULTIPART
    if (imagem != null) {
      print('DEBUG Flutter - Enviando multipart com imagem');
      var request = http.MultipartRequest(
        isUpdate ? 'POST' : 'POST', // Laravel geralmente usa POST + _method
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // 🔥 IMPORTANTE para update
      if (isUpdate) {
        request.fields['_method'] = 'PUT';
      }
      if (kIsWeb) {
          // Na web, lemos os bytes da imagem na memória e enviamos
          final bytes = await imagem.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes('imagem', bytes, filename: imagem.name)
          );
        } else {
          // No celular (Android/iOS/Windows), o fromPath funciona perfeitamente
          request.files.add(
            await http.MultipartFile.fromPath('imagem', imagem.path)
          );
        }
        
      // Campos
      request.fields['title'] = post.title;
      request.fields['content'] = post.content;
      request.fields['valor'] = post.valor.toString();
      request.fields['categoria_id'] = post.categoriaId.toString();
      request.fields['recorrente'] = post.recorrente ? '1' : '0';

      // Imagem
    

      print('DEBUG Flutter - Campos enviados: ${request.fields}');
      print('DEBUG Flutter - Arquivos enviados: ${request.files.length}');

     var response = await request.send();
        return response.statusCode == 200 || response.statusCode == 201;
    }
      

    // 🧾 SEM IMAGEM → JSON normal (seu código)
    print('DEBUG Flutter - Enviando JSON sem imagem');
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
  } catch (e) {
    print('Erro ao salvar post: $e');
    return false;
  }
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
  final token = await _authService.getToken();
  if (token == null || token.isEmpty) return [];

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/categorias'),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erro ao carregar categorias');
  }
}
// Novo método para salvar post com imagem


}

