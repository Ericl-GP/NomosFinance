import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/post_model.dart';
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

  int _currentIndex = 0;
  int _refreshKey = 0;
  bool _isLoading = false;
  String _userName = 'Usuário';

  // Estados de cache para persistência de ordem e filtros
  List<Post>? _comprovantesOrdenados;
  List<Post>? _topGastosPersonalizados;

  // Estados do controle de Calendário
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _authService.getUserName();
      if (name != null && name.isNotEmpty) {
        setState(() {
          _userName = name;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _confirmLogout() async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do App'),
        content: const Text('Deseja realmente encerrar sua sessão no Nomos Finance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    bool? confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: Text('Tem certeza que deseja apagar "${post.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao != true) return;

    setState(() => _isLoading = true);
    final success = await _postService.deletePost(post.id!);
    setState(() => _isLoading = false);

    if (success && mounted) {
      setState(() {
        _comprovantesOrdenados = null;
        _topGastosPersonalizados = null;
        _refreshKey++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro excluído com sucesso!'), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir o registro do banco.'), backgroundColor: Colors.red),
      );
    }
  }

  List<Post> _obterMaioresGastos(List<Post> todosOsPosts) {
    List<Post> ordenada = todosOsPosts.where((p) => p.valor > 0).toList();
    ordenada.sort((a, b) => b.valor.compareTo(a.valor));
    return ordenada.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 224, 224),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 18, 168, 86),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostFormScreen()),
          );
          if (refresh == true) {
            setState(() {
              _comprovantesOrdenados = null;
              _topGastosPersonalizados = null;
              _refreshKey++;
            });
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                      color: const Color.fromARGB(198, 49, 179, 108),
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
                        Text(
                          _userName,
                          style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0), fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _confirmLogout,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.black26, thickness: 2, indent: 16, endIndent: 16, height: 10),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
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
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : FutureBuilder<List<Post>>(
                        key: ValueKey(_refreshKey),
                        future: _postService.getPosts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhum registro encontrado.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)));
                          }

                          final posts = snapshot.data!;

                          switch (_currentIndex) {
                            case 0:
                              return _buildInicio(posts);
                            case 1:
                              return _buildExtrato(posts);
                            case 2:
                              return _buildCalendario(posts);
                            case 3:
                              return _buildComprovantes(posts);
                            default:
                              return _buildInicio(posts);
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF32794C),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Extrato'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Comprovantes'),
        ],
      ),
    );
  }

  // ABA 1: Visão Geral com Rolagem Independente
  Widget _buildInicio(List<Post> posts) {
    final historicoRecentes = posts.reversed.toList();
    _topGastosPersonalizados ??= _obterMaioresGastos(posts);

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8.0),
            child: Text(
              'Últimos Adicionados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historicoRecentes.length,
              itemBuilder: (context, index) {
                return _longCard(historicoRecentes[index], const Color.fromARGB(255, 85, 87, 102));
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white38, thickness: 1),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Maiores Gastos do Mês',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 100,
            child: _topGastosPersonalizados!.isEmpty
                ? const Center(child: Text('Nenhum gasto registrado.', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topGastosPersonalizados!.length,
                    itemBuilder: (context, index) {
                      final itemGasto = _topGastosPersonalizados![index];
                      final cardColor = index == 0 ? Colors.red[400]! : Colors.orange[400]!;

                      return _squareCard(
                        title: itemGasto.title,
                        valor: itemGasto.valor,
                        color: cardColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ABA 2: Novo Módulo de Extrato com Somatório Mensal Dedicado
  Widget _buildExtrato(List<Post> posts) {
    final agora = DateTime.now();
    final postsDoMes = posts.where((p) => p.data.month == agora.month && p.data.year == agora.year).toList();
    
    postsDoMes.sort((a, b) => b.data.compareTo(a.data));

    final double totalGasto = postsDoMes.fold(0.0, (sum, item) => sum + item.valor);

    const meses = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    final nomeMes = meses[agora.month];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 50, 80, 180),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Acumulado em $nomeMes',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${totalGasto.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Detalhamento Cronológico',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        Expanded(
          child: postsDoMes.isEmpty
              ? const Center(child: Text('Nenhum lançamento efetuado este mês.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: postsDoMes.length,
                  itemBuilder: (context, index) {
                    final item = postsDoMes[index];
                    final String diaMeseFormatado = "${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}";
                    return Card(
                      color: const Color.fromARGB(255, 85, 87, 102),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            diaMeseFormatado,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.content, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(
                          'R\$ ${item.valor.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onTap: () => _abrirDescricaoModal(item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ABA 3: Calendário Financeiro
  Widget _buildCalendario(List<Post> posts) {
    final notasDoDia = posts.where((post) {
      bool mesmoDiaComum = post.data.year == _selectedDay?.year &&
          post.data.month == _selectedDay?.month &&
          post.data.day == _selectedDay?.day;

      bool recorrenciaMensal = post.recorrente &&
          post.data.day == _selectedDay?.day &&
          _selectedDay!.isAfter(post.data.subtract(const Duration(days: 1)));

      return mesmoDiaComum || recorrenciaMensal;
    }).toList();

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return posts.where((post) {
              return (post.data.year == day.year && post.data.month == day.month && post.data.day == day.day) ||
                     (post.recorrente && post.data.day == day.day && day.isAfter(post.data.subtract(const Duration(days: 1))));
            }).toList();
          },
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.white),
            weekendStyle: TextStyle(color: Colors.orangeAccent),
          ),
          calendarStyle: const CalendarStyle(
            defaultTextStyle: TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(color: Colors.orangeAccent),
            outsideDaysVisible: false,
            selectedDecoration: BoxDecoration(
              color: Color(0xFF32794C),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
        const Divider(color: Colors.white38, height: 20, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lançamentos do Dia: ${_selectedDay!.day}/${_selectedDay!.month}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
              ),
              Text(
                '${notasDoDia.length} encontrados',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: notasDoDia.isEmpty
              ? const Center(child: Text('Nenhum registro para este dia.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: notasDoDia.length,
                  itemBuilder: (context, index) {
                    final item = notasDoDia[index];
                    return Card(
                      color: const Color.fromARGB(255, 50, 80, 180),
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.recorrente ? Icons.autorenew : Icons.label_important_outline,
                          color: Colors.amber,
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text('R\$ ${item.valor.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white70),
                        onTap: () => _abrirDescricaoModal(item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ABA 4: Galeria Reordenável por Arrastar
  Widget _buildComprovantes(List<Post> posts) {
    if (_comprovantesOrdenados == null) {
      var filtrados = posts.where((p) => p.imagem != null).toList();
      filtrados.sort((a, b) => b.data.compareTo(a.data));
      _comprovantesOrdenados = filtrados;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: _comprovantesOrdenados!.isEmpty
          ? const Center(child: Text('Nenhum comprovante anexado.', style: TextStyle(color: Colors.white70)))
          : ReorderableGridView.builder(
              itemCount: _comprovantesOrdenados!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
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
                  key: ValueKey(postItem.id),
                );
              },
            ),
    );
  }

  void _abrirDescricaoModal(Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (post.recorrente)
                    const Chip(
                      label: const Text("Recorrência Mensal", style: TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: Colors.orange,
                    )
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Valor: R\$ ${post.valor.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent),
              ),
              const Divider(height: 24),
              const Text("Descrição / Anotações:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                post.content.isNotEmpty ? post.content : "Nenhuma anotação vinculada a este registro.",
                style: const TextStyle(fontSize: 15, height: 1.3, color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _longCard(Post post, Color color) {
    final String dataFormatada = "${post.data.day.toString().padLeft(2, '0')}/${post.data.month.toString().padLeft(2, '0')}/${post.data.year}";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(post.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text(
                      dataFormatada, 
                      style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                'R\$ ${post.valor.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostFormScreen(post: post)),
                  );
                  if (refresh == true && mounted) {
                    setState(() {
                      _comprovantesOrdenados = null;
                      _topGastosPersonalizados = null;
                      _refreshKey++;
                    });
                  }
                },
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deletePost(post),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _squareCard({required String title, required double valor, required Color color}) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'R\$ ${valor.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _comprovanteCard(Post post, {Key? key}) {
    return Container(
      key: key,
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
                              return Container(
                                color: Colors.black26,
                                padding: const EdgeInsets.all(4),
                                child: Center(
                                  child: Text(
                                    post.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.black26,
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                post.title,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PostFormScreen(post: post)),
                            );
                            if (refresh == true && mounted) {
                              setState(() {
                                _comprovantesOrdenados = null;
                                _topGastosPersonalizados = null;
                                _refreshKey++;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () => _deletePost(post),
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
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}