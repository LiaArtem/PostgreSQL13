-- DROP TYPE p_interface.t_fair_value;

CREATE TYPE p_interface.t_fair_value AS (
	calc_date timestamp,
	cpcode varchar(255),
	ccy varchar(3),
	fair_value numeric,
	ytm numeric,
	clean_rate numeric,
	cor_coef numeric,
	maturity timestamp,
	cor_coef_cash numeric,
	notional numeric,
	avr_rate numeric,
	option_value numeric,
	intrinsic_value numeric,
	time_value numeric,
	delta_per numeric,
	delta_equ numeric,
	dop varchar(255));
