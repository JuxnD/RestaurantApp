# Predicción móvil: validación de integración

## Cambio y dependencia
Estadísticas abre la consulta de IA para propietario y administrador. El cliente HTTP y JWT son los existentes. Requiere el backend `da4637b` o posterior ([PR #1](https://github.com/Mauzg19/backend-spring-boot/pull/1)). No cambia entrenamiento ni deriva historias automáticamente de pedidos.

## Validación repetida antes de publicar
2026-11-15: `flutter test --no-pub`: **63 aprobadas**, salida nativa y código 0. `flutter analyze --no-pub`: **sin incidencias**. Cuatro pruebas nuevas en `test/demand_page_test.dart` cubren solicitud exacta y cifra 45,27; fecha/valor inválidos sin POST; resultado obsoleto eliminado, desconexión y reintento; informe vacío y recarga.

## Integración Android ejecutada durante la preparación del video
[Resultado exportado](integracion-movil.json), APK SHA256 `70efa55da35a942d8032e745d0add04896185313ec7f915f6f82c381e9612bfc`, AVD Android 35 x86_64:

- Tres consultas nativas del escenario Hamburguesa devolvieron 45,27 unidades.
- Cinco productos cotejados con las salidas del informe del modelo; diferencias menores a 1e-5.
- Propietario y administrador: 200; cliente y gerente: 403; historia negativa rechazada.
- Retirar la ruta al backend provocó el mensaje de desconexión sin resultado anterior; restaurarla permitió recuperar la consulta.
- Reiniciar la app sin acceso a la API permitió consultar inventario guardado.

Control negativo en una copia aislada: sumar 10 a units hizo fallar la prueba de la cifra exacta. La ejecución válida fue `6e7f0d98ecd14847aa8cde90ec581889`; los fallos previos de preparación no se cuentan como detección.

## Repetición manual
1. Ejecutar el backend con el modelo versionado y un usuario de propietario o administrador.
2. Configurar `BACKEND_BASE_URL`, iniciar sesión y abrir Estadísticas → Predicción de demanda.
3. Elegir Hamburguesa, fecha 2026-09-01, lag1=38, lag7=40, mean7=65.71428571428571. Esperar 45,27.
4. Modificar una entrada: debe desaparecer el resultado previo. Ingresar 2026-02-30: no debe enviarse consulta.
5. Desconectar la API: mostrar error. Restaurar conexión y reintentar: mostrar el nuevo resultado.
6. Verificar rechazo de cliente/gerente desde la API; ocultar el acceso no sustituye autorización del servidor.

Las pruebas nativas anteriores son evidencia histórica del mismo código funcional; en esta publicación se repitieron suite y análisis. El APK QA usa localhost:15454 con adb reverse; no se entrega como configuración de teléfono independiente. Teléfono físico y Stripe fueron aplazados. No se afirma certificación completa de todos los recorridos ni operación de producción.
