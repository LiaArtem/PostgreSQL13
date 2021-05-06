CREATE OR REPLACE FUNCTION p_interface.read_isin_secur(p_format text)
 RETURNS SETOF p_interface.t_isin_secur
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
      -- Перечень ISIN ЦБ с купонными периодами
      -- Получить данные
      -- select * from p_interface.read_isin_secur('xml')
      p_url                  varchar(255) := '';
      p_response_body        text;
      p_dop_param            varchar(5) := '';
      p_isin_secur_row       p_interface.t_isin_secur;
      k  					 RECORD;
      kk 					 RECORD;     
BEGIN
      if p_format = 'json' then p_dop_param := '?json'; end if;
      p_url := 'https://bank.gov.ua/depo_securities'||p_dop_param;

      -- запрашиваем данные
      p_response_body := p_service.get(p_uri => p_url, p_decode => 'utf-8'); 
     
      --RAISE EXCEPTION 'p_response_body %.', p_response_body;                    
       
       if p_format = 'json'            
       then
          if p_check.is_valid_json(p_response_body) = 'T'
          then  		
              for k in    select (e.item ->> 'cpcode') as cpcode,
  			                     (e.item ->> 'nominal') as nominal,
  			                     p_convert.str_to_num((e.item ->> 'auk_proc')) as auk_proc,
  			                     p_convert.str_to_date((e.item ->> 'pgs_date'),'yyyy-mm-dd') as pgs_date,
  			                     p_convert.str_to_date((e.item ->> 'razm_date'),'yyyy-mm-dd') as razm_date,
  			                     (e.item ->> 'cptype') as cptype,
  			                     (e.item ->> 'cpdescr') as cpdescr,
  			                     (e.item ->> 'pay_period') as pay_period,
  			                     (e.item ->> 'val_code') as val_code,
  			                     (e.item ->> 'emit_okpo') as emit_okpo,
  			                     (e.item ->> 'emit_name') as emit_name,
  			                     (e.item ->> 'cptype_nkcpfr') as cptype_nkcpfr,
  			                     (e.item ->> 'cpcode_cfi') as cpcode_cfi,
  			                     (e.item ->> 'pay_period') as total_bonds,
  			                     (e.item ->> 'payments') as payments  			                     
                            from jsonb_path_query(p_response_body::jsonb, '$[*]') as e(item)                         
               loop             
                  if k.payments is null
                  then  
                      p_isin_secur_row.cpcode := k.cpcode;
                      p_isin_secur_row.nominal := k.nominal;
                      p_isin_secur_row.auk_proc := k.auk_proc;
                      p_isin_secur_row.pgs_date := k.pgs_date;
                      p_isin_secur_row.razm_date := k.razm_date;
                      p_isin_secur_row.cptype := k.cptype;
                      p_isin_secur_row.cpdescr := k.cpdescr;
                      p_isin_secur_row.pay_period := k.pay_period;
                      p_isin_secur_row.val_code := k.val_code;
                      p_isin_secur_row.emit_okpo := k.emit_okpo;
                      p_isin_secur_row.emit_name := k.emit_name;
                      p_isin_secur_row.cptype_nkcpfr := k.cptype_nkcpfr;
                      p_isin_secur_row.cpcode_cfi := k.cpcode_cfi;
                      p_isin_secur_row.total_bonds := k.total_bonds;
                      p_isin_secur_row.pay_date := null;
                      p_isin_secur_row.pay_type := null;
                      p_isin_secur_row.pay_val := null;
                      p_isin_secur_row.pay_array := null;
                      return next p_isin_secur_row;
                  else
                      -- периоды
                      for kk in select p_convert.str_to_date((e.item ->> 'pay_date'),'yyyy-mm-dd') as pay_date,
		  			                   (e.item ->> 'pay_type') as pay_type,
		  			                   (e.item ->> 'pay_val') as pay_val,
		  			                   (e.item ->> 'array') as pay_array 			                     
	                            from jsonb_path_query(k.payments::jsonb, '$[*]') as e(item)                          
                      loop          
                          p_isin_secur_row.cpcode := k.cpcode;
                          p_isin_secur_row.nominal := k.nominal;
                          p_isin_secur_row.auk_proc := k.auk_proc;
                          p_isin_secur_row.pgs_date := k.pgs_date;
                          p_isin_secur_row.razm_date := k.razm_date;
                          p_isin_secur_row.cptype := k.cptype;
                          p_isin_secur_row.cpdescr := k.cpdescr;
                          p_isin_secur_row.pay_period := k.pay_period;
                          p_isin_secur_row.val_code := k.val_code;
                          p_isin_secur_row.emit_okpo := k.emit_okpo;
                          p_isin_secur_row.emit_name := k.emit_name;
                          p_isin_secur_row.cptype_nkcpfr := k.cptype_nkcpfr;
                          p_isin_secur_row.cpcode_cfi := k.cpcode_cfi;
                          p_isin_secur_row.total_bonds := k.total_bonds;
                          p_isin_secur_row.pay_date := kk.pay_date;
                          p_isin_secur_row.pay_type := kk.pay_type;
                          p_isin_secur_row.pay_val := kk.pay_val;
                          p_isin_secur_row.pay_array := kk.pay_array;
                          return next p_isin_secur_row;
                      end loop;
                   end if;
               end loop;
           end if;
       else  
          if p_check.is_valid_xml(p_response_body) = 'T'
          then  
              for k in select t.cpcode,
                              t.nominal,                                      
                              p_convert.str_to_num(t.auk_proc) as auk_proc,
                              p_convert.str_to_date(t.pgs_date,'yyyy-mm-dd') as pgs_date,
                              p_convert.str_to_date(t.razm_date,'yyyy-mm-dd') as razm_date,
                              t.cptype,
                              t.cpdescr,
                              t.pay_period,                                      
                              t.val_code,                                      
                              t.emit_okpo,
                              t.emit_name,
                              t.cptype_nkcpfr,
                              t.cpcode_cfi,
                              t.total_bonds,
                              t.payments
                          from xmltable('//security' passing (p_response_body::xml)
                                           columns                 
                                              cpcode          varchar(255) path 'cpcode',
                                              nominal         numeric      path 'nominal',                                      
                                              auk_proc        varchar(255) path 'auk_proc',                                      
                                              pgs_date        varchar(255) path 'pgs_date',                                      
                                              razm_date       varchar(255) path 'razm_date',                                      
                                              cptype          varchar(255) path 'cptype',
                                              cpdescr         varchar(255) path 'cpdescr',
                                              pay_period      numeric      path 'pay_period',                                      
                                              val_code        varchar(3)   path 'val_code',                                      
                                              emit_okpo       varchar(255) path 'emit_okpo',
                                              emit_name       varchar(255) path 'emit_name',
                                              cptype_nkcpfr   varchar(255) path 'cptype_nkcpfr',
                                              cpcode_cfi      varchar(255) path 'cpcode_cfi',
                                              total_bonds     numeric      path 'pay_period',                                          
                                              payments        xml          path 'payments'
                                            ) t  
               loop             
                  if k.payments is null
                  then  
                      p_isin_secur_row.cpcode := k.cpcode;
                      p_isin_secur_row.nominal := k.nominal;
                      p_isin_secur_row.auk_proc := k.auk_proc;
                      p_isin_secur_row.pgs_date := k.pgs_date;
                      p_isin_secur_row.razm_date := k.razm_date;
                      p_isin_secur_row.cptype := k.cptype;
                      p_isin_secur_row.cpdescr := k.cpdescr;
                      p_isin_secur_row.pay_period := k.pay_period;
                      p_isin_secur_row.val_code := k.val_code;
                      p_isin_secur_row.emit_okpo := k.emit_okpo;
                      p_isin_secur_row.emit_name := k.emit_name;
                      p_isin_secur_row.cptype_nkcpfr := k.cptype_nkcpfr;
                      p_isin_secur_row.cpcode_cfi := k.cpcode_cfi;
                      p_isin_secur_row.total_bonds := k.total_bonds;
                      p_isin_secur_row.pay_date := null;
                      p_isin_secur_row.pay_type := null;
                      p_isin_secur_row.pay_val := null;
                      p_isin_secur_row.pay_array := null;
                      return next p_isin_secur_row;
                  else
                      -- периоды
                      for kk in select  p_convert.str_to_date(t.pay_date,'yyyy-mm-dd') as pay_date,
                                        t.pay_type,                                      
                                        p_convert.str_to_num(t.pay_val) as pay_val,
                                        t.pay_array
                                    from xmltable('//payment' passing k.payments
                                                     columns                 
                                                        pay_date        varchar(255) path 'pay_date',
                                                        pay_type        numeric      path 'pay_type',                                      
                                                        pay_val         varchar(255) path 'pay_val',                                      
                                                        pay_array       varchar(255) path 'array'
                                                      ) t  
                      loop          
                          p_isin_secur_row.cpcode := k.cpcode;
                          p_isin_secur_row.nominal := k.nominal;
                          p_isin_secur_row.auk_proc := k.auk_proc;
                          p_isin_secur_row.pgs_date := k.pgs_date;
                          p_isin_secur_row.razm_date := k.razm_date;
                          p_isin_secur_row.cptype := k.cptype;
                          p_isin_secur_row.cpdescr := k.cpdescr;
                          p_isin_secur_row.pay_period := k.pay_period;
                          p_isin_secur_row.val_code := k.val_code;
                          p_isin_secur_row.emit_okpo := k.emit_okpo;
                          p_isin_secur_row.emit_name := k.emit_name;
                          p_isin_secur_row.cptype_nkcpfr := k.cptype_nkcpfr;
                          p_isin_secur_row.cpcode_cfi := k.cpcode_cfi;
                          p_isin_secur_row.total_bonds := k.total_bonds;
                          p_isin_secur_row.pay_date := kk.pay_date;
                          p_isin_secur_row.pay_type := kk.pay_type;
                          p_isin_secur_row.pay_val := kk.pay_val;
                          p_isin_secur_row.pay_array := kk.pay_array;
                          return next p_isin_secur_row;
                      end loop;
                   end if;
               end loop;
           end if;
       end if;

       return;
    end;

$function$
;
