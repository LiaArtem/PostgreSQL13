CREATE OR REPLACE FUNCTION p_convert.get_datetime(p_text text)
 RETURNS timestamp without time zone
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    -- Преобразование текста в дату и время
    m_date timestamp;

BEGIN
     if p_text in ('null', 'nul') then return null; end if;

     if length(p_text) > 20
     then
         select max(cast(TO_TIMESTAMP(p_text, 'YYYY-MM-DD"T"hh24:mi:ss.FF9"Z"') AS timestamp)) into STRICT m_date;
        
     elsif length(p_text) = 20
     then
         select max(cast(TO_TIMESTAMP(p_text, 'YYYY-MM-DD"T"hh24:mi:ss"Z"') AS timestamp)) into STRICT m_date;
        
     elsif length(p_text) = 17
     then
         select max(cast(TO_TIMESTAMP(p_text, 'YYYY-MM-DD"T"hh24:mi"Z"') AS timestamp)) into STRICT m_date;
        
     end if;

     return m_date;
  exception
     when others then
        return null;
  end;

$function$
;
