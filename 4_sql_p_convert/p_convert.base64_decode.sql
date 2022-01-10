CREATE OR REPLACE FUNCTION p_convert.base64_decode(p_value text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  -- Преобразование из base64
    m_result text;
begin
    if p_value is null then return null; end if;      
    select convert_from(decode(p_value, 'base64'), 'UTF8') into STRICT m_result;
    return m_result;
  end;
$function$
;
