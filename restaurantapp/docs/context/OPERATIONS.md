# Operations
## Local workflow
Desde restaurantapp: flutter pub get, flutter analyze --no-pub, flutter test --no-pub. Configurar BACKEND_BASE_URL mediante --dart-define para el entorno elegido.
## Verification
Suite ejecutada mediante codex-check.py con framework raw: inspeccionar salida nativa (63 tests) y código de salida. Test nuevo: test/demand_page_test.dart. Integración ejecutable y evidencias están en el directorio de video móvil indicado por EVIDENCE.md.
## Delivery and rollback
APK de QA compilado con http://127.0.0.1:15454; requiere adb reverse tcp:15454 tcp:15454 y el backend demo. No es un instalador configurado para teléfono independiente. Copia anterior y videos V4 preservados. El usuario autorizó publicar la rama y actualizar el PR; no fusionar main ni desplegar.
## Observability
Errores visibles de conexión, permiso, sesión y respuesta inválida. No registrar JWT. Repetir integración si cambia APK, backend o contrato.
