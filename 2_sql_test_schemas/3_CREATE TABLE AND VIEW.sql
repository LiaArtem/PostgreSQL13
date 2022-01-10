-- Table: test_schemas.curs

-- DROP TABLE IF EXISTS test_schemas.curs;

CREATE TABLE IF NOT EXISTS test_schemas.curs
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    curs_date date NOT NULL,
    curr_code character varying(3) COLLATE pg_catalog."default" NOT NULL,
    rate numeric,
    CONSTRAINT pk_curs PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS test_schemas.curs
    OWNER to test_user;

COMMENT ON TABLE test_schemas.curs
    IS 'Курсы валют';

COMMENT ON COLUMN test_schemas.curs.id
    IS 'ID';

COMMENT ON COLUMN test_schemas.curs.curs_date
    IS 'Дата курса';

COMMENT ON COLUMN test_schemas.curs.curr_code
    IS 'Код валюты';

COMMENT ON COLUMN test_schemas.curs.rate
    IS 'Курс';
-- Index: uk_curs

-- DROP INDEX IF EXISTS test_schemas.uk_curs;

CREATE UNIQUE INDEX IF NOT EXISTS uk_curs
    ON test_schemas.curs USING btree
    (curs_date ASC NULLS LAST, curr_code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

-- View: test_schemas.view_kurs_report

-- DROP VIEW test_schemas.view_kurs_report;

CREATE OR REPLACE VIEW test_schemas.view_kurs_report
 AS
 WITH curs_avg_year(part_date_year, curr_code, avg_rate) AS (
         SELECT to_char(k_1.curs_date::timestamp with time zone, 'YYYY'::text) AS part_date_year,
            k_1.curr_code,
            avg(k_1.rate) AS avg_rate
           FROM test_schemas.curs k_1
          GROUP BY (to_char(k_1.curs_date::timestamp with time zone, 'YYYY'::text)), k_1.curr_code
        ), curs_avg(part_day_month, curr_code, avg_rate) AS (
         SELECT f.part_day_month,
            f.curr_code,
            avg(f.avg_rate) AS avg_rate
           FROM ( SELECT to_char(k_1.curs_date::timestamp with time zone, 'MM-DD'::text) AS part_day_month,
                    k_1.curr_code,
                    k_1.rate / a_1.avg_rate * 100::numeric AS avg_rate
                   FROM test_schemas.curs k_1
                     JOIN curs_avg_year a_1 ON a_1.part_date_year = to_char(k_1.curs_date::timestamp with time zone, 'YYYY'::text) AND a_1.curr_code::text = k_1.curr_code::text) f
          GROUP BY f.part_day_month, f.curr_code
        )
 SELECT k.curs_date,
    k.curr_code,
    k.rate,
    a.avg_rate
   FROM test_schemas.curs k
     JOIN curs_avg a ON a.part_day_month = to_char(k.curs_date::timestamp with time zone, 'MM-DD'::text) AND a.curr_code::text = k.curr_code::text
  WHERE (to_char(k.curs_date::timestamp with time zone, 'YYYY'::text) IN ( SELECT to_char(max(kk.curs_date)::timestamp with time zone, 'YYYY'::text) AS to_char
           FROM test_schemas.curs kk))
  ORDER BY k.curs_date;

ALTER TABLE test_schemas.view_kurs_report
    OWNER TO test_user;

