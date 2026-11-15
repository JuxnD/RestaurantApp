# Evidence ledger
## Claims
Base app: fix/sustentacion-restaurant-fast, 559d13d06a1af541a7be0323b1a6bcd01b8fbfd8, base de la integración de IA publicada en el PR. Backend de referencia da4637bf7eeca6043de85af017de048a7d472ced.

Evidencia local: C:/My Projects/Universidad/RestaurantFast-sustentacion/mineria-video-20261114/video-movil-20261115/evidence/.

- flutter-tests/12e3db828a7942d88046aaba64a9eece: 63 tests aprobados en stdout nativo. Analyze sin issues.
- mutante/6e7f0d98ecd14847aa8cde90ec581889: alterar units +10 en copia aislada hace fallar la aserción exacta 45.27. Fallos previos de preparación no cuentan como detección.
- integracion-movil.json: cinco respuestas de referencia coinciden; propietario/admin 200, cliente/gerente 403; historia negativa rechazada.
- android/predict-1.txt a predict-3.txt: resultado nativo 45,27; predict-offline.txt y predict-recovered.txt: error y recuperación; offline-after-restart.txt: inventario en caché tras reinicio sin ruta API.
- APK SHA256: 70efa55da35a942d8032e745d0add04896185313ec7f915f6f82c381e9612bfc.

Las pruebas y capturas identifican este artefacto y entorno; no constituyen aceptación formal ni prueba de dispositivo físico.

Video final: video-movil-20261115/entrega-final/VERIFICACION.json y AUDITORIA_FINAL.json. 6014 fotogramas, 17 escenas, 56 subtítulos; decodificación completa sin errores y revisión visual de cuadros/transiciones. ZIP editable verificado por CRC y hashes. Narración medida y transcrita, sin afirmar audición humana.

Evidencia portable y verificación previa al push: [validación](../validation/2026-11-15-prediccion.md), [resultado de integración](../validation/integracion-movil.json) y [corrida de publicación](../validation/pruebas-publicacion.json).
