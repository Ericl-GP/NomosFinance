class Post {
  final int? id;
  final String title;
  final String content;
  final double valor; // Novo campo
  final int categoriaId; // FK para categorias
  final bool recorrente; // tinyint no banco
  final String? imagem;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.valor,
    required this.categoriaId,
    this.recorrente = false,
    this.imagem,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      // Tratamento para garantir que o valor seja lido como double
      valor: json['valor'] != null ? double.parse(json['valor'].toString()) : 0.0,
      categoriaId: json['categoria_id'] ?? 1,
      recorrente: json['recorrente'] == 1 || json['recorrente'] == true,
      imagem: json['imagem'] as String?,
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
    };
  }
}