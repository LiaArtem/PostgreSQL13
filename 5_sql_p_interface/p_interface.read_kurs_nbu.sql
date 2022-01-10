CREATE OR REPLACE FUNCTION p_interface.read_kurs_nbu(p_date timestamp without time zone, p_format text, p_currency text DEFAULT NULL::text)
 RETURNS TABLE(r030 character varying, txt character varying, rate numeric, cc character varying, exchangedate timestamp without time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
     -- Курсы валют НБУ
     -- Получить данные
     -- select t.* from p_interface.read_kurs_nbu(p_convert.str_to_date('05.05.2021'), 'json', 'USD') t            
      p_url                  varchar(255) := '';
      p_response_body        text;
      p_dop_param            varchar(5) := '';
BEGIN
      if p_format = 'json' then p_dop_param := '&json'; end if;

      if p_currency is null
      then  
         p_url := 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date='||to_char(p_date,'yyyymmdd')||p_dop_param;
      else
         p_url := 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode='||p_currency||'&date='||to_char(p_date,'yyyymmdd')||p_dop_param;
      end if;

       -- запрашиваем данные
       p_response_body := p_service.get(p_uri => p_url, p_decode => 'utf-8'); 
      
      --RAISE EXCEPTION 'p_response_body %.', p_response_body;
       
       if p_format = 'json'            
       then
          if p_check.is_valid_json(p_response_body) = 'T'
          then  
  			 return query select lpad(e.item ->> 'r030',3,'0')::varchar(3) as r030,
						         (e.item ->> 'txt')::varchar(255) as txt,
						         p_convert.str_to_num((e.item ->> 'rate')) as rate,
						         (e.item ->> 'cc')::varchar(3) as cc,
						         p_convert.str_to_date((e.item ->> 'exchangedate')) as exchangedate      
                            from jsonb_path_query(p_response_body::jsonb, '$[*]') as e(item);
			
			  -- Так как выполнение ещё не закончено, можно проверить, были ли возвращены строки, и выдать исключение, если нет.
			  --if not found 
			  --then
			  --   RAISE EXCEPTION 'Нет курсов на дату: %.', p_date;
			  --end if;			
           end if;
       else
          if p_check.is_valid_xml(p_response_body) = 'T'
          then
              return query select lpad(j.r030,3,'0')::varchar(3) as r030,
	                               j.txt::varchar(255) as txt,
	                               p_convert.str_to_num(j.rate) as rate,
	                               j.cc::varchar(3) as cc,
	                               p_convert.str_to_date(j.exchangedate) as exchangedate
	                          from xmltable('//exchange/currency' passing (p_response_body::xml)
	                                 columns 
	                                         r030 varchar(3)   path 'r030',
	                                         txt  varchar(255) path 'txt',
	                                         rate varchar(255) path 'rate',                       
	                                         cc   varchar(255) path 'cc',                       
	                                         exchangedate varchar(255) path 'exchangedate'                       
	                                         ) j;     
           null;          
           end if;
       end if;

       return;
    end;

$function$
;
