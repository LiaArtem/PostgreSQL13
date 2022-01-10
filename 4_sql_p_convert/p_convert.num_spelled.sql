create or replace function p_convert.num_spelled_int (
  n numeric,
  g char,
  d text[]
) returns text
language plpgsql as $BODY$
declare
  r text;
  s text[];
begin
  r := ltrim(to_char(n, '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.')) || '.';

  if array_upper(d,1) = 1 and d[1] is not null then
    s := array[ d[1], d[1], d[1] ];
  else
    s := array[ coalesce(d[1],''), coalesce(d[2],''), coalesce(d[3],'') ];
  end if;

  --t - тысячи; m - милионы; M - миллиарды;
  r := replace( r, ',,,,,,', 'eM');
  r := replace( r, ',,,,,', 'em');
  r := replace( r, ',,,,', 'et');
  --e - единицы; d - десятки; c - сотни;
  r := replace( r, ',,,', 'e');
  r := replace( r, ',,', 'd');
  r := replace( r, ',', 'c');
  --удаление незначащих нулей
  r := replace( r, '0c0d0et', '');
  r := replace( r, '0c0d0em', '');
  r := replace( r, '0c0d0eM', '');

  --сотни
  r := replace( r, '0c', '');
  r := replace( r, '1c', 'сто ');
  r := replace( r, '2c', 'двести ');
  r := replace( r, '3c', 'триста ');
  r := replace( r, '4c', 'четыреста ');
  r := replace( r, '5c', 'пятьсот ');
  r := replace( r, '6c', 'шестьсот ');
  r := replace( r, '7c', 'семьсот ');
  r := replace( r, '8c', 'восемьсот ');
  r := replace( r, '9c', 'девятьсот ');

  --десятки
  r := replace( r, '1d0e', 'десять ');
  r := replace( r, '1d1e', 'одиннадцать ');
  r := replace( r, '1d2e', 'двенадцать ');
  r := replace( r, '1d3e', 'тринадцать ');
  r := replace( r, '1d4e', 'четырнадцать ');
  r := replace( r, '1d5e', 'пятнадцать ');
  r := replace( r, '1d6e', 'шестнадцать ');
  r := replace( r, '1d7e', 'семнадцать ');
  r := replace( r, '1d8e', 'восемнадцать ');
  r := replace( r, '1d9e', 'девятнадцать ');
  r := replace( r, '0d', '');
  r := replace( r, '2d', 'двадцать ');
  r := replace( r, '3d', 'тридцать ');
  r := replace( r, '4d', 'сорок ');
  r := replace( r, '5d', 'пятьдесят ');
  r := replace( r, '6d', 'шестьдесят ');
  r := replace( r, '7d', 'семьдесят ');
  r := replace( r, '8d', 'восемьдесят ');
  r := replace( r, '9d', 'девяносто ');

  --единицы
  r := replace( r, '0e', '');
  r := replace( r, '5e', 'пять ');
  r := replace( r, '6e', 'шесть ');
  r := replace( r, '7e', 'семь ');
  r := replace( r, '8e', 'восемь ');
  r := replace( r, '9e', 'девять ');

  if g = 'M' then
    r := replace( r, '1e.', 'один !'||s[1]||' '); --один рубль
    r := replace( r, '2e.', 'два !'||s[2]||' '); --два рубля
  elsif g = 'F' then
    r := replace( r, '1e.', 'одна !'||s[1]||' '); --одна тонна
    r := replace( r, '2e.', 'две !'||s[2]||' '); --две тонны
  elsif g = 'N' then
    r := replace( r, '1e.', 'одно !'||s[1]||' '); --одно место
    r := replace( r, '2e.', 'два !'||s[2]||' '); --два места
  end if;
  r := replace( r, '3e.', 'три !'||s[2]||' ');
  r := replace( r, '4e.', 'четыре !'||s[2]||' ');

  r := replace( r, '1et', 'одна тысяча ');
  r := replace( r, '2et', 'две тысячи ');
  r := replace( r, '3et', 'три тысячи ');
  r := replace( r, '4et', 'четыре тысячи ');
  r := replace( r, '1em', 'один миллион ');
  r := replace( r, '2em', 'два миллиона ');
  r := replace( r, '3em', 'три миллиона ');
  r := replace( r, '4em', 'четыре миллиона ');
  r := replace( r, '1eM', 'один милиард ');
  r := replace( r, '2eM', 'два милиарда ');
  r := replace( r, '3eM', 'три милиарда ');
  r := replace( r, '4eM', 'четыре милиарда ');

  r := replace( r, 't', 'тысяч ');
  r := replace( r, 'm', 'миллионов ');
  r := replace( r, 'M', 'милиардов ');

  r := replace( r, '.', ' !'||s[3]||' ');

  if n = 0 then
    r := 'ноль ' || r;
  end if;

  return r;
end;
$BODY$;

/*
select
  n,
  _num_spelled(n, 'M', '{рубль,рубля,рублей}'),
  _num_spelled(n, 'F', '{копейка,копейки,копеек}'),
  _num_spelled(n, 'N', '{евро}')
from (values(0),(1),(2),(3),(5),(10),(11),(20),(21),(22),(23),(25),(45678),(1234567),(78473298395)) t(n);
*/

create or replace function p_convert.num_spelled (
  source_number    numeric,
  int_unit_gender  char,
  int_units        text[],
  frac_unit_gender char,
  frac_units       text[],
  frac_format      text
) returns text
language plpgsql as $BODY$
declare
  i numeric;
  f numeric;
  fmt text;
  fs  text;
  s int := 0;
  result text;
begin
  i := trunc(abs(source_number));
  fmt := regexp_replace(frac_format, '[^09]', '', 'g');
  s := char_length(fmt);
  f := round((abs(source_number) - i) * pow(10, s));
  
  result := num_spelled_int(i, int_unit_gender, int_units);
  fs := num_spelled_int(f, frac_unit_gender, frac_units);

  if coalesce(s,0) > 0 then --дробная часть
    if frac_format like '%d%' then --цифрами
      fs := to_char(f, fmt) || ' ' || substring(fs, '!.*');
    end if;
    if frac_format like '%m%' then --между целой частью и ед.изм.
      result := replace(result, '!', ', '||fs||' ');
    else --в конце
      result := result || ' ' || fs;
    end if;
  end if;
  result := replace(result, '!', '');
  result := regexp_replace(result, ' +', ' ', 'g'); --лишние пробелы
  result := replace(result, ' ,', ',');

  if source_number < 0 then
    result := 'минус ' || result;
  end if;
  
  return trim(result);
end;
$BODY$;

comment on function p_convert.num_spelled (
  source_number    numeric,
  int_unit_gender  char,
  int_units        text[],
  frac_unit_gender char,
  frac_units       text[],
  frac_format      text
) is
$$Число прописью.
source_number    numeric   исходное число
int_unit_gender  char      род целой единицы измерения (F/M/N)
int_units        text[]    названия целых единиц (3 элемента):
                           [1] - 1 рубль/1 тонна/1 место
                           [2] - 2 рубля/2 тонны/2 места
                           [3] - 0 рублей/0 тонн/0 мест
frac_unit_gender char      род дробной единицы измерения (F/M/N)
frac_units       text      названия дробных единиц (3 элемента):
                           [1] - 1 грамм/1 копейка
                           [2] - 2 грамма/2 копейки
                           [3] - 0 граммов/0 копеек
frac_format      text      каким образом выводить дроби:
                           '0' - число разрядов, с ведущими нулями
                           '9' - число разрядов, без ведущих нулей
                           't' - текстом ('00t' -> четыре рубля двадцать копеек)
                           'd' - цифрами ('00d' -> четыре рубля 20 копеек)
                           'm' - выводить дробную часть перед единицей измерения целой части
                             ('00dm' -> четыре, 20 рубля)
$$;

/*
select
  n,
  num_spelled(n, 'M', '{рубль,рубля,рублей}', 'F', '{копейка,копейки,копеек}', '00t'),
  num_spelled(n, 'M', '{рубль,рубля,рублей}', 'F', '{копейка,копейки,копеек}', '00d'),
  num_spelled(n, 'M', '{рубль,рубля,рублей}', 'F', NULL, '00dm'),
  num_spelled(n, 'N', '{евро}', 'M', '{цент,цента,центов}', '00t'),
  num_spelled(n, 'F', '{тонна,тонны,тонн}', NULL, NULL, NULL),
  num_spelled(n, 'F', '{"тн,"}', 'M', '{кг}', '999d')
from (values(0),(1),(1.23),(45.678),(12345.67),(-1),(-123.45)) t(n);
*/

