import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:app_clientes/rutas/mis_rutas.dart';
import 'package:app_clientes/screens/carritopage_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/producto_provider.dart';
import '../providers/carrito_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool buscando = false;

  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductosProvider>().cargarProductos();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void abrirBusqueda() {
    setState(() {
      buscando = true;
    });
  }

  void cerrarBusqueda() {
    _busquedaController.clear();

    setState(() {
      buscando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productosProvider = context.watch<ProductosProvider>();
    final carrito = context.watch<CarritoProvider>();
    final usuario = context.watch<UserProvider>().usuario;
    final productos = productosProvider.buscarProductos(
      _busquedaController.text,
    );

    final totalUnidades = carrito.cantidadProductos;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: buscando
              ? TextField(
                  controller: _busquedaController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar producto...',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                )
              : Row(
                  children: [
                    Builder(
                      builder: (context) {
                        final esPreventista = usuario?.role == 'preventista';

                        if (!esPreventista) {
                          return IconButton(
                            icon: const Icon(Icons.account_circle_outlined),
                            tooltip: 'Mi perfil',
                            onPressed: () {
                              Navigator.pushNamed(context, MisRutas.usuario);
                            },
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_outlined),
                            tooltip: 'Mi perfil',
                            onPressed: () {
                              Navigator.pushNamed(context, MisRutas.clientes);
                            },
                          );
                        }
                      },
                    ),
                    const Text('Productos'),
                  ],
                ),
          actions: [
            if (buscando)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: cerrarBusqueda,
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: abrirBusqueda,
              ),
            IconButton(
              icon: Badge(
                isLabelVisible: totalUnidades > 0,
                label: Text('$totalUnidades'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarritoPage()),
                );
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (productosProvider.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productosProvider.error != null) {
              return Center(child: Text(productosProvider.error!));
            }

            if (productos.isEmpty) {
              return const Center(child: Text('No se encontraron productos'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];

                final cantidad = carrito.cantidadDe(producto.id);
                final sinStock = producto.stock <= 0;
                final llegoAlStock = cantidad >= producto.stock;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            producto.imagen,
                            width: 100,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 110,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 35,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (producto.descuento > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '-${producto.descuento.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '\$${producto.precio.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                  Text(
                                    '\$${producto.precioFinal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${producto.stock}',
                                style: TextStyle(
                                  color: sinStock
                                      ? Colors.red
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: cantidad > 0
                                        ? () {
                                            context
                                                .read<CarritoProvider>()
                                                .quitarProducto(producto.id);
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: Colors.red,
                                    tooltip: 'Quitar una unidad',
                                  ),
                                  Text(
                                    '$cantidad',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: !sinStock && !llegoAlStock
                                        ? () {
                                            context
                                                .read<CarritoProvider>()
                                                .agregarProducto(producto);
                                          }
                                        : null,
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.deepPurple,
                                    tooltip: 'Agregar una unidad',
                                  ),
                                ],
                              ),
                              if (cantidad > 0)
                                Text(
                                  'Subtotal: \$${(producto.precioFinal * cantidad).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
