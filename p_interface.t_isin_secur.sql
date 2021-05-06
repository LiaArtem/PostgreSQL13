-- DROP TYPE p_interface.t_isin_secur;

CREATE TYPE p_interface.t_isin_secur AS (
	cpcode varchar(255),
	nominal numeric,
	auk_proc numeric,
	pgs_date timestamp,
	razm_date timestamp,
	cptype varchar(255),
	cpdescr varchar(255),
	pay_period numeric,
	val_code varchar(3),
	emit_okpo varchar(255),
	emit_name varchar(255),
	cptype_nkcpfr varchar(255),
	cpcode_cfi varchar(255),
	total_bonds numeric,
	pay_date timestamp,
	pay_type numeric,
	pay_val numeric,
	pay_array varchar(5));
