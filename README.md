# Productos artesanales Gema

Aplicación móvil en Flutter para una persona que vende alimentos artesanales
(galletas, salsas, postres y dulces típicos). Permite administrar un catálogo
con imágenes, comprar con un carrito y pago con tarjeta (modo de prueba),
consultar pedidos y recibir notificaciones push.

**Autor:** Edson Sebastian Guillen Padilla
**Materia:** Desarrollos móviles y tecnologías en la nube

## Funcionalidades

- Autenticación con Firebase: correo y contraseña (con verificación de correo y
  recuperación de contraseña), Google y GitHub.
- Perfil con avatar sincronizado; la foto solo se puede cambiar en cuentas de correo.
- Catálogo de productos en tiempo real con Cloud Firestore.
- Imágenes en Supabase Storage, con caché local para verlas sin conexión.
- Notificaciones push (FCM) por temas, en primer plano, segundo plano y app cerrada.
- Sensor: lector de huella digital (`local_auth`) para eliminar productos y confirmar pagos.
- Mapa nativo con `flutter_map` (sin WebView).
- Carrito, pago con tarjeta con validaciones (Stripe en modo de prueba) e historial de pedidos.
- Estado con Provider (sin `setState` ni `ValueNotifier`), tema claro/oscuro,
  fuente Poppins, onboarding y diseño responsivo.
- Widgets avanzados: `Hero` y `AnimatedSwitcher`.

## Cómo ejecutarla

1. Instala dependencias:
   flutter pub get
2. Si falta `lib/firebase_options.dart`, genera la configuración de Firebase:
   flutter configure
3. Ejecuta en un dispositivo Android:
   flutter run
4. Opcional, para usar Stripe en modo de prueba (sin esta clave los pagos
   funcionan en modo simulado):
   flutter run --dart-define=STRIPE_SECRET_KEY=sk_test_TU_CLAVE

## Tarjetas de prueba

| Número | Resultado |
| --- | --- |
| 4242 4242 4242 4242 | Aprobada |
| 4000 0000 0000 0002 | Rechazada |
| 4000 0000 0000 9995 | Fondos insuficientes |

Usa cualquier fecha futura y cualquier CVV. No uses tarjetas reales.

## Notas

- Las notificaciones se envían desde la consola de Firebase, a los temas
  `ofertas`, `novedades` y `avisos`.
- El cobro con Stripe se hace desde la app solo para pruebas; en producción
  debe hacerlo un servidor.
