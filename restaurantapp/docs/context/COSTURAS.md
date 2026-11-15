# Costuras de la consulta móvil de IA
## Parámetros de verificación
Artefacto: APK SHA en EVIDENCE.md. Entorno: emulador Android 35 x86_64, emulator-5570, API demo 15454 y datos sintéticos. Recorrido crítico: propietario → Estadísticas → Predicción → enviar escenario Hamburguesa 2026-09-01, 38/40/65.71428571428571 → 45.27. Resultado esperado independiente: informe del modelo del backend. Autoridad: usuario autorizó integrar IA y generar video; sin publicación externa.

Comandos: flutter test --no-pub; python verificar_api.py en video-movil-20261115 con demo activa. Prueba nativa: abrir ruta, enviar escenario, retirar solo adb reverse del puerto demo, verificar error, restaurar y reintentar. Control negativo numérico +10 registrado en EVIDENCE.md.
## Inventario
| Límite | Estado | Evidencia |
|---|---|---|
| Formulario → repositorio | Cubierto para esta versión | 4 tests nuevos, validación y cuerpo exacto |
| Repositorio → API/modelo | Cubierto localmente | 5 productos, API y resultado APK |
| Rol → autorización | Cubierto para endpoint | 4 roles, 200/403 |
| Red → interfaz | Cubierto localmente | desconexión y recuperación |
| Caché → reinicio sin API | Cubierto para inventario consultado | offline-after-restart |
| Archivos → video entregado | Ver evidencia audiovisual externa | VERIFICACION.json en entrega-final |
| Teléfono físico / Stripe | Fuera de esta revisión, aplazados | decisión del usuario |
| Otros recorridos históricos | No recertificados aquí | consultar auditorías anteriores |
