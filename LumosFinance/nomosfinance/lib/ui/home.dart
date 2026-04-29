import 'package:flutter/material.dart';
import '../data/post_model.dart'; // Certifique-se que o caminho está correto
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'post_form_screen.dart';

class NomosFinance extends StatefulWidget {
  const NomosFinance({Key? key}) : super(key: key);

  @override
  State<NomosFinance> createState() => _NomosFinanceState();
}

class _NomosFinanceState extends State<NomosFinance> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  
  int _selectedIndex = 0;
  String _userName = "Carregando...";
  bool _isLoading = true;
  int _refreshKey = 0; // Chave para forçar refresh do FutureBuilder

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // Carrega os dados iniciais (Usuário e Posts)
  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    
    // Pega o nome do usuário que foi salvo no SharedPreferences pelo AuthService
    final name = await _authService.getUserName(); 
    
    setState(() {
      _userName = name ?? "Usuário";
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                // Adicione isso no final do Scaffold da home.dart
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2EC4B6),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Abre a tela de formulário
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostFormScreen()),
          );
          
          // Se o PostFormScreen retornou true (sucesso), recarrega a lista
          if (refresh == true) {
            setState(() => _refreshKey++); // Incrementa chave para forçar refresh
          }
        },
      ),
      backgroundColor: const Color.fromARGB(255, 148, 147, 147),
      body: SafeArea(
        child: Column(
          children: [
            // Header com Nome do Usuário Dinâmico
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 57, 58, 58),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nomos Finance',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(_userName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                        onPressed: _confirmLogout,
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Menu de Navegação Superior (conforme seu design)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton('Início', 0),
                  _navButton('Gastos', 1),
                  _navButton('Comprovantes', 2),
                ],
              ),
            ),

            const Divider(color: Colors.black26, thickness: 2, indent: 16, endIndent: 16, height: 30),

            // Conteúdo usando FutureBuilder para os Posts
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildPageContent(),
            ),
          ],
        ),
      ),
      
    );
  }

  // Lógica de Logout igual ao post_list_screen
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair?'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    return FutureBuilder<List<Post>>(
      key: ValueKey(_refreshKey), // Chave para forçar refresh
      future: _postService.getPosts(), // Chama o PostController@index do Laravel
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nenhum post encontrado."));
        }

        final posts = snapshot.data!;

        if (_selectedIndex == 0) return _buildInicio(posts);
        if (_selectedIndex == 1) return _buildGastos(posts);
        return _buildComprovantes(posts);
      },
    );
  }

  Widget _buildInicio(List<Post> posts) {
    posts = posts.take(10).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mapeia os títulos dos posts reais para os cards verdes
          ...posts.take(3).map((post) => _longCard(post, const Color.fromARGB(255, 85, 87, 102))).toList(),
          const SizedBox(height: 16),
          const Text(
            'Maiores Gastos do Mês',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _squareCard('Exemplo', const Color.fromARGB(255, 74, 74, 74), 100),
              _squareCard('Exemplo', const Color.fromARGB(255, 74, 74, 74), 100),
              _squareCard('Exemplo', const Color.fromARGB(255, 74, 74, 74), 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGastos(List<Post> posts) {
    posts = posts.where((p) => p.imagem == null).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _longCard(post, const Color.fromARGB(255, 82, 67, 55));
      },
    );
  }

// Para a aba de Comprovantes, vamos usar um GridView para mostrar os posts como "comprovantes"
  Widget _buildComprovantes(List<Post> posts) {
    posts = posts.where((p) => p.imagem != null).toList(); // Filtra apenas os posts que têm imagem (comprovante)
    print('DEBUG Flutter - Posts com imagem: ${posts.length}');
    posts.forEach((p) => print('DEBUG Flutter - Post ID: ${p.id}, imagem: ${p.imagem}'));
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _comprovanteCard(post);
        },
      ),
    );
  }

  Widget _comprovanteCard(Post post) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 200, 135),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: post.imagem != null && post.imagem!.isNotEmpty
                        ? Image.network(
                            '${ApiConstants.storageBaseUrl}/storage/${post.imagem}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('DEBUG Flutter - Erro ao carregar imagem: ${post.imagem}, erro: $error');
                              return Container(
                                color: Colors.black26,
                                child: Center(
                                  child: Text(
                                    post.title,
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.black26,
                            child: Center(
                              child: Text(
                                post.title,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                          padding: const EdgeInsets.all(6),
                          onPressed: () async {
                            final refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PostFormScreen(post: post)),
                            );
                            if (refresh == true && mounted) {
                              setState(() => _refreshKey++);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                          padding: const EdgeInsets.all(6),
                          onPressed: () => _confirmDelete(post),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir post?'),
        content: const Text('Deseja realmente excluir este post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePost(post);
            },
            child: const Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(Post post) async {
    final success = await _postService.deletePost(post.id!);
    if (success && mounted) {
      setState(() => _refreshKey++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir o post.')),
      );
    }
  }

  Widget _navButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightGreenAccent.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _longCard(Post post, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.white30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              post.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
            onPressed: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostFormScreen(post: post)),
              );
              if (refresh == true && mounted) {
                setState(() => _refreshKey++); // Incrementa chave para forçar refresh
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
            onPressed: () => _confirmDelete(post),
          ),
        ],
      ),
    );
  }

  Widget _squareCard(String text, Color color, double size) {
    return Container(
      width: size,
      height: size + 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}