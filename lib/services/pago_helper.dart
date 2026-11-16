import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import 'pago_service.dart';

class PagoHelper {
  PagoHelper({PagoService? service}) : _service = service ?? PagoService();

  final PagoService _service;
  StreamSubscription<Uri>? _sub;

  Future<void> pagar(BuildContext context, int pedidoId, String token) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      debugPrint('Iniciando pago del pedido $pedidoId'); // 1
      final url = await _service.iniciarPago(pedidoId, token);
      debugPrint('init_point: $url'); // 2
      _escucharRetorno(messenger, pedidoId, token);
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: const CustomTabsOptions(showTitle: true),
        safariVCOptions: const SafariViewControllerOptions(),
      );
    } catch (e) {
      debugPrint('Error al iniciar pago: $e'); // 3
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _escucharRetorno(
    ScaffoldMessengerState messenger,
    int pedidoId,
    String token,
  ) {
    _sub?.cancel();
    _sub = AppLinks().uriLinkStream.listen((uri) async {
      if (uri.scheme != 'miapp' || uri.host != 'pago') return;
      _sub?.cancel();

      final estado = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (estado == 'failure') {
        messenger.showSnackBar(
          const SnackBar(content: Text('El pago fue rechazado o cancelado')),
        );
        return;
      }

      // El deep link no prueba el pago: se confirma contra el backend.
      final pagado = await _esperarConfirmacion(pedidoId, token);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            pagado ? 'Pago aprobado' : 'Pago pendiente de acreditación',
          ),
        ),
      );
    });
  }

  Future<bool> _esperarConfirmacion(int pedidoId, String token) async {
    for (var i = 0; i < 5; i++) {
      try {
        if (await _service.estaPagado(pedidoId, token)) return true;
      } catch (_) {
        // un error de red puntual no debe cortar la espera
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    return false;
  }
}
