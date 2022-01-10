CREATE OR REPLACE FUNCTION p_convert.base64_encode(p_value text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  -- Преобразование в base64
    m_result text;
begin
    if p_value is null then return null; end if;    
    select encode(p_value::bytea, 'base64') into STRICT m_result;
    return m_result;
  end;

$function$
;
