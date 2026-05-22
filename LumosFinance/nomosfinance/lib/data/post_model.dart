class Post {
  final int? id;
  final String title;
  final String content;
  final double valor;
  final int categoriaId;
  final bool recorrente;
  final String? imagem;
  final DateTime data; // <-- NOVO ATRIBUTO

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.valor,
    required this.categoriaId,
    this.recorrente = false,
    this.imagem,
    required this.data, // <-- REQUERIDO
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      valor: json['valor'] != null ? double.parse(json['valor'].toString()) : 0.0,
      categoriaId: json['categoria_id'] ?? 1,
      recorrente: json['recorrente'] == 1 || json['recorrente'] == true,
      imagem: json['imagem'] as String?,
      // Converte a String de data vinda do Laravel para o objeto DateTime do Flutter
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'valor': valor,
      'categoria_id': categoriaId,
      'recorrente': recorrente ? 1 : 0,
      if (imagem != null) 'imagem': imagem,
      'data': data.toIso8601String(), // Envia para o Laravel no formato correto
    };
  }
}