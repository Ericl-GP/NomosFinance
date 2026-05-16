import 'package:flutter/material.dart';
import '../data/post_model.dart';
import 'package:flutter/gestures.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'post_form_screen.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';



// ==> A Home é a tela principal do app, onde o usuário verá o feed de gastos, os maiores gastos do mês e os comprovantes. Ela também tem um menu de navegação para acessar outras seções (que vamos criar depois) e um botão flutuante para adicionar novos gastos. <==

class NomosFinance extends StatefulWidget {
  
  const NomosFinance({Key? key}) : super(key: key);
  

  @override
  State<NomosFinance> createState() => _NomosFinanceState();
}

class post {
  final int id;
  final String title;
  final String content;
  final double valor;
  final int categoriaId;
  final bool recorrente;
  final String? imagem;

  post({
    required this.id,
    required this.title,
    required this.content,
    required this.valor,
    required this.categoriaId,
    required this.recorrente,
    this.imagem,
  });



  factory post.fromJson(Map<String, dynamic> json) {
    return post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      valor: (json['valor'] as num).toDouble(),
      categoriaId: json['categoria_id'],
      recorrente: json['recorrente'],
      imagem: json['imagem'], // Pode ser nulo
    );
  }
}
List<Post> getMaioresGastos(List<Post> todosOsPosts) {
  // Cria uma cópia para não alterar a ordem da lista original do feed
  List<Post> listaOrdenada = List.from(todosOsPosts);
  
  // Ordena do maior para o menor (b.compareTo(a))
  listaOrdenada.sort((a, b) => b.valor.compareTo(a.valor));
  
  return listaOrdenada; // O índice 0 será sempre o maior gasto!
}

class _NomosFinanceState extends State<NomosFinance> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  List<Post>? _comprovantesOrdenados;
  List<Post>? _topGastosPersonalizados; // <-- Adicione isso junto das outras variáveis
  
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
        backgroundColor: const Color.fromARGB(255, 18, 168, 86), // Verde vibrante para destacar a ação de adicionar gasto
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
      backgroundColor: const Color.fromARGB(223, 206, 206, 206), // Fundo branco semi-transparente para destacar os cards
      body: SafeArea(
        child: Column(
          children: [
            // Header com Nome do Usuário Dinâmico
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 114, 248),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(221, 0, 0, 0),
                          blurRadius: 4,
                          offset: Offset(4, 6),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nomos Finance',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(198, 49, 179, 108), // Verde mais suave para o nome do usuário
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(4, 6),
                        ),
                      ],
                      
                    ),
                    child: Row(
                      children: [
                        Text(_userName, style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0), fontSize: 14)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                          onPressed: _confirmLogout,
                        )
                      ],
                    ),
                  ),
                  
                ],
              ),
            ),

            // Menu de Navegação Superior (conforme seu design)
            
              //Padding(
                
                //padding: const EdgeInsets.symmetric(horizontal: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                  
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 65, 114, 248),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(234, 0, 0, 0),
                    blurRadius: 8,
                    offset: Offset(4, 6),
                  ),
                ],

                  ),
                  
                  
                  child: Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    
                    children: [
                      
                      _navButton('Início', 0),
                      _navButton('Gastos', 1),
                      _navButton('Comprovantes', 2),
                    ],
                  ),
              ),

            const Divider(color: Colors.black26, thickness: 2, indent: 16, endIndent: 16, height: 30), // Linha divisória entre o menu e o conteúdo

            // Conteúdo usando FutureBuilder para os Posts
            Expanded(
              child: Container(
                margin: (const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                padding: const EdgeInsets.all(16),
                
                decoration: BoxDecoration(
                  color: const Color.fromARGB(234, 23, 116, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(199, 0, 0, 0),
                    blurRadius: 8,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildPageContent(),
            ),
            //Expanded(
            //  child: _isLoading 
            //    ? const Center(child: CircularProgressIndicator())
            //    : _buildPageContent(),
            //),
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
    // Histórico de adicionados (Invertido para mostrar os mais novos primeiro)
    final historicoRecentes = posts.reversed.toList(); 

    // Filtra e ordena os maiores gastos (Sempre automático por valor, sem reordenar com a mão)
    final postsValidos = posts.where((p) => p.valor > 0).toList(); 
    final maioresGastos = getMaioresGastos(postsValidos).take(5).toList();

    // ScrollConfiguration ativa o clique e arrasto do mouse para as listas internas
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // SEÇÃO 1: HISTÓRICO DE POSTS (Rolagem Independente)
          // =======================================================
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
            child: Text(
              'Últimos Adicionados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 10),
          
          // O Expanded cria a separação! O histórico rola aqui dentro e não mexe o resto da tela
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: historicoRecentes.length,
              itemBuilder: (context, index) {
                return _longCard(historicoRecentes[index], const Color.fromARGB(255, 85, 87, 102));
              },
            ),
          ),

          // =======================================================
          // DIVISOR / SEPARAÇÃO ENTRE AS SEÇÕES
          // =======================================================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.black26, thickness: 1),
                SizedBox(height: 8),
                Text(
                  'Maiores Gastos do Mês (Comprovantes)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // =======================================================
          // SEÇÃO 2: MAIORES GASTOS (Fixo embaixo, rola só para o lado)
          // =======================================================
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
            child: SizedBox(
              height: 140, // Altura fixa para o carrossel horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: maioresGastos.length,
                itemBuilder: (context, index) {
                  final itemPost = maioresGastos[index];
                  
                  // Mantém a lógica de cor (O maior valor absoluto fica em destaque vermelho)
                  final cardColor = index == 0 ? Colors.red[400]! : Colors.orange[400]!;

                  return _squareCard(
                    title: itemPost.title,
                    valor: itemPost.valor,
                    color: cardColor,
                    size: 110,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGastos(List<Post> posts) {
    
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
    // Inicializa a lista ordenável apenas na primeira vez que a aba abre
    if (_comprovantesOrdenados == null) {
      _comprovantesOrdenados = posts.where((p) => p.imagem != null).toList();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ReorderableGridView.builder(
        itemCount: _comprovantesOrdenados!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        // Função que reorganiza os itens ao soltar o clique
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final element = _comprovantesOrdenados!.removeAt(oldIndex);
            _comprovantesOrdenados!.insert(newIndex, element);
          });
        },
        itemBuilder: (context, index) {
          final postItem = _comprovantesOrdenados![index];
          return _comprovanteCard(
            postItem, 
            key: ValueKey(postItem.id), // Chave obrigatória para o drag and drop funcionar
          );
        },
      ),
    );
  }

  // Adicionamos a {Key? key} para o Container saber qual card está a ser movido
  Widget _comprovanteCard(Post post, {Key? key}) {
    return Container(
      key: key, // <-- Passamos a chave para o Container principal do card
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
                              setState(() {
                                _comprovantesOrdenados = null; // Reseta a lista para recarregar os dados novos do Laravel
                                _refreshKey++;
                              });
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
                          onPressed: () {
                            _confirmDelete(post);
                            // Dica: Se a eliminação no _confirmDelete der sucesso,
                            // lembre-se de colocar _comprovantesOrdenados = null lá dentro também!
                          },
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
    _comprovantesOrdenados = null; // Reseta a lista para recarregar os dados novos do Laravel
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
            child: const Text('Sim', style: TextStyle(color: Colors.red)
            ),
            
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
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(214, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(4, 6),
      ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Color.fromARGB(122, 139, 137, 137)),
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

  Widget _squareCard(
  {
  Key? key,
  required String title,
  required double valor,
  required Color color,
  required double size,}
) {

   
    
  return Container(

    key: key, // <-- ADICIONADO AQUI
    width: size,
    height: size + 20,
    padding: const EdgeInsets.all(12), // Dá um respiro interno
    margin: const EdgeInsets.only(right: 12), // Espaçamento entre os cards
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12), // Bordas um pouco mais arredondadas
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(178, 0, 0, 0),
          blurRadius: 6,
          offset: Offset(0, 3), // Sombreado leve estilo financeiro
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Título do Gasto (Ex: "Aluguel")
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70, // Branco mais suave
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Coloca "..." se o nome for grande
        ),
        const SizedBox(height: 8),
        // Valor do Gasto (Ex: "R$ 1500.00")
        Text(
          'R\$ ${valor.toStringAsFixed(2)}', // Formata com 2 casas decimais
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}
// Coloque no final do arquivo
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // Permite arrastar com clique do mouse
        PointerDeviceKind.trackpad,
      };
}