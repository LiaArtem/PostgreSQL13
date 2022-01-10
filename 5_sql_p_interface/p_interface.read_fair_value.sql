CREATE OR REPLACE FUNCTION p_interface.read_fair_value(p_date timestamp without time zone)
 RETURNS SETOF p_interface.t_fair_value
 LANGUAGE plpgsql
AS $function$
DECLARE
      -- Справедливая стоимость ЦБ (котировки НБУ)
      -- Получить данные
      -- select t.* from p_interface.read_fair_value(p_convert.str_to_date('06.05.2021')) t
      p_url                  varchar(255) := '';
      p_response_body        text;
      p_fair_value_row       p_interface.t_fair_value;
      p_num					 numeric := 1;
      j 					 RECORD;
  	  k 					 RECORD;
begin	
      p_url := 'https://bank.gov.ua/files/Fair_value/'||to_char(p_date,'yyyymm/yyyymmdd')||'_fv.txt';

      -- запрашиваем данные
      p_response_body := p_service.get(p_uri => p_url, p_decode => 'cp1251'); 
      
      --RAISE EXCEPTION 'p_response_body %.', p_response_body;
     
      for j in with a as (select p_response_body as source_text)
               select regexp_split_to_table(a.source_text, '\n+') as string_row 
               from a
      loop    
          -- заголовок пропускаем          
          if p_num > 1
          then                            
	          for k in with b as (select j.string_row as source_text_row)
	                   select  p_convert.str_to_date(split_part(b.source_text_row, ';', 1)) as calc_date,
	                           split_part(b.source_text_row, ';', 2) as cpcode,
	                           split_part(b.source_text_row, ';', 3) as ccy,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 4)) as fair_value,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 5)) as ytm,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 6)) as clean_rate,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 7)) as cor_coef,
	                           p_convert.str_to_date(split_part(b.source_text_row, ';', 8)) as maturity,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 9)) as cor_coef_cash,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 10)) as notional,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 11)) as avr_rate,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 12)) as option_value,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 13)) as intrinsic_value,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 14)) as time_value,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 15)) as delta_per,
	                           p_convert.str_to_num(split_part(b.source_text_row, ';', 16)) as delta_equ,
	                           split_part(b.source_text_row, ';', 16) as dop
	                   from b        
	           loop
	              p_fair_value_row.calc_date := k.calc_date;
	              p_fair_value_row.cpcode := k.cpcode;
	              p_fair_value_row.ccy := k.ccy;
	              p_fair_value_row.fair_value := k.fair_value;
	              p_fair_value_row.ytm := k.ytm;
	              p_fair_value_row.clean_rate := k.clean_rate;
	              p_fair_value_row.cor_coef := k.cor_coef;
	              p_fair_value_row.maturity := k.maturity;
	              p_fair_value_row.cor_coef_cash := k.cor_coef_cash;
	              p_fair_value_row.notional := k.notional;
	              p_fair_value_row.avr_rate := k.avr_rate;
	              p_fair_value_row.option_value := k.option_value;
	              p_fair_value_row.intrinsic_value := k.intrinsic_value;
	              p_fair_value_row.time_value := k.time_value;
	              p_fair_value_row.delta_per := k.delta_per;
	              p_fair_value_row.delta_equ := k.delta_equ;
	              p_fair_value_row.dop := k.dop;
	              return next p_fair_value_row;
	           end loop;
		   end if;       
           p_num := p_num + 1;          
       end loop;
      
       return;
    end;
   
$function$
;
