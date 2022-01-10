CREATE OR REPLACE FUNCTION p_convert.str_amount_curr(p_amount numeric, p_curr_code character varying DEFAULT 'UAH'::character varying, p_is_decimal character DEFAULT 'F'::bpchar)
 RETURNS character varying
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    -- ѕреобразование суммы в текст (с валютой)
    dig       varchar(255)[];
    dig_a     varchar(255)[];
    ten       varchar(255)[];
    hun       varchar(255)[];
    tis       varchar(255)[];
    mln       varchar(255)[];
    mlrd      varchar(255)[];
	i         numeric := 0;
    CurrValue numeric;
    OriginVal numeric;
    Fraction  numeric;
    l         integer;
    S         numeric;
    DIGIT     varchar(255) := '';
    RADIX     varchar(255) := '';
    CResult   varchar(255);
    p_result  varchar(255) := '';

begin	
    CurrValue := trunc(p_amount);
    OriginVal := CurrValue;
    Fraction  := trunc((p_amount - CurrValue) * 100);

    -- тыс€чи
    tis[0] := 'тис€ч ';
    tis[1] := 'тис€ча ';
    tis[2] := 'тис€чi ';
    tis[3] := 'тис€чi ';
    tis[4] := 'тис€чi ';
    tis[5] := 'тис€ч ';
    tis[6] := 'тис€ч ';
    tis[7] := 'тис€ч ';
    tis[8] := 'тис€ч ';
    tis[9] := 'тис€ч ';
    tis[10] := 'тис€ч ';
    tis[11] := 'тис€ч ';
    tis[12] := 'тис€ч ';
    tis[13] := 'тис€ч ';
    tis[14] := 'тис€ч ';
    tis[15] := 'тис€ч ';
    tis[16] := 'тис€ч ';
    tis[17] := 'тис€ч ';
    tis[18] := 'тис€ч ';
    tis[19] := 'тис€ч ';

    -- мiльйон
    mln[0] := 'мiльйонiв ';
    mln[1] := 'мiльйон ';
    mln[2] := 'мiльйона ';
    mln[3] := 'мiльйона ';
    mln[4] := 'мiльйона ';
    mln[5] := 'мiльйонiв ';
    mln[6] := 'мiльйонiв ';
    mln[7] := 'мiльйонiв ';
    mln[8] := 'мiльйонiв ';
    mln[9] := 'мiльйонiв ';
    mln[10] := 'мiльйонiв ';
    mln[11] := 'мiльйонiв ';
    mln[12] := 'мiльйонiв ';
    mln[13] := 'мiльйонiв ';
    mln[14] := 'мiльйонiв ';
    mln[15] := 'мiльйонiв ';
    mln[16] := 'мiльйонiв ';
    mln[17] := 'мiльйонiв ';
    mln[18] := 'мiльйонiв ';
    mln[19] := 'мiльйонiв ';

    -- мiль€рдiв
    mlrd[0] := ' ';
    mlrd[1] := 'мiль€рд ';
    mlrd[2] := 'мiль€рда ';
    mlrd[3] := 'мiль€рда ';
    mlrd[4] := 'мiль€рда ';
    mlrd[5] := 'мiль€рдiв ';
    mlrd[6] := 'мiль€рдiв ';
    mlrd[7] := 'мiль€рдiв ';
    mlrd[8] := 'мiль€рдiв ';
    mlrd[9] := 'мiль€рдiв ';
    mlrd[10] := 'мiль€рдiв ';
    mlrd[11] := 'мiль€рдiв ';
    mlrd[12] := 'мiль€рдiв ';
    mlrd[13] := 'мiль€рдiв ';
    mlrd[14] := 'мiль€рдiв ';
    mlrd[15] := 'мiль€рдiв ';
    mlrd[16] := 'мiль€рдiв ';
    mlrd[17] := 'мiль€рдiв ';
    mlrd[18] := 'мiль€рдiв ';
    mlrd[19] := 'мiль€рдiв ';

    Dig[0] := '';
    dig[1] := 'один ';
    dig[2] := 'два ';
    dig[3] := 'три ';
    dig[4] := 'чотири ';
    dig[5] := 'п''€ть ';
    dig[6] := 'шiсть ';
    dig[7] := 'сiм ';
    dig[8] := 'вiсiм ';
    dig[9] := 'дев''€ть ';
    dig[10] := 'дес€ть ';
    dig[11] := 'одинадц€ть ';
    dig[12] := 'дванадц€ть ';
    dig[13] := 'тринадц€ть ';
    dig[14] := 'чотирнадц€ть ';
    dig[15] := 'п''€тнадц€ть ';
    dig[16] := 'шiстнадц€ть ';
    dig[17] := 'сiмнадц€ть ';
    dig[18] := 'вiсiмнадц€ть ';
    dig[19] := 'дев''€тнадц€ть ';

    Dig_a[0] := '';
    dig_a[1] := 'один ';
    dig_a[2] := 'два ';
    dig_a[3] := 'три ';
    dig_a[4] := 'чотири ';
    dig_a[5] := 'п''€ть ';
    dig_a[6] := 'шiсть ';
    dig_a[7] := 'сiм ';
    dig_a[8] := 'вiсiм ';
    dig_a[9] := 'дев''€ть ';
    dig_a[10] := 'дес€ть ';
    dig_a[11] := 'одинадц€ть ';
    dig_a[12] := 'дванадц€ть ';
    dig_a[13] := 'тринадц€ть ';
    dig_a[14] := 'чотирнадц€ть ';
    dig_a[15] := 'п''€тнадц€ть ';
    dig_a[16] := 'шiстнадц€ть ';
    dig_a[17] := 'сiмнадц€ть ';
    dig_a[18] := 'вiсiмнадц€ть ';
    dig_a[19] := 'дев''€тнадц€ть ';

    ten[0] := '';
    ten[1] := '';
    ten[2] := 'двадц€ть ';
    ten[3] := 'тридц€ть ';
    ten[4] := 'сорок ';
    ten[5] := 'п''€тдес€т ';
    ten[6] := 'шiстдес€т ';
    ten[7] := 'сiмдес€т ';
    ten[8] := 'вiсiмдес€т ';
    ten[9] := 'дев''€носто ';

    Hun[0] := '';
    Hun[1] := 'сто ';
    Hun[2] := 'двiстi ';
    Hun[3] := 'триста ';
    Hun[4] := 'чотириста ';
    Hun[5] := 'п''€тсот ';
    Hun[6] := 'шiстсот ';
    Hun[7] := 'сiмсот ';
    Hun[8] := 'вiсiмсот ';
    Hun[9] := 'дев''€тсот ';

    if Currvalue = 0
    then
      p_result := 'Ќуль ';
    else
      while CurrValue > 0
      loop
        if (CurrValue % 1000) <> 0 
        then
          S := CurrValue % 100;
          if S < 20
          then
            if i <= 1 
            then
              if p_curr_code = 'UAH' 
              then
                DIGIT := dig_a[s];
              else
                DIGIT := dig[s];
              end if;
            else
              DIGIT := dig[s];
            end if;

            if i = 0 then
              RADIX := '';
            elsif i = 1 then
              RADIX := tis[s];
            elsif i = 2 then
              RADIX := mln[s];
            elsif i = 3 then
              RADIX := mlrd[s];
            end if;

            p_result := DIGIT || RADIX || p_result;
          else

            if i <= 1 then
              DIGIT := dig_a[mod(s, 10)];
            else
              DIGIT := dig[mod(s, 10)];
            end if;

            if i = 0 then
              RADIX := '';
            elsif i = 1 then
              RADIX := tis[mod(s, 10)];
            elsif i = 2 then
              begin
                if mod(s, 10) = 0 then
                  RADIX := mln[5];
                else
                  RADIX := mln[mod(s, 10)];
                end if;
              end;
            elsif i = 3 then
              begin
                if mod(s, 10) = 0 then
                  RADIX := mlrd[5];
                else
                  RADIX := mlrd[mod(s, 10)];
                end if;
              end;
            end if;

            p_result := Ten[trunc(S / 10)] || DIGIT || RADIX || p_result;

          end if;
          CurrValue := trunc(CurrValue / 100);
          S         := CurrValue % 10;
          p_result    := Hun[S] || p_result;
          CurrValue := trunc(CurrValue / 10);
          i         := i + 1;
        else
          CurrValue := trunc(CurrValue / 1000);
          i         := i + 1;
        end if;
      end loop;
    end if;

    if p_is_decimal = 'T' then
      p_result := p_result || ' цiлих ' || to_char(fraction, '00') || ' сотих';
    else
      if (upper(p_curr_code) = 'UAH') or (trim(both p_curr_code) is null) then
        CResult := OriginVal::varchar;
        l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || ' гривень';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || ' гривень';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || ' гривн€';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || ' гривн≥';
        else
          p_result := p_result || ' гривень';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йка';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йки';
        else
          p_result := p_result || to_char(fraction, '00') || ' коп≥йок';
        end if;
  ------------------------------------------------------------------
      elsif (upper(p_curr_code) = 'USD') then
        CResult := OriginVal::varchar;
        l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || ' доларiв —Ўј';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || ' доларiв —Ўј';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || ' долар —Ўј';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || ' долари —Ўј';
        else
          p_result := p_result || ' доларiв —Ўј';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' цент';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' центи';
        else
          p_result := p_result || to_char(fraction, '00') || ' центiв';
        end if;
  ------------------------------------------------------------------
        elsif (upper(p_curr_code) = 'EUR') then
          p_result := p_result || ' Ївро ';
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' Ївроцент';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' Ївроценти';
        else
          p_result := p_result || to_char(fraction, '00') || ' Ївроцентiв';
        end if;
  ------------------------------------------------------------------
        elsif (upper(p_curr_code) = 'GBP') then
          CResult := OriginVal::varchar;
          l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || ' англ≥йських ‘унт≥в стерл≥нг≥в';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || ' англ≥йських ‘унт≥в стерл≥нг≥в';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || ' англ≥йських ‘унт стерл≥нг≥в';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || ' англ≥йських ‘унти стерл≥нг≥в';
        else
          p_result := p_result || ' англ≥йських ‘унт≥в стерл≥нг≥в';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' пенс';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' пенси';
        else
          p_result := p_result || to_char(fraction, '00') || ' пенсiв';
        end if;
  ------------------------------------------------------------------
        elsif (upper(p_curr_code) = 'CHF') then
          CResult := OriginVal::varchar;
          l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || ' швейцарських франк≥в';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || ' швейцарських франк≥в';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || ' швейцарський франк';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || ' швейцарських франки';
        else
          p_result := p_result || ' швейцарських франк≥в';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' сантим';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' сантими';
        else
          p_result := p_result || to_char(fraction, '00') || ' сантимiв';
        end if;
  ------------------------------------------------------------------
        elsif (upper(p_curr_code) = 'RUR') then
          CResult := OriginVal::varchar;
          l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || 'рос≥йських рубл≥в';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || 'рос≥йських рубл≥в';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || 'рос≥йський рубель';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || 'рос≥йських рубл€';
        else
          p_result := p_result || 'рос≥йських рубл≥в';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йка';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йки';
        else
          p_result := p_result || to_char(fraction, '00') || ' коп≥йок';
        end if;
  ------------------------------------------------------------------
        elsif (upper(p_curr_code) = 'RUB') then
          CResult := OriginVal::varchar;
          l       := length(CResult);
        if ((l > 1) and ((substr(CResult, l - 1, 2))::numeric  > 10) and ((substr(CResult, l - 1, 2))::numeric  < 20)) then
          p_result := p_result || 'рос≥йських рубл≥в';
        elsif (substr(CResult, l, 1))::numeric  = 0 then
          p_result := p_result || 'рос≥йських рубл≥в';
        elsif (substr(CResult, l, 1))::numeric  = 1 then
          p_result := p_result || 'рос≥йський рубель';
        elsif ((substr(CResult, l, 1))::numeric  = 2) or ((substr(CResult, l, 1))::numeric  = 3) or ((substr(CResult, l, 1))::numeric  = 4) then
          p_result := p_result || 'рос≥йських рубл€';
        else
          p_result := p_result || 'рос≥йських рубл≥в';
        end if;
  ------------------------------------------------------------------
        if substr(fraction::varchar,1,2) in ('01','21','31','41','51','61','71','81','91') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йка';
        elsif substr(fraction::varchar,1,2) in ('02','03','04','22','23','24','32','33','34',
                                                '42','43','44','52','53','54','62','63','64',
                                                '72','73','74','82','83','84','92','93','94') then
          p_result := p_result || to_char(fraction, '00') || ' коп≥йки';
        else
          p_result := p_result || to_char(fraction, '00') || ' коп≥йок';
        end if;
  ------------------------------------------------------------------
        else
          p_result := p_result || ' ' || to_char(fraction, '00') || ' ' ||
                  p_curr_code;
        end if;
    end if;

    p_result := upper(substr(p_result, 1, 1)) || substr(p_result, 2, 254);
    p_result := replace(p_result, '  ', ' ');

    return(trim(both substr(p_result, 1, 255)));

  exception when others
  then
      return null;
  end;
  
$function$
;
