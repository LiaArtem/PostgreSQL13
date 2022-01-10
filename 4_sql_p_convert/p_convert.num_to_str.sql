CREATE OR REPLACE FUNCTION p_convert.num_to_str(p_amount numeric)
 RETURNS character varying
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
     -- Преобразование числа в текст
     m_result   varchar(60);
     m_len      integer;

BEGIN
     if p_amount is null then return ''; end if;

     m_result := trim(both to_char(p_amount, '999999999999999999999999999999.99999999999999999999999999999'));
     m_len    := length(m_result);

     for i in 0..m_len
     loop
       if substr(m_result, m_len - i, 1) != '0'
       then
         exit;
       else
         m_result := substr(m_result, 1, m_len - (i + 1));
       end if;
     end loop;

     m_result := trim(both m_result);
     m_len    := length(m_result);

     if substr(m_result, m_len, 1) in ('.', ',')
     then
       m_result := substr(m_result, 1, m_len - 1);
     end if;

     m_result := trim(both m_result);

     if substr(m_result, 1, 1) in ('.', ',')
     then
       m_result := '0'||m_result;
     end if;

     return m_result;
  end;
  
$function$
;
