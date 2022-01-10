CREATE OR REPLACE FUNCTION p_check.is_valid_xml(p_text text)
 RETURNS character varying
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
		-- Проверка валидности XML
        p_xml xml;

BEGIN
        p_xml := p_text::xml;
        return 'T';
    exception when others
    then
        return 'F';
    end;

$function$
;
