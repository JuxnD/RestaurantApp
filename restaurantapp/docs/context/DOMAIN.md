# Domain
## Glossary
Escenario: producto académico, fecha, lag1 (día previo), lag7 (hace siete días), mean7 (promedio siete días). Predicción: unidades estimadas por la red. MAE: error absoluto medio de la evaluación sintética. Catálogo operativo y productos académicos son conjuntos independientes.
## Invariants
Sin conexión no se genera una nueva predicción. El servidor decide permisos. Respuesta debe coincidir con producto y fecha solicitados y tener unidades finitas no negativas. Cambiar entradas invalida resultado.
## Lifecycles
Informe: carga → formulario o error/reintento. Predicción: validación → solicitud → resultado o error. Sesión: login → JWT seguro → solicitudes autenticadas → logout elimina sesión.
