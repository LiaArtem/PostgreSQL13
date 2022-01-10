CREATE OR REPLACE FUNCTION p_convert.str_to_num(p_text character varying)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    -- Преобразование теста с число
    m_text varchar(32000);

begin
	if (p_text is null or p_text = '') then return null; end if;
    m_text := replace(p_text,',','.');
    m_text := replace(p_text,' ','');
    m_text := replace(p_text,chr(13),'');
    m_text := replace(p_text,chr(10),'');   
    return(to_number(trim(both m_text), '999999999999999999999999999999.99999999999999999999999999999'));
  exception when others
  then
     RAISE EXCEPTION '%', 'Невозможно преобразовать в число ="'||p_text||'"' USING ERRCODE = '45000';
  end;
 
$function$
;
