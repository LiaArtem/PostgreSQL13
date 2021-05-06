CREATE OR REPLACE FUNCTION p_interface.read_erb_minfin(p_categorycode text DEFAULT NULL::text, p_identcode text DEFAULT NULL::text, p_lastname text DEFAULT NULL::text, p_firstname text DEFAULT NULL::text, p_middlename text DEFAULT NULL::text, p_birthdate timestamp without time zone DEFAULT NULL::timestamp without time zone, p_type_cust_code text DEFAULT NULL::text)
 RETURNS SETOF p_interface.t_erb_minfin
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
      -- НАИС - поиск контрагента в ЕРД (едином реестре должников)
      -- Получить данные
      -- select * from p_interface.read_erb_minfin(p_identcode => '33270581', p_type_cust_code => '2')    
      -- select * from p_interface.read_erb_minfin(p_identCode => '2985108376', p_type_cust_code => '1')
	  -- select * from p_interface.read_erb_minfin(p_lastName       => 'Бондарчук',
	  --	                                       p_firstName      => 'Ігор',
	  --                                           p_middleName     => 'Володимирович',
	  --                                           p_birthDate      => to_date('23.09.1981','dd.mm.yyyy'),
	  --                                           p_type_cust_code => '1')
      p_url                  varchar(255);
      p_response_body        text;
      p_request_body         text;
      p_num                  numeric := 1;
      p_erb_minfin_row       t_erb_minfin;     
      k 					 RECORD;
      j 					 RECORD;
BEGIN
      p_url := 'https://erb.minjust.gov.ua/listDebtorsEndpoint';

      -- физ. лица
      if p_type_cust_code = '1'
      then  
          select json_build_object('searchType','1', 'paging','1',
                                   'filter', json_build_object('LastName', p_lastName,
                                                               'FirstName', p_firstName,
                                                               'MiddleName', p_middleName,
                                                               'BirthDate', case when p_birthDate is null then null
                                                                                 else to_char(p_birthDate,'YYYY-MM-DD')||'T00:00:00.000Z'
                                                                                 end,       
                                                               'IdentCode', p_identCode,
                                                               'categoryCode',  p_categoryCode
                                                            -- если будет пустая переменная, тег не подставляется (используем json_strip_nulls(json_build_object())
                                                            -- по умолчанию, если пустая передается null
                                                            )                   
                            )
                        into STRICT p_request_body;
      else
      -- юр. лица        
          select json_build_object('searchType','2',
                                   'filter', json_build_object('FirmName', p_lastName,
                                                               'FirmEdrpou', p_identCode,
                                                               'categoryCode', p_categoryCode
                                                               )                   
                                  )
                        into STRICT p_request_body;
      end if;
      
      -- запрашиваем данные
      p_response_body := p_service.post(p_uri => p_url, p_request_body => p_request_body::json, p_paramenters => '[]', p_decode => 'utf-8'); 
      
      --RAISE EXCEPTION 'p_response_body %.', p_response_body;     
       
      if p_check.is_valid_json(p_response_body) = 'T'
      then  
          for j in select (e.item ->> 'isSuccess') as isSuccess,
  			              (e.item ->> 'rows') as num_rows,
			              (e.item ->> 'requestDate') as requestDate,  			                     
			              (e.item ->> 'isOverflow') as isOverflow,
			              (e.item ->> 'errMsg') as errMsg
			         from jsonb_path_query(p_response_body::jsonb, '$[*]') as e(item)
		  loop   
   	          if j.errMsg is not null
		      then  
		          RAISE EXCEPTION '%', p_request_body||chr(13)||chr(10)||j.errMsg USING ERRCODE = '45000';
		      end if;
		  
	          p_erb_minfin_row.isSuccess := j.isSuccess;
	          p_erb_minfin_row.num_rows := j.num_rows;
	          p_erb_minfin_row.requestDate := p_convert.get_datetime(j.requestDate);
	          p_erb_minfin_row.isOverflow := j.isOverflow;

	          if p_erb_minfin_row.num_rows > 0
	          then  
	                for k in select (e.item ->> 'ID') as num_id,
	  			                     (e.item ->> 'rootID') as root_id,
	  			                     (e.item ->> 'lastName') as lastname,  			                     
	  			                     (e.item ->> 'firstName') as firstName,
	  			                     (e.item ->> 'middleName') as middleName,
	  			                     (e.item ->> 'birthDate') as birthDate,
	  			                     (e.item ->> 'publisher') as publisher,
	  			                     (e.item ->> 'departmentCode') as departmentCode,
	  			                     (e.item ->> 'departmentName') as departmentName,
	  			                     (e.item ->> 'departmentPhone') as departmentPhone,
	  			                     (e.item ->> 'executor') as executor,
	  			                     (e.item ->> 'executorPhone') as executorPhone,
	  			                     (e.item ->> 'executorEmail') as executorEmail,
	  			                     (e.item ->> 'deductionType') as deductionType,
	  			                     (e.item ->> 'vpNum') as vpNum,
	  			                     (e.item ->> 'code') as okpo,
	  			                     (e.item ->> 'name') as full_name
	  			                     from jsonb_path_query(p_response_body::jsonb, '$.results[*]') as e(item)                     
	                 loop
	                    p_erb_minfin_row.num_id          := k.num_id;
	                    p_erb_minfin_row.root_id         := k.root_id;
	                    p_erb_minfin_row.lastname        := k.lastname;
	                    p_erb_minfin_row.firstname       := k.firstname;
	                    p_erb_minfin_row.middlename      := k.middlename;
	                    p_erb_minfin_row.birthdate       := p_convert.get_datetime(k.birthdate);
	                    p_erb_minfin_row.publisher       := k.publisher;
	                    p_erb_minfin_row.departmentcode  := k.departmentcode;
	                    p_erb_minfin_row.departmentname  := k.departmentname;
	                    p_erb_minfin_row.departmentphone := k.departmentphone;
	                    p_erb_minfin_row.executor        := k.executor;
	                    p_erb_minfin_row.executorphone   := k.executorphone;
	                    p_erb_minfin_row.executoremail   := k.executoremail;
	                    p_erb_minfin_row.deductiontype   := k.deductiontype;
	                    p_erb_minfin_row.vpnum           := k.vpnum;
	                    p_erb_minfin_row.okpo            := k.okpo;
	                    p_erb_minfin_row.full_name       := k.full_name;
	                    return next p_erb_minfin_row; 
	                 end loop;
	           end if;
	       end loop;   
       end if;

       return;
    end;

$function$
;
