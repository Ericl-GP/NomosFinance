import 'package:flutter/material.dart';
import '../data/post_model.dart';
import '../services/post_service.dart';
import '../utils/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import 'dart:math'; // Adicione para gerar números aleatórios
import '../services/notification_service.dart'; // Adicione para chamar a notificação
import 'package:flutter/foundation.dart' show kIsWeb;



class PostFormScreen extends StatefulWidget {

  
  final Post? post; // Se vier preenchido, é edição. Se for nulo, é criação.

  const PostFormScreen({Key? key, this.post}) : super(key: key);

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> { // Aqui é onde a mágica acontece!
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _valorController = TextEditingController();
  XFile? _imagem;
  final ImagePicker _picker = ImagePicker();
  
  int _categoriaId = 1; 
  bool _recorrente = false;
  bool _isLoading = false;

  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    // Se estiver editando, preenche os campos
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _valorController.text = widget.post!.valor.toString();
      _categoriaId = widget.post!.categoriaId;
      _recorrente = widget.post!.recorrente;
      // DEBUG: Verificar se imagem existe no post
      print('DEBUG Flutter - Editando post ID: ${widget.post!.id}, imagem: ${widget.post!.imagem}');
    }
  }
 
  Future<void> _salvarPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final novoPost = Post(
      id: widget.post?.id, // Mantém o ID se for edição
      title: _titleController.text,
      content: _contentController.text,
      valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
      categoriaId: _categoriaId,
      recorrente: _recorrente,
      data: DateTime.now(), // Define a data atual para o post
);
    if (novoPost.valor == null || novoPost.valor <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, insira um valor numérico válido.'),
        backgroundColor: Colors.red,
      ),
    );
    return; // Para a execução aqui, não envia para a API
  }

    // Usa o seu PostService perfeitamente!
    final sucesso = await _postService.savePost(novoPost, imagem: _imagem);

    setState(() => _isLoading = false);

    if (sucesso && mounted) {
      // ==========================================
      // É AQUI QUE VOCÊ PASSA O ID E DISPARA!
      // ==========================================
      NotificationService().mostrarNotificacaoImediata(
        id: Random().nextInt(100000), // Gera um ID único e aleatório para não sobrepor
        title: 'Nomos Finance',
        body: 'O registro "${_titleController.text}" foi salvo com sucesso!',
      );

      
      Navigator.pop(context, true); // Retorna true para a Home atualizar a lista
      NotificationService().mostrarNotificacaoImediata(
      id: 1, 
      title: 'Nova Anotação no Calendário!', 
      body: 'O lembrete "${_titleController.text}" foi salvo com sucesso.'
    );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar o gasto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Novo Gasto' : 'Editar Gasto', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1D5D57), // Verde escuro do header
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título (Ex: Aluguel, Mercado)'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contexto / Descrição'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                // 1. Força o teclado do celular a abrir já nos números
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                
                // 2. Bloqueia qualquer coisa que não seja número, ponto ou vírgula
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                validator: (v) => v!.isEmpty ? 'Insira o valor' : null,
              ),
              const SizedBox(height: 16),
              
              // Dropdown simulando os IDs da tabela 'categorias'
              DropdownButtonFormField<int>(
                value: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Alimentação')),
                  DropdownMenuItem(value: 2, child: Text('Transporte')),
                  DropdownMenuItem(value: 3, child: Text('Moradia')),
                  DropdownMenuItem(value: 4, child: Text('Outros')),
                ],
                onChanged: (val) => setState(() => _categoriaId = val!),
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Gasto Recorrente?'),
                subtitle: const Text('Se repete todo mês'),
                activeColor: const Color(0xFF2EC4B6),
                value: _recorrente,
                onChanged: (val) => setState(() => _recorrente = val),
              ),
              Row(
                
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 32),
                    onPressed: _tirarFoto,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, size: 32),
                    onPressed: _selecionarImagem,
                  ),
                ],
              ),
              if (_imagem != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: kIsWeb 
                      ? Image.network(_imagem!.path, height: 150) 
                      : Image.file(File(_imagem!.path), height: 150),
                ),
              // Mostrar imagem existente se estiver editando
              if (widget.post != null && widget.post!.imagem != null && _imagem == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      const Text('Imagem atual:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Image.network(
                        '${ApiConstants.storageBaseUrl}/storage/${widget.post!.imagem}',
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          print('DEBUG Flutter - Erro ao carregar imagem existente: ${widget.post!.imagem}');
                          return const Text('Erro ao carregar imagem');
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarPost,// Chama a função de salvar, mas desabilita o botão se já estiver carregando
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EC4B6), // Verde esmeralda
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar no Nomos Finance', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
   Future<void> _tirarFoto() async {// Função para tirar foto usando a câmera
  final foto = await _picker.pickImage(source: ImageSource.camera);
  if (foto != null) {
    setState(() {
      _imagem = XFile(foto.path);
    });
  }

}
Future<void> _selecionarImagem() async {// Função para selecionar imagem da galeria
  final img = await _picker.pickImage(source: ImageSource.gallery);
  if (img != null) {
    setState(() {
      _imagem = XFile(img.path);
    });
  }
}

}