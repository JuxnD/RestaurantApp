# Estadísticas móviles para la sustentación

El panel del propietario incorpora la pestaña **Estadísticas**, antes un marcador sin funcionalidad. Reutiliza los pedidos cargados del restaurante, el tema y los componentes Flutter. No agrega una librería de gráficas.

La línea de ventas usa `CustomPainter`. Las barras por estado usan `LinearProgressIndicator` con animación breve, etiquetas numéricas y semántica accesible. El rango muestra siete días calendario hasta la fecha del último pedido cargado; no se anuncia como los siete días hasta hoy. Un conjunto vacío muestra un mensaje; los días sin ventas tienen cero.

Los pedidos se deduplican por ID. Ventas significa importe total de pedidos `paid`, excluyendo cancelados. El importe procede del campo canónico `totalAmount` de Spring a través del repositorio existente; `totalPrice` es un campo heredado y puede ser cero. Los conteos por estado incluyen todos los pedidos cargados, aunque no estén pagados. No es un agregado paginado del servidor ni un reporte contable.

Pruebas: 59 tests Flutter aprobados, incluidos cálculo, deduplicación, exclusión de cancelados y widget a 390 px. APK debug ARM64/x86_64 construido e instalado en el AVD `RestaurantFast_QA`, Android 35, x86_64. La pantalla nativa se contrastó con una lectura HTTP independiente: $405.000 COP, ocho pagos, ocho pedidos y siete importes diarios. Estados: cuatro entregados, dos preparando, uno pendiente y uno listo.

El APK local de la entrega usa `BACKEND_BASE_URL=http://127.0.0.1:15454` y depende de `adb reverse`; no es un APK de producción para instalar directamente en otro teléfono. Para un dispositivo físico, configurar su URL de backend y repetir conectividad, fotos y Stripe Test Mode, aplazados por el usuario.

La minería neuronal se implementa en la web. Esta pestaña móvil muestra estadísticas operativas reales de la demo sintética y no inferencias del modelo. Evidencia: `../../mineria-video-20261114/evidence/android-api-parity.json` y `android-stats-final.xml`.
