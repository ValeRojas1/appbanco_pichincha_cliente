# Flujo integrado — App Cliente (referencia)

> Copia de la guía compartida con el repo **appbanco_pichincha_ventas**.  
> Ver el documento completo en ventas: `docs/FLUJO_CLIENTE_OPERADOR_ADMIN.md`

## Cambios ya aplicados en este repo (cliente)

1. **`lib/app/services/solicitud_credito_service.dart`**  
   Método `crearSolicitudDesdePreEvaluacion()` inserta en `solicitudescredito` con `estado = pendiente_operador`.

2. **`lib/app/view/simulador/preevaluacion_screen.dart`**  
   El botón **Solicitar crédito con un asesor** persiste la solicitud (ya no es solo un diálogo).

3. **`lib/app/core/estado_solicitud.dart`**  
   Estados alineados: `pendiente_operador`, `en_atencion`, `completa`.

## Flujo resumido

1. Cliente se registra → pre-evalúa → solicita crédito → fila en Supabase (`pendiente_operador`).
2. Operador (app ventas) ve la bandeja **Solicitudes clientes** → **ATENDER**.
3. Operador completa wizard, fotos, firma, transmisión.
4. Administrador (web ventas) aprueba en comité.
5. Cliente ve avances en **Mis solicitudes** (Realtime por `dni`).

## Antes de probar

Ejecutar en Supabase la migración del repo ventas:

`supabase/migrations/20260618_flujo_cliente_operador.sql`

## Pendientes opcionales (cliente)

- Notificaciones FCM al cliente cuando cambia el estado.
- Wizard completo de solicitud sin depender del operador en campo.
- Columna `clienteid` en `solicitudescredito`.
- RLS estricta por usuario autenticado.
