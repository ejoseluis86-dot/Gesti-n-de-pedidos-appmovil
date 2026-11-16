import 'package:app_clientes/providers/cliente_provider.dart';
import 'package:app_clientes/rutas/mis_rutas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cliente.dart';

class ClientesDiaScreen extends StatefulWidget {
  const ClientesDiaScreen({super.key});

  @override
  State<ClientesDiaScreen> createState() => _ClientesDiaScreenState();
}

class _ClientesDiaScreenState extends State<ClientesDiaScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  List<Cliente> _clientes = [];
  bool _cargando = true;
  String? _error;
  String _diaSeleccionado = 'lunes';

  final List<String> _dias = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      //los clientes ya deberian estar cargados en el provider, así que solo los obtenemos desde allí
      final clientes = context.read<ClienteProvider>().clientes;

      if (!mounted) return;

      setState(() {
        _clientes = clientes;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudieron cargar los clientes.';
        _cargando = false;
      });
    }
  }

  String _normalizar(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  List<Cliente> get _clientesFiltrados {
    final busqueda = _normalizar(_busquedaController.text);

    return _clientes.where((cliente) {
      final coincideDia =
          _normalizar(cliente.dia) == _normalizar(_diaSeleccionado);

      final coincideBusqueda =
          _normalizar(cliente.nombre).contains(busqueda) ||
          _normalizar(cliente.direccion).contains(busqueda) ||
          cliente.celular.contains(busqueda);

      return coincideDia && coincideBusqueda;
    }).toList();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rosa = Color(0xFFE91E63);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Clientes por día'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Mi perfil',
              onPressed: () {
                Navigator.pushNamed(context, MisRutas.usuario);
              },
            ),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: _cargando ? null : _cargarClientes,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, dirección o celular',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busquedaController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _dias.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final dia = _dias[index];
                    final seleccionado = dia == _diaSeleccionado;

                    return ChoiceChip(
                      label: Text(_capitalizar(dia)),
                      selected: seleccionado,
                      selectedColor: rosa,
                      labelStyle: TextStyle(
                        color: seleccionado ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _diaSeleccionado = dia);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _cargarClientes,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _clientesFiltrados.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay clientes para ${_capitalizar(_diaSeleccionado)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarClientes,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _clientesFiltrados.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientesFiltrados[index];

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFFCE4EC),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: rosa,
                                  ),
                                ),
                                title: Text(
                                  cliente.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(cliente.direccion),
                                      const SizedBox(height: 4),
                                      Text(cliente.celular),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  //aca guardaremos el cliente en un provider para que pueda ser accedido
                                  // desde otras pantallas para crear un pedido y luego sera limpiado
                                  //el provider cuando se cierre la pantalla de detalle del cliente
                                  context
                                      .read<ClienteProvider>()
                                      .cargarClienteSeleccionado(cliente.id!);

                                  Navigator.pushNamed(context, '/');
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
