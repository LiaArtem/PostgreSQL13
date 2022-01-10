CREATE OR REPLACE FUNCTION p_check.is_valid_json(p_text text)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
      -- Проверка валидности JSON
      p_json json;

begin
        p_json := p_text::json;
        return 'T';
    exception when others
    then
        return 'F';
    end;	        
    
$function$
;
