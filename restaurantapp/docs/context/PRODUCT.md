# Product
## Users and outcomes
Restaurant Fast: el cliente consulta comida y pedidos; propietario y administrador operan el restaurante. Revisión actual centrada en la consulta móvil de IA.
## Scope
Nueva ruta Estadísticas → Predicción de demanda. Reutiliza el modelo Spring existente. La versión v2 conserva el formulario y usa pesos actualizados en Spring. Los pagos siguen fuera del alcance de esta actualización.
## Acceptance
La app envía producto, fecha e historia; muestra unidades del backend; impide fechas inválidas y valores fuera de 0..10000; elimina resultados anteriores al cambiar entradas; comunica desconexión y permite reintentar. No presenta estimaciones como ventas garantizadas.
