# Architecture
## System context
Flutter Android → API REST Spring Boot → MySQL. SQLite conserva catálogo y pedidos; el backend ejecuta el modelo de demanda entrenado.
## Containers and components
Pantallas, dominio y repositorios existentes. DemandPage usa DemandRepository con HttpClientService autenticado. AdministratorHomePage aplica canOperateRestaurant antes de abrir la ruta.
## Critical flows
GET /api/admin/demand/report carga ejemplos y MAE. POST /api/admin/demand/predict recibe el escenario y devuelve units. DemandPage muestra dos decimales. El formulario no toma automáticamente pedidos operativos.
## Trust boundaries
JWT en FlutterSecureStorage; autorización definitiva en Spring. Validación cliente mejora experiencia, no reemplaza controles del servidor. No hay secretos en esta documentación.
