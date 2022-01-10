CREATE OR REPLACE FUNCTION p_convert.str_amount_format(p_number numeric, p_count_comma integer DEFAULT 2)
 RETURNS character varying
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    -- ѕреобразование суммы в текстовый формат числа
    p_n varchar(255);
    pos integer;
    p_num numeric;

BEGIN
    if p_number is null then return p_number; end if;
    p_num := p_number;
    if p_num > 999999999999 then p_num := 999999999999; end if;

    if p_count_comma = 0 then p_n := to_char(p_num,'999G999G999G990'); end if;
    if p_count_comma = 1 then p_n := to_char(p_num,'999G999G999G990D0'); end if;
    if p_count_comma = 2 then p_n := to_char(p_num,'999G999G999G990D00'); end if;
    if p_count_comma = 3 then p_n := to_char(p_num,'999G999G999G990D000'); end if;
    if p_count_comma = 4 then p_n := to_char(p_num,'999G999G999G990D0000'); end if;
    if p_count_comma = 5 then p_n := to_char(p_num,'999G999G999G990D00000'); end if;
    if p_count_comma > 5 or p_count_comma is null
    then
       RAISE EXCEPTION '%', ' оличество знаков после зап€той не может быль больше 5 или NULL !!!' USING ERRCODE = '45000';
    end if;

    p_n := replace(p_n,'.',chr(44));
    p_n := replace(p_n,chr(44),' ');
    p_n := trim(both p_n);

    -- восстанавливаем последнюю зап€тую
    pos := instr(p_n,' ',-1,1);
    if p_count_comma = 0 then p_n := p_n; end if;
    if p_count_comma <> 0 then p_n := substr(p_n,1,pos-1) || chr(44) || substr(p_n,pos+1,length(p_n)-pos); end if;

    return p_n;
  end;

$function$
;
