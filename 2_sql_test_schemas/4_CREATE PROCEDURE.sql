-- PROCEDURE: test_schemas.insert_curs(character varying, character varying, double precision)

-- DROP PROCEDURE IF EXISTS test_schemas.insert_curs(character varying, character varying, double precision);

CREATE OR REPLACE PROCEDURE test_schemas.insert_curs(
	IN p_curs_date character varying,
	IN p_curr_code character varying,
	IN p_rate double precision)
LANGUAGE 'sql'
AS $BODY$

	   INSERT INTO test_schemas.curs (CURS_DATE, CURR_CODE, RATE)
	       SELECT TO_DATE(p_curs_date, 'YYYY-MM-DD'), p_curr_code, p_rate
	       WHERE NOT EXISTS (SELECT 1 FROM test_schemas.curs c where c.curs_date = TO_DATE(p_curs_date, 'YYYY-MM-DD') and c.curr_code = p_curr_code);
$BODY$;