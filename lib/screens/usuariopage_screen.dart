import 'package:app_clientes/providers/carrito_provider.dart';
import 'package:app_clientes/providers/cliente_provider.dart';
import 'package:app_clientes/providers/pedido_provider.dart';
import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidosProvider>().cargar();
    });
  }

  // 2026-11-10 -> 10/11/2026
  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _elegirRango() async {
    final provider = context.read<PedidosProvider>();
    final ahora = DateTime.now();

    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(ahora.year, ahora.month, ahora.day),
      initialDateRange: provider.hayFiltro
          ? DateTimeRange(start: provider.desde!, end: provider.hasta!)
          : null,
      helpText: 'Filtrar por fecha',
    );

    if (rango != null) {
      provider.filtrarPorFechas(rango.start, rango.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidosProvider>();
    final esPreventista =
        context.watch<UserProvider>().usuario?.role == 'preventista';

    return Scaffold(
      appBar: AppBar(
        title: Text(esPreventista ? 'Pedidos realizados' : 'Mis pedidos'),
        actions: [
          IconButton(
            tooltip: 'Filtrar por fechas',
            icon: Icon(
              provider.hayFiltro ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: _elegirRango,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final pedidos = context.read<PedidosProvider>();
              final carrito = context.read<CarritoProvider>();
              final clientes = context.read<ClienteProvider>();

              await context.read<UserProvider>().cerrarSesion();

              pedidos.limpiar();
              carrito.vaciarCarrito();
              clientes.limpiar();

              navigator.pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (provider.hayFiltro)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    '${_fecha(provider.desde!)} - ${_fecha(provider.hasta!)}',
                  ),
                  onPressed: _elegirRango,
                  onDeleted: provider.limpiarFiltro,
                ),
              ),
            ),
          Expanded(child: _contenido(provider, esPreventista)),
        ],
      ),
    );
  }

  Widget _contenido(PedidosProvider provider, bool esPreventista) {
    if (provider.cargando && provider.pedidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No se pudieron cargar los pedidos.\n${provider.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: provider.cargar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final lista = provider.pedidosFiltrados;

    return RefreshIndicator(
      onRefresh: provider.cargar,
      child: lista.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    provider.hayFiltro
                        ? 'No hay pedidos en ese rango de fechas.'
                        : 'Todavía no hay pedidos.',
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final p = lista[index];

                return Card(
                  child: ListTile(
                    title: Text('Pedido #${p.id}'),
                    subtitle: Text(
                      [
                        p.fechaFormateada,
                        if (esPreventista) p.cliente,
                        if (p.nota.isNotEmpty) 'Nota: ${p.nota}',
                      ].join('\n'),
                    ),
                    isThreeLine: esPreventista || p.nota.isNotEmpty,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${p.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          p.pagado ? 'Pagado' : 'Pendiente',
                          style: TextStyle(
                            color: p.pagado ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
