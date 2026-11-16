import 'package:app_clientes/models/detalle_pedido_request.dart';
import 'package:app_clientes/models/pedido_request.dart';
import 'package:app_clientes/providers/cliente_provider.dart';
import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:app_clientes/services/pago_helper.dart';
import 'package:app_clientes/services/pedido_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final usuario = context.watch<UserProvider>().usuario;
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final clienteProvider = context.watch<ClienteProvider>();

            final esPreventista = usuario?.role == 'preventista';

            if (esPreventista) {
              final cliente = clienteProvider.clienteSeleccionado;

              return Text(
                cliente != null ? cliente.nombre : 'Seleccioná un cliente',
              );
            }

            return const Text('Mi carrito');
          },
        ),
        actions: [
          if (carrito.items.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Vaciar carrito'),
                    content: const Text(
                      '¿Querés eliminar todos los productos?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          context.read<CarritoProvider>().vaciarCarrito();
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Vaciar'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: carrito.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('Tu carrito está vacío'),
                  SizedBox(height: 6),
                  Text('Agregá productos para realizar un pedido.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: carrito.items.length,
              itemBuilder: (context, index) {
                final item = carrito.items[index];
                final producto = item.producto;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            producto.imagen,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 75,
                              height: 75,
                              color: Colors.black12,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (producto.descuento > 0)
                                    Text(
                                      '\$${producto.precio.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${producto.precioFinal.toStringAsFixed(2)} c/u',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      if (producto.descuento > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade600,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Text(
                                            '-${producto.descuento.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),
                              Text(
                                'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      context
                                          .read<CarritoProvider>()
                                          .quitarProducto(producto.id);
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text(
                                    '${item.cantidad}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: item.cantidad < producto.stock
                                        ? () {
                                            context
                                                .read<CarritoProvider>()
                                                .agregarProducto(producto);
                                          }
                                        : null,
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Eliminar producto',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text(
                                            'Eliminar producto',
                                          ),
                                          content: const Text(
                                            '¿Querés sacar este producto del Carrito?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                context
                                                    .read<CarritoProvider>()
                                                    .eliminarProducto(
                                                      producto.id,
                                                    );
                                                Navigator.pop(dialogContext);
                                              },
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: carrito.items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unidades:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${carrito.cantidadProductos}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${carrito.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final clienteProvider = context
                              .read<ClienteProvider>();

                          if (usuario == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No hay un usuario autenticado.'),
                              ),
                            );
                            return;
                          }

                          // Obtener el cliente según el rol del usuario.
                          final cliente = usuario.role == 'preventista'
                              ? clienteProvider.clienteSeleccionado
                              : clienteProvider.miCliente;

                          if (cliente == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  usuario.role == 'preventista'
                                      ? 'Primero seleccioná un cliente.'
                                      : 'No se encontró tu perfil de cliente.',
                                ),
                              ),
                            );
                            return;
                          }

                          // Desde acá podés mantener el resto de tu código.
                          final pedido = PedidoRequest(
                            fecha: DateTime.now()
                                .toIso8601String()
                                .split('T')
                                .first,
                            nota: '',
                            cliente: cliente.nombre,
                            direccion: cliente.direccion,
                            total: carrito.total,
                            usuarioId: usuario.id!,
                            clienteId: cliente.id!,
                            detalles: carrito.items.map((item) {
                              final producto = item.producto;

                              return DetallePedidoRequest(
                                cantidad: item.cantidad,
                                precioProducto: producto.precio,
                                costoProducto: 0,
                                descuento: producto.descuento.toInt(),
                                subtotal: item.subtotal,
                                productoId: producto.id,
                              );
                            }).toList(),
                          );
                          final token = context
                              .read<UserProvider>()
                              .token; // ajustá al nombre real
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            if (token == null || token.isEmpty) {
                              throw Exception(
                                'Iniciá sesión para registrar pedidos.',
                              );
                            }
                            final creado = await context
                                .read<PedidoService>()
                                .crearPedido(token: token, pedido: pedido);

                            if (!context.mounted) return;

                            final pedidoId = (creado['id'] as num)
                                .toInt(); // ajustar si viene anidado
                            final esPreventista = usuario.role == 'preventista';

                            carrito.vaciarCarrito();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Pedido #$pedidoId registrado.'),
                              ),
                            );

                            // Los clientes pasan directo a pagar con Mercado Pago
                            if (!esPreventista && context.mounted) {
                              await PagoHelper().pagar(
                                context,
                                pedidoId,
                                token,
                              );
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No se pudo registrar el pedido: $e',
                                ),
                              ),
                            );
                          }
                        },

                        icon: const Icon(Icons.payment),
                        label: Text(
                          usuario?.role == 'preventista'
                              ? 'Crear pedido'
                              : 'Continuar al pago',
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
