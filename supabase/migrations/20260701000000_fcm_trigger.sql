-- APP_Mi_Banco_VRC (ipiqcrlpepoajvsbhnun)
-- La tabla clientes_fcmtokens ya existe desde bloque_cliente_auth_fcm con:
--   id uuid, clienteid uuid (unique), fcmtoken text, plataforma text, updatedat, createdat
-- El trigger notify_solicitud_estado ya existe y usa pg_net + anon key.

-- Esta migración solo extiende el trigger para notificar cambios de fechadesembolso.
DROP TRIGGER IF EXISTS on_solicitud_estado_changed ON public.solicitudescredito;

CREATE TRIGGER on_solicitud_estado_changed
AFTER UPDATE OF estado, fechadesembolso ON public.solicitudescredito
FOR EACH ROW
WHEN (
  OLD.estado IS DISTINCT FROM NEW.estado
  OR (
    OLD.fechadesembolso IS DISTINCT FROM NEW.fechadesembolso
    AND NEW.estado IN ('aprobada', 'condicionada', 'desembolsada')
  )
)
EXECUTE FUNCTION public.notify_solicitud_estado();
