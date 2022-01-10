CREATE OR REPLACE FUNCTION p_convert.convert_str(p_text text, p_char_set_to character varying, p_char_set_from character varying)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
   -- ѕреобразование теста из одной в другую кодировку
   -- 'UTF8','WIN1251'	
      return convert_from(convert(p_text::bytea, p_char_set_from, p_char_set_to), 'UTF8'); 
  end;   
$function$
;
