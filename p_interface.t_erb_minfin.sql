-- DROP TYPE p_interface.t_erb_minfin;

CREATE TYPE p_interface.t_erb_minfin AS (
	issuccess text,
	num_rows numeric,
	requestdate timestamp,
	isoverflow text,
	num_id numeric,
	root_id numeric,
	lastname text,
	firstname text,
	middlename text,
	birthdate timestamp,
	publisher text,
	departmentcode text,
	departmentname text,
	departmentphone text,
	executor text,
	executorphone text,
	executoremail text,
	deductiontype text,
	vpnum text,
	okpo text,
	full_name text);
