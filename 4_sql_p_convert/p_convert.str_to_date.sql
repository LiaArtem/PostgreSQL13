CREATE OR REPLACE FUNCTION p_convert.str_to_date(p_text character varying, p_format character varying DEFAULT 'dd.mm.yyyy'::character varying)
 RETURNS timestamp without time zone
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
	-- Преобразование теста в дату
    return(to_date(trim(both p_text), p_format));
  exception when others
  then
     RAISE EXCEPTION '%', 'Невозможно преобразовать в дату ='||p_text USING ERRCODE = '45000';
  end;

$function$
;
