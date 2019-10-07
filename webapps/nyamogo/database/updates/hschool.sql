--
-- PostgreSQL database dump
--

-- Dumped from database version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: accountants_login(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.accountants_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO entitys(entity_type_id, use_key_id,  org_id, entity_name, user_name, primary_email, primary_telephone,
         is_active)
        VALUES(1, 1, 0, NEW.accountant_name, NEW.email, NEW.email, New.telno, true);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.accountants_login() OWNER TO postgres;

--
-- Name: add_sys_login(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_sys_login(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_sys_login_id			integer;
	v_entity_id				integer;
BEGIN
	SELECT entity_id INTO v_entity_id
	FROM entitys WHERE user_name = $1;

	v_sys_login_id := nextval('sys_logins_sys_login_id_seq');

	INSERT INTO sys_logins (sys_login_id, entity_id)
	VALUES (v_sys_login_id, v_entity_id);

	UPDATE entitys SET last_login = current_timestamp
	WHERE (entity_id = v_entity_id);

	return v_sys_login_id;
END;
$_$;


ALTER FUNCTION public.add_sys_login(character varying) OWNER TO postgres;

--
-- Name: aft_entitys(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aft_entitys() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF(NEW.entity_type_id is not null) THEN
		INSERT INTO entity_subscriptions (org_id, entity_type_id, entity_id)
		VALUES (NEW.org_id, NEW.entity_type_id, NEW.entity_id);
	END IF;

	INSERT INTO entity_values (org_id, entity_id, entity_field_id)
	SELECT NEW.org_id, NEW.entity_id, entity_field_id
	FROM entity_fields
	WHERE (org_id = NEW.org_id) AND (is_active = true);

	INSERT INTO sys_access_entitys (entity_id, sys_access_level_id, org_id)
	SELECT NEW.entity_id, sys_access_level_id, org_id
	FROM sys_access_levels
	WHERE (org_id = NEW.org_id) AND (use_key_id = NEW.use_key_id);

	RETURN NULL;
END;
$$;


ALTER FUNCTION public.aft_entitys() OWNER TO postgres;

--
-- Name: change_password(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.change_password(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	old_password 		varchar(64);
	v_entity_id			integer;
	v_pass_change		varchar(120);
	msg					varchar(120);
BEGIN
	msg := 'Password Error';
	v_entity_id := $1::int;

	SELECT Entity_password INTO old_password
	FROM entitys WHERE (entity_id = v_entity_id);

	IF ($2 = '0') THEN
		v_pass_change := first_password();
		UPDATE entitys SET first_password = v_pass_change, Entity_password = md5(v_pass_change)
		WHERE (entity_id = v_entity_id);
		msg := 'New Password Changed';
	ELSIF (old_password = md5($2)) THEN
		UPDATE entitys SET Entity_password = md5($3) WHERE (entity_id = v_entity_id);
		msg := 'Password Changed';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.change_password(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: change_password(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.change_password(character varying, character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	old_password 		varchar(64);
	v_entity_id			integer;
	v_pass_change		varchar(120);
	msg					varchar(120);
BEGIN
	msg := 'Password Error';
	v_entity_id := $1::int;

	SELECT Entity_password INTO old_password
	FROM entitys WHERE (entity_id = v_entity_id);

	IF ($3 = '1') THEN
		v_pass_change := first_password();
		UPDATE entitys SET first_password = v_pass_change, Entity_password = md5(v_pass_change)
		WHERE (entity_id = v_entity_id);
		msg := 'Password Changed';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.change_password(character varying, character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: default_currency(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.default_currency(character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT orgs.currency_id
	FROM orgs INNER JOIN entitys ON orgs.org_id = entitys.org_id
	WHERE (entitys.entity_id = CAST($1 as integer));
$_$;


ALTER FUNCTION public.default_currency(character varying) OWNER TO postgres;

--
-- Name: email_credentials(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.email_credentials(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_entity_id			integer;
	v_org_id			integer;
	v_sys_email_id		integer;
	msg					varchar(120);
BEGIN
	SELECT entity_id, org_id INTO v_entity_id, v_org_id
	FROM entitys WHERE (entity_id = $1::int);

	SELECT sys_email_id INTO v_sys_email_id
	FROM sys_emails WHERE (use_type = 2) AND (org_id = v_org_id);

	IF(v_sys_email_id is null)THEN
		msg := 'Ensure you have an email template setup';
	ELSE
		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(v_org_id, v_sys_email_id, v_entity_id, 'entitys');

		msg := 'Emailed the credentials';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.email_credentials(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: email_to_username(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.email_to_username(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_entity_id			integer;
	v_email				varchar(120);
	v_user_name			varchar(120);
	msg					varchar(120);
BEGIN
	msg := 'Error changing email to username';

	SELECT entity_id, trim(lower(primary_email)) INTO v_entity_id, v_email
	FROM entitys WHERE (entity_id = $1::int);

	SELECT user_name INTO v_user_name
	FROM entitys WHERE (trim(lower(user_name)) = v_email);

	IF(v_email is null)THEN
		msg := 'Ensure you have an email entered';
	ELSIF(v_user_name is not null)THEN
		msg := 'There is an existing user with that email address as username';
	ELSE
		UPDATE entitys SET user_name = v_email WHERE entity_id = v_entity_id;
		msg := 'Email address updated to username';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.email_to_username(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: emailed(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.emailed(integer, character varying) RETURNS void
    LANGUAGE sql
    AS $_$
	UPDATE sys_emailed SET emailed = true WHERE (sys_emailed_id = CAST($2 as int));
$_$;


ALTER FUNCTION public.emailed(integer, character varying) OWNER TO postgres;

--
-- Name: first_password(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.first_password() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	rnd integer;
	passchange varchar(12);
BEGIN
	passchange := trunc(random()*1000);
	rnd := trunc(65+random()*25);
	passchange := passchange || chr(rnd);
	passchange := passchange || trunc(random()*1000);
	rnd := trunc(65+random()*25);
	passchange := passchange || chr(rnd);
	rnd := trunc(65+random()*25);
	passchange := passchange || chr(rnd);

	RETURN passchange;
END;
$$;


ALTER FUNCTION public.first_password() OWNER TO postgres;

--
-- Name: generate_fee_invoices(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_fee_invoices(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE 
msg			VARCHAR(120);
BEGIN
	INSERT INTO student_fee_invoices (student_id, org_id, fee_structure_id, class_level_id)
	SELECT student_id, 0, $1::int, students.class_level_id
	FROM students 
	INNER JOIN fees_structure ON students.class_level_id = fees_structure.class_level_id;
	msg:='Student Invoices Generated';

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.generate_fee_invoices(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: get_config_value(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_config_value(integer) RETURNS text
    LANGUAGE sql
    AS $_$
	SELECT config_value FROM sys_configs
	WHERE (sys_config_id = $1);
$_$;


ALTER FUNCTION public.get_config_value(integer) OWNER TO postgres;

--
-- Name: get_config_value(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_config_value(character varying) RETURNS text
    LANGUAGE sql
    AS $_$
	SELECT config_value FROM sys_configs
	WHERE (config_name = $1);
$_$;


ALTER FUNCTION public.get_config_value(character varying) OWNER TO postgres;

--
-- Name: get_currency_rate(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_currency_rate(integer, integer) RETURNS real
    LANGUAGE sql
    AS $_$
	SELECT max(exchange_rate)
	FROM currency_rates
	WHERE (org_id = $1) AND (currency_id = $2)
		AND (exchange_date = (SELECT max(exchange_date) FROM currency_rates WHERE (org_id = $1) AND (currency_id = $2)));
$_$;


ALTER FUNCTION public.get_currency_rate(integer, integer) OWNER TO postgres;

--
-- Name: get_current_year(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_current_year(character varying) RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT to_char(current_date, 'YYYY');
$$;


ALTER FUNCTION public.get_current_year(character varying) OWNER TO postgres;

--
-- Name: get_default_country(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_default_country(integer) RETURNS character
    LANGUAGE sql
    AS $_$
	SELECT default_country_id::varchar(2)
	FROM orgs
	WHERE (org_id = $1);
$_$;


ALTER FUNCTION public.get_default_country(integer) OWNER TO postgres;

--
-- Name: get_default_currency(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_default_currency(integer) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT currency_id
	FROM orgs
	WHERE (org_id = $1);
$_$;


ALTER FUNCTION public.get_default_currency(integer) OWNER TO postgres;

--
-- Name: get_end_month(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_end_month(character varying) RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT to_char((to_char(current_date, 'YYYY-MM') || '-01')::date + '1 month'::interval - '1 day'::interval, 'DD/MM/YYYY');
$$;


ALTER FUNCTION public.get_end_month(character varying) OWNER TO postgres;

--
-- Name: get_end_year(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_end_year(character varying) RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT '31/12/' || to_char(current_date, 'YYYY');
$$;


ALTER FUNCTION public.get_end_year(character varying) OWNER TO postgres;

--
-- Name: get_et_field_name(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_et_field_name(integer) RETURNS character varying
    LANGUAGE sql
    AS $_$
	SELECT et_field_name
	FROM et_fields WHERE (et_field_id = $1);
$_$;


ALTER FUNCTION public.get_et_field_name(integer) OWNER TO postgres;

--
-- Name: get_org_logo(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_org_logo(integer) RETURNS character varying
    LANGUAGE sql
    AS $_$
	SELECT orgs.logo
	FROM orgs WHERE (orgs.org_id = $1);
$_$;


ALTER FUNCTION public.get_org_logo(integer) OWNER TO postgres;

--
-- Name: get_phase_email(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_phase_email(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
    myrec	RECORD;
	myemail	varchar(320);
BEGIN
	myemail := null;
	FOR myrec IN SELECT entitys.primary_email
		FROM entitys INNER JOIN entity_subscriptions ON entitys.entity_id = entity_subscriptions.entity_id
		WHERE (entity_subscriptions.entity_type_id = $1) LOOP

		IF (myemail is null) THEN
			IF (myrec.primary_email is not null) THEN
				myemail := myrec.primary_email;
			END IF;
		ELSE
			IF (myrec.primary_email is not null) THEN
				myemail := myemail || ', ' || myrec.primary_email;
			END IF;
		END IF;

	END LOOP;

	RETURN myemail;
END;
$_$;


ALTER FUNCTION public.get_phase_email(integer) OWNER TO postgres;

--
-- Name: get_phase_entitys(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_phase_entitys(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
    myrec			RECORD;
	myentitys		varchar(320);
BEGIN
	myentitys := null;
	FOR myrec IN SELECT entitys.entity_name
		FROM entitys INNER JOIN entity_subscriptions ON entitys.entity_id = entity_subscriptions.entity_id
		WHERE (entity_subscriptions.entity_type_id = $1) LOOP

		IF (myentitys is null) THEN
			IF (myrec.entity_name is not null) THEN
				myentitys := myrec.entity_name;
			END IF;
		ELSE
			IF (myrec.entity_name is not null) THEN
				myentitys := myentitys || ', ' || myrec.entity_name;
			END IF;
		END IF;

	END LOOP;

	RETURN myentitys;
END;
$_$;


ALTER FUNCTION public.get_phase_entitys(integer) OWNER TO postgres;

--
-- Name: get_phase_status(boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_phase_status(boolean, boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	ps		varchar(16);
BEGIN
	ps := 'Draft';
	IF ($1 = true) THEN
		ps := 'Approved';
	END IF;
	IF ($2 = true) THEN
		ps := 'Rejected';
	END IF;

	RETURN ps;
END;
$_$;


ALTER FUNCTION public.get_phase_status(boolean, boolean) OWNER TO postgres;

--
-- Name: get_reporting_list(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_reporting_list(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
    myrec	RECORD;
	mylist	varchar(320);
BEGIN
	mylist := null;
	FOR myrec IN SELECT entitys.entity_name
		FROM reporting INNER JOIN entitys ON reporting.report_to_id = entitys.entity_id
		WHERE (reporting.primary_report = true) AND (reporting.entity_id = $1)
	LOOP

		IF (mylist is null) THEN
			mylist := myrec.entity_name;
		ELSE
			mylist := mylist || ', ' || myrec.entity_name;
		END IF;
	END LOOP;

	RETURN mylist;
END;
$_$;


ALTER FUNCTION public.get_reporting_list(integer) OWNER TO postgres;

--
-- Name: get_start_month(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_start_month(character varying) RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT '01/' || to_char(current_date, 'MM/YYYY');
$$;


ALTER FUNCTION public.get_start_month(character varying) OWNER TO postgres;

--
-- Name: get_start_year(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_start_year(character varying) RETURNS character varying
    LANGUAGE sql
    AS $$
	SELECT '01/01/' || to_char(current_date, 'YYYY');
$$;


ALTER FUNCTION public.get_start_year(character varying) OWNER TO postgres;

--
-- Name: ins_address(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_address() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_address_id		integer;
BEGIN
	SELECT address_id INTO v_address_id
	FROM address WHERE (is_default = true)
		AND (table_name = NEW.table_name) AND (table_id = NEW.table_id) AND (address_id <> NEW.address_id);

	IF(NEW.is_default is null)THEN
		NEW.is_default := false;
	END IF;

	IF(NEW.is_default = true) AND (v_address_id is not null) THEN
		RAISE EXCEPTION 'Only one default Address allowed.';
	ELSIF (NEW.is_default = false) AND (v_address_id is null) THEN
		NEW.is_default := true;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_address() OWNER TO postgres;

--
-- Name: ins_approvals(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_approvals() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	reca	RECORD;
BEGIN

	IF (NEW.forward_id is not null) THEN
		SELECT workflow_phase_id, org_entity_id, app_entity_id, approval_level, table_name, table_id INTO reca
		FROM approvals
		WHERE (approval_id = NEW.forward_id);

		NEW.workflow_phase_id := reca.workflow_phase_id;
		NEW.approval_level := reca.approval_level;
		NEW.table_name := reca.table_name;
		NEW.table_id := reca.table_id;
		NEW.approve_status := 'Completed';
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_approvals() OWNER TO postgres;

--
-- Name: ins_entitys(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_entitys() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF(NEW.org_id is null)THEN
		RAISE EXCEPTION 'You have to select a valid organisation';
	END IF;

	SELECT use_key_id INTO NEW.use_key_id
	FROM entity_types
	WHERE (entity_type_id = NEW.entity_type_id);

	IF(NEW.sys_language_id is null)THEN
		NEW.sys_language_id := 0;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_entitys() OWNER TO postgres;

--
-- Name: ins_entry_form(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_entry_form(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec 		RECORD;
	vorgid		integer;
	formName 	varchar(120);
	msg 		varchar(120);
BEGIN
	SELECT entry_form_id, org_id INTO rec
	FROM entry_forms 
	WHERE (form_id = CAST($1 as int)) AND (entity_ID = CAST($2 as int))
		AND (approve_status = 'Draft');

	SELECT form_name, org_id INTO formName, vorgid
	FROM forms WHERE (form_id = CAST($1 as int));

	IF rec.entry_form_id is null THEN
		INSERT INTO entry_forms (form_id, entity_id, org_id) 
		VALUES (CAST($1 as int), CAST($2 as int), vorgid);
		msg := 'Added Form : ' || formName;
	ELSE
		msg := 'There is an incomplete form : ' || formName;
	END IF;

	return msg;
END;
$_$;


ALTER FUNCTION public.ins_entry_form(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: ins_entry_forms(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_entry_forms() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	reca		RECORD;
BEGIN
	
	SELECT default_values, default_sub_values INTO reca
	FROM forms
	WHERE (form_id = NEW.form_id);
	
	NEW.answer := reca.default_values;
	NEW.sub_answer := reca.default_sub_values;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_entry_forms() OWNER TO postgres;

--
-- Name: ins_fields(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_ord	integer;
BEGIN
	IF(NEW.field_order is null) THEN
		SELECT max(field_order) INTO v_ord
		FROM fields
		WHERE (form_id = NEW.form_id);

		IF (v_ord is null) THEN
			NEW.field_order := 10;
		ELSE
			NEW.field_order := v_ord + 10;
		END IF;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_fields() OWNER TO postgres;

--
-- Name: ins_password(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_entity_id		integer;
BEGIN

	SELECT entity_id INTO v_entity_id
	FROM entitys
	WHERE (trim(lower(user_name)) = trim(lower(NEW.user_name)))
		AND entity_id <> NEW.entity_id;

	IF(v_entity_id is not null)THEN
		RAISE EXCEPTION 'The username exists use a different one or reset password for the current one';
	END IF;

	IF(TG_OP = 'INSERT') THEN
		IF(NEW.first_password is null)THEN
			NEW.first_password := first_password();
		END IF;

		IF (NEW.entity_password is null) THEN
			NEW.entity_password := md5(NEW.first_password);
		END IF;
	ELSIF(OLD.first_password <> NEW.first_password) THEN
		NEW.Entity_password := md5(NEW.first_password);
	END IF;

	IF(NEW.user_name is null)THEN
		SELECT org_sufix || '.' || lower(trim(replace(NEW.entity_name, ' ', ''))) INTO NEW.user_name
		FROM orgs
		WHERE org_id = NEW.org_id;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_password() OWNER TO postgres;

--
-- Name: ins_sub_fields(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_sub_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_ord	integer;
BEGIN
	IF(NEW.sub_field_order is null) THEN
		SELECT max(sub_field_order) INTO v_ord
		FROM sub_fields
		WHERE (field_id = NEW.field_id);

		IF (v_ord is null) THEN
			NEW.sub_field_order := 10;
		ELSE
			NEW.sub_field_order := v_ord + 10;
		END IF;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ins_sub_fields() OWNER TO postgres;

--
-- Name: ins_sys_reset(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ins_sys_reset() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_entity_id			integer;
	v_org_id			integer;
	v_sys_email_id		integer;
	v_password			varchar(32);
BEGIN
	SELECT entity_id, org_id INTO v_entity_id, v_org_id
	FROM entitys
	WHERE (lower(trim(primary_email)) = lower(trim(NEW.request_email)));

	IF(v_entity_id is not null) THEN
		v_password := upper(substring(md5(random()::text) from 3 for 9));

		UPDATE entitys SET first_password = v_password, entity_password = md5(v_password)
		WHERE entity_id = v_entity_id;

		SELECT sys_email_id INTO v_sys_email_id
		FROM sys_emails WHERE (use_type = 3) AND (org_id = v_org_id);

		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(v_org_id, v_sys_email_id, v_entity_id, 'entitys');
	END IF;

	RETURN NULL;
END;
$$;


ALTER FUNCTION public.ins_sys_reset() OWNER TO postgres;

--
-- Name: issue_book(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.issue_book(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
    msg                 varchar(120);
BEGIN
    UPDATE books SET is_borrowed = true 
    FROM
    (SELECT book_id FROM 
        books_issuance WHERE books_issuance_id = $1::int
    ) as a
    WHERE books.book_id = a.book_id;
    msg:='Book issued';
    RETURN msg;
END;
$_$;


ALTER FUNCTION public.issue_book(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: librarian_login(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.librarian_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO entitys(entity_type_id, use_key_id,  org_id, entity_name, user_name, primary_email, primary_telephone,
         is_active)
        VALUES(1, 1, 0, NEW.librarian_name, NEW.email, NEW.email, New.telno, true);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.librarian_login() OWNER TO postgres;

--
-- Name: mark_book_return(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mark_book_return(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
    msg                 varchar(120);
BEGIN
    UPDATE books SET is_borrowed = false 
    FROM
    (SELECT book_id FROM 
        books_issuance WHERE books_issuance_id = $1::int
    ) as a
    WHERE books.book_id = a.book_id;
    msg:='Book Returned';
    RETURN msg;
END;
$_$;


ALTER FUNCTION public.mark_book_return(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: password_validate(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.password_validate(character varying, character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_entity_id			integer;
	v_entity_password	varchar(64);
BEGIN

	SELECT entity_id, entity_password INTO v_entity_id, v_entity_password
	FROM entitys WHERE (user_name = $1);

	IF(v_entity_id is null)THEN
		v_entity_id = -1;
	ELSIF(md5($2) != v_entity_password) THEN
		v_entity_id = -1;
	END IF;

	return v_entity_id;
END;
$_$;


ALTER FUNCTION public.password_validate(character varying, character varying) OWNER TO postgres;

--
-- Name: password_validate(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.password_validate(character varying, character varying, character varying, character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_entity_id			integer;
	v_entity_password	varchar(64);
BEGIN

	SELECT entity_id, entity_password INTO v_entity_id, v_entity_password
	FROM entitys WHERE (user_name = $1);

	IF(v_entity_id is null)THEN
		v_entity_id = -1;
	ELSIF(md5($2) != v_entity_password) THEN
		INSERT INTO sys_logins (entity_id, login_ip, phone_serial_number, correct_login)
		VALUES (v_entity_id, $3, $4, false);
		v_entity_id = -1;
	ELSE
		INSERT INTO sys_logins (entity_id, login_ip, phone_serial_number, correct_login)
		VALUES (v_entity_id, $3, $4, true);
	END IF;

	return v_entity_id;
END;
$_$;


ALTER FUNCTION public.password_validate(character varying, character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: process_payment(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_payment(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
BEGIN
    UPDATE employee_month 
    SET is_disbursed = TRUE, is_paid = TRUE
    WHERE employee_month_id = $1::int;

    RETURN 'Payment Made successfully';
END;
$_$;


ALTER FUNCTION public.process_payment(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: process_payroll(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_payroll(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
BEGIN
	INSERT INTO employee_month(employee_id, org_id, employee_month)
	SELECT employee_id, 0, $1
	FROM employees 
	WHERE employee_id NOT IN (SELECT employee_id FROM employee_month WHERE employee_month = $1);

    RETURN 'Payroll Processed Successfully';
END;
$_$;


ALTER FUNCTION public.process_payroll(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: staffs_login(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.staffs_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO entitys(entity_type_id, use_key_id,  org_id, entity_name, user_name, primary_email, primary_telephone,
         is_active)
        VALUES(9 ,9, 0, NEW.person_title||' '||NEW.surname||' '||NEW.first_name||' '||NEW.middle_name, NEW.person_title||NEW.surname||NEW.first_name||NEW.middle_name, '',  New.phone, true);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.staffs_login() OWNER TO postgres;

--
-- Name: student_login(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.student_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO entitys(entity_type_id, use_key_id,  org_id, entity_name, user_name, primary_email, primary_telephone,
         is_active)
        VALUES(7, 7, 0, NEW.surname||' '||NEW.first_name||' '|| NEW.second_name, NEW.second_name||''||NEW.first_name, '', '', true);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.student_login() OWNER TO postgres;

--
-- Name: teacher_login(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.teacher_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO entitys(entity_type_id, use_key_id,  org_id, entity_name, user_name, primary_email, primary_telephone,
         is_active)
        VALUES(8, 8, 0, NEW.teacher_name, NEW.teacher_name, NEW.teacher_name, New.telno, true);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.teacher_login() OWNER TO postgres;

--
-- Name: upd_access_level(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_access_level(character varying, character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	v_org_id				integer;
	v_sys_access_entity_id	integer;
	msg						varchar(120);
BEGIN

	IF($3 = '1')THEN
		SELECT org_id INTO v_org_id FROM entitys WHERE (entity_id = $4::int);

		SELECT sys_access_entity_id INTO v_sys_access_entity_id
		FROM sys_access_entitys
		WHERE (entity_id = $4::int) AND (sys_access_level_id = $1::int);

		IF(v_sys_access_entity_id is null)THEN
			INSERT INTO sys_access_entitys (entity_id, sys_access_level_id, org_id)
			VALUES ($4::int, $1::int, v_org_id);

			msg := 'Granted access level';
		ELSE
			msg := 'Access level already granted';
		END IF;
	ELSIF($3 = '2')THEN
		DELETE FROM sys_access_entitys WHERE sys_access_level_id = $1::int;

		msg := 'Rovoked access level';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.upd_access_level(character varying, character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: upd_action(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_action() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_column_name			varchar;
	v_workflow_narrative	varchar(240);
	wfid					integer;
	reca					record;
	tbid					integer;
	iswf					boolean;
	add_flow				boolean;
BEGIN
	add_flow := false;
	IF(TG_OP = 'INSERT')THEN
		IF (NEW.approve_status = 'Completed')THEN
			add_flow := true;
		END IF;
	ELSE
		IF(OLD.approve_status = 'Draft') AND (NEW.approve_status = 'Completed')THEN
			add_flow := true;
		END IF;
	END IF;

	IF(add_flow = true)THEN
		wfid := nextval('workflow_table_id_seq');
		NEW.workflow_table_id := wfid;

		SELECT column_name INTO v_column_name
		FROM information_schema.columns
		WHERE table_name = TG_TABLE_NAME and column_name = 'workflow_narrative';
		IF(v_column_name is not null)THEN v_workflow_narrative := NEW.workflow_narrative; END IF;
		IF(v_workflow_narrative is null)THEN v_workflow_narrative := ''; END IF;

		IF(TG_OP = 'UPDATE')THEN
			IF(OLD.workflow_table_id is not null)THEN
				INSERT INTO workflow_logs (org_id, table_name, table_id, table_old_id)
				VALUES (NEW.org_id, TG_TABLE_NAME, wfid, OLD.workflow_table_id);
			END IF;
		END IF;

		FOR reca IN SELECT workflows.workflow_id, workflows.table_name, workflows.table_link_field, workflows.table_link_id
		FROM workflows INNER JOIN entity_subscriptions ON workflows.source_entity_id = entity_subscriptions.entity_type_id
		WHERE (workflows.table_name = TG_TABLE_NAME) AND (entity_subscriptions.entity_id= NEW.entity_id) LOOP
			iswf := true;
			IF(reca.table_link_field is null)THEN
				iswf := true;
			ELSE
				IF(TG_TABLE_NAME = 'entry_forms')THEN
					tbid := NEW.form_id;
				END IF;
				IF(tbid = reca.table_link_id)THEN
					iswf := true;
				END IF;
			END IF;

			IF(iswf = true)THEN
				INSERT INTO approvals (org_id, workflow_phase_id, table_name, table_id, org_entity_id,
					escalation_days, escalation_hours, approval_level,
					approval_narrative, to_be_done)
				SELECT org_id, workflow_phase_id, TG_TABLE_NAME, wfid, NEW.entity_id,
					escalation_days, escalation_hours, approval_level,
					(CASE WHEN phase_narrative is null THEN v_workflow_narrative
						ELSE phase_narrative || ' - ' || v_workflow_narrative END),
					'Approve - ' || COALESCE(phase_narrative, '')
				FROM vw_workflow_entitys
				WHERE (table_name = TG_TABLE_NAME) AND (entity_id = NEW.entity_id) AND (workflow_id = reca.workflow_id)
				ORDER BY approval_level, workflow_phase_id;

				UPDATE approvals SET approve_status = 'Completed'
				WHERE (table_id = wfid) AND (approval_level = 1);
			END IF;
		END LOOP;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.upd_action() OWNER TO postgres;

--
-- Name: upd_approvals(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_approvals() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	reca		RECORD;
	wfid		integer;
	vorgid		integer;
	vnotice		boolean;
	vadvice		boolean;
BEGIN

	SELECT notice, advice, org_id INTO vnotice, vadvice, vorgid
	FROM workflow_phases
	WHERE (workflow_phase_id = NEW.workflow_phase_id);

	IF (NEW.approve_status = 'Completed') THEN
		INSERT INTO sys_emailed (table_id, table_name, email_type, org_id)
		VALUES (NEW.approval_id, TG_TABLE_NAME, 1, vorgid);
	END IF;
	IF (NEW.approve_status = 'Approved') AND (vadvice = true) AND (NEW.forward_id is null) THEN
		INSERT INTO sys_emailed (table_id, table_name, email_type, org_id)
		VALUES (NEW.approval_id, TG_TABLE_NAME, 1, vorgid);
	END IF;
	IF (NEW.approve_status = 'Approved') AND (vnotice = true) AND (NEW.forward_id is null) THEN
		INSERT INTO sys_emailed (table_id, table_name, email_type, org_id)
		VALUES (NEW.approval_id, TG_TABLE_NAME, 2, vorgid);
	END IF;

	IF(TG_OP = 'INSERT') AND (NEW.forward_id is null) THEN
		INSERT INTO approval_checklists (approval_id, checklist_id, requirement, manditory, org_id)
		SELECT NEW.approval_id, checklist_id, requirement, manditory, org_id
		FROM checklists
		WHERE (workflow_phase_id = NEW.workflow_phase_id)
		ORDER BY checklist_number;
	END IF;

	RETURN NULL;
END;
$$;


ALTER FUNCTION public.upd_approvals() OWNER TO postgres;

--
-- Name: upd_approvals(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_approvals(character varying, character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	app_id		Integer;
	reca 		RECORD;
	recb		RECORD;
	recc		RECORD;
	min_level	Integer;
	mysql		varchar(240);
	msg 		varchar(120);
BEGIN
	app_id := CAST($1 as int);
	SELECT approvals.org_id, approvals.approval_id, approvals.org_id, approvals.table_name, approvals.table_id,
		approvals.approval_level, approvals.review_advice, approvals.org_entity_id,
		workflow_phases.workflow_phase_id, workflow_phases.workflow_id, workflow_phases.return_level INTO reca
	FROM approvals INNER JOIN workflow_phases ON approvals.workflow_phase_id = workflow_phases.workflow_phase_id
	WHERE (approvals.approval_id = app_id);

	SELECT count(approval_checklist_id) as cl_count INTO recc
	FROM approval_checklists
	WHERE (approval_id = app_id) AND (manditory = true) AND (done = false);

	IF ($3 = '1') THEN
		UPDATE approvals SET approve_status = 'Completed', completion_date = now()
		WHERE approval_id = app_id;
		msg := 'Completed';
	ELSIF ($3 = '2') AND (recc.cl_count <> 0) THEN
		msg := 'There are manditory checklist that must be checked first.';
	ELSIF ($3 = '2') AND (recc.cl_count = 0) THEN
		UPDATE approvals SET approve_status = 'Approved', action_date = now(), app_entity_id = CAST($2 as int)
		WHERE approval_id = app_id;

		SELECT min(approvals.approval_level) INTO min_level
		FROM approvals INNER JOIN workflow_phases ON approvals.workflow_phase_id = workflow_phases.workflow_phase_id
		WHERE (approvals.table_id = reca.table_id) AND (approvals.approve_status = 'Draft')
			AND (workflow_phases.advice = false) AND (workflow_phases.notice = false);

		IF(min_level is null)THEN
			mysql := 'UPDATE ' || reca.table_name || ' SET approve_status = ' || quote_literal('Approved')
			|| ', action_date = now()'
			|| ' WHERE workflow_table_id = ' || reca.table_id;
			EXECUTE mysql;

			INSERT INTO sys_emailed (org_id, table_id, table_name, email_type)
			VALUES (reca.org_id, reca.table_id, 'vw_workflow_approvals', 1);

			FOR recb IN SELECT workflow_phase_id, advice, notice
			FROM workflow_phases
			WHERE (workflow_id = reca.workflow_id) AND (approval_level >= reca.approval_level) LOOP
				IF (recb.advice = true) or (recb.notice = true) THEN
					UPDATE approvals SET approve_status = 'Approved', action_date = now(), completion_date = now()
					WHERE (workflow_phase_id = recb.workflow_phase_id) AND (table_id = reca.table_id);
				END IF;
			END LOOP;
		ELSE
			FOR recb IN SELECT workflow_phase_id, advice, notice
			FROM workflow_phases
			WHERE (workflow_id = reca.workflow_id) AND (approval_level <= min_level) LOOP
				IF (recb.advice = true) or (recb.notice = true) THEN
					UPDATE approvals SET approve_status = 'Approved', action_date = now(), completion_date = now()
					WHERE (workflow_phase_id = recb.workflow_phase_id)
						AND (approve_status = 'Draft') AND (table_id = reca.table_id);
				ELSE
					UPDATE approvals SET approve_status = 'Completed', completion_date = now()
					WHERE (workflow_phase_id = recb.workflow_phase_id)
						AND (approve_status = 'Draft') AND (table_id = reca.table_id);
				END IF;
			END LOOP;
		END IF;
		msg := 'Approved';
	ELSIF ($3 = '3') THEN
		UPDATE approvals SET approve_status = 'Rejected',  action_date = now(), app_entity_id = CAST($2 as int)
		WHERE approval_id = app_id;

		mysql := 'UPDATE ' || reca.table_name || ' SET approve_status = ' || quote_literal('Rejected')
		|| ', action_date = now()'
		|| ' WHERE workflow_table_id = ' || reca.table_id;
		EXECUTE mysql;

		INSERT INTO sys_emailed (table_id, table_name, email_type, org_id)
		VALUES (reca.table_id, 'vw_workflow_approvals', 2, reca.org_id);
		msg := 'Rejected';
	ELSIF ($3 = '4') AND (reca.return_level = 0) THEN
		UPDATE approvals SET approve_status = 'Review',  action_date = now(), app_entity_id = CAST($2 as int)
		WHERE approval_id = app_id;

		mysql := 'UPDATE ' || reca.table_name || ' SET approve_status = ' || quote_literal('Draft')
		|| ', action_date = now()'
		|| ' WHERE workflow_table_id = ' || reca.table_id;
		EXECUTE mysql;

		msg := 'Forwarded to owner for review';
	ELSIF ($3 = '4') AND (reca.return_level <> 0) THEN
		UPDATE approvals SET approve_status = 'Review',  action_date = now(), app_entity_id = CAST($2 as int)
		WHERE approval_id = app_id;

		INSERT INTO approvals (org_id, workflow_phase_id, table_name, table_id, org_entity_id, escalation_days, escalation_hours, approval_level, approval_narrative, to_be_done, approve_status)
		SELECT org_id, workflow_phase_id, reca.table_name, reca.table_id, CAST($2 as int), escalation_days, escalation_hours, approval_level, phase_narrative, reca.review_advice, 'Completed'
		FROM vw_workflow_entitys
		WHERE (workflow_id = reca.workflow_id) AND (approval_level = reca.return_level)
			AND (entity_id = reca.org_entity_id)
		ORDER BY workflow_phase_id;

		UPDATE approvals SET approve_status = 'Draft' WHERE approval_id = app_id;

		msg := 'Forwarded for review';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.upd_approvals(character varying, character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: upd_checklist(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_checklist(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	cl_id		Integer;
	reca 		RECORD;
	recc 		RECORD;
	msg 		varchar(120);
BEGIN
	cl_id := CAST($1 as int);

	SELECT approval_checklist_id, approval_id, checklist_id, requirement, manditory, done INTO reca
	FROM approval_checklists
	WHERE (approval_checklist_id = cl_id);

	IF ($3 = '1') THEN
		UPDATE approval_checklists SET done = true WHERE (approval_checklist_id = cl_id);

		SELECT count(approval_checklist_id) as cl_count INTO recc
		FROM approval_checklists
		WHERE (approval_id = reca.approval_id) AND (manditory = true) AND (done = false);
		msg := 'Checklist done.';
	ELSIF ($3 = '2') THEN
		UPDATE approval_checklists SET done = false WHERE (approval_checklist_id = cl_id);
		msg := 'Checklist not done.';
	END IF;

	RETURN msg;
END;
$_$;


ALTER FUNCTION public.upd_checklist(character varying, character varying, character varying) OWNER TO postgres;

--
-- Name: upd_complete_form(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upd_complete_form(character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
	msg varchar(120);
BEGIN
	IF ($3 = '1') THEN
		UPDATE entry_forms SET approve_status = 'Completed', completion_date = now()
		WHERE (entry_form_id = CAST($1 as int));
		msg := 'Completed the form';
	ELSIF ($3 = '2') THEN
		UPDATE entry_forms SET approve_status = 'Approved', action_date = now()
		WHERE (entry_form_id = CAST($1 as int));
		msg := 'Approved the form';
	ELSIF ($3 = '3') THEN
		UPDATE entry_forms SET approve_status = 'Rejected', action_date = now()
		WHERE (entry_form_id = CAST($1 as int));
		msg := 'Rejected the form';
	END IF;

	return msg;
END;
$_$;


ALTER FUNCTION public.upd_complete_form(character varying, character varying, character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accountants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accountants (
    accountant_id integer NOT NULL,
    accountant_name character varying(120),
    org_id integer,
    telno character varying(20),
    gender character varying(2),
    email character varying(50),
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.accountants OWNER TO postgres;

--
-- Name: accountants_accountant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accountants_accountant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accountants_accountant_id_seq OWNER TO postgres;

--
-- Name: accountants_accountant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accountants_accountant_id_seq OWNED BY public.accountants.accountant_id;


--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    address_id integer NOT NULL,
    address_type_id integer,
    sys_country_id character(2),
    org_id integer,
    address_name character varying(120),
    table_name character varying(32),
    table_id integer,
    post_office_box character varying(50),
    postal_code character varying(12),
    premises character varying(120),
    street character varying(120),
    town character varying(50),
    phone_number character varying(150),
    extension character varying(15),
    mobile character varying(150),
    fax character varying(150),
    email character varying(120),
    website character varying(120),
    is_default boolean DEFAULT false NOT NULL,
    first_password character varying(32),
    details text
);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: address_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_address_id_seq OWNER TO postgres;

--
-- Name: address_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_address_id_seq OWNED BY public.address.address_id;


--
-- Name: address_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address_types (
    address_type_id integer NOT NULL,
    org_id integer,
    address_type_name character varying(50)
);


ALTER TABLE public.address_types OWNER TO postgres;

--
-- Name: address_types_address_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_types_address_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_types_address_type_id_seq OWNER TO postgres;

--
-- Name: address_types_address_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_types_address_type_id_seq OWNED BY public.address_types.address_type_id;


--
-- Name: approval_checklists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.approval_checklists (
    approval_checklist_id integer NOT NULL,
    approval_id integer NOT NULL,
    checklist_id integer NOT NULL,
    org_id integer,
    requirement text,
    manditory boolean DEFAULT false NOT NULL,
    done boolean DEFAULT false NOT NULL,
    narrative character varying(320)
);


ALTER TABLE public.approval_checklists OWNER TO postgres;

--
-- Name: approval_checklists_approval_checklist_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.approval_checklists_approval_checklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.approval_checklists_approval_checklist_id_seq OWNER TO postgres;

--
-- Name: approval_checklists_approval_checklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.approval_checklists_approval_checklist_id_seq OWNED BY public.approval_checklists.approval_checklist_id;


--
-- Name: approvals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.approvals (
    approval_id integer NOT NULL,
    workflow_phase_id integer NOT NULL,
    org_entity_id integer NOT NULL,
    app_entity_id integer,
    org_id integer,
    approval_level integer DEFAULT 1 NOT NULL,
    escalation_days integer DEFAULT 0 NOT NULL,
    escalation_hours integer DEFAULT 3 NOT NULL,
    escalation_time timestamp without time zone DEFAULT now() NOT NULL,
    forward_id integer,
    table_name character varying(64),
    table_id integer,
    application_date timestamp without time zone DEFAULT now() NOT NULL,
    completion_date timestamp without time zone,
    action_date timestamp without time zone,
    approve_status character varying(16) DEFAULT 'Draft'::character varying NOT NULL,
    approval_narrative character varying(240),
    to_be_done text,
    what_is_done text,
    review_advice text,
    details text
);


ALTER TABLE public.approvals OWNER TO postgres;

--
-- Name: approvals_approval_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.approvals_approval_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.approvals_approval_id_seq OWNER TO postgres;

--
-- Name: approvals_approval_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.approvals_approval_id_seq OWNED BY public.approvals.approval_id;


--
-- Name: bank_branch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bank_branch (
    bank_branch_id integer NOT NULL,
    bank_name character varying(120),
    org_id integer,
    branch_name character varying(120),
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.bank_branch OWNER TO postgres;

--
-- Name: bank_branch_bank_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bank_branch_bank_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bank_branch_bank_branch_id_seq OWNER TO postgres;

--
-- Name: bank_branch_bank_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bank_branch_bank_branch_id_seq OWNED BY public.bank_branch.bank_branch_id;


--
-- Name: book_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.book_category (
    book_category_id integer NOT NULL,
    book_category_name character varying(120),
    org_id integer,
    details text
);


ALTER TABLE public.book_category OWNER TO postgres;

--
-- Name: book_category_book_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.book_category_book_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.book_category_book_category_id_seq OWNER TO postgres;

--
-- Name: book_category_book_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.book_category_book_category_id_seq OWNED BY public.book_category.book_category_id;


--
-- Name: book_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.book_status (
    book_status_id integer NOT NULL,
    book_status_name character varying(120),
    org_id integer,
    details text
);


ALTER TABLE public.book_status OWNER TO postgres;

--
-- Name: book_status_book_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.book_status_book_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.book_status_book_status_id_seq OWNER TO postgres;

--
-- Name: book_status_book_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.book_status_book_status_id_seq OWNED BY public.book_status.book_status_id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.books (
    book_id integer NOT NULL,
    org_id integer,
    book_category_id integer,
    isbn character varying(20),
    book_title character varying(120),
    author character varying(120),
    book_status_id integer,
    details text,
    book_edition character varying(50),
    publisher_id integer,
    is_borrowed boolean DEFAULT false
);


ALTER TABLE public.books OWNER TO postgres;

--
-- Name: books_book_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.books_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.books_book_id_seq OWNER TO postgres;

--
-- Name: books_book_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.books_book_id_seq OWNED BY public.books.book_id;


--
-- Name: books_issuance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.books_issuance (
    books_issuance_id integer NOT NULL,
    org_id integer,
    book_id integer,
    librarian_id integer,
    loanee integer,
    issuance_date date,
    return_date date,
    days_exceeded integer,
    is_returned boolean DEFAULT false,
    return_condition character varying(50),
    details text
);


ALTER TABLE public.books_issuance OWNER TO postgres;

--
-- Name: books_issuance_books_issuance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.books_issuance_books_issuance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.books_issuance_books_issuance_id_seq OWNER TO postgres;

--
-- Name: books_issuance_books_issuance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.books_issuance_books_issuance_id_seq OWNED BY public.books_issuance.books_issuance_id;


--
-- Name: calendar_year; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendar_year (
    calendar_year_id integer NOT NULL,
    org_id integer,
    calendar_year_name character varying(20)
);


ALTER TABLE public.calendar_year OWNER TO postgres;

--
-- Name: calendar_year_calendar_year_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calendar_year_calendar_year_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_year_calendar_year_id_seq OWNER TO postgres;

--
-- Name: calendar_year_calendar_year_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calendar_year_calendar_year_id_seq OWNED BY public.calendar_year.calendar_year_id;


--
-- Name: checklists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checklists (
    checklist_id integer NOT NULL,
    workflow_phase_id integer NOT NULL,
    org_id integer,
    checklist_number integer,
    manditory boolean DEFAULT false NOT NULL,
    requirement text,
    details text
);


ALTER TABLE public.checklists OWNER TO postgres;

--
-- Name: checklists_checklist_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checklists_checklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklists_checklist_id_seq OWNER TO postgres;

--
-- Name: checklists_checklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checklists_checklist_id_seq OWNED BY public.checklists.checklist_id;


--
-- Name: class_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_levels (
    class_level_id integer NOT NULL,
    org_id integer,
    class_level_name character varying(100),
    details text
);


ALTER TABLE public.class_levels OWNER TO postgres;

--
-- Name: class_levels_class_level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_levels_class_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.class_levels_class_level_id_seq OWNER TO postgres;

--
-- Name: class_levels_class_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_levels_class_level_id_seq OWNED BY public.class_levels.class_level_id;


--
-- Name: currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currency (
    currency_id integer NOT NULL,
    currency_name character varying(50),
    currency_symbol character varying(3),
    org_id integer
);


ALTER TABLE public.currency OWNER TO postgres;

--
-- Name: currency_currency_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.currency_currency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.currency_currency_id_seq OWNER TO postgres;

--
-- Name: currency_currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.currency_currency_id_seq OWNED BY public.currency.currency_id;


--
-- Name: currency_rates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currency_rates (
    currency_rate_id integer NOT NULL,
    currency_id integer,
    org_id integer,
    exchange_date date DEFAULT CURRENT_DATE NOT NULL,
    exchange_rate real DEFAULT 1 NOT NULL
);


ALTER TABLE public.currency_rates OWNER TO postgres;

--
-- Name: currency_rates_currency_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.currency_rates_currency_rate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.currency_rates_currency_rate_id_seq OWNER TO postgres;

--
-- Name: currency_rates_currency_rate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.currency_rates_currency_rate_id_seq OWNED BY public.currency_rates.currency_rate_id;


--
-- Name: e_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.e_fields (
    e_field_id integer NOT NULL,
    et_field_id integer,
    org_id integer,
    table_code integer NOT NULL,
    table_id integer,
    e_field_value character varying(320)
);


ALTER TABLE public.e_fields OWNER TO postgres;

--
-- Name: e_fields_e_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.e_fields_e_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.e_fields_e_field_id_seq OWNER TO postgres;

--
-- Name: e_fields_e_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.e_fields_e_field_id_seq OWNED BY public.e_fields.e_field_id;


--
-- Name: employee_designations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_designations (
    employee_designation_id integer NOT NULL,
    org_id integer,
    employee_designation_name character varying(50),
    duties text
);


ALTER TABLE public.employee_designations OWNER TO postgres;

--
-- Name: employee_designations_employee_designation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_designations_employee_designation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_designations_employee_designation_id_seq OWNER TO postgres;

--
-- Name: employee_designations_employee_designation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_designations_employee_designation_id_seq OWNED BY public.employee_designations.employee_designation_id;


--
-- Name: employee_month; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_month (
    employee_month_id integer NOT NULL,
    employee_id integer NOT NULL,
    org_id integer,
    employee_month character varying(100),
    is_disbursed boolean DEFAULT false,
    disbursed_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_paid boolean DEFAULT false,
    doc_no character varying(120),
    details text,
    amount real
);


ALTER TABLE public.employee_month OWNER TO postgres;

--
-- Name: employee_month_employee_month_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_month_employee_month_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_month_employee_month_id_seq OWNER TO postgres;

--
-- Name: employee_month_employee_month_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_month_employee_month_id_seq OWNED BY public.employee_month.employee_month_id;


--
-- Name: employee_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_types (
    employee_type_id integer NOT NULL,
    org_id integer,
    employee_type_name character varying(50)
);


ALTER TABLE public.employee_types OWNER TO postgres;

--
-- Name: employee_types_employee_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_types_employee_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_types_employee_type_id_seq OWNER TO postgres;

--
-- Name: employee_types_employee_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_types_employee_type_id_seq OWNED BY public.employee_types.employee_type_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    employee_type_id integer NOT NULL,
    employee_designation_id integer NOT NULL,
    payment_mode_id integer,
    bank_branch_id integer NOT NULL,
    org_id integer NOT NULL,
    person_title character varying(7),
    surname character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    middle_name character varying(50),
    employee_full_name character varying(120),
    employee_email character varying(120),
    date_of_birth date,
    gender character varying(1),
    phone character varying(120),
    marital_status character varying(2),
    appointment_date date,
    exit_date date,
    employment_terms text,
    identity_card character varying(50),
    basic_salary real NOT NULL,
    bank_account character varying(32),
    picture_file character varying(32),
    active boolean DEFAULT true NOT NULL,
    language character varying(320),
    previous_sal_point character varying(16),
    current_sal_point character varying(16),
    halt_point character varying(16),
    field_of_study text
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: entity_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_fields (
    entity_field_id integer NOT NULL,
    org_id integer NOT NULL,
    use_type integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true,
    entity_field_name character varying(240),
    entity_field_source character varying(320)
);


ALTER TABLE public.entity_fields OWNER TO postgres;

--
-- Name: entity_fields_entity_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_fields_entity_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_fields_entity_field_id_seq OWNER TO postgres;

--
-- Name: entity_fields_entity_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_fields_entity_field_id_seq OWNED BY public.entity_fields.entity_field_id;


--
-- Name: entity_orgs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_orgs (
    entity_org_id integer NOT NULL,
    entity_id integer NOT NULL,
    org_id integer,
    details text
);


ALTER TABLE public.entity_orgs OWNER TO postgres;

--
-- Name: entity_orgs_entity_org_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_orgs_entity_org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_orgs_entity_org_id_seq OWNER TO postgres;

--
-- Name: entity_orgs_entity_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_orgs_entity_org_id_seq OWNED BY public.entity_orgs.entity_org_id;


--
-- Name: entity_reset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_reset (
    entity_reset_id integer NOT NULL,
    entity_id integer,
    org_id integer,
    request_email character varying(320),
    request_time timestamp without time zone DEFAULT now(),
    login_ip character varying(64),
    phone_serial_number character varying(50),
    narrative character varying(240)
);


ALTER TABLE public.entity_reset OWNER TO postgres;

--
-- Name: entity_reset_entity_reset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_reset_entity_reset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_reset_entity_reset_id_seq OWNER TO postgres;

--
-- Name: entity_reset_entity_reset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_reset_entity_reset_id_seq OWNED BY public.entity_reset.entity_reset_id;


--
-- Name: entity_subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_subscriptions (
    entity_subscription_id integer NOT NULL,
    entity_type_id integer NOT NULL,
    entity_id integer NOT NULL,
    org_id integer,
    details text
);


ALTER TABLE public.entity_subscriptions OWNER TO postgres;

--
-- Name: entity_subscriptions_entity_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_subscriptions_entity_subscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_subscriptions_entity_subscription_id_seq OWNER TO postgres;

--
-- Name: entity_subscriptions_entity_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_subscriptions_entity_subscription_id_seq OWNED BY public.entity_subscriptions.entity_subscription_id;


--
-- Name: entity_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_types (
    entity_type_id integer NOT NULL,
    use_key_id integer NOT NULL,
    org_id integer,
    entity_type_name character varying(50) NOT NULL,
    entity_role character varying(240),
    start_view character varying(120),
    group_email character varying(120),
    description text,
    details text
);


ALTER TABLE public.entity_types OWNER TO postgres;

--
-- Name: entity_types_entity_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_types_entity_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_types_entity_type_id_seq OWNER TO postgres;

--
-- Name: entity_types_entity_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_types_entity_type_id_seq OWNED BY public.entity_types.entity_type_id;


--
-- Name: entity_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_values (
    entity_value_id integer NOT NULL,
    entity_id integer,
    entity_field_id integer,
    org_id integer,
    entity_value character varying(240)
);


ALTER TABLE public.entity_values OWNER TO postgres;

--
-- Name: entity_values_entity_value_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_values_entity_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_values_entity_value_id_seq OWNER TO postgres;

--
-- Name: entity_values_entity_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_values_entity_value_id_seq OWNED BY public.entity_values.entity_value_id;


--
-- Name: entitys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entitys (
    entity_id integer NOT NULL,
    entity_type_id integer NOT NULL,
    use_key_id integer NOT NULL,
    sys_language_id integer,
    org_id integer NOT NULL,
    entity_name character varying(120) NOT NULL,
    user_name character varying(120) NOT NULL,
    primary_email character varying(120),
    primary_telephone character varying(50),
    super_user boolean DEFAULT false NOT NULL,
    entity_leader boolean DEFAULT false NOT NULL,
    no_org boolean DEFAULT false NOT NULL,
    function_role character varying(240),
    date_enroled timestamp without time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    entity_password character varying(64) NOT NULL,
    first_password character varying(64) NOT NULL,
    new_password character varying(64),
    start_url character varying(64),
    is_picked boolean DEFAULT false NOT NULL,
    locked_until timestamp without time zone,
    details text
);


ALTER TABLE public.entitys OWNER TO postgres;

--
-- Name: entitys_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entitys_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entitys_entity_id_seq OWNER TO postgres;

--
-- Name: entitys_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entitys_entity_id_seq OWNED BY public.entitys.entity_id;


--
-- Name: entry_forms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entry_forms (
    entry_form_id integer NOT NULL,
    org_id integer,
    entity_id integer,
    form_id integer,
    entered_by_id integer,
    application_date timestamp without time zone DEFAULT now() NOT NULL,
    completion_date timestamp without time zone,
    approve_status character varying(16) DEFAULT 'Draft'::character varying NOT NULL,
    workflow_table_id integer,
    action_date timestamp without time zone,
    narrative character varying(240),
    answer text,
    sub_answer text,
    details text
);


ALTER TABLE public.entry_forms OWNER TO postgres;

--
-- Name: entry_forms_entry_form_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entry_forms_entry_form_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entry_forms_entry_form_id_seq OWNER TO postgres;

--
-- Name: entry_forms_entry_form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entry_forms_entry_form_id_seq OWNED BY public.entry_forms.entry_form_id;


--
-- Name: et_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.et_fields (
    et_field_id integer NOT NULL,
    org_id integer,
    et_field_name character varying(320) NOT NULL,
    table_name character varying(64) NOT NULL,
    table_code integer NOT NULL,
    table_link integer,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.et_fields OWNER TO postgres;

--
-- Name: et_fields_et_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.et_fields_et_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.et_fields_et_field_id_seq OWNER TO postgres;

--
-- Name: et_fields_et_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.et_fields_et_field_id_seq OWNED BY public.et_fields.et_field_id;


--
-- Name: fee_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fee_payments (
    fee_payment_id integer NOT NULL,
    org_id integer,
    school_term_id integer,
    student_id integer,
    accountant_id integer,
    invoice_no character varying(20),
    doc_no character varying(100),
    school_year character varying(4),
    amount real,
    payed_by character varying(120),
    date_payed date DEFAULT CURRENT_DATE,
    details text,
    payment_mode_id integer
);


ALTER TABLE public.fee_payments OWNER TO postgres;

--
-- Name: fee_payments_fee_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fee_payments_fee_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fee_payments_fee_payment_id_seq OWNER TO postgres;

--
-- Name: fee_payments_fee_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fee_payments_fee_payment_id_seq OWNED BY public.fee_payments.fee_payment_id;


--
-- Name: fees_structure; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fees_structure (
    fees_structure_id integer NOT NULL,
    school_term_id integer,
    org_id integer,
    class_level_id integer,
    is_current boolean DEFAULT true,
    details text,
    calendar_year_id integer
);


ALTER TABLE public.fees_structure OWNER TO postgres;

--
-- Name: fees_structure_fees_structure_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fees_structure_fees_structure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fees_structure_fees_structure_id_seq OWNER TO postgres;

--
-- Name: fees_structure_fees_structure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fees_structure_fees_structure_id_seq OWNED BY public.fees_structure.fees_structure_id;


--
-- Name: fees_structure_vote_heads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fees_structure_vote_heads (
    fees_structure_vote_head_id integer NOT NULL,
    org_id integer,
    fees_structure_id integer,
    vote_head_id integer,
    amount real,
    details text
);


ALTER TABLE public.fees_structure_vote_heads OWNER TO postgres;

--
-- Name: fees_structure_vote_heads_fees_structure_vote_head_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fees_structure_vote_heads_fees_structure_vote_head_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fees_structure_vote_heads_fees_structure_vote_head_id_seq OWNER TO postgres;

--
-- Name: fees_structure_vote_heads_fees_structure_vote_head_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fees_structure_vote_heads_fees_structure_vote_head_id_seq OWNED BY public.fees_structure_vote_heads.fees_structure_vote_head_id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fields (
    field_id integer NOT NULL,
    org_id integer,
    form_id integer,
    field_name character varying(50),
    question text,
    field_lookup text,
    field_type character varying(25) NOT NULL,
    field_class character varying(25),
    field_bold character(1) DEFAULT '0'::bpchar NOT NULL,
    field_italics character(1) DEFAULT '0'::bpchar NOT NULL,
    field_order integer NOT NULL,
    share_line integer,
    field_size integer DEFAULT 25 NOT NULL,
    label_position character(1) DEFAULT 'L'::bpchar,
    field_fnct character varying(120),
    manditory character(1) DEFAULT '0'::bpchar NOT NULL,
    show character(1) DEFAULT '1'::bpchar,
    tab character varying(25),
    details text
);


ALTER TABLE public.fields OWNER TO postgres;

--
-- Name: fields_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fields_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fields_field_id_seq OWNER TO postgres;

--
-- Name: fields_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fields_field_id_seq OWNED BY public.fields.field_id;


--
-- Name: forms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.forms (
    form_id integer NOT NULL,
    org_id integer,
    form_name character varying(240) NOT NULL,
    form_number character varying(50),
    table_name character varying(50),
    version character varying(25),
    completed character(1) DEFAULT '0'::bpchar NOT NULL,
    is_active character(1) DEFAULT '0'::bpchar NOT NULL,
    use_key integer DEFAULT 0,
    form_header text,
    form_footer text,
    default_values text,
    details text
);


ALTER TABLE public.forms OWNER TO postgres;

--
-- Name: forms_form_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.forms_form_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forms_form_id_seq OWNER TO postgres;

--
-- Name: forms_form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.forms_form_id_seq OWNED BY public.forms.form_id;


--
-- Name: librarians; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.librarians (
    librarian_id integer NOT NULL,
    librarian_name character varying(120),
    org_id integer,
    telno character varying(20),
    gender character varying(2),
    email character varying(50),
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.librarians OWNER TO postgres;

--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.librarians_librarian_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.librarians_librarian_id_seq OWNER TO postgres;

--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.librarians_librarian_id_seq OWNED BY public.librarians.librarian_id;


--
-- Name: orgs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orgs (
    org_id integer NOT NULL,
    currency_id integer,
    default_country_id character(2),
    parent_org_id integer,
    org_name character varying(50) NOT NULL,
    org_full_name character varying(120),
    org_sufix character varying(4) NOT NULL,
    is_default boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    department_filter boolean DEFAULT false NOT NULL,
    pin character varying(50),
    pcc character varying(12),
    logo character varying(50),
    letter_head character varying(50),
    email_from character varying(120),
    web_logos boolean DEFAULT false NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    system_key character varying(64),
    system_identifier character varying(64),
    mac_address character varying(64),
    public_key bytea,
    license bytea,
    details text
);


ALTER TABLE public.orgs OWNER TO postgres;

--
-- Name: orgs_org_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orgs_org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orgs_org_id_seq OWNER TO postgres;

--
-- Name: orgs_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orgs_org_id_seq OWNED BY public.orgs.org_id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_methods (
    payment_method_id integer NOT NULL,
    org_id integer,
    payment_method_name character varying(100),
    doc_name character varying(100),
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.payment_methods OWNER TO postgres;

--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_methods_payment_method_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_methods_payment_method_id_seq OWNER TO postgres;

--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_methods_payment_method_id_seq OWNED BY public.payment_methods.payment_method_id;


--
-- Name: payment_modes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_modes (
    payment_mode_id integer NOT NULL,
    payment_mode_name character varying(120),
    org_id integer,
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.payment_modes OWNER TO postgres;

--
-- Name: payment_modes_payment_mode_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_modes_payment_mode_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_modes_payment_mode_id_seq OWNER TO postgres;

--
-- Name: payment_modes_payment_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_modes_payment_mode_id_seq OWNED BY public.payment_modes.payment_mode_id;


--
-- Name: picture_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.picture_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.picture_id_seq OWNER TO postgres;

--
-- Name: publishers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publishers (
    publisher_id integer NOT NULL,
    org_id integer,
    publisher_name character varying(120),
    publisher_address text
);


ALTER TABLE public.publishers OWNER TO postgres;

--
-- Name: publishers_publisher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.publishers_publisher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.publishers_publisher_id_seq OWNER TO postgres;

--
-- Name: publishers_publisher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.publishers_publisher_id_seq OWNED BY public.publishers.publisher_id;


--
-- Name: reporting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting (
    reporting_id integer NOT NULL,
    entity_id integer,
    report_to_id integer,
    org_id integer,
    date_from date,
    date_to date,
    reporting_level integer DEFAULT 1 NOT NULL,
    primary_report boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    ps_reporting real,
    details text
);


ALTER TABLE public.reporting OWNER TO postgres;

--
-- Name: reporting_reporting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_reporting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_reporting_id_seq OWNER TO postgres;

--
-- Name: reporting_reporting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_reporting_id_seq OWNED BY public.reporting.reporting_id;


--
-- Name: school_calendar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.school_calendar (
    school_calendar_id integer NOT NULL,
    org_id integer,
    school_calendar_name character varying(100),
    school_term_id integer,
    start_date date,
    end_date date,
    school_year character varying(4),
    details text,
    is_current boolean DEFAULT true,
    calendar_year_id integer
);


ALTER TABLE public.school_calendar OWNER TO postgres;

--
-- Name: school_calendar_school_calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.school_calendar_school_calendar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.school_calendar_school_calendar_id_seq OWNER TO postgres;

--
-- Name: school_calendar_school_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.school_calendar_school_calendar_id_seq OWNED BY public.school_calendar.school_calendar_id;


--
-- Name: school_terms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.school_terms (
    school_term_id integer NOT NULL,
    org_id integer,
    school_term_name character varying(100),
    details text
);


ALTER TABLE public.school_terms OWNER TO postgres;

--
-- Name: school_terms_school_term_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.school_terms_school_term_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.school_terms_school_term_id_seq OWNER TO postgres;

--
-- Name: school_terms_school_term_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.school_terms_school_term_id_seq OWNED BY public.school_terms.school_term_id;


--
-- Name: select_yes_no; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.select_yes_no (
    select_id integer,
    select_state boolean,
    select_value text
);


ALTER TABLE public.select_yes_no OWNER TO postgres;

--
-- Name: streams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.streams (
    stream_id integer NOT NULL,
    stream_name character varying(120),
    org_id integer,
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.streams OWNER TO postgres;

--
-- Name: streams_stream_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.streams_stream_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.streams_stream_id_seq OWNER TO postgres;

--
-- Name: streams_stream_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.streams_stream_id_seq OWNED BY public.streams.stream_id;


--
-- Name: student_fee_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_fee_invoices (
    student_fee_invoice_id integer NOT NULL,
    student_id integer,
    org_id integer,
    fee_structure_id integer,
    class_level_id integer
);


ALTER TABLE public.student_fee_invoices OWNER TO postgres;

--
-- Name: student_fee_invoices_student_fee_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_fee_invoices_student_fee_invoice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_fee_invoices_student_fee_invoice_id_seq OWNER TO postgres;

--
-- Name: student_fee_invoices_student_fee_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_fee_invoices_student_fee_invoice_id_seq OWNED BY public.student_fee_invoices.student_fee_invoice_id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    student_id integer NOT NULL,
    admission_no character varying(120),
    org_id integer,
    first_name character varying(120),
    second_name character varying(120),
    surname character varying(120),
    gender character varying(2),
    address character varying(120),
    dob date,
    fname character varying(120),
    mname character varying(120),
    mphone_no character varying(10),
    fphone_no character varying(10),
    class_level_id integer,
    stream_id integer,
    is_suspended boolean DEFAULT false,
    is_active boolean DEFAULT true,
    details text,
    picture_file character varying(150)
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_student_id_seq OWNER TO postgres;

--
-- Name: students_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_student_id_seq OWNED BY public.students.student_id;


--
-- Name: sub_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sub_fields (
    sub_field_id integer NOT NULL,
    org_id integer,
    field_id integer,
    sub_field_order integer NOT NULL,
    sub_title_share character varying(120),
    sub_field_type character varying(25),
    sub_field_lookup text,
    sub_field_size integer NOT NULL,
    sub_col_spans integer DEFAULT 1 NOT NULL,
    manditory character(1) DEFAULT '0'::bpchar NOT NULL,
    show character(1) DEFAULT '1'::bpchar,
    question text
);


ALTER TABLE public.sub_fields OWNER TO postgres;

--
-- Name: sub_fields_sub_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sub_fields_sub_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_fields_sub_field_id_seq OWNER TO postgres;

--
-- Name: sub_fields_sub_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sub_fields_sub_field_id_seq OWNED BY public.sub_fields.sub_field_id;


--
-- Name: sys_access_entitys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_access_entitys (
    sys_access_entity_id integer NOT NULL,
    sys_access_level_id integer NOT NULL,
    entity_id integer NOT NULL,
    org_id integer,
    narrative character varying(320)
);


ALTER TABLE public.sys_access_entitys OWNER TO postgres;

--
-- Name: sys_access_entitys_sys_access_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_access_entitys_sys_access_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_access_entitys_sys_access_entity_id_seq OWNER TO postgres;

--
-- Name: sys_access_entitys_sys_access_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_access_entitys_sys_access_entity_id_seq OWNED BY public.sys_access_entitys.sys_access_entity_id;


--
-- Name: sys_access_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_access_levels (
    sys_access_level_id integer NOT NULL,
    use_key_id integer,
    sys_country_id character(2),
    org_id integer,
    sys_access_level_name character varying(64) NOT NULL,
    access_tag character varying(32) NOT NULL,
    acess_details text
);


ALTER TABLE public.sys_access_levels OWNER TO postgres;

--
-- Name: sys_access_levels_sys_access_level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_access_levels_sys_access_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_access_levels_sys_access_level_id_seq OWNER TO postgres;

--
-- Name: sys_access_levels_sys_access_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_access_levels_sys_access_level_id_seq OWNED BY public.sys_access_levels.sys_access_level_id;


--
-- Name: sys_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_apps (
    sys_app_id integer NOT NULL,
    sys_app_name character varying(50) NOT NULL,
    details text
);


ALTER TABLE public.sys_apps OWNER TO postgres;

--
-- Name: sys_apps_sys_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_apps_sys_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_apps_sys_app_id_seq OWNER TO postgres;

--
-- Name: sys_apps_sys_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_apps_sys_app_id_seq OWNED BY public.sys_apps.sys_app_id;


--
-- Name: sys_audit_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_audit_details (
    sys_audit_trail_id integer NOT NULL,
    old_value text
);


ALTER TABLE public.sys_audit_details OWNER TO postgres;

--
-- Name: sys_audit_trail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_audit_trail (
    sys_audit_trail_id integer NOT NULL,
    user_id character varying(50) NOT NULL,
    user_ip character varying(50),
    change_date timestamp without time zone DEFAULT now() NOT NULL,
    table_name character varying(50) NOT NULL,
    record_id character varying(50) NOT NULL,
    change_type character varying(50) NOT NULL,
    narrative character varying(240)
);


ALTER TABLE public.sys_audit_trail OWNER TO postgres;

--
-- Name: sys_audit_trail_sys_audit_trail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_audit_trail_sys_audit_trail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_audit_trail_sys_audit_trail_id_seq OWNER TO postgres;

--
-- Name: sys_audit_trail_sys_audit_trail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_audit_trail_sys_audit_trail_id_seq OWNED BY public.sys_audit_trail.sys_audit_trail_id;


--
-- Name: sys_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_configs (
    sys_config_id integer NOT NULL,
    config_type_id integer NOT NULL,
    config_name character varying(254) NOT NULL,
    config_value text NOT NULL
);


ALTER TABLE public.sys_configs OWNER TO postgres;

--
-- Name: sys_configs_sys_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_configs_sys_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_configs_sys_config_id_seq OWNER TO postgres;

--
-- Name: sys_configs_sys_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_configs_sys_config_id_seq OWNED BY public.sys_configs.sys_config_id;


--
-- Name: sys_continents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_continents (
    sys_continent_id character(2) NOT NULL,
    sys_continent_name character varying(120)
);


ALTER TABLE public.sys_continents OWNER TO postgres;

--
-- Name: sys_countrys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_countrys (
    sys_country_id character(2) NOT NULL,
    sys_continent_id character(2),
    sys_country_code character varying(3),
    sys_country_name character varying(120),
    sys_country_number character varying(3),
    sys_country_capital character varying(64),
    sys_phone_code character varying(7),
    sys_currency_name character varying(50),
    sys_currency_code character varying(3),
    sys_currency_cents character varying(50),
    sys_currency_exchange real
);


ALTER TABLE public.sys_countrys OWNER TO postgres;

--
-- Name: sys_dashboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_dashboard (
    sys_dashboard_id integer NOT NULL,
    entity_id integer,
    org_id integer,
    narrative character varying(240),
    details text
);


ALTER TABLE public.sys_dashboard OWNER TO postgres;

--
-- Name: sys_dashboard_sys_dashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_dashboard_sys_dashboard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_dashboard_sys_dashboard_id_seq OWNER TO postgres;

--
-- Name: sys_dashboard_sys_dashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_dashboard_sys_dashboard_id_seq OWNED BY public.sys_dashboard.sys_dashboard_id;


--
-- Name: sys_emailed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_emailed (
    sys_emailed_id integer NOT NULL,
    sys_email_id integer,
    org_id integer,
    table_id integer,
    table_name character varying(50),
    email_type integer DEFAULT 1 NOT NULL,
    emailed boolean DEFAULT false NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    narrative character varying(240),
    mail_body text
);


ALTER TABLE public.sys_emailed OWNER TO postgres;

--
-- Name: sys_emailed_sys_emailed_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_emailed_sys_emailed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_emailed_sys_emailed_id_seq OWNER TO postgres;

--
-- Name: sys_emailed_sys_emailed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_emailed_sys_emailed_id_seq OWNED BY public.sys_emailed.sys_emailed_id;


--
-- Name: sys_emails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_emails (
    sys_email_id integer NOT NULL,
    org_id integer,
    use_type integer DEFAULT 1 NOT NULL,
    sys_email_name character varying(50),
    default_email character varying(320),
    title character varying(240) NOT NULL,
    details text
);


ALTER TABLE public.sys_emails OWNER TO postgres;

--
-- Name: sys_emails_sys_email_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_emails_sys_email_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_emails_sys_email_id_seq OWNER TO postgres;

--
-- Name: sys_emails_sys_email_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_emails_sys_email_id_seq OWNED BY public.sys_emails.sys_email_id;


--
-- Name: sys_errors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_errors (
    sys_error_id integer NOT NULL,
    sys_error character varying(240) NOT NULL,
    error_message text NOT NULL
);


ALTER TABLE public.sys_errors OWNER TO postgres;

--
-- Name: sys_errors_sys_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_errors_sys_error_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_errors_sys_error_id_seq OWNER TO postgres;

--
-- Name: sys_errors_sys_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_errors_sys_error_id_seq OWNED BY public.sys_errors.sys_error_id;


--
-- Name: sys_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_files (
    sys_file_id integer NOT NULL,
    org_id integer,
    table_id integer,
    table_name character varying(50),
    file_name character varying(320),
    file_type character varying(320),
    file_size integer,
    narrative character varying(320),
    details text
);


ALTER TABLE public.sys_files OWNER TO postgres;

--
-- Name: sys_files_sys_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_files_sys_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_files_sys_file_id_seq OWNER TO postgres;

--
-- Name: sys_files_sys_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_files_sys_file_id_seq OWNED BY public.sys_files.sys_file_id;


--
-- Name: sys_languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_languages (
    sys_language_id integer NOT NULL,
    sys_language_name character varying(50) NOT NULL
);


ALTER TABLE public.sys_languages OWNER TO postgres;

--
-- Name: sys_languages_sys_language_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_languages_sys_language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_languages_sys_language_id_seq OWNER TO postgres;

--
-- Name: sys_languages_sys_language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_languages_sys_language_id_seq OWNED BY public.sys_languages.sys_language_id;


--
-- Name: sys_logins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_logins (
    sys_login_id integer NOT NULL,
    entity_id integer,
    login_time timestamp without time zone DEFAULT now(),
    login_ip character varying(64),
    phone_serial_number character varying(50),
    correct_login boolean DEFAULT true NOT NULL,
    narrative character varying(240)
);


ALTER TABLE public.sys_logins OWNER TO postgres;

--
-- Name: sys_logins_sys_login_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_logins_sys_login_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_logins_sys_login_id_seq OWNER TO postgres;

--
-- Name: sys_logins_sys_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_logins_sys_login_id_seq OWNED BY public.sys_logins.sys_login_id;


--
-- Name: sys_menu_msg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_menu_msg (
    sys_menu_msg_id integer NOT NULL,
    menu_id character varying(16) NOT NULL,
    menu_name character varying(50) NOT NULL,
    xml_file character varying(50) NOT NULL,
    msg text
);


ALTER TABLE public.sys_menu_msg OWNER TO postgres;

--
-- Name: sys_menu_msg_sys_menu_msg_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_menu_msg_sys_menu_msg_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_menu_msg_sys_menu_msg_id_seq OWNER TO postgres;

--
-- Name: sys_menu_msg_sys_menu_msg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_menu_msg_sys_menu_msg_id_seq OWNED BY public.sys_menu_msg.sys_menu_msg_id;


--
-- Name: sys_nationalitys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_nationalitys (
    sys_nationality_id character varying(3),
    sys_nationality_name character varying(100)
);


ALTER TABLE public.sys_nationalitys OWNER TO postgres;

--
-- Name: sys_news; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_news (
    sys_news_id integer NOT NULL,
    org_id integer,
    sys_news_group integer,
    sys_news_title character varying(240) NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    details text
);


ALTER TABLE public.sys_news OWNER TO postgres;

--
-- Name: sys_news_sys_news_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_news_sys_news_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_news_sys_news_id_seq OWNER TO postgres;

--
-- Name: sys_news_sys_news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_news_sys_news_id_seq OWNED BY public.sys_news.sys_news_id;


--
-- Name: sys_queries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_queries (
    sys_queries_id integer NOT NULL,
    org_id integer,
    sys_query_name character varying(50),
    query_date timestamp without time zone DEFAULT now() NOT NULL,
    query_text text,
    query_params text
);


ALTER TABLE public.sys_queries OWNER TO postgres;

--
-- Name: sys_queries_sys_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_queries_sys_queries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_queries_sys_queries_id_seq OWNER TO postgres;

--
-- Name: sys_queries_sys_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_queries_sys_queries_id_seq OWNED BY public.sys_queries.sys_queries_id;


--
-- Name: sys_reset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_reset (
    sys_reset_id integer NOT NULL,
    entity_id integer,
    org_id integer,
    request_email character varying(320),
    request_time timestamp without time zone DEFAULT now(),
    login_ip character varying(64),
    narrative character varying(240)
);


ALTER TABLE public.sys_reset OWNER TO postgres;

--
-- Name: sys_reset_sys_reset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_reset_sys_reset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_reset_sys_reset_id_seq OWNER TO postgres;

--
-- Name: sys_reset_sys_reset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_reset_sys_reset_id_seq OWNED BY public.sys_reset.sys_reset_id;


--
-- Name: sys_translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_translations (
    sys_translation_id integer NOT NULL,
    sys_app_id integer,
    sys_language_id integer,
    org_id integer,
    reference character varying(64) NOT NULL,
    title character varying(320) NOT NULL,
    narration character varying(320) NOT NULL
);


ALTER TABLE public.sys_translations OWNER TO postgres;

--
-- Name: sys_translations_sys_translation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_translations_sys_translation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sys_translations_sys_translation_id_seq OWNER TO postgres;

--
-- Name: sys_translations_sys_translation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_translations_sys_translation_id_seq OWNED BY public.sys_translations.sys_translation_id;


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    teacher_id integer NOT NULL,
    teacher_name character varying(120),
    org_id integer,
    telno character varying(20),
    gender character varying(2),
    email character varying(50),
    is_active boolean DEFAULT true,
    details text
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teachers_teacher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teachers_teacher_id_seq OWNER TO postgres;

--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teachers_teacher_id_seq OWNED BY public.teachers.teacher_id;


--
-- Name: tomcat_users; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tomcat_users AS
 SELECT entitys.user_name,
    entitys.entity_password,
    entity_types.entity_role
   FROM ((public.entity_subscriptions
     JOIN public.entitys ON ((entity_subscriptions.entity_id = entitys.entity_id)))
     JOIN public.entity_types ON ((entity_subscriptions.entity_type_id = entity_types.entity_type_id)))
  WHERE (entitys.is_active = true);


ALTER TABLE public.tomcat_users OWNER TO postgres;

--
-- Name: use_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.use_keys (
    use_key_id integer NOT NULL,
    use_key_name character varying(32) NOT NULL,
    use_function integer
);


ALTER TABLE public.use_keys OWNER TO postgres;

--
-- Name: vote_heads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vote_heads (
    vote_head_id integer NOT NULL,
    org_id integer,
    vote_head_name character varying(120),
    details text
);


ALTER TABLE public.vote_heads OWNER TO postgres;

--
-- Name: vote_heads_vote_head_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vote_heads_vote_head_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vote_heads_vote_head_id_seq OWNER TO postgres;

--
-- Name: vote_heads_vote_head_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vote_heads_vote_head_id_seq OWNED BY public.vote_heads.vote_head_id;


--
-- Name: vw_accountants; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_accountants AS
 SELECT accountants.org_id,
    accountants.accountant_id,
    accountants.accountant_name,
    accountants.telno,
        CASE
            WHEN ((accountants.gender)::text = 'M'::text) THEN 'MALE'::text
            ELSE 'FEMALE'::text
        END AS gender,
    accountants.email,
    accountants.is_active,
    accountants.details
   FROM public.accountants;


ALTER TABLE public.vw_accountants OWNER TO postgres;

--
-- Name: vw_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_address AS
 SELECT sys_countrys.sys_country_id,
    sys_countrys.sys_country_name,
    address.address_id,
    address.org_id,
    address.address_name,
    address.table_name,
    address.table_id,
    address.post_office_box,
    address.postal_code,
    address.premises,
    address.street,
    address.town,
    address.phone_number,
    address.extension,
    address.mobile,
    address.fax,
    address.email,
    address.is_default,
    address.website,
    address.details,
    address_types.address_type_id,
    address_types.address_type_name
   FROM ((public.address
     JOIN public.sys_countrys ON ((address.sys_country_id = sys_countrys.sys_country_id)))
     LEFT JOIN public.address_types ON ((address.address_type_id = address_types.address_type_id)));


ALTER TABLE public.vw_address OWNER TO postgres;

--
-- Name: vw_address_entitys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_address_entitys AS
 SELECT vw_address.address_id,
    vw_address.address_name,
    vw_address.table_id,
    vw_address.table_name,
    vw_address.sys_country_id,
    vw_address.sys_country_name,
    vw_address.is_default,
    vw_address.post_office_box,
    vw_address.postal_code,
    vw_address.premises,
    vw_address.street,
    vw_address.town,
    vw_address.phone_number,
    vw_address.extension,
    vw_address.mobile,
    vw_address.fax,
    vw_address.email,
    vw_address.website
   FROM public.vw_address
  WHERE (((vw_address.table_name)::text = 'entitys'::text) AND (vw_address.is_default = true));


ALTER TABLE public.vw_address_entitys OWNER TO postgres;

--
-- Name: workflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflows (
    workflow_id integer NOT NULL,
    source_entity_id integer NOT NULL,
    org_id integer,
    workflow_name character varying(240) NOT NULL,
    table_name character varying(64),
    table_link_field character varying(64),
    table_link_id integer,
    approve_email text NOT NULL,
    reject_email text NOT NULL,
    approve_file character varying(320),
    reject_file character varying(320),
    link_copy integer,
    details text
);


ALTER TABLE public.workflows OWNER TO postgres;

--
-- Name: vw_workflows; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflows AS
 SELECT entity_types.entity_type_id AS source_entity_id,
    entity_types.entity_type_name AS source_entity_name,
    workflows.workflow_id,
    workflows.org_id,
    workflows.workflow_name,
    workflows.table_name,
    workflows.table_link_field,
    workflows.table_link_id,
    workflows.approve_email,
    workflows.reject_email,
    workflows.approve_file,
    workflows.reject_file,
    workflows.details
   FROM (public.workflows
     JOIN public.entity_types ON ((workflows.source_entity_id = entity_types.entity_type_id)));


ALTER TABLE public.vw_workflows OWNER TO postgres;

--
-- Name: workflow_phases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_phases (
    workflow_phase_id integer NOT NULL,
    workflow_id integer NOT NULL,
    approval_entity_id integer NOT NULL,
    org_id integer,
    approval_level integer DEFAULT 1 NOT NULL,
    return_level integer DEFAULT 1 NOT NULL,
    escalation_days integer DEFAULT 0 NOT NULL,
    escalation_hours integer DEFAULT 3 NOT NULL,
    required_approvals integer DEFAULT 1 NOT NULL,
    reporting_level integer DEFAULT 1 NOT NULL,
    use_reporting boolean DEFAULT false NOT NULL,
    advice boolean DEFAULT false NOT NULL,
    notice boolean DEFAULT false NOT NULL,
    phase_narrative character varying(240) NOT NULL,
    advice_email text,
    notice_email text,
    advice_file character varying(320),
    notice_file character varying(320),
    details text
);


ALTER TABLE public.workflow_phases OWNER TO postgres;

--
-- Name: vw_workflow_phases; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflow_phases AS
 SELECT vw_workflows.source_entity_id,
    vw_workflows.source_entity_name,
    vw_workflows.workflow_id,
    vw_workflows.workflow_name,
    vw_workflows.table_name,
    vw_workflows.table_link_field,
    vw_workflows.table_link_id,
    vw_workflows.approve_email,
    vw_workflows.reject_email,
    vw_workflows.approve_file,
    vw_workflows.reject_file,
    entity_types.entity_type_id AS approval_entity_id,
    entity_types.entity_type_name AS approval_entity_name,
    workflow_phases.workflow_phase_id,
    workflow_phases.org_id,
    workflow_phases.approval_level,
    workflow_phases.return_level,
    workflow_phases.escalation_days,
    workflow_phases.escalation_hours,
    workflow_phases.notice,
    workflow_phases.notice_email,
    workflow_phases.notice_file,
    workflow_phases.advice,
    workflow_phases.advice_email,
    workflow_phases.advice_file,
    workflow_phases.required_approvals,
    workflow_phases.use_reporting,
    workflow_phases.reporting_level,
    workflow_phases.phase_narrative,
    workflow_phases.details
   FROM ((public.workflow_phases
     JOIN public.vw_workflows ON ((workflow_phases.workflow_id = vw_workflows.workflow_id)))
     JOIN public.entity_types ON ((workflow_phases.approval_entity_id = entity_types.entity_type_id)));


ALTER TABLE public.vw_workflow_phases OWNER TO postgres;

--
-- Name: vw_approvals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_approvals AS
 SELECT vw_workflow_phases.workflow_id,
    vw_workflow_phases.workflow_name,
    vw_workflow_phases.approve_email,
    vw_workflow_phases.reject_email,
    vw_workflow_phases.source_entity_id,
    vw_workflow_phases.source_entity_name,
    vw_workflow_phases.approval_entity_id,
    vw_workflow_phases.approval_entity_name,
    vw_workflow_phases.approve_file,
    vw_workflow_phases.reject_file,
    vw_workflow_phases.workflow_phase_id,
    vw_workflow_phases.approval_level,
    vw_workflow_phases.phase_narrative,
    vw_workflow_phases.return_level,
    vw_workflow_phases.required_approvals,
    vw_workflow_phases.notice,
    vw_workflow_phases.notice_email,
    vw_workflow_phases.notice_file,
    vw_workflow_phases.advice,
    vw_workflow_phases.advice_email,
    vw_workflow_phases.advice_file,
    vw_workflow_phases.use_reporting,
    approvals.approval_id,
    approvals.org_id,
    approvals.forward_id,
    approvals.table_name,
    approvals.table_id,
    approvals.completion_date,
    approvals.escalation_days,
    approvals.escalation_hours,
    approvals.escalation_time,
    approvals.application_date,
    approvals.approve_status,
    approvals.action_date,
    approvals.approval_narrative,
    approvals.to_be_done,
    approvals.what_is_done,
    approvals.review_advice,
    approvals.details,
    oe.entity_id AS org_entity_id,
    oe.entity_name AS org_entity_name,
    oe.user_name AS org_user_name,
    oe.primary_email AS org_primary_email,
    ae.entity_id AS app_entity_id,
    ae.entity_name AS app_entity_name,
    ae.user_name AS app_user_name,
    ae.primary_email AS app_primary_email
   FROM (((public.vw_workflow_phases
     JOIN public.approvals ON ((vw_workflow_phases.workflow_phase_id = approvals.workflow_phase_id)))
     JOIN public.entitys oe ON ((approvals.org_entity_id = oe.entity_id)))
     LEFT JOIN public.entitys ae ON ((approvals.app_entity_id = ae.entity_id)));


ALTER TABLE public.vw_approvals OWNER TO postgres;

--
-- Name: vw_approvals_entitys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_approvals_entitys AS
 SELECT vw_workflow_phases.workflow_id,
    vw_workflow_phases.workflow_name,
    vw_workflow_phases.source_entity_id,
    vw_workflow_phases.source_entity_name,
    vw_workflow_phases.approval_entity_id,
    vw_workflow_phases.approval_entity_name,
    vw_workflow_phases.workflow_phase_id,
    vw_workflow_phases.approval_level,
    vw_workflow_phases.notice,
    vw_workflow_phases.notice_email,
    vw_workflow_phases.notice_file,
    vw_workflow_phases.advice,
    vw_workflow_phases.advice_email,
    vw_workflow_phases.advice_file,
    vw_workflow_phases.return_level,
    vw_workflow_phases.required_approvals,
    vw_workflow_phases.phase_narrative,
    vw_workflow_phases.use_reporting,
    approvals.approval_id,
    approvals.org_id,
    approvals.forward_id,
    approvals.table_name,
    approvals.table_id,
    approvals.completion_date,
    approvals.escalation_days,
    approvals.escalation_hours,
    approvals.escalation_time,
    approvals.application_date,
    approvals.approve_status,
    approvals.action_date,
    approvals.approval_narrative,
    approvals.to_be_done,
    approvals.what_is_done,
    approvals.review_advice,
    approvals.details,
    oe.entity_id AS org_entity_id,
    oe.entity_name AS org_entity_name,
    oe.user_name AS org_user_name,
    oe.primary_email AS org_primary_email,
    entitys.entity_id,
    entitys.entity_name,
    entitys.user_name,
    entitys.primary_email
   FROM ((((public.vw_workflow_phases
     JOIN public.approvals ON ((vw_workflow_phases.workflow_phase_id = approvals.workflow_phase_id)))
     JOIN public.entitys oe ON ((approvals.org_entity_id = oe.entity_id)))
     JOIN public.entity_subscriptions ON ((vw_workflow_phases.approval_entity_id = entity_subscriptions.entity_type_id)))
     JOIN public.entitys ON ((entity_subscriptions.entity_id = entitys.entity_id)))
  WHERE ((approvals.forward_id IS NULL) AND (vw_workflow_phases.use_reporting = false))
UNION
 SELECT vw_workflow_phases.workflow_id,
    vw_workflow_phases.workflow_name,
    vw_workflow_phases.source_entity_id,
    vw_workflow_phases.source_entity_name,
    vw_workflow_phases.approval_entity_id,
    vw_workflow_phases.approval_entity_name,
    vw_workflow_phases.workflow_phase_id,
    vw_workflow_phases.approval_level,
    vw_workflow_phases.notice,
    vw_workflow_phases.notice_email,
    vw_workflow_phases.notice_file,
    vw_workflow_phases.advice,
    vw_workflow_phases.advice_email,
    vw_workflow_phases.advice_file,
    vw_workflow_phases.return_level,
    vw_workflow_phases.required_approvals,
    vw_workflow_phases.phase_narrative,
    vw_workflow_phases.use_reporting,
    approvals.approval_id,
    approvals.org_id,
    approvals.forward_id,
    approvals.table_name,
    approvals.table_id,
    approvals.completion_date,
    approvals.escalation_days,
    approvals.escalation_hours,
    approvals.escalation_time,
    approvals.application_date,
    approvals.approve_status,
    approvals.action_date,
    approvals.approval_narrative,
    approvals.to_be_done,
    approvals.what_is_done,
    approvals.review_advice,
    approvals.details,
    oe.entity_id AS org_entity_id,
    oe.entity_name AS org_entity_name,
    oe.user_name AS org_user_name,
    oe.primary_email AS org_primary_email,
    entitys.entity_id,
    entitys.entity_name,
    entitys.user_name,
    entitys.primary_email
   FROM ((((public.vw_workflow_phases
     JOIN public.approvals ON ((vw_workflow_phases.workflow_phase_id = approvals.workflow_phase_id)))
     JOIN public.entitys oe ON ((approvals.org_entity_id = oe.entity_id)))
     JOIN public.reporting ON (((approvals.org_entity_id = reporting.entity_id) AND (vw_workflow_phases.reporting_level = reporting.reporting_level))))
     JOIN public.entitys ON ((reporting.report_to_id = entitys.entity_id)))
  WHERE ((approvals.forward_id IS NULL) AND (reporting.primary_report = true) AND (reporting.is_active = true) AND (vw_workflow_phases.use_reporting = true));


ALTER TABLE public.vw_approvals_entitys OWNER TO postgres;

--
-- Name: vw_books; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_books AS
 SELECT book_category.book_category_id,
    books.org_id,
    book_category.book_category_name,
    book_status.book_status_id,
    book_status.book_status_name,
    books.book_id,
    books.isbn,
    books.book_title,
    publishers.publisher_name,
    publishers.publisher_address,
    books.book_edition,
    books.author,
    books.is_borrowed,
    books.details
   FROM (((public.books
     JOIN public.book_category ON ((books.book_category_id = book_category.book_category_id)))
     JOIN public.book_status ON ((books.book_status_id = book_status.book_status_id)))
     LEFT JOIN public.publishers ON ((books.publisher_id = publishers.publisher_id)));


ALTER TABLE public.vw_books OWNER TO postgres;

--
-- Name: vw_books_issuance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_books_issuance AS
 SELECT vw_books.book_id,
    vw_books.book_category_name,
    vw_books.book_status_name,
    vw_books.book_title,
    vw_books.isbn,
    vw_books.is_borrowed,
    books_issuance.org_id,
    entitys.entity_id,
    entitys.entity_name,
    entitys.entity_type_id,
    librarians.librarian_id,
    librarians.librarian_name,
    librarians.telno,
    librarians.email,
    librarians.is_active,
    books_issuance.books_issuance_id,
    books_issuance.loanee,
    books_issuance.issuance_date,
    books_issuance.return_date,
    books_issuance.days_exceeded,
    books_issuance.is_returned,
    books_issuance.return_condition,
    books_issuance.details,
        CASE
            WHEN (vw_books.is_borrowed = false) THEN 'Pending'::text
            ELSE 'Issued'::text
        END AS status
   FROM (((public.books_issuance
     JOIN public.vw_books ON ((books_issuance.book_id = vw_books.book_id)))
     JOIN public.entitys ON ((books_issuance.loanee = entitys.entity_id)))
     JOIN public.librarians ON ((books_issuance.librarian_id = librarians.librarian_id)));


ALTER TABLE public.vw_books_issuance OWNER TO postgres;

--
-- Name: vw_calendar_year; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_calendar_year AS
 SELECT calendar_year.calendar_year_id,
    calendar_year.calendar_year_name,
    calendar_year.org_id
   FROM public.calendar_year;


ALTER TABLE public.vw_calendar_year OWNER TO postgres;

--
-- Name: vw_current_periods; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_current_periods AS
 SELECT to_char(((date_trunc('Month'::text, month.month))::date)::timestamp with time zone, 'Month'::text) AS period,
    'process payroll for this month'::text AS narrative,
    0 AS org_id
   FROM generate_series(( SELECT ((to_char((CURRENT_DATE)::timestamp with time zone, 'YYYY'::text) || '-01-01'::text))::timestamp without time zone AS "timestamp"), ( SELECT ((to_char((CURRENT_DATE)::timestamp with time zone, 'YYYY'::text) || '-12-01'::text))::timestamp without time zone AS "timestamp"), '1 mon'::interval) month(month);


ALTER TABLE public.vw_current_periods OWNER TO postgres;

--
-- Name: vw_e_fields; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_e_fields AS
 SELECT orgs.org_id,
    orgs.org_name,
    et_fields.et_field_id,
    et_fields.et_field_name,
    et_fields.table_name,
    et_fields.table_link,
    e_fields.e_field_id,
    e_fields.table_code,
    e_fields.table_id,
    e_fields.e_field_value
   FROM ((public.e_fields
     JOIN public.orgs ON ((e_fields.org_id = orgs.org_id)))
     JOIN public.et_fields ON ((e_fields.et_field_id = et_fields.et_field_id)));


ALTER TABLE public.vw_e_fields OWNER TO postgres;

--
-- Name: vw_employees; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_employees AS
 SELECT bank_branch.bank_branch_id,
    bank_branch.bank_name,
    bank_branch.branch_name,
    employee_designations.employee_designation_id,
    employee_designations.employee_designation_name,
    employee_types.employee_type_id,
    employee_types.employee_type_name,
    payment_modes.payment_mode_id,
    payment_modes.payment_mode_name,
    employees.employee_id,
    employees.person_title,
    employees.surname,
    employees.first_name,
    employees.middle_name,
    (concat(employees.surname, ' ', employees.first_name, ' ', employees.middle_name))::character varying(120) AS employee_full_name,
    employees.employee_email,
    employees.date_of_birth,
        CASE
            WHEN ((employees.gender)::text = 'M'::text) THEN 'MALE'::text
            ELSE 'FEMALE'::text
        END AS gender,
    employees.phone,
        CASE
            WHEN ((employees.gender)::text = 'M'::text) THEN 'MARRIED'::text
            ELSE 'SINGLE'::text
        END AS marital_status,
    employees.appointment_date,
    employees.exit_date,
    employees.employment_terms,
    employees.identity_card,
    employees.basic_salary,
    employees.bank_account,
    employees.picture_file,
    employees.active,
    employees.language,
    employees.previous_sal_point,
    employees.current_sal_point,
    employees.halt_point,
    employees.field_of_study,
    employees.org_id
   FROM ((((public.employees
     JOIN public.bank_branch ON ((employees.bank_branch_id = bank_branch.bank_branch_id)))
     JOIN public.employee_designations ON ((employees.employee_designation_id = employee_designations.employee_designation_id)))
     JOIN public.employee_types ON ((employees.employee_type_id = employee_types.employee_type_id)))
     JOIN public.payment_modes ON ((employees.payment_mode_id = payment_modes.payment_mode_id)));


ALTER TABLE public.vw_employees OWNER TO postgres;

--
-- Name: vw_employee_month; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_employee_month AS
 SELECT vw_employees.bank_branch_id,
    vw_employees.bank_name,
    vw_employees.branch_name,
    vw_employees.employee_designation_id,
    vw_employees.employee_designation_name,
    vw_employees.employee_type_id,
    vw_employees.employee_type_name,
    vw_employees.payment_mode_id,
    vw_employees.payment_mode_name,
    vw_employees.employee_id,
    vw_employees.person_title,
    vw_employees.surname,
    vw_employees.first_name,
    vw_employees.middle_name,
    vw_employees.employee_full_name,
    vw_employees.employee_email,
    vw_employees.date_of_birth,
    vw_employees.gender,
    vw_employees.phone,
    vw_employees.marital_status,
    vw_employees.appointment_date,
    vw_employees.exit_date,
    vw_employees.employment_terms,
    vw_employees.identity_card,
    vw_employees.basic_salary,
    vw_employees.bank_account,
    vw_employees.picture_file,
    vw_employees.active,
    vw_employees.language,
    vw_employees.previous_sal_point,
    vw_employees.current_sal_point,
    vw_employees.halt_point,
    vw_employees.field_of_study,
    employee_month.employee_month_id,
    employee_month.employee_month,
    employee_month.is_disbursed,
    employee_month.disbursed_on,
    employee_month.is_paid,
    employee_month.doc_no,
    (vw_employees.basic_salary - employee_month.amount) AS unpaid,
    employee_month.amount,
    employee_month.details,
    employee_month.org_id
   FROM (public.employee_month
     JOIN public.vw_employees ON ((employee_month.employee_id = vw_employees.employee_id)));


ALTER TABLE public.vw_employee_month OWNER TO postgres;

--
-- Name: vw_entity_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entity_address AS
 SELECT vw_address.address_id,
    vw_address.address_name,
    vw_address.sys_country_id,
    vw_address.sys_country_name,
    vw_address.table_id,
    vw_address.table_name,
    vw_address.is_default,
    vw_address.post_office_box,
    vw_address.postal_code,
    vw_address.premises,
    vw_address.street,
    vw_address.town,
    vw_address.phone_number,
    vw_address.extension,
    vw_address.mobile,
    vw_address.fax,
    vw_address.email,
    vw_address.website
   FROM public.vw_address
  WHERE (((vw_address.table_name)::text = 'entitys'::text) AND (vw_address.is_default = true));


ALTER TABLE public.vw_entity_address OWNER TO postgres;

--
-- Name: vw_entity_orgs; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entity_orgs AS
 SELECT entitys.entity_id,
    entitys.entity_name,
    entitys.user_name,
    entitys.super_user,
    entitys.entity_leader,
    entitys.date_enroled,
    entitys.is_active,
    entitys.entity_password,
    entitys.first_password,
    entitys.function_role,
    entitys.use_key_id,
    entitys.primary_email,
    entitys.primary_telephone,
    orgs.org_id,
    orgs.org_name,
    orgs.org_full_name,
    entity_orgs.entity_org_id,
    entity_orgs.details
   FROM ((public.entity_orgs
     JOIN public.entitys ON ((entitys.entity_id = entity_orgs.entity_id)))
     JOIN public.orgs ON ((entity_orgs.org_id = orgs.org_id)));


ALTER TABLE public.vw_entity_orgs OWNER TO postgres;

--
-- Name: vw_entity_subscriptions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entity_subscriptions AS
 SELECT entity_types.entity_type_id,
    entity_types.entity_type_name,
    entitys.entity_id,
    entitys.entity_name,
    entity_subscriptions.entity_subscription_id,
    entity_subscriptions.org_id,
    entity_subscriptions.details
   FROM ((public.entity_subscriptions
     JOIN public.entity_types ON ((entity_subscriptions.entity_type_id = entity_types.entity_type_id)))
     JOIN public.entitys ON ((entity_subscriptions.entity_id = entitys.entity_id)));


ALTER TABLE public.vw_entity_subscriptions OWNER TO postgres;

--
-- Name: vw_entity_types; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entity_types AS
 SELECT use_keys.use_key_id,
    use_keys.use_key_name,
    use_keys.use_function,
    entity_types.entity_type_id,
    entity_types.org_id,
    entity_types.entity_type_name,
    entity_types.entity_role,
    entity_types.start_view,
    entity_types.group_email,
    entity_types.description,
    entity_types.details
   FROM (public.use_keys
     JOIN public.entity_types ON ((use_keys.use_key_id = entity_types.use_key_id)));


ALTER TABLE public.vw_entity_types OWNER TO postgres;

--
-- Name: vw_entity_values; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entity_values AS
 SELECT entitys.entity_id,
    entitys.entity_name,
    entity_fields.entity_field_id,
    entity_fields.entity_field_name,
    entity_values.org_id,
    entity_values.entity_value_id,
    entity_values.entity_value
   FROM ((public.entity_values
     JOIN public.entitys ON ((entity_values.entity_id = entitys.entity_id)))
     JOIN public.entity_fields ON ((entity_values.entity_field_id = entity_fields.entity_field_id)));


ALTER TABLE public.vw_entity_values OWNER TO postgres;

--
-- Name: vw_org_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_org_address AS
 SELECT vw_address.sys_country_id AS org_sys_country_id,
    vw_address.sys_country_name AS org_sys_country_name,
    vw_address.address_id AS org_address_id,
    vw_address.table_id AS org_table_id,
    vw_address.table_name AS org_table_name,
    vw_address.post_office_box AS org_post_office_box,
    vw_address.postal_code AS org_postal_code,
    vw_address.premises AS org_premises,
    vw_address.street AS org_street,
    vw_address.town AS org_town,
    vw_address.phone_number AS org_phone_number,
    vw_address.extension AS org_extension,
    vw_address.mobile AS org_mobile,
    vw_address.fax AS org_fax,
    vw_address.email AS org_email,
    vw_address.website AS org_website
   FROM public.vw_address
  WHERE (((vw_address.table_name)::text = 'orgs'::text) AND (vw_address.is_default = true));


ALTER TABLE public.vw_org_address OWNER TO postgres;

--
-- Name: vw_orgs; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_orgs AS
 SELECT orgs.org_id,
    orgs.org_name,
    orgs.is_default,
    orgs.is_active,
    orgs.logo,
    orgs.org_full_name,
    orgs.pin,
    orgs.pcc,
    orgs.details,
    currency.currency_id,
    currency.currency_name,
    currency.currency_symbol,
    vw_org_address.org_sys_country_id,
    vw_org_address.org_sys_country_name,
    vw_org_address.org_address_id,
    vw_org_address.org_table_name,
    vw_org_address.org_post_office_box,
    vw_org_address.org_postal_code,
    vw_org_address.org_premises,
    vw_org_address.org_street,
    vw_org_address.org_town,
    vw_org_address.org_phone_number,
    vw_org_address.org_extension,
    vw_org_address.org_mobile,
    vw_org_address.org_fax,
    vw_org_address.org_email,
    vw_org_address.org_website
   FROM ((public.orgs
     JOIN public.currency ON ((orgs.currency_id = currency.currency_id)))
     LEFT JOIN public.vw_org_address ON ((orgs.org_id = vw_org_address.org_table_id)));


ALTER TABLE public.vw_orgs OWNER TO postgres;

--
-- Name: vw_entitys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entitys AS
 SELECT vw_orgs.org_id,
    vw_orgs.org_name,
    vw_orgs.is_default AS org_is_default,
    vw_orgs.is_active AS org_is_active,
    vw_orgs.logo AS org_logo,
    vw_orgs.org_sys_country_id,
    vw_orgs.org_sys_country_name,
    vw_orgs.org_address_id,
    vw_orgs.org_table_name,
    vw_orgs.org_post_office_box,
    vw_orgs.org_postal_code,
    vw_orgs.org_premises,
    vw_orgs.org_street,
    vw_orgs.org_town,
    vw_orgs.org_phone_number,
    vw_orgs.org_extension,
    vw_orgs.org_mobile,
    vw_orgs.org_fax,
    vw_orgs.org_email,
    vw_orgs.org_website,
    vw_entity_address.address_id,
    vw_entity_address.address_name,
    vw_entity_address.sys_country_id,
    vw_entity_address.sys_country_name,
    vw_entity_address.table_name,
    vw_entity_address.is_default,
    vw_entity_address.post_office_box,
    vw_entity_address.postal_code,
    vw_entity_address.premises,
    vw_entity_address.street,
    vw_entity_address.town,
    vw_entity_address.phone_number,
    vw_entity_address.extension,
    vw_entity_address.mobile,
    vw_entity_address.fax,
    vw_entity_address.email,
    vw_entity_address.website,
    entity_types.entity_type_id,
    entity_types.entity_type_name,
    entity_types.entity_role,
    entitys.entity_id,
    entitys.entity_name,
    entitys.user_name,
    entitys.super_user,
    entitys.entity_leader,
    entitys.date_enroled,
    entitys.is_active,
    entitys.entity_password,
    entitys.first_password,
    entitys.function_role,
    entitys.use_key_id,
    entitys.primary_email,
    entitys.primary_telephone
   FROM (((public.entitys
     LEFT JOIN public.vw_entity_address ON ((entitys.entity_id = vw_entity_address.table_id)))
     JOIN public.vw_orgs ON ((entitys.org_id = vw_orgs.org_id)))
     JOIN public.entity_types ON ((entitys.entity_type_id = entity_types.entity_type_id)));


ALTER TABLE public.vw_entitys OWNER TO postgres;

--
-- Name: vw_entry_forms; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_entry_forms AS
 SELECT entitys.entity_id,
    entitys.entity_name,
    forms.form_id,
    forms.form_name,
    forms.form_number,
    forms.completed,
    forms.is_active,
    forms.use_key,
    entry_forms.org_id,
    entry_forms.entry_form_id,
    entry_forms.approve_status,
    entry_forms.application_date,
    entry_forms.completion_date,
    entry_forms.action_date,
    entry_forms.narrative,
    entry_forms.answer,
    entry_forms.workflow_table_id,
    entry_forms.details
   FROM ((public.entry_forms
     JOIN public.entitys ON ((entry_forms.entity_id = entitys.entity_id)))
     JOIN public.forms ON ((entry_forms.form_id = forms.form_id)));


ALTER TABLE public.vw_entry_forms OWNER TO postgres;

--
-- Name: vw_students; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_students AS
 SELECT class_levels.class_level_id,
    class_levels.class_level_name,
    streams.stream_id,
    streams.stream_name,
    students.org_id,
    students.student_id,
    students.admission_no,
    students.first_name,
    students.second_name,
    concat(class_levels.class_level_name, ' ', streams.stream_name) AS class_name,
    students.surname,
    concat(students.surname, ' ', students.second_name, ' ', students.first_name) AS student_name,
        CASE
            WHEN ((students.gender)::text = 'M'::text) THEN 'MALE'::text
            ELSE 'FEMALE'::text
        END AS gender,
    students.address,
    students.dob,
    students.fname,
    students.mname,
    students.mphone_no,
    students.fphone_no,
    students.is_suspended,
    students.is_active,
    students.details,
    students.picture_file
   FROM ((public.students
     JOIN public.class_levels ON ((students.class_level_id = class_levels.class_level_id)))
     JOIN public.streams ON ((students.stream_id = streams.stream_id)));


ALTER TABLE public.vw_students OWNER TO postgres;

--
-- Name: vw_fee_payments; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fee_payments AS
 SELECT accountants.accountant_id,
    accountants.accountant_name,
    payment_modes.payment_mode_id,
    payment_modes.payment_mode_name,
    school_terms.school_term_id,
    school_terms.school_term_name,
    vw_students.student_id,
    vw_students.student_name,
    concat(vw_students.class_level_name, vw_students.stream_name) AS class_name,
    fee_payments.org_id,
    fee_payments.fee_payment_id,
    fee_payments.invoice_no,
    fee_payments.doc_no,
    fee_payments.school_year,
    fee_payments.amount,
    fee_payments.payed_by,
    fee_payments.date_payed,
    fee_payments.details
   FROM ((((public.fee_payments
     LEFT JOIN public.accountants ON ((fee_payments.accountant_id = accountants.accountant_id)))
     JOIN public.payment_modes ON ((fee_payments.payment_mode_id = payment_modes.payment_mode_id)))
     JOIN public.school_terms ON ((fee_payments.school_term_id = school_terms.school_term_id)))
     JOIN public.vw_students ON ((fee_payments.student_id = vw_students.student_id)));


ALTER TABLE public.vw_fee_payments OWNER TO postgres;

--
-- Name: vw_fees_structure; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fees_structure AS
 SELECT class_levels.class_level_id,
    class_levels.class_level_name,
    school_terms.school_term_id,
    school_terms.school_term_name,
    fees_structure.fees_structure_id,
    fees_structure.org_id,
    calendar_year.calendar_year_id,
    calendar_year.calendar_year_name,
    fees_structure.is_current,
    fees_structure.details
   FROM (((public.fees_structure
     JOIN public.calendar_year ON ((fees_structure.calendar_year_id = calendar_year.calendar_year_id)))
     JOIN public.class_levels ON ((fees_structure.class_level_id = class_levels.class_level_id)))
     JOIN public.school_terms ON ((fees_structure.school_term_id = school_terms.school_term_id)));


ALTER TABLE public.vw_fees_structure OWNER TO postgres;

--
-- Name: vw_fees_structure_vote_heads; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fees_structure_vote_heads AS
 SELECT vw_fees_structure.class_level_id,
    vw_fees_structure.class_level_name,
    vw_fees_structure.school_term_id,
    vw_fees_structure.school_term_name,
    vw_fees_structure.fees_structure_id,
    vw_fees_structure.org_id,
    vw_fees_structure.is_current,
    vw_fees_structure.calendar_year_id,
    vw_fees_structure.calendar_year_name,
    vote_heads.vote_head_id,
    vote_heads.vote_head_name,
    fees_structure_vote_heads.fees_structure_vote_head_id,
    fees_structure_vote_heads.amount
   FROM ((public.fees_structure_vote_heads
     JOIN public.vw_fees_structure ON ((fees_structure_vote_heads.fees_structure_id = vw_fees_structure.fees_structure_id)))
     JOIN public.vote_heads ON ((fees_structure_vote_heads.vote_head_id = vote_heads.vote_head_id)));


ALTER TABLE public.vw_fees_structure_vote_heads OWNER TO postgres;

--
-- Name: vw_fee_structure_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fee_structure_summary AS
 SELECT vw_fees_structure_vote_heads.fees_structure_id,
    vw_fees_structure_vote_heads.class_level_name,
    vw_fees_structure_vote_heads.school_term_name,
    sum(vw_fees_structure_vote_heads.amount) AS total_fees,
    vw_fees_structure_vote_heads.is_current,
    vw_fees_structure_vote_heads.org_id,
    vw_fees_structure_vote_heads.calendar_year_name,
    vw_fees_structure_vote_heads.calendar_year_id
   FROM public.vw_fees_structure_vote_heads
  GROUP BY vw_fees_structure_vote_heads.fees_structure_id, vw_fees_structure_vote_heads.class_level_name, vw_fees_structure_vote_heads.school_term_name, vw_fees_structure_vote_heads.is_current, vw_fees_structure_vote_heads.org_id, vw_fees_structure_vote_heads.calendar_year_name, vw_fees_structure_vote_heads.calendar_year_id
  ORDER BY vw_fees_structure_vote_heads.fees_structure_id;


ALTER TABLE public.vw_fee_structure_summary OWNER TO postgres;

--
-- Name: vw_fields; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fields AS
 SELECT forms.form_id,
    forms.form_name,
    fields.field_id,
    fields.org_id,
    fields.question,
    fields.field_lookup,
    fields.field_type,
    fields.field_order,
    fields.share_line,
    fields.field_size,
    fields.field_fnct,
    fields.manditory,
    fields.field_bold,
    fields.field_italics
   FROM (public.fields
     JOIN public.forms ON ((fields.form_id = forms.form_id)));


ALTER TABLE public.vw_fields OWNER TO postgres;

--
-- Name: vw_librarians; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_librarians AS
 SELECT librarians.librarian_id,
    librarians.org_id,
    librarians.librarian_name,
    librarians.telno,
        CASE
            WHEN ((librarians.gender)::text = 'M'::text) THEN 'MALE'::text
            ELSE 'FEMALE'::text
        END AS gender,
    librarians.email,
    librarians.is_active,
    librarians.details
   FROM public.librarians;


ALTER TABLE public.vw_librarians OWNER TO postgres;

--
-- Name: vw_org_select; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_org_select AS
 SELECT orgs.org_id,
    orgs.parent_org_id,
    orgs.org_name
   FROM public.orgs
  WHERE ((orgs.is_active = true) AND (orgs.org_id <> orgs.parent_org_id))
UNION
 SELECT orgs.org_id,
    orgs.org_id AS parent_org_id,
    orgs.org_name
   FROM public.orgs
  WHERE (orgs.is_active = true);


ALTER TABLE public.vw_org_select OWNER TO postgres;

--
-- Name: vw_reporting; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_reporting AS
 SELECT entitys.entity_id,
    entitys.entity_name,
    rpt.entity_id AS rpt_id,
    rpt.entity_name AS rpt_name,
    reporting.org_id,
    reporting.reporting_id,
    reporting.date_from,
    reporting.date_to,
    reporting.primary_report,
    reporting.is_active,
    reporting.ps_reporting,
    reporting.reporting_level,
    reporting.details
   FROM ((public.reporting
     JOIN public.entitys ON ((reporting.entity_id = entitys.entity_id)))
     JOIN public.entitys rpt ON ((reporting.report_to_id = rpt.entity_id)));


ALTER TABLE public.vw_reporting OWNER TO postgres;

--
-- Name: vw_school_calendar; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_school_calendar AS
 SELECT school_terms.school_term_id,
    school_terms.school_term_name,
    school_calendar.school_calendar_id,
    school_calendar.org_id,
    school_calendar.school_calendar_name,
    school_calendar.start_date,
    school_calendar.end_date,
    school_calendar.school_year,
    school_calendar.details,
    school_calendar.is_current,
    calendar_year.calendar_year_name,
    calendar_year.calendar_year_id
   FROM ((public.school_calendar
     JOIN public.school_terms ON ((school_calendar.school_term_id = school_terms.school_term_id)))
     JOIN public.calendar_year ON ((school_calendar.calendar_year_id = school_calendar.calendar_year_id)));


ALTER TABLE public.vw_school_calendar OWNER TO postgres;

--
-- Name: vw_student_fee_invoices; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_student_fee_invoices AS
 SELECT class_levels.class_level_id,
    class_levels.class_level_name,
    vw_fees_structure_vote_heads.school_term_id,
    vw_fees_structure_vote_heads.school_term_name,
    vw_fees_structure_vote_heads.calendar_year_id,
    vw_fees_structure_vote_heads.calendar_year_name,
    vw_fees_structure_vote_heads.vote_head_id,
    vw_fees_structure_vote_heads.vote_head_name,
    vw_fees_structure_vote_heads.amount,
    student_fee_invoices.student_fee_invoice_id,
    student_fee_invoices.fee_structure_id,
    vw_students.stream_id,
    vw_students.stream_name,
    vw_students.student_id,
    vw_students.admission_no,
    vw_students.first_name,
    vw_students.second_name,
    vw_students.class_name,
    vw_students.surname,
    vw_students.student_name,
    vw_students.gender,
    vw_students.address,
    vw_students.dob,
    vw_students.fname,
    vw_students.mname,
    vw_students.mphone_no,
    vw_students.fphone_no,
    vw_students.is_suspended,
    vw_students.is_active,
    vw_students.details,
    vw_students.picture_file
   FROM (((public.student_fee_invoices
     JOIN public.class_levels ON ((student_fee_invoices.class_level_id = class_levels.class_level_id)))
     JOIN public.vw_fees_structure_vote_heads ON ((student_fee_invoices.fee_structure_id = vw_fees_structure_vote_heads.fees_structure_id)))
     JOIN public.vw_students ON ((student_fee_invoices.student_id = vw_students.student_id)));


ALTER TABLE public.vw_student_fee_invoices OWNER TO postgres;

--
-- Name: vw_sub_fields; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sub_fields AS
 SELECT vw_fields.form_id,
    vw_fields.form_name,
    vw_fields.field_id,
    sub_fields.sub_field_id,
    sub_fields.org_id,
    sub_fields.sub_field_order,
    sub_fields.sub_title_share,
    sub_fields.sub_field_type,
    sub_fields.sub_field_lookup,
    sub_fields.sub_field_size,
    sub_fields.sub_col_spans,
    sub_fields.manditory,
    sub_fields.question
   FROM (public.sub_fields
     JOIN public.vw_fields ON ((sub_fields.field_id = vw_fields.field_id)));


ALTER TABLE public.vw_sub_fields OWNER TO postgres;

--
-- Name: vw_sys_access_entitys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sys_access_entitys AS
 SELECT sys_access_levels.sys_access_level_id,
    sys_access_levels.use_key_id,
    sys_access_levels.sys_access_level_name,
    sys_access_levels.access_tag,
    entitys.entity_id,
    entitys.entity_name,
    sys_access_entitys.org_id,
    sys_access_entitys.sys_access_entity_id,
    sys_access_entitys.narrative
   FROM ((public.sys_access_entitys
     JOIN public.sys_access_levels ON ((sys_access_entitys.sys_access_level_id = sys_access_levels.sys_access_level_id)))
     JOIN public.entitys ON ((sys_access_entitys.entity_id = entitys.entity_id)));


ALTER TABLE public.vw_sys_access_entitys OWNER TO postgres;

--
-- Name: vw_sys_countrys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sys_countrys AS
 SELECT sys_continents.sys_continent_id,
    sys_continents.sys_continent_name,
    sys_countrys.sys_country_id,
    sys_countrys.sys_country_code,
    sys_countrys.sys_country_number,
    sys_countrys.sys_phone_code,
    sys_countrys.sys_country_name
   FROM (public.sys_continents
     JOIN public.sys_countrys ON ((sys_continents.sys_continent_id = sys_countrys.sys_continent_id)));


ALTER TABLE public.vw_sys_countrys OWNER TO postgres;

--
-- Name: vw_sys_emailed; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sys_emailed AS
 SELECT sys_emails.sys_email_id,
    sys_emails.org_id,
    sys_emails.sys_email_name,
    sys_emails.use_type,
    sys_emails.title,
    sys_emails.details,
    sys_emailed.sys_emailed_id,
    sys_emailed.table_id,
    sys_emailed.table_name,
    sys_emailed.email_type,
    sys_emailed.created,
    sys_emailed.emailed,
    sys_emailed.narrative
   FROM (public.sys_emails
     RIGHT JOIN public.sys_emailed ON ((sys_emails.sys_email_id = sys_emailed.sys_email_id)));


ALTER TABLE public.vw_sys_emailed OWNER TO postgres;

--
-- Name: vw_teachers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_teachers AS
 SELECT teachers.teacher_id,
    teachers.org_id,
    teachers.teacher_name,
    teachers.telno,
        CASE
            WHEN ((teachers.gender)::text = 'M'::text) THEN 'MALE'::text
            ELSE 'FEMALE'::text
        END AS gender,
    teachers.email,
    teachers.is_active,
    teachers.details
   FROM public.teachers;


ALTER TABLE public.vw_teachers OWNER TO postgres;

--
-- Name: vw_workflow_approvals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflow_approvals AS
 SELECT vw_approvals.org_id,
    vw_approvals.approval_id,
    vw_approvals.workflow_id,
    vw_approvals.workflow_name,
    vw_approvals.approve_email,
    vw_approvals.approve_file,
    vw_approvals.reject_file,
    vw_approvals.reject_email,
    vw_approvals.source_entity_id,
    vw_approvals.source_entity_name,
    vw_approvals.table_name,
    vw_approvals.table_id,
    vw_approvals.org_entity_id,
    vw_approvals.org_entity_name,
    vw_approvals.org_user_name,
    vw_approvals.org_primary_email,
    rt.rejected_count,
        CASE
            WHEN (rt.rejected_count IS NULL) THEN ((vw_approvals.workflow_name)::text || ' Approved'::text)
            ELSE ((vw_approvals.workflow_name)::text || ' declined'::text)
        END AS workflow_narrative
   FROM (public.vw_approvals
     LEFT JOIN ( SELECT approvals.table_id,
            count(approvals.approval_id) AS rejected_count
           FROM public.approvals
          WHERE (((approvals.approve_status)::text = 'Rejected'::text) AND (approvals.forward_id IS NULL))
          GROUP BY approvals.table_id) rt ON ((vw_approvals.table_id = rt.table_id)))
  GROUP BY vw_approvals.org_id, vw_approvals.approval_id, vw_approvals.workflow_id, vw_approvals.workflow_name, vw_approvals.approve_email, vw_approvals.approve_file, vw_approvals.reject_file, vw_approvals.reject_email, vw_approvals.source_entity_id, vw_approvals.source_entity_name, vw_approvals.table_name, vw_approvals.table_id, vw_approvals.org_entity_id, vw_approvals.org_entity_name, vw_approvals.org_user_name, vw_approvals.org_primary_email, rt.rejected_count;


ALTER TABLE public.vw_workflow_approvals OWNER TO postgres;

--
-- Name: vw_workflow_entitys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflow_entitys AS
 SELECT vw_workflow_phases.workflow_id,
    vw_workflow_phases.org_id,
    vw_workflow_phases.workflow_name,
    vw_workflow_phases.table_name,
    vw_workflow_phases.table_link_id,
    vw_workflow_phases.source_entity_id,
    vw_workflow_phases.source_entity_name,
    vw_workflow_phases.approve_file,
    vw_workflow_phases.reject_file,
    vw_workflow_phases.approval_entity_id,
    vw_workflow_phases.approval_entity_name,
    vw_workflow_phases.workflow_phase_id,
    vw_workflow_phases.approval_level,
    vw_workflow_phases.return_level,
    vw_workflow_phases.escalation_days,
    vw_workflow_phases.escalation_hours,
    vw_workflow_phases.notice,
    vw_workflow_phases.notice_email,
    vw_workflow_phases.notice_file,
    vw_workflow_phases.advice,
    vw_workflow_phases.advice_email,
    vw_workflow_phases.advice_file,
    vw_workflow_phases.required_approvals,
    vw_workflow_phases.use_reporting,
    vw_workflow_phases.phase_narrative,
    entity_subscriptions.entity_subscription_id,
    entity_subscriptions.entity_id
   FROM (public.vw_workflow_phases
     JOIN public.entity_subscriptions ON ((vw_workflow_phases.source_entity_id = entity_subscriptions.entity_type_id)));


ALTER TABLE public.vw_workflow_entitys OWNER TO postgres;

--
-- Name: workflow_sql; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_sql (
    workflow_sql_id integer NOT NULL,
    workflow_phase_id integer NOT NULL,
    org_id integer,
    workflow_sql_name character varying(50),
    is_condition boolean DEFAULT false,
    is_action boolean DEFAULT false,
    message text NOT NULL,
    sql text NOT NULL
);


ALTER TABLE public.workflow_sql OWNER TO postgres;

--
-- Name: vw_workflow_sql; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflow_sql AS
 SELECT workflow_sql.org_id,
    workflow_sql.workflow_sql_id,
    workflow_sql.workflow_phase_id,
    workflow_sql.workflow_sql_name,
    workflow_sql.is_condition,
    workflow_sql.is_action,
    workflow_sql.message,
    workflow_sql.sql,
    approvals.approval_id,
    approvals.org_entity_id,
    approvals.app_entity_id,
    approvals.approval_level,
    approvals.escalation_days,
    approvals.escalation_hours,
    approvals.escalation_time,
    approvals.forward_id,
    approvals.table_name,
    approvals.table_id,
    approvals.application_date,
    approvals.completion_date,
    approvals.action_date,
    approvals.approve_status,
    approvals.approval_narrative
   FROM (public.workflow_sql
     JOIN public.approvals ON ((workflow_sql.workflow_phase_id = approvals.workflow_phase_id)));


ALTER TABLE public.vw_workflow_sql OWNER TO postgres;

--
-- Name: workflow_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_logs (
    workflow_log_id integer NOT NULL,
    org_id integer,
    table_name character varying(64),
    table_id integer,
    table_old_id integer
);


ALTER TABLE public.workflow_logs OWNER TO postgres;

--
-- Name: workflow_logs_workflow_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_logs_workflow_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflow_logs_workflow_log_id_seq OWNER TO postgres;

--
-- Name: workflow_logs_workflow_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_logs_workflow_log_id_seq OWNED BY public.workflow_logs.workflow_log_id;


--
-- Name: workflow_phases_workflow_phase_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_phases_workflow_phase_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflow_phases_workflow_phase_id_seq OWNER TO postgres;

--
-- Name: workflow_phases_workflow_phase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_phases_workflow_phase_id_seq OWNED BY public.workflow_phases.workflow_phase_id;


--
-- Name: workflow_sql_workflow_sql_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_sql_workflow_sql_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflow_sql_workflow_sql_id_seq OWNER TO postgres;

--
-- Name: workflow_sql_workflow_sql_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_sql_workflow_sql_id_seq OWNED BY public.workflow_sql.workflow_sql_id;


--
-- Name: workflow_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflow_table_id_seq OWNER TO postgres;

--
-- Name: workflows_workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflows_workflow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflows_workflow_id_seq OWNER TO postgres;

--
-- Name: workflows_workflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflows_workflow_id_seq OWNED BY public.workflows.workflow_id;


--
-- Name: accountants accountant_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accountants ALTER COLUMN accountant_id SET DEFAULT nextval('public.accountants_accountant_id_seq'::regclass);


--
-- Name: address address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN address_id SET DEFAULT nextval('public.address_address_id_seq'::regclass);


--
-- Name: address_types address_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address_types ALTER COLUMN address_type_id SET DEFAULT nextval('public.address_types_address_type_id_seq'::regclass);


--
-- Name: approval_checklists approval_checklist_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_checklists ALTER COLUMN approval_checklist_id SET DEFAULT nextval('public.approval_checklists_approval_checklist_id_seq'::regclass);


--
-- Name: approvals approval_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals ALTER COLUMN approval_id SET DEFAULT nextval('public.approvals_approval_id_seq'::regclass);


--
-- Name: bank_branch bank_branch_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_branch ALTER COLUMN bank_branch_id SET DEFAULT nextval('public.bank_branch_bank_branch_id_seq'::regclass);


--
-- Name: book_category book_category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_category ALTER COLUMN book_category_id SET DEFAULT nextval('public.book_category_book_category_id_seq'::regclass);


--
-- Name: book_status book_status_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_status ALTER COLUMN book_status_id SET DEFAULT nextval('public.book_status_book_status_id_seq'::regclass);


--
-- Name: books book_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books ALTER COLUMN book_id SET DEFAULT nextval('public.books_book_id_seq'::regclass);


--
-- Name: books_issuance books_issuance_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance ALTER COLUMN books_issuance_id SET DEFAULT nextval('public.books_issuance_books_issuance_id_seq'::regclass);


--
-- Name: calendar_year calendar_year_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_year ALTER COLUMN calendar_year_id SET DEFAULT nextval('public.calendar_year_calendar_year_id_seq'::regclass);


--
-- Name: checklists checklist_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklists ALTER COLUMN checklist_id SET DEFAULT nextval('public.checklists_checklist_id_seq'::regclass);


--
-- Name: class_levels class_level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_levels ALTER COLUMN class_level_id SET DEFAULT nextval('public.class_levels_class_level_id_seq'::regclass);


--
-- Name: currency currency_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency ALTER COLUMN currency_id SET DEFAULT nextval('public.currency_currency_id_seq'::regclass);


--
-- Name: currency_rates currency_rate_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency_rates ALTER COLUMN currency_rate_id SET DEFAULT nextval('public.currency_rates_currency_rate_id_seq'::regclass);


--
-- Name: e_fields e_field_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_fields ALTER COLUMN e_field_id SET DEFAULT nextval('public.e_fields_e_field_id_seq'::regclass);


--
-- Name: employee_designations employee_designation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_designations ALTER COLUMN employee_designation_id SET DEFAULT nextval('public.employee_designations_employee_designation_id_seq'::regclass);


--
-- Name: employee_month employee_month_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_month ALTER COLUMN employee_month_id SET DEFAULT nextval('public.employee_month_employee_month_id_seq'::regclass);


--
-- Name: employee_types employee_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_types ALTER COLUMN employee_type_id SET DEFAULT nextval('public.employee_types_employee_type_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: entity_fields entity_field_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_fields ALTER COLUMN entity_field_id SET DEFAULT nextval('public.entity_fields_entity_field_id_seq'::regclass);


--
-- Name: entity_orgs entity_org_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_orgs ALTER COLUMN entity_org_id SET DEFAULT nextval('public.entity_orgs_entity_org_id_seq'::regclass);


--
-- Name: entity_reset entity_reset_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_reset ALTER COLUMN entity_reset_id SET DEFAULT nextval('public.entity_reset_entity_reset_id_seq'::regclass);


--
-- Name: entity_subscriptions entity_subscription_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions ALTER COLUMN entity_subscription_id SET DEFAULT nextval('public.entity_subscriptions_entity_subscription_id_seq'::regclass);


--
-- Name: entity_types entity_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types ALTER COLUMN entity_type_id SET DEFAULT nextval('public.entity_types_entity_type_id_seq'::regclass);


--
-- Name: entity_values entity_value_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values ALTER COLUMN entity_value_id SET DEFAULT nextval('public.entity_values_entity_value_id_seq'::regclass);


--
-- Name: entitys entity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys ALTER COLUMN entity_id SET DEFAULT nextval('public.entitys_entity_id_seq'::regclass);


--
-- Name: entry_forms entry_form_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms ALTER COLUMN entry_form_id SET DEFAULT nextval('public.entry_forms_entry_form_id_seq'::regclass);


--
-- Name: et_fields et_field_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.et_fields ALTER COLUMN et_field_id SET DEFAULT nextval('public.et_fields_et_field_id_seq'::regclass);


--
-- Name: fee_payments fee_payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments ALTER COLUMN fee_payment_id SET DEFAULT nextval('public.fee_payments_fee_payment_id_seq'::regclass);


--
-- Name: fees_structure fees_structure_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure ALTER COLUMN fees_structure_id SET DEFAULT nextval('public.fees_structure_fees_structure_id_seq'::regclass);


--
-- Name: fees_structure_vote_heads fees_structure_vote_head_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure_vote_heads ALTER COLUMN fees_structure_vote_head_id SET DEFAULT nextval('public.fees_structure_vote_heads_fees_structure_vote_head_id_seq'::regclass);


--
-- Name: fields field_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields ALTER COLUMN field_id SET DEFAULT nextval('public.fields_field_id_seq'::regclass);


--
-- Name: forms form_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forms ALTER COLUMN form_id SET DEFAULT nextval('public.forms_form_id_seq'::regclass);


--
-- Name: librarians librarian_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians ALTER COLUMN librarian_id SET DEFAULT nextval('public.librarians_librarian_id_seq'::regclass);


--
-- Name: orgs org_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs ALTER COLUMN org_id SET DEFAULT nextval('public.orgs_org_id_seq'::regclass);


--
-- Name: payment_methods payment_method_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN payment_method_id SET DEFAULT nextval('public.payment_methods_payment_method_id_seq'::regclass);


--
-- Name: payment_modes payment_mode_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_modes ALTER COLUMN payment_mode_id SET DEFAULT nextval('public.payment_modes_payment_mode_id_seq'::regclass);


--
-- Name: publishers publisher_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishers ALTER COLUMN publisher_id SET DEFAULT nextval('public.publishers_publisher_id_seq'::regclass);


--
-- Name: reporting reporting_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting ALTER COLUMN reporting_id SET DEFAULT nextval('public.reporting_reporting_id_seq'::regclass);


--
-- Name: school_calendar school_calendar_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar ALTER COLUMN school_calendar_id SET DEFAULT nextval('public.school_calendar_school_calendar_id_seq'::regclass);


--
-- Name: school_terms school_term_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_terms ALTER COLUMN school_term_id SET DEFAULT nextval('public.school_terms_school_term_id_seq'::regclass);


--
-- Name: streams stream_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.streams ALTER COLUMN stream_id SET DEFAULT nextval('public.streams_stream_id_seq'::regclass);


--
-- Name: student_fee_invoices student_fee_invoice_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices ALTER COLUMN student_fee_invoice_id SET DEFAULT nextval('public.student_fee_invoices_student_fee_invoice_id_seq'::regclass);


--
-- Name: students student_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN student_id SET DEFAULT nextval('public.students_student_id_seq'::regclass);


--
-- Name: sub_fields sub_field_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_fields ALTER COLUMN sub_field_id SET DEFAULT nextval('public.sub_fields_sub_field_id_seq'::regclass);


--
-- Name: sys_access_entitys sys_access_entity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys ALTER COLUMN sys_access_entity_id SET DEFAULT nextval('public.sys_access_entitys_sys_access_entity_id_seq'::regclass);


--
-- Name: sys_access_levels sys_access_level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels ALTER COLUMN sys_access_level_id SET DEFAULT nextval('public.sys_access_levels_sys_access_level_id_seq'::regclass);


--
-- Name: sys_apps sys_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_apps ALTER COLUMN sys_app_id SET DEFAULT nextval('public.sys_apps_sys_app_id_seq'::regclass);


--
-- Name: sys_audit_trail sys_audit_trail_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_audit_trail ALTER COLUMN sys_audit_trail_id SET DEFAULT nextval('public.sys_audit_trail_sys_audit_trail_id_seq'::regclass);


--
-- Name: sys_configs sys_config_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_configs ALTER COLUMN sys_config_id SET DEFAULT nextval('public.sys_configs_sys_config_id_seq'::regclass);


--
-- Name: sys_dashboard sys_dashboard_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_dashboard ALTER COLUMN sys_dashboard_id SET DEFAULT nextval('public.sys_dashboard_sys_dashboard_id_seq'::regclass);


--
-- Name: sys_emailed sys_emailed_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emailed ALTER COLUMN sys_emailed_id SET DEFAULT nextval('public.sys_emailed_sys_emailed_id_seq'::regclass);


--
-- Name: sys_emails sys_email_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emails ALTER COLUMN sys_email_id SET DEFAULT nextval('public.sys_emails_sys_email_id_seq'::regclass);


--
-- Name: sys_errors sys_error_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_errors ALTER COLUMN sys_error_id SET DEFAULT nextval('public.sys_errors_sys_error_id_seq'::regclass);


--
-- Name: sys_files sys_file_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_files ALTER COLUMN sys_file_id SET DEFAULT nextval('public.sys_files_sys_file_id_seq'::regclass);


--
-- Name: sys_languages sys_language_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_languages ALTER COLUMN sys_language_id SET DEFAULT nextval('public.sys_languages_sys_language_id_seq'::regclass);


--
-- Name: sys_logins sys_login_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_logins ALTER COLUMN sys_login_id SET DEFAULT nextval('public.sys_logins_sys_login_id_seq'::regclass);


--
-- Name: sys_menu_msg sys_menu_msg_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_menu_msg ALTER COLUMN sys_menu_msg_id SET DEFAULT nextval('public.sys_menu_msg_sys_menu_msg_id_seq'::regclass);


--
-- Name: sys_news sys_news_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_news ALTER COLUMN sys_news_id SET DEFAULT nextval('public.sys_news_sys_news_id_seq'::regclass);


--
-- Name: sys_queries sys_queries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_queries ALTER COLUMN sys_queries_id SET DEFAULT nextval('public.sys_queries_sys_queries_id_seq'::regclass);


--
-- Name: sys_reset sys_reset_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_reset ALTER COLUMN sys_reset_id SET DEFAULT nextval('public.sys_reset_sys_reset_id_seq'::regclass);


--
-- Name: sys_translations sys_translation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations ALTER COLUMN sys_translation_id SET DEFAULT nextval('public.sys_translations_sys_translation_id_seq'::regclass);


--
-- Name: teachers teacher_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers ALTER COLUMN teacher_id SET DEFAULT nextval('public.teachers_teacher_id_seq'::regclass);


--
-- Name: vote_heads vote_head_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vote_heads ALTER COLUMN vote_head_id SET DEFAULT nextval('public.vote_heads_vote_head_id_seq'::regclass);


--
-- Name: workflow_logs workflow_log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_logs ALTER COLUMN workflow_log_id SET DEFAULT nextval('public.workflow_logs_workflow_log_id_seq'::regclass);


--
-- Name: workflow_phases workflow_phase_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_phases ALTER COLUMN workflow_phase_id SET DEFAULT nextval('public.workflow_phases_workflow_phase_id_seq'::regclass);


--
-- Name: workflow_sql workflow_sql_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_sql ALTER COLUMN workflow_sql_id SET DEFAULT nextval('public.workflow_sql_workflow_sql_id_seq'::regclass);


--
-- Name: workflows workflow_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows ALTER COLUMN workflow_id SET DEFAULT nextval('public.workflows_workflow_id_seq'::regclass);


--
-- Data for Name: accountants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accountants (accountant_id, accountant_name, org_id, telno, gender, email, is_active, details) FROM stdin;
1	MARY OTIENO	0	0702771424	F	fchege22@gmail.com	t	\N
\.


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address (address_id, address_type_id, sys_country_id, org_id, address_name, table_name, table_id, post_office_box, postal_code, premises, street, town, phone_number, extension, mobile, fax, email, website, is_default, first_password, details) FROM stdin;
\.


--
-- Data for Name: address_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address_types (address_type_id, org_id, address_type_name) FROM stdin;
\.


--
-- Data for Name: approval_checklists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.approval_checklists (approval_checklist_id, approval_id, checklist_id, org_id, requirement, manditory, done, narrative) FROM stdin;
\.


--
-- Data for Name: approvals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.approvals (approval_id, workflow_phase_id, org_entity_id, app_entity_id, org_id, approval_level, escalation_days, escalation_hours, escalation_time, forward_id, table_name, table_id, application_date, completion_date, action_date, approve_status, approval_narrative, to_be_done, what_is_done, review_advice, details) FROM stdin;
\.


--
-- Data for Name: bank_branch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bank_branch (bank_branch_id, bank_name, org_id, branch_name, is_active, details) FROM stdin;
1	Equity	0	Homabay	t	\N
\.


--
-- Data for Name: book_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.book_category (book_category_id, book_category_name, org_id, details) FROM stdin;
1	KISWAHILI NOVELS	\N	\N
2	ENGLISH SET BOOKS	\N	\N
3	HISTORY REVISION BOOK	\N	\N
4	KISWAHILI REVISION BOOK	\N	\N
5	ENGLISH SET BOOKS	0	\N
\.


--
-- Data for Name: book_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.book_status (book_status_id, book_status_name, org_id, details) FROM stdin;
1	GOOD	\N	Book in good condition 
2	UNDER REPAIR	\N	Being repaired cannot be issued
3	MISPLACED	\N	Lost book
4	POOR 	0	\N
5	GOOD	0	\N
6	NEED REPAIR	0	\N
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.books (book_id, org_id, book_category_id, isbn, book_title, author, book_status_id, details, book_edition, publisher_id, is_borrowed) FROM stdin;
1	\N	3	0-7868-4907-X(pbk)	Peter and the star catchers	Dave Barry & Ridley Pearson	1	An English Novel 	1st	1	f
2	0	5	235GXXNY	AN ENEMY OF THE PEOPLE	JOHN RUGANDA	5	\N	1st	2	f
\.


--
-- Data for Name: books_issuance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.books_issuance (books_issuance_id, org_id, book_id, librarian_id, loanee, issuance_date, return_date, days_exceeded, is_returned, return_condition, details) FROM stdin;
2	0	2	0	4	2019-10-06	2019-10-26	\N	f	\N	\N
3	0	2	0	6	2019-10-09	2019-10-18	\N	f	\N	\N
\.


--
-- Data for Name: calendar_year; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calendar_year (calendar_year_id, org_id, calendar_year_name) FROM stdin;
1	0	2019
\.


--
-- Data for Name: checklists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checklists (checklist_id, workflow_phase_id, org_id, checklist_number, manditory, requirement, details) FROM stdin;
\.


--
-- Data for Name: class_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_levels (class_level_id, org_id, class_level_name, details) FROM stdin;
1	0	FORM 1	\N
2	0	FORM 2	\N
3	0	FORM 3	\N
4	0	FORM 4	\N
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.currency (currency_id, currency_name, currency_symbol, org_id) FROM stdin;
1	Kenya Shillings	KES	0
2	US Dollar	USD	0
3	British Pound	BPD	0
4	Euro	ERO	0
\.


--
-- Data for Name: currency_rates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.currency_rates (currency_rate_id, currency_id, org_id, exchange_date, exchange_rate) FROM stdin;
0	1	0	2019-09-19	1
\.


--
-- Data for Name: e_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.e_fields (e_field_id, et_field_id, org_id, table_code, table_id, e_field_value) FROM stdin;
\.


--
-- Data for Name: employee_designations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_designations (employee_designation_id, org_id, employee_designation_name, duties) FROM stdin;
1	0	COOK	Preparing Meals for students and Teachers
2	0	Librarian	Manage library
3	0	Teachers	\N
\.


--
-- Data for Name: employee_month; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_month (employee_month_id, employee_id, org_id, employee_month, is_disbursed, disbursed_on, is_paid, doc_no, details, amount) FROM stdin;
1	1	0	October  	t	2019-10-01 18:35:03.430857	t	1258963	\N	2000
\.


--
-- Data for Name: employee_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_types (employee_type_id, org_id, employee_type_name) FROM stdin;
1	0	CASUALS
2	0	BOG TEACHERS
3	0	PERMANENT
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (employee_id, employee_type_id, employee_designation_id, payment_mode_id, bank_branch_id, org_id, person_title, surname, first_name, middle_name, employee_full_name, employee_email, date_of_birth, gender, phone, marital_status, appointment_date, exit_date, employment_terms, identity_card, basic_salary, bank_account, picture_file, active, language, previous_sal_point, current_sal_point, halt_point, field_of_study) FROM stdin;
1	2	1	2	1	0	Mr	Otieno	James	 Kamau	\N	\N	2019-10-07	M	078978645	S	2019-10-23	\N	\N	29593816	16000	160000000	\N	t	\N	\N	\N	\N	\N
2	2	1	2	1	0	Mr	Katam	Ruth	Jepchirchir	\N	\N	2019-10-16	M	078978645	S	\N	\N	\N	456789	34000	0160000	\N	t	\N	\N	\N	\N	\N
\.


--
-- Data for Name: entity_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_fields (entity_field_id, org_id, use_type, is_active, entity_field_name, entity_field_source) FROM stdin;
\.


--
-- Data for Name: entity_orgs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_orgs (entity_org_id, entity_id, org_id, details) FROM stdin;
\.


--
-- Data for Name: entity_reset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_reset (entity_reset_id, entity_id, org_id, request_email, request_time, login_ip, phone_serial_number, narrative) FROM stdin;
\.


--
-- Data for Name: entity_subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_subscriptions (entity_subscription_id, entity_type_id, entity_id, org_id, details) FROM stdin;
1	0	0	0	\N
2	0	1	0	\N
4	1	3	0	\N
5	7	4	0	\N
6	1	5	0	\N
7	8	6	0	\N
8	9	7	0	\N
\.


--
-- Data for Name: entity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_types (entity_type_id, use_key_id, org_id, entity_type_name, entity_role, start_view, group_email, description, details) FROM stdin;
0	0	0	System Admins	sysadmin	\N	\N	\N	\N
1	1	0	Staff	staff	\N	\N	\N	\N
2	2	0	Client	client	\N	\N	\N	\N
3	3	0	Supplier	supplier	\N	\N	\N	\N
4	4	0	Applicant	applicant	10:0	\N	\N	\N
5	5	0	Subscription	subscription	\N	\N	\N	\N
6	6	0	User	user	\N	\N	\N	\N
7	7	0	students	student	\N	\N	\N	\N
8	8	0	teachers	teacher	\N	\N	\N	\N
9	9	0	non teaching staff	non teaching staff	\N	\N	\N	\N
\.


--
-- Data for Name: entity_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_values (entity_value_id, entity_id, entity_field_id, org_id, entity_value) FROM stdin;
\.


--
-- Data for Name: entitys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entitys (entity_id, entity_type_id, use_key_id, sys_language_id, org_id, entity_name, user_name, primary_email, primary_telephone, super_user, entity_leader, no_org, function_role, date_enroled, is_active, last_login, entity_password, first_password, new_password, start_url, is_picked, locked_until, details) FROM stdin;
1	0	0	0	0	repository	repository	repository@localhost	\N	f	t	f	\N	2019-09-19 09:29:12.395727	t	\N	b6f0038dfd42f8aa6ca25354cd2e3660	baraza	\N	\N	f	\N	\N
3	1	1	0	0	Willis Olando	willis@gmail.com	willis@gmail.com	0702771424	f	f	f	\N	2019-10-01 17:31:30.633567	t	\N	d4a41f643f4eb8c7d3fd6e6c3b70b171	449L191AA	\N	\N	f	\N	\N
4	7	7	0	0	OMOLO MERCY Odhiambo	OdhiamboMERCY			f	f	f	\N	2019-10-03 16:45:57.522634	t	\N	b80493d0730d8cb2dea2fee70a8eb138	474W46XK	\N	\N	f	\N	\N
5	1	1	0	0	JAMES ODONGO	fchege22@gmail.com	fchege22@gmail.com	0702771424	f	f	f	\N	2019-10-03 16:50:25.6682	t	\N	535d1e24151241efa58710a664b98f6e	97G961WL	\N	\N	f	\N	\N
6	8	8	0	0	James Waringo	James Waringo	James Waringo	0702771424	f	f	f	\N	2019-10-03 17:09:14.514884	t	\N	e082a82d131ff5b336532755f226d695	705F676NA	\N	\N	f	\N	\N
7	9	9	0	0	Mr Katam Ruth Jepchirchir	MrKatamRuthJepchirchir		078978645	f	f	f	\N	2019-10-03 17:18:04.148224	t	\N	abf256fdf316990a6e150a373162cddf	86I984ES	\N	\N	f	\N	\N
0	0	0	0	0	root	root	root@localhost	\N	t	t	f	\N	2019-09-19 09:29:12.395727	t	2019-10-07 07:31:59.059887	b6f0038dfd42f8aa6ca25354cd2e3660	baraza	\N	\N	f	\N	\N
\.


--
-- Data for Name: entry_forms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entry_forms (entry_form_id, org_id, entity_id, form_id, entered_by_id, application_date, completion_date, approve_status, workflow_table_id, action_date, narrative, answer, sub_answer, details) FROM stdin;
\.


--
-- Data for Name: et_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.et_fields (et_field_id, org_id, et_field_name, table_name, table_code, table_link, is_active) FROM stdin;
\.


--
-- Data for Name: fee_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fee_payments (fee_payment_id, org_id, school_term_id, student_id, accountant_id, invoice_no, doc_no, school_year, amount, payed_by, date_payed, details, payment_mode_id) FROM stdin;
1	0	1	2	1	\N	chq12345690	\N	10000	parent	2019-10-06	\N	2
\.


--
-- Data for Name: fees_structure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fees_structure (fees_structure_id, school_term_id, org_id, class_level_id, is_current, details, calendar_year_id) FROM stdin;
3	2	0	1	f	\N	1
\.


--
-- Data for Name: fees_structure_vote_heads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fees_structure_vote_heads (fees_structure_vote_head_id, org_id, fees_structure_id, vote_head_id, amount, details) FROM stdin;
5	0	3	2	12000	\N
6	0	3	1	6000	\N
\.


--
-- Data for Name: fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fields (field_id, org_id, form_id, field_name, question, field_lookup, field_type, field_class, field_bold, field_italics, field_order, share_line, field_size, label_position, field_fnct, manditory, show, tab, details) FROM stdin;
\.


--
-- Data for Name: forms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.forms (form_id, org_id, form_name, form_number, table_name, version, completed, is_active, use_key, form_header, form_footer, default_values, details) FROM stdin;
\.


--
-- Data for Name: librarians; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.librarians (librarian_id, librarian_name, org_id, telno, gender, email, is_active, details) FROM stdin;
4	Willis Olando	0	0702771424	F	willis@gmail.com	t	\N
0	JAMES ODONGO	0	0702771424	M	fchege22@gmail.com	t	\N
\.


--
-- Data for Name: orgs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orgs (org_id, currency_id, default_country_id, parent_org_id, org_name, org_full_name, org_sufix, is_default, is_active, department_filter, pin, pcc, logo, letter_head, email_from, web_logos, created, system_key, system_identifier, mac_address, public_key, license, details) FROM stdin;
0	1	\N	\N	default	\N	dc	t	t	f	\N	\N	logo.png	\N	\N	f	2019-09-19 09:29:12.395727	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_methods (payment_method_id, org_id, payment_method_name, doc_name, is_active, details) FROM stdin;
\.


--
-- Data for Name: payment_modes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_modes (payment_mode_id, payment_mode_name, org_id, is_active, details) FROM stdin;
1	cash	0	t	\N
2	Bank	0	t	\N
\.


--
-- Data for Name: publishers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publishers (publisher_id, org_id, publisher_name, publisher_address) FROM stdin;
1	\N	EAST AFRICAN PUBLISHERS	NAIROBI KENYA \r\nP.O.BOX 23456
2	0	EAST AFRICAN PUBLISHERS	\N
\.


--
-- Data for Name: reporting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting (reporting_id, entity_id, report_to_id, org_id, date_from, date_to, reporting_level, primary_report, is_active, ps_reporting, details) FROM stdin;
\.


--
-- Data for Name: school_calendar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.school_calendar (school_calendar_id, org_id, school_calendar_name, school_term_id, start_date, end_date, school_year, details, is_current, calendar_year_id) FROM stdin;
1	0	\N	1	2019-01-03	2018-03-08	\N	\N	t	\N
2	0	\N	1	2019-09-02	2019-09-12	\N	\N	f	1
3	0	\N	2	2019-11-05	2019-09-28	\N	\N	f	1
4	0	\N	3	2019-12-22	2019-12-31	\N	\N	f	1
\.


--
-- Data for Name: school_terms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.school_terms (school_term_id, org_id, school_term_name, details) FROM stdin;
1	0	TERM 1	\N
2	0	TERM 2	\N
3	0	TERM 3	\N
\.


--
-- Data for Name: select_yes_no; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.select_yes_no (select_id, select_state, select_value) FROM stdin;
0	f	No
1	t	Yes
\.


--
-- Data for Name: streams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.streams (stream_id, stream_name, org_id, is_active, details) FROM stdin;
1	EAST	0	t	\N
3	NORTH	0	t	\N
4	SOUTH	0	t	\N
2	WEST	0	t	\N
\.


--
-- Data for Name: student_fee_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_fee_invoices (student_fee_invoice_id, student_id, org_id, fee_structure_id, class_level_id) FROM stdin;
1	11	0	3	1
2	3	0	3	1
3	2	0	3	1
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (student_id, admission_no, org_id, first_name, second_name, surname, gender, address, dob, fname, mname, mphone_no, fphone_no, class_level_id, stream_id, is_suspended, is_active, details, picture_file) FROM stdin;
2	2389	0	Francis	Chege	Kamau	M	240-20300	1992-10-17	JOHN KAMAU	MARGRET WAMBUI	0702771424	0702771424	1	1	f	t	\N	\N
3	2345	0	Reagan	Odhiambo	Otieno	M	240-20300	2019-10-08	JOHN KAMAU	MARGRET WAMBUI	0702771424	0702771424	1	1	f	t	\N	\N
11	4567	0	MERCY	Odhiambo	OMOLO	M	240-20300	2019-10-17	JOHN KAMAU	MARGRET WAMBUI	0702771424	0702771424	1	1	f	f	\N	\N
\.


--
-- Data for Name: sub_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_fields (sub_field_id, org_id, field_id, sub_field_order, sub_title_share, sub_field_type, sub_field_lookup, sub_field_size, sub_col_spans, manditory, show, question) FROM stdin;
\.


--
-- Data for Name: sys_access_entitys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_access_entitys (sys_access_entity_id, sys_access_level_id, entity_id, org_id, narrative) FROM stdin;
\.


--
-- Data for Name: sys_access_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_access_levels (sys_access_level_id, use_key_id, sys_country_id, org_id, sys_access_level_name, access_tag, acess_details) FROM stdin;
\.


--
-- Data for Name: sys_apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_apps (sys_app_id, sys_app_name, details) FROM stdin;
0	Baraza Core	\N
1	HR	\N
2	Payroll	\N
3	Business	\N
4	Attendance	\N
5	Projects	\N
6	Banking	\N
7	Sacco	\N
8	Chama	\N
9	UMIS	\N
10	Judiciary	\N
11	Agency	\N
\.


--
-- Data for Name: sys_audit_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_audit_details (sys_audit_trail_id, old_value) FROM stdin;
\.


--
-- Data for Name: sys_audit_trail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_audit_trail (sys_audit_trail_id, user_id, user_ip, change_date, table_name, record_id, change_type, narrative) FROM stdin;
1	0	127.0.0.1	2019-09-21 16:14:13.343494	book_category	1	INSERT	\N
2	0	127.0.0.1	2019-09-21 16:14:28.864111	book_category	2	INSERT	\N
3	0	127.0.0.1	2019-09-21 16:14:42.941671	book_category	3	INSERT	\N
4	0	127.0.0.1	2019-09-21 16:15:02.076104	book_category	4	INSERT	\N
5	0	127.0.0.1	2019-09-21 16:17:50.00327	book_status	1	INSERT	\N
6	0	127.0.0.1	2019-09-21 16:18:25.993263	book_status	2	INSERT	\N
7	0	127.0.0.1	2019-09-21 16:18:49.604543	book_status	3	INSERT	\N
8	0	127.0.0.1	2019-09-21 16:45:28.908116	publishers	1	INSERT	\N
9	0	127.0.0.1	2019-09-21 16:47:59.535894	books	1	INSERT	\N
10	0	127.0.0.1	2019-09-23 22:45:20.308953	streams	1	INSERT	\N
11	0	127.0.0.1	2019-09-23 22:45:28.351156	streams	2	INSERT	\N
12	0	127.0.0.1	2019-09-23 22:45:38.817344	streams	3	INSERT	\N
13	0	127.0.0.1	2019-09-23 22:45:49.023676	streams	4	INSERT	\N
14	0	127.0.0.1	2019-09-23 22:45:58.583431	streams	2	EDIT	\N
15	0	127.0.0.1	2019-09-23 22:46:20.559273	class_levels	1	INSERT	\N
16	0	127.0.0.1	2019-09-23 22:46:28.915995	class_levels	2	INSERT	\N
17	0	127.0.0.1	2019-09-23 22:46:37.282028	class_levels	3	INSERT	\N
18	0	127.0.0.1	2019-09-23 22:46:46.629766	class_levels	4	INSERT	\N
19	0	127.0.0.1	2019-09-23 22:47:06.41228	school_terms	1	INSERT	\N
20	0	127.0.0.1	2019-09-23 22:47:17.53106	school_terms	2	INSERT	\N
21	0	127.0.0.1	2019-09-23 22:47:25.143536	school_terms	3	INSERT	\N
22	0	127.0.0.1	2019-09-23 22:49:00.86718	school_calendar	1	INSERT	\N
23	0	127.0.0.1	2019-09-25 21:01:29.84527	process_payroll	April    	FUNCTION	\N
24	0	127.0.0.1	2019-09-25 22:12:19.013446	calendar_year	1	INSERT	\N
25	0	127.0.0.1	2019-09-25 22:15:23.256741	school_calendar	2	INSERT	\N
26	0	127.0.0.1	2019-09-25 22:17:19.779742	school_calendar	3	INSERT	\N
27	0	127.0.0.1	2019-09-25 22:17:58.964273	school_calendar	4	INSERT	\N
28	0	127.0.0.1	2019-10-01 16:05:27.252027	students	1	INSERT	\N
29	0	127.0.0.1	2019-10-01 16:10:24.362101	students	2	INSERT	\N
30	0	127.0.0.1	2019-10-01 17:15:47.072745	librarians	1	INSERT	\N
31	0	127.0.0.1	2019-10-01 17:31:30.651035	librarians	4	INSERT	\N
32	0	127.0.0.1	2019-10-01 17:49:27.520152	employee_types	1	INSERT	\N
33	0	127.0.0.1	2019-10-01 17:49:41.848746	employee_types	2	INSERT	\N
34	0	127.0.0.1	2019-10-01 17:49:56.856698	employee_types	3	INSERT	\N
35	0	127.0.0.1	2019-10-01 17:50:34.629751	employee_designations	1	INSERT	\N
36	0	127.0.0.1	2019-10-01 17:50:52.164627	employee_designations	2	INSERT	\N
37	0	127.0.0.1	2019-10-01 17:51:00.347684	employee_designations	3	INSERT	\N
38	0	127.0.0.1	2019-10-01 17:51:14.190619	payment_modes	1	INSERT	\N
39	0	127.0.0.1	2019-10-01 17:51:28.272746	payment_modes	2	INSERT	\N
40	0	127.0.0.1	2019-10-01 17:52:27.60446	payment_modes	2	EDIT	\N
41	0	127.0.0.1	2019-10-01 17:52:48.443801	bank_branch	1	INSERT	\N
42	0	127.0.0.1	2019-10-01 18:18:44.029935	employees	1	INSERT	\N
43	0	127.0.0.1	2019-10-01 18:35:03.407867	process_payroll	October  	FUNCTION	\N
44	0	127.0.0.1	2019-10-01 20:52:20.210772	employee_month	1	EDIT	\N
45	0	127.0.0.1	2019-10-01 20:52:37.707138	employee_month	1	EDIT	\N
46	0	127.0.0.1	2019-10-01 20:52:59.9282	process_payment	1	FUNCTION	\N
47	0	127.0.0.1	2019-10-01 20:56:44.946728	process_payment	1	FUNCTION	\N
48	0	127.0.0.1	2019-10-01 20:57:13.878148	process_payment	1	FUNCTION	\N
49	0	127.0.0.1	2019-10-01 20:58:16.253104	process_payment	1	FUNCTION	\N
50	0	127.0.0.1	2019-10-01 21:00:10.561171	process_payment	1	FUNCTION	\N
51	0	127.0.0.1	2019-10-01 21:28:13.284255	accountants	1	INSERT	\N
52	0	127.0.0.1	2019-10-01 21:42:40.268304	letter_heads	1	INSERT	\N
53	0	127.0.0.1	2019-10-01 21:42:49.864866	letter_heads	2	INSERT	\N
54	0	127.0.0.1	2019-10-01 21:43:14.391075	letter_heads	3	INSERT	\N
55	0	127.0.0.1	2019-10-01 21:43:36.032856	letter_heads	4	INSERT	\N
56	0	127.0.0.1	2019-10-01 21:53:07.524504	vote_heads	1	INSERT	\N
57	0	127.0.0.1	2019-10-01 21:53:20.144832	vote_heads	2	INSERT	\N
58	0	127.0.0.1	2019-10-01 22:04:45.076074	fees_structure	1	INSERT	\N
59	0	127.0.0.1	2019-10-03 16:22:28.504048	book_category	5	INSERT	\N
60	0	127.0.0.1	2019-10-03 16:22:41.042162	book_status	4	INSERT	\N
61	0	127.0.0.1	2019-10-03 16:22:49.86712	book_status	5	INSERT	\N
62	0	127.0.0.1	2019-10-03 16:22:59.918116	book_status	6	INSERT	\N
63	0	127.0.0.1	2019-10-03 16:23:13.453971	publishers	2	INSERT	\N
64	0	127.0.0.1	2019-10-03 16:24:08.787022	books	2	INSERT	\N
65	0	127.0.0.1	2019-10-03 16:25:27.867165	books	2	EDIT	\N
66	0	127.0.0.1	2019-10-03 16:34:37.221707	students	3	INSERT	\N
67	0	127.0.0.1	2019-10-03 16:45:57.927661	students	11	INSERT	\N
68	0	127.0.0.1	2019-10-03 16:50:44.496333	books_issuance	2	INSERT	\N
69	0	127.0.0.1	2019-10-03 16:50:52.409297	issue_book	2	FUNCTION	\N
70	0	127.0.0.1	2019-10-03 16:51:38.280239	issue_book	2	FUNCTION	\N
71	0	127.0.0.1	2019-10-03 16:51:51.22799	mark_book_return	2	FUNCTION	\N
72	0	127.0.0.1	2019-10-03 16:52:44.000917	mark_book_return	2	FUNCTION	\N
73	0	127.0.0.1	2019-10-03 17:09:14.591418	teachers	1	INSERT	\N
74	0	127.0.0.1	2019-10-03 17:09:39.816878	books_issuance	3	INSERT	\N
75	0	127.0.0.1	2019-10-03 17:18:04.217917	employees	2	INSERT	\N
76	0	127.0.0.1	2019-10-03 17:22:03.04941	fees_structure	2	INSERT	\N
77	0	127.0.0.1	2019-10-03 17:41:14.298189	fees_structure	1	INSERT	\N
78	0	127.0.0.1	2019-10-03 17:41:22.96247	fees_structure_vote_heads	1	INSERT	\N
79	0	127.0.0.1	2019-10-06 21:23:29.489587	fees_structure_vote_heads	2	INSERT	\N
80	0	127.0.0.1	2019-10-06 21:59:01.876401	fees_structure	2	INSERT	\N
81	0	127.0.0.1	2019-10-06 21:59:14.38789	fees_structure_vote_heads	3	INSERT	\N
82	0	127.0.0.1	2019-10-06 21:59:24.913885	fees_structure_vote_heads	4	INSERT	\N
83	0	127.0.0.1	2019-10-06 22:05:25.095067	fees_structure	3	INSERT	\N
84	0	127.0.0.1	2019-10-06 22:05:36.738979	fees_structure_vote_heads	5	INSERT	\N
85	0	127.0.0.1	2019-10-06 22:05:45.908433	fees_structure_vote_heads	6	INSERT	\N
86	0	127.0.0.1	2019-10-06 22:45:56.307998	generate_fee_invoices	3	FUNCTION	\N
87	0	127.0.0.1	2019-10-06 23:22:48.368743	fee_payments	1	INSERT	\N
88	0	127.0.0.1	2019-10-06 23:26:41.239421	fee_payments	1	EDIT	\N
\.


--
-- Data for Name: sys_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_configs (sys_config_id, config_type_id, config_name, config_value) FROM stdin;
\.


--
-- Data for Name: sys_continents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_continents (sys_continent_id, sys_continent_name) FROM stdin;
AF	Africa
AS	Asia
EU	Europe
NA	North America
SA	South America
OC	Oceania
AN	Antarctica
\.


--
-- Data for Name: sys_countrys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_countrys (sys_country_id, sys_continent_id, sys_country_code, sys_country_name, sys_country_number, sys_country_capital, sys_phone_code, sys_currency_name, sys_currency_code, sys_currency_cents, sys_currency_exchange) FROM stdin;
AO	AF	AGO	Angola	024	Luanda	+244	kwanza	AOA	lwei	\N
BF	AF	BFA	Burkina Faso	854	Ouagadougou	+226	CFA franc	XOF	centime	\N
BI	AF	BDI	Burundi	108	Bujumbura	+257	Burundi franc	BIF	centime	\N
BJ	AF	BEN	Benin	204	Porto Novo13	+229	CFA franc	XOF	centime	\N
BW	AF	BWA	Botswana	072	Gaborone		pula	BWP	thebe	\N
CD	AF	COD	Democratic Republic of Congo	180	Kinshasa	+243	Congolese franc	CDF	centime	\N
CF	AF	CAF	Central African Republic	140	Bangui	+236	CFA franc	XAF	centime	\N
CG	AF	COG	Republic of Congo	178	Brazzaville	+242	CFA franc	XAF	centime	\N
CI	AF	CIV	Cote d Ivoire	384	Yamoussoukro30	+225	CFA franc	XOF	centime	\N
CM	AF	CMR	Cameroon	120	Yaoundé	+237	CFA franc	XAF	centime	\N
CV	AF	CPV	Cape Verde	132	Praia	+238	Cape Verde escudo	CVE	centavo	\N
DJ	AF	DJI	Djibouti	262	Djibouti	+253	Djibouti franc	DJF	centime	\N
DZ	AF	DZA	Algeria	012	Algiers	+213	Algerian dinar	DZD	centime	\N
EG	AF	EGY	Egypt	818	Cairo	+20	Egyptian pound	EGP	piastre	\N
EH	AF	ESH	Western Sahara	732	Al aaiun		Moroccan dirham	MAD	centime	\N
ER	AF	ERI	Eritrea	232	Asmara	+291	nakfa	ERN	centime	\N
ET	AF	ETH	Ethiopia	231	Addis Ababa	+251	Ethiopian birr	ETB	cent	\N
GA	AF	GAB	Gabon	266	Libreville	+241	CFA franc39	XAF	centime	\N
GH	AF	GHA	Ghana	288	Accra	+233	cedi	GHC	pesewa	\N
GM	AF	GMB	Gambia	270	Banjul	+220	dalasi	GMD	butut	\N
GN	AF	GIN	Guinea	324	Conakry	+224	Guinean franc	GNF	-	\N
GQ	AF	GNQ	Equatorial Guinea	226	Malabo	+240	CFA franc	XAF	centime	\N
GW	AF	GNB	Guinea-Bissau	624	Bissau	+245	CFA franc	XOF	centime	\N
KE	AF	KEN	Kenya	404	Nairobi	+254	Kenyan shilling	KES	cent	\N
KM	AF	COM	Comoros	174	Moroni	+269	Comorian franc	KMF	centime	\N
LR	AF	LBR	Liberia	430	Monrovia	+231	Liberian dollar	LRD	cent	\N
LS	AF	LSO	Lesotho	426	Maseru	+266	loti	LSL	sente	\N
LY	AF	LBY	Libyan Arab Jamahiriya	434	Tripoli	+218	Libyan dinar	LYD	dirham	\N
MA	AF	MAR	Morocco	504	Rabat	+212	Moroccan dirham	MAD	centime	\N
MG	AF	MDG	Madagascar	450	Antananarivo	+261	Malagasy franc	MGF	centime	\N
ML	AF	MLI	Mali	466	Bamako	+223	CFA franc47	XOF	centime	\N
MR	AF	MRT	Mauritania	478	Nouakchott	+222	Mauritanian ouguiya	MRO	khoum	\N
MU	AF	MUS	Mauritius	480	Port Louis	+230	Mauritian rupee	MUR	cent	\N
MW	AF	MWI	Malawi	454	Lilongwe	+265	Malawian kwacha	MWK	tambala	\N
MZ	AF	MOZ	Mozambique	508	Maputo	+258	metical	MZM	centavo	\N
NA	AF	NAM	Namibia	516	Windhoek	+264	Namibian dollar	NAD	cent	\N
NE	AF	NER	Niger	562	Niamey	+227	CFA franc	XOF	centime	\N
NG	AF	NGA	Nigeria	566	Abuja58	+234	naira	NGN	kobo	\N
RE	AF	REU	Reunion	638	Saint-Denis	+262	euro	EUR	cent	\N
RW	AF	RWA	Rwanda	646	Kigali	+250	Rwandese franc	RWF	centime	\N
SC	AF	SYC	Seychelles	690	Victoria	+248	Seychelles rupee	SCR	cent	\N
SD	AF	SDN	Sudan	736	Khartoum	+249	Sudanese dinar	SDD	piastre	\N
SH	AF	SHN	Saint Helena	654	Jamestown	+290	Saint Helena pound	SHP	penny	\N
SL	AF	SLE	Sierra Leone	694	Freetown	+232	leone	SLL	cent	\N
SN	AF	SEN	Senegal	686	Dakar	+221	CFA franc	XOF	centime	\N
SO	AF	SOM	Somalia	706	Mogadishu	+252	Somali shilling	SOS	cent	\N
SS	AF	SSN	South Sudan	737						\N
ST	AF	STP	Sao Tome and Principe	678	São Tomé	+239	dobra	STD	centavo	\N
SZ	AF	SWZ	Swaziland	748	Mbabane	+268	lilangeni	SZL	cent	\N
TD	AF	TCD	Chad	148	NDjamena	+235	CFA franc	XAF	centime	\N
TG	AF	TGO	Togo	768	Lomé		CFA franc79	XOF	centime	\N
TN	AF	TUN	Tunisia	788	Tunis	+216	Tunisian dinar	TND	millime	\N
TZ	AF	TZA	Tanzania	834	Dodoma78	+255	Tanzanian shilling	TZS	cent	\N
UG	AF	UGA	Uganda	800	Kampala	+256	Ugandan shilling	UGX	cent	\N
YT	AF	MYT	Mayotte	175	Mamoudzou	+269	euro	EUR	cent	\N
ZA	AF	ZAF	South Africa	710	Pretoria73		rand	ZAR	cent	\N
ZM	AF	ZMB	Zambia	894	Lusaka	+260	Zambian kwacha	ZMK	ngwee	\N
ZW	AF	ZWE	Zimbabwe	716	Harare	+263	Zimbabwe dollar	ZWD	cent	\N
AQ	AN	ATA	Antarctica	010		+672				\N
BV	AN	BVT	Bouvet Island	074						\N
GS	AN	SGS	South Georgia and the South Sandwich Islands	239						\N
HM	AN	HMD	Heard Island and McDonald Islands	334						\N
TF	AN	ATF	French Southern Territories	260						\N
AE	AS	ARE	United Arab Emirates	784	Abu Dhabi	+971	UAE dirham	AED	fils	\N
AF	AS	AFG	Afghanistan	004	Kabul	+93	afghani	AFN	pul	\N
AM	AS	ARM	Armenia	051	Yerevan	+374	dram	AMD	luma	\N
AZ	AS	AZE	Azerbaijan	031	Baku	+994	Azerbaijani manat	AZM	kepik	\N
BD	AS	BGD	Bangladesh	050	Dhaka	+880	taka	BDT	poisha	\N
BH	AS	BHR	Bahrain	048	Manama	+973	Bahraini dinar	BHD	fils	\N
BN	AS	BRN	Brunei Darussalam	096	Bandar Seri Begawan	+673	Brunei dollar	BND	sen	\N
BT	AS	BTN	Bhutan	064	Thimphu	+975	ngultrum	BTN	chhetrum	\N
CC	AS	CCK	Cocos Keeling Islands	166	Bantam	+61	Australian dollar	AUD	cent	\N
CN	AS	CHN	China	156	Beijing	+86	renminbi-yuan	CNY	jiao,  fen	\N
CX	AS	CXR	Christmas Island	162	Flying Fish Cove	+53	Australian dollar	AUD	cent	\N
CY	AS	CYP	Cyprus	196	Nicosia	+357	Cyprus pound	CYP	cent	\N
GE	AS	GEO	Georgia	268	Tbilisi	+995	lari	GEL	tetri	\N
HK	AS	HKG	Hong Kong	344	-	+852	Hong Kong dollar	HKD	cent	\N
ID	AS	IDN	Indonesia	360	Jakarta	+62	Indonesian rupiah	IDR	sen	\N
IL	AS	ISR	Israel	376	-44	+972	new shekel	ILS	agora	\N
IN	AS	IND	India	356	New Delhi	+91	Indian rupee	INR	paisa	\N
IO	AS	IOT	British Indian Ocean Territory	086						\N
IQ	AS	IRQ	Iraq	368	Baghdad	+964	Iraqi dinar	IQD	fils	\N
IR	AS	IRN	Iran	364	Tehran	+98	Iranian rial	IRR	-	\N
JO	AS	JOR	Jordan	400	Amman	+962	Jordanian dinar	JOD	fils	\N
JP	AS	JPN	Japan	392	Tokyo	+81	yen	JPY	sen	\N
KG	AS	KGZ	Kyrgyz Republic	417	Bishkek	+996	som	KGS	tyiyn	\N
KH	AS	KHM	Cambodia	116	Phnom Penh	+855	riel	KHR	sen	\N
KP	AS	PRK	North Korea	408	Pyongyang	+850	North Korean won	KPW	chun	\N
KR	AS	KOR	South Korea	410	Seoul	+82	South Korean won	KRW	chun	\N
KW	AS	KWT	Kuwait	414	Kuwait City	+965	Kuwaiti dinar	KWD	fils	\N
KZ	AS	KAZ	Kazakhstan	398	Astana	+7	tenge	KZT	tiyn	\N
LA	AS	LAO	Lao Peoples Democratic Republic	418	Vientiane	+856	kip	LAK	at	\N
LB	AS	LBN	Lebanon	422	Beirut	+961	Lebanese pound	LBP	piastre	\N
LK	AS	LKA	Sri Lanka	144	Colombo	+94	Sri Lankan rupee	LKR	cent	\N
MM	AS	MMR	Myanmar	104	Yangon52	+95	kyat	MMK	pya	\N
MN	AS	MNG	Mongolia	496	Ulan Bator	+976	tugrik	MNT	möngö	\N
MO	AS	MAC	Macao	446	Macau	+853	pataca	MOP	avo	\N
MV	AS	MDV	Maldives	462	Malé	+960	rufiyaa	MVR	laari	\N
MY	AS	MYS	Malaysia	458	Kuala Lumpur	+60	Malaysian ringgit	MYR	sen	\N
NP	AS	NPL	Nepal	524	Kathmandu	+977	Nepalese rupee	NPR	paisa	\N
OM	AS	OMN	Oman	512	Muscat	+968	Omani rial	OMR	baiza	\N
PH	AS	PHL	Philippines	608	Manila		Philippine peso	PHP	centavo	\N
PK	AS	PAK	Pakistan	586	Islamabad	+92	Pakistani rupee	PKR	paisa	\N
PS	AS	PSE	Palestinian Territory	275		+970				\N
QA	AS	QAT	Qatar	634	Doha	+974 	Qatari riyal	QAR	dirham	\N
SA	AS	SAU	Saudi Arabia	682	Riyadh		Saudi riyal	SAR	halala	\N
SG	AS	SGP	Singapore	702	Singapore	+65	Singapore dollar	SGD	cent	\N
SY	AS	SYR	Syrian Arab Republic	760	Damascus	+963	Syrian pound	SYP	piastre	\N
TH	AS	THA	Thailand	764	Bangkok		baht	THB	satang	\N
TJ	AS	TJK	Tajikistan	762	Dushanbe	+992	somoni	TJS	diram	\N
TL	AS	TLS	Timor-Leste	626	Dili		US dollar	USD	-	\N
TM	AS	TKM	Turkmenistan	795	Ashgabat	+993	Turkmen manat	TMM	tenge	\N
TR	AS	TUR	Turkey	792	Ankara	+90	Turkish lira	TRL	kurus	\N
TW	AS	TWN	Taiwan	158	Taipei	+886	new Taiwan dollar	TWD	fen	\N
UZ	AS	UZB	Uzbekistan	860	Tashkent	+998	sum	UZS	tiyin	\N
VN	AS	VNM	Vietnam	704	Hanoi	+84	dong	VND	-	\N
YE	AS	YEM	Yemen	887	Sana		Yemeni rial	YER	fils	\N
AD	EU	AND	Andorra	020	Andorra la Vella	+376	euro	EUR	cent	\N
AL	EU	ALB	Albania	008	Tirana	+355	lek	ALL	qindar	\N
AT	EU	AUT	Austria	040	Vienna	+43	euro	EUR	cent	\N
AX	EU	ALA	Aland Islands	248						\N
BA	EU	BIH	Bosnia and Herzegovina	070	Sarajevo	+387	Bosnian convertible mark	BAM	fening	\N
BE	EU	BEL	Belgium	056	Brussels	+32	euro	EUR	cent	\N
BG	EU	BGR	Bulgaria	100	Sofia	+359	lev	BGN	stotinka	\N
BY	EU	BLR	Belarus	112	Minsk	+375	Belarusian rouble	BYR	kopek	\N
CH	EU	CHE	Switzerland	756	Berne	+41	Swiss franc	CHF	centime	\N
CZ	EU	CZE	Czech Republic	203	Prague		Czech koruna	CZK	halér	\N
DE	EU	DEU	Germany	276	Berlin	+49	euro	EUR	cent	\N
DK	EU	DNK	Denmark	208	Copenhagen	+45	Danish krone	DKK	øre	\N
EE	EU	EST	Estonia	233	Tallinn	+372	Estonian kroon	EEK	sent	\N
ES	EU	ESP	Spain	724	Madrid	+34	euro	EUR	cent	\N
FI	EU	FIN	Finland	246	Helsinki	+358	euro	EUR	cent	\N
FO	EU	FRO	Faroe Islands	234	Thorshavn	+298	Danish krone	DKK	øre	\N
FR	EU	FRA	France	250	Paris	+33	euro	EUR	cent	\N
GB	EU	GBR	United Kingdom of Great Britain & Northern Ireland	826	London	+44	pound sterling	GBP	penny	\N
GG	EU	GGY	Guernsey	831						\N
GI	EU	GIB	Gibraltar	292	Gibraltar		Gibraltar pound	GIP	penny	\N
GR	EU	GRC	Greece	300	Athens	+30	euro	EUR	cent	\N
HR	EU	HRV	Croatia	191	Zagreb	+385	kuna	HRK	lipa	\N
HU	EU	HUN	Hungary	348	Budapest	+36	forint	HUF	-	\N
IE	EU	IRL	Ireland	372	Dublin	+353	euro	EUR	cent	\N
IM	EU	IMN	Isle of Man	833						\N
IS	EU	ISL	Iceland	352	Reykjavik	+354	Icelandic króna	ISK	eyrir	\N
IT	EU	ITA	Italy	380	Rome	+39	euro	EUR	cent	\N
JE	EU	JEY	Bailiwick of Jersey	832						\N
LI	EU	LIE	Liechtenstein	438	Vaduz	+423	Swiss franc	CHF	centime	\N
LT	EU	LTU	Lithuania	440	Vilnius	+370	litas	LTL	centas	\N
LU	EU	LUX	Luxembourg	442	Luxembourg	+352	euro	EUR	cent	\N
LV	EU	LVA	Latvia	428	Riga	+371	lats	LVL	santims	\N
MC	EU	MCO	Monaco	492	Monaco	+377	euro	EUR	cent	\N
MD	EU	MDA	Moldova	498	Chisinau	+373	Moldovan leu	MDL	ban	\N
ME	EU	MNE	Montenegro	499						\N
MK	EU	MKD	Macedonia	807	Skopje	+389	denar	MKD	deni	\N
MT	EU	MLT	Malta	470	Valletta	+356	Maltese lira	MTL	cent	\N
NL	EU	NLD	Netherlands	528	Amsterdam54	+31	euro	EUR	cent	\N
NO	EU	NOR	Norway	578	Oslo	+47	Norwegian krone	NOK	øre	\N
PL	EU	POL	Poland	616	Warsaw	+48	zloty	PLN	grosz	\N
PT	EU	PRT	Portugal	620	Lisbon	+351	euro	EUR	cent	\N
RO	EU	ROU	Romania	642	Bucharest		Romanian leu	ROL	ban	\N
RS	EU	SRB	Serbia	688						\N
RU	EU	RUS	Russian Federation	643	Moscow	+7	rouble	RUB	kopek	\N
SE	EU	SWE	Sweden	752	Stockholm	+46	Swedish krona	SEK	öre	\N
SI	EU	SVN	Slovenia	705	Ljubljana	+386	tolar	SIT	stotin	\N
SJ	EU	SJM	Svalbard & Jan Mayen Islands	744	Longyearbyen76		Norwegian krone	NOK	øre	\N
SK	EU	SVK	Slovakia	703	Bratislava	+421	Slovak koruna	SKK	halier	\N
SM	EU	SMR	San Marino	674	San Marino	+378	euro	EUR	cent	\N
UA	EU	UKR	Ukraine	804	Kiev	+380	hryvnia	UAH	kopiyka	\N
VA	EU	VAT	Vatican City State	336	Vatican City	+418	euro	EUR	cent	\N
VE	SA	VEN	Venezuela	862	Caracas	+58	bolívar	VEB	centavo	\N
AG	NA	ATG	Antigua and Barbuda	028	St Johns	+1-268	Eastern Caribbean dollar	XCD	cent	\N
AI	NA	AIA	Anguilla	660	The Valley	+1-264	Eastern Caribbean dollar	XCD	cent	\N
AN	NA	ANT	Netherlands Antilles	530	Willemstad	+599	Netherlands Antillean guilder	ANG	cent	\N
AW	NA	ABW	Aruba	533	Oranjestad	+297	Aruban guilder	AWG	cent	\N
BB	NA	BRB	Barbados	052	Bridgetown	+1-246	Barbados dollar	BBD	cent	\N
BL	NA	BLM	Saint Barthelemy	652						\N
BM	NA	BMU	Bermuda	060	Hamilton	+1-441	Bermuda dollar	BMD	cent	\N
BS	NA	BHS	Bahamas	044	Nassau	+1-242	Bahamian dollar	BSD	cent	\N
BZ	NA	BLZ	Belize	084	Belmopan	+501	Belize dollar	BZD	cent	\N
CA	NA	CAN	Canada	124	Ottawa	+1	Canadian dollar	CAD	cent	\N
CR	NA	CRI	Costa Rica	188	San José	+506	Costa Rican colón	CRC	céntimo	\N
CU	NA	CUB	Cuba	192	Havana	+53	Cuban peso	CUP	centavo	\N
DM	NA	DMA	Dominica	212	Roseau	+1-767	Eastern Caribbean dollar	XCD	cent	\N
DO	NA	DOM	Dominican Republic	214	Santo Domingo	+1-809	Dominican peso	DOP	centavo	\N
GD	NA	GRD	Grenada	308	St Georges	+1-473	Eastern Caribbean dollar	XCD	cent	\N
GL	NA	GRL	Greenland	304	Nuuk	+299	Danish krone	DKK	øre	\N
GP	NA	GLP	Guadeloupe	312	Basse Terre	+590	euro	EUR	cent	\N
GT	NA	GTM	Guatemala	320	Guatemala City	+502	Guatemalan quetzal	GTQ	centavo	\N
HN	NA	HND	Honduras	340	Tegucigalpa	+504	lempira	HNL	centavo	\N
HT	NA	HTI	Haiti	332	Port-au-Prince		gourde	HTG	centime	\N
JM	NA	JAM	Jamaica	388	Kingston	+1-876	Jamaica dollar	JMD	cent	\N
KN	NA	KNA	Saint Kitts and Nevis	659	Basseterre	+1-869	Eastern Caribbean dollar	XCD	cent	\N
KY	NA	CYM	Cayman Islands	136	George Town	+1-345	Cayman Islands dollar	KYD	cent	\N
LC	NA	LCA	Saint Lucia	662	Castries	+1-758	Eastern Caribbean dollar	XCD	cent	\N
MF	NA	MAF	Saint Martin	663						\N
MQ	NA	MTQ	Martinique	474	Fort-de-France	+596	euro	EUR	cent	\N
MS	NA	MSR	Montserrat	500	Plymouth	+1-664	Eastern Caribbean dollar	XCD	cent	\N
MX	NA	MEX	Mexico	484	Mexico City	+52	Mexican peso	MXN	centavo	\N
NI	NA	NIC	Nicaragua	558	Managua	+505	córdoba	NIO	centavo	\N
PA	NA	PAN	Panama	591	Panama City	+507	balboa	PAB	centésimo	\N
PM	NA	SPM	Saint Pierre and Miquelon	666	Saint-Pierre	+508	euro	EUR	cent	\N
PR	NA	PRI	Puerto Rico	630	San Juan	+1-787	US dollar	USD	cent	\N
SV	NA	SLV	El Salvador	222	San Salvador	+503	US dollar	USD	centavo	\N
TC	NA	TCA	Turks and Caicos Islands	796	Cockburn Town	+1-649	US dollar	USD	cent	\N
TT	NA	TTO	Trinidad and Tobago	780	Port of Spain		Trinidad and Tobago dollar	TTD	cent	\N
US	NA	USA	United States of America	840	Washington DC		US dollar	USD	cent	\N
VC	NA	VCT	Saint Vincent and the Grenadines	670	Kingstown	+1-784	Eastern Caribbean dollar	XCD	cent	\N
VG	NA	VGB	British Virgin Islands	092	Road Town		US dollar	USD	cent	\N
VI	NA	VIR	United States Virgin Islands	850	Charlotte Amalie	+1-284	US dollar	USD	cent	\N
AS	OC	ASM	American Samoa	016	Pago Pago	+1-684	US dollar	USD	cent	\N
AU	OC	AUS	Australia	036	Canberra	+61	Australian dollar	AUD	cent	\N
CK	OC	COK	Cook Islands	184	Avarua	+682	New Zealand dollar	NZD	cent	\N
FJ	OC	FJI	Fiji	242	Suva	+679	Fiji dollar	FJD	cent	\N
FM	OC	FSM	Micronesia	583	Palikir	+691	US dollar	USD	cent	\N
GU	OC	GUM	Guam	316	Hagåtña	+1-671	US dollar	USD	cent	\N
KI	OC	KIR	Kiribati	296	Tarawa	+686	Australian dollar	AUD	cent	\N
MH	OC	MHL	Marshall Islands	584	Majuro	+692	US dollar	USD	cent	\N
MP	OC	MNP	Northern Mariana Islands	580	Garapan62	+1-670	US dollar	USD	cent	\N
NC	OC	NCL	New Caledonia	540	Nouméa	+687	CFP franc	XPF	centime	\N
NF	OC	NFK	Norfolk Island	574	Kingston	+672	Australian dollar	AUD	cent	\N
NR	OC	NRU	Nauru	520	Yaren	+674	Australian dollar	AUD	cent	\N
NU	OC	NIU	Niue	570	Alofi	+683	New Zealand dollar	NZD	cent	\N
NZ	OC	NZL	New Zealand	554	Wellington	+64	New Zealand dollar	NZD	cent	\N
PF	OC	PYF	French Polynesia	258	Papeete		CFP franc	XPF	centime	\N
PG	OC	PNG	Papua New Guinea	598	Port Moresby	+675	kina	PGK	toea	\N
PN	OC	PCN	Pitcairn Islands	612	Adamstown		New Zealand dollar	NZD	cent	\N
PW	OC	PLW	Palau	585	Koror	+680	US dollar	USD	cent	\N
SB	OC	SLB	Solomon Islands	090	Honiara	+677	Solomon Islands dollar	SBD	cent	\N
TK	OC	TKL	Tokelau	772	Fakaofo	+690	New Zealand dollar	NZD	cent	\N
TO	OC	TON	Tonga	776	Nukualofa	+676	paanga	TOP	seniti	\N
TV	OC	TUV	Tuvalu	798	Fongafale82	+688	Australian dollar	AUD	cent	\N
UM	OC	UMI	United States Minor Outlying Islands	581						\N
VU	OC	VUT	Vanuatu	548	Port Vila	+678	vatu	VUV	-	\N
WF	OC	WLF	Wallis and Futuna	876	Mata-Utu		CFP franc	XPF	centime	\N
WS	OC	WSM	Samoa	882	Apia	+685	tala	WST	sene	\N
AR	SA	ARG	Argentina	032	Buenos Aires	+54	Argentine peso	ARS	centavo	\N
BO	SA	BOL	Bolivia	068	Sucre16	+591	boliviano	BOB	centavo	\N
BR	SA	BRA	Brazil	076	Brasilia		Brazilian real	BRL	centavo	\N
CL	SA	CHL	Chile	152	Santiago	+56	Chilean peso	CLP	centavo	\N
CO	SA	COL	Colombia	170	Santa Fe de Bogotá	+57	Colombian peso	COP	centavo	\N
EC	SA	ECU	Ecuador	218	Quito	+593	US dollar	USD	-	\N
FK	SA	FLK	Falkland Islands	238	Stanley	+500	Falkland Islands pound	FKP	new penny	\N
GF	SA	GUF	French Guiana	254	Cayenne	+594	euro	EUR	cent	\N
GY	SA	GUY	Guyana	328	Georgetown	+592	Guyanese dollar	GYD	cent	\N
PE	SA	PER	Peru	604	Lima	+51	new sol	PEN	céntimo	\N
PY	SA	PRY	Paraguay	600	Asunción	+595	guaraní	PYG	céntimo	\N
SR	SA	SUR	Suriname	740	Paramaribo		Suriname guilder	SRG	cent	\N
UY	SA	URY	Uruguay	858	Montevideo	+598	Uruguayan peso	UYU	centésimo	\N
\.


--
-- Data for Name: sys_dashboard; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_dashboard (sys_dashboard_id, entity_id, org_id, narrative, details) FROM stdin;
\.


--
-- Data for Name: sys_emailed; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_emailed (sys_emailed_id, sys_email_id, org_id, table_id, table_name, email_type, emailed, created, narrative, mail_body) FROM stdin;
\.


--
-- Data for Name: sys_emails; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_emails (sys_email_id, org_id, use_type, sys_email_name, default_email, title, details) FROM stdin;
\.


--
-- Data for Name: sys_errors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_errors (sys_error_id, sys_error, error_message) FROM stdin;
\.


--
-- Data for Name: sys_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_files (sys_file_id, org_id, table_id, table_name, file_name, file_type, file_size, narrative, details) FROM stdin;
\.


--
-- Data for Name: sys_languages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_languages (sys_language_id, sys_language_name) FROM stdin;
0	English
1	French
2	Arabic
3	Simple Chinese
4	Traditional Chinese
5	Spanish
\.


--
-- Data for Name: sys_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_logins (sys_login_id, entity_id, login_time, login_ip, phone_serial_number, correct_login, narrative) FROM stdin;
1	0	2019-09-21 16:12:33.225207	127.0.0.1	\N	t	\N
2	0	2019-09-23 21:56:55.604927	127.0.0.1	\N	t	\N
3	0	2019-09-25 16:10:34.648283	127.0.0.1	\N	t	\N
4	0	2019-09-25 20:48:12.395772	127.0.0.1	\N	t	\N
5	0	2019-10-01 15:34:36.505415	127.0.0.1	\N	t	\N
6	0	2019-10-01 17:10:11.223015	127.0.0.1	\N	t	\N
7	0	2019-10-01 20:47:09.276296	127.0.0.1	\N	t	\N
8	0	2019-10-03 16:21:14.978888	127.0.0.1	\N	t	\N
9	0	2019-10-03 16:40:09.423619	127.0.0.1	\N	t	\N
10	0	2019-10-03 16:44:05.121758	127.0.0.1	\N	t	\N
11	0	2019-10-03 16:45:08.12293	127.0.0.1	\N	t	\N
12	0	2019-10-03 17:50:52.577059	127.0.0.1	\N	t	\N
13	0	2019-10-04 12:06:57.12315	127.0.0.1	\N	t	\N
14	0	2019-10-06 21:15:29.98848	127.0.0.1	\N	t	\N
15	0	2019-10-06 21:34:01.398625	127.0.0.1	\N	t	\N
16	0	2019-10-07 07:31:59.059887	127.0.0.1	\N	t	\N
\.


--
-- Data for Name: sys_menu_msg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_menu_msg (sys_menu_msg_id, menu_id, menu_name, xml_file, msg) FROM stdin;
\.


--
-- Data for Name: sys_nationalitys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_nationalitys (sys_nationality_id, sys_nationality_name) FROM stdin;
AF	Afghan
AX	Åland Island
AL	Albanian
DZ	Algerian
AS	American Samoan
AD	Andorran
AO	Angolan
AI	Anguillan
AQ	Antarctic
AG	Antiguan/Barbudan
AR	Argentine
AM	Armenian
AW	Aruban
AU	Australian
AT	Austrian
AZ	Azerbaijani, Azeri
BS	Bahamian
BH	Bahraini
BD	Bangladeshi
BB	Barbadian
BY	Belarusian
BE	Belgian
BZ	Belizean
BJ	Beninese/Beninois
BM	Bermudian/Bermudan
BT	Bhutanese
BO	Bolivian
BQ	Bonaire
BA	Bosnian/Herzegovinian
BW	Motswana/Botswanan
BV	Bouvet Island
BR	Brazilian
IO	BIOT
BN	Bruneian
BG	Bulgarian
BF	Burkinabé
BI	Burundian
CV	Cabo Verdean
KH	Cambodian
CM	Cameroonian
CA	Canadian
KY	Caymanian
CF	Central African
TD	Chadian
CL	Chilean
CN	Chinese
CX	Christmas Island
CC	Cocos Island
CO	Colombian
KM	Comoran/Comorian
CG	Congolese
CD	Congolese
CK	Cook Island
CR	Costa Rican
CI	Ivorian
HR	Croatian
CU	Cuban
CW	Curaçaoan
CY	Cypriot
CZ	Czech
DK	Danish
DJ	Djiboutian
DM	Dominican
DO	Dominican
EC	Ecuadorian
EG	Egyptian
SV	Salvadoran
GQ	Equatorial Guinean/Equatoguinean
ER	Eritrean
EE	Estonian
ET	Ethiopian
FK	Falkland Island
FO	Faroese
FJ	Fijian
FI	Finnish
FR	French
GF	French Guianese
PF	French Polynesian
TF	French Southern Territories
GA	Gabonese
GM	Gambian
GE	Georgian
DE	German
GH	Ghanaian
GI	Gibraltar
GR	Greek/Hellenic
GL	Greenlandic
GD	Grenadian
GP	Guadeloupe
GU	Guamanian/Guambat
GT	Guatemalan
GG	Channel Island
GN	Guinean
GW	Bissau-Guinean
GY	Guyanese
HT	Haitian
HM	Heard Island/McDonald Islands
VA	Vatican
HN	Honduran
HK	Hong Kong/ Hong Kongese
HU	Hungarian/Magyar
IS	Icelandic
IN	Indian
ID	Indonesian
IR	Iranian/Persian
IQ	Iraqi
IE	Irish
IM	Manx
IL	Israeli
IT	Italian
JM	Jamaican
JP	Japanese
JE	Channel Island
JO	Jordanian
KZ	Kazakhstani/ Kazakh
KE	Kenyan
KI	I-Kiribati
KP	North Korean
KR	South Korean
KW	Kuwaiti
KG	Kyrgyzstani/Kyrgyz/Kirgiz/Kirghiz
LA	Lao, Laotian
LV	Latvian
LB	Lebanese
LS	Basotho
LR	Liberian
LY	Libyan
LI	Liechtenstein
LT	Lithuanian
LU	Luxembourg/Luxembourgish
MO	Macanese, Chinese
MK	Macedonian
MG	Malagasy
MW	Malawian
MY	Malaysian
MV	Maldivian
ML	Malian/Malinese
MT	Maltese
MH	Marshallese
MQ	Martiniquais/Martinican
MR	Mauritanian
MU	Mauritian
YT	Mahoran
MX	Mexican
FM	Micronesian
MD	Moldovan
MC	Monégasque/Monacan
MN	Mongolian
ME	Montenegrin
MS	Montserratian
MA	Moroccan
MZ	Mozambican
MM	Burmese
NA	Namibian
NR	Nauruan
NP	Nepali/Nepalese
NL	Dutch/Netherlandic
NC	New Caledonian
NZ	New Zealand, NZ
NI	Nicaraguan
NE	Nigerien
NG	Nigerian
NU	Niuean
NF	Norfolk Island
MP	Northern Marianan
NO	Norwegian
OM	Omani
PK	Pakistani
PW	Palauan
PS	Palestinian
PA	Panamanian
PG	Papua New Guinean, Papuan
PY	Paraguayan
PE	Peruvian
PH	Philippine/Filipino
PN	Pitcairn Island
PL	Polish
PT	Portuguese
PR	Puerto Rican
QA	Qatari
RE	Réunionese/Réunionnais
RO	Romanian
RU	Russian
RW	Rwandan
BL	Barthélemois
SH	Saint Helenian
KN	Kittitian/Nevisian
LC	Saint Lucian
MF	Saint-Martinoise
PM	Saint-Pierrais/ Miquelonnais
VC	Saint Vincentian/Vincentian
WS	Samoan
SM	Sammarinese
ST	São Toméan
SA	Saudi/Saudi Arabian
SN	Senegalese
RS	Serbian
SC	Seychellois
SL	Sierra Leonean
SG	Singaporean
SX	Sint Maarten
SK	Slovak
SI	Slovenian/Slovene
SB	Solomon Island
SO	Somali/Somalian
ZA	South African
GS	South Georgia/South Sandwich Islands
SS	South Sudanese
ES	Spanish
LK	Sri Lankan
SD	Sudanese
SR	Surinamese
SJ	Svalbard
SZ	Swazi
SE	Swedish
CH	Swiss
SY	Syrian
TW	Chinese/Taiwanese
TJ	Tajikistani
TZ	Tanzanian
TH	Thai
TL	Timorese
TG	Togolese
TK	Tokelauan
TO	Tongan
TT	Trinidadian/Tobagonian
TN	Tunisian
TR	Turkish
TM	Turkmen
TC	Turks and Caicos Island
TV	Tuvaluan
UG	Ugandan
UA	Ukrainian
AE	Emirati/Emirian/Emiri
GB	British, UK
UM	American
US	American
UY	Uruguayan
UZ	Uzbekistani/Uzbek
VU	Ni-Vanuatu/Vanuatuan
VE	Venezuelan
VN	Vietnamese
VG	British Virgin Island
VI	U.S. Virgin Island
WF	 Wallisian
EH	Sahrawi/Sahrawian/Sahraouian
YE	Yemeni
ZM	Zambian
ZW	Zimbabwean
\.


--
-- Data for Name: sys_news; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_news (sys_news_id, org_id, sys_news_group, sys_news_title, publish, details) FROM stdin;
\.


--
-- Data for Name: sys_queries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_queries (sys_queries_id, org_id, sys_query_name, query_date, query_text, query_params) FROM stdin;
\.


--
-- Data for Name: sys_reset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_reset (sys_reset_id, entity_id, org_id, request_email, request_time, login_ip, narrative) FROM stdin;
\.


--
-- Data for Name: sys_translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sys_translations (sys_translation_id, sys_app_id, sys_language_id, org_id, reference, title, narration) FROM stdin;
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (teacher_id, teacher_name, org_id, telno, gender, email, is_active, details) FROM stdin;
1	James Waringo	0	0702771424	M	james@gmail.com	t	\N
\.


--
-- Data for Name: use_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.use_keys (use_key_id, use_key_name, use_function) FROM stdin;
0	System Admins	0
1	Staff	0
2	Client	0
3	Supplier	0
4	Applicant	0
5	Subscription	0
6	User	0
7	students	0
8	teachers	0
9	non teaching staff	0
\.


--
-- Data for Name: vote_heads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vote_heads (vote_head_id, org_id, vote_head_name, details) FROM stdin;
1	0	Tuition	\N
2	0	Boarding	\N
\.


--
-- Data for Name: workflow_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_logs (workflow_log_id, org_id, table_name, table_id, table_old_id) FROM stdin;
\.


--
-- Data for Name: workflow_phases; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_phases (workflow_phase_id, workflow_id, approval_entity_id, org_id, approval_level, return_level, escalation_days, escalation_hours, required_approvals, reporting_level, use_reporting, advice, notice, phase_narrative, advice_email, notice_email, advice_file, notice_file, details) FROM stdin;
\.


--
-- Data for Name: workflow_sql; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_sql (workflow_sql_id, workflow_phase_id, org_id, workflow_sql_name, is_condition, is_action, message, sql) FROM stdin;
\.


--
-- Data for Name: workflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflows (workflow_id, source_entity_id, org_id, workflow_name, table_name, table_link_field, table_link_id, approve_email, reject_email, approve_file, reject_file, link_copy, details) FROM stdin;
\.


--
-- Name: accountants_accountant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accountants_accountant_id_seq', 1, true);


--
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_address_id_seq', 1, false);


--
-- Name: address_types_address_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_types_address_type_id_seq', 1, false);


--
-- Name: approval_checklists_approval_checklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.approval_checklists_approval_checklist_id_seq', 1, false);


--
-- Name: approvals_approval_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.approvals_approval_id_seq', 1, false);


--
-- Name: bank_branch_bank_branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bank_branch_bank_branch_id_seq', 1, true);


--
-- Name: book_category_book_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.book_category_book_category_id_seq', 5, true);


--
-- Name: book_status_book_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.book_status_book_status_id_seq', 6, true);


--
-- Name: books_book_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.books_book_id_seq', 2, true);


--
-- Name: books_issuance_books_issuance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.books_issuance_books_issuance_id_seq', 3, true);


--
-- Name: calendar_year_calendar_year_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calendar_year_calendar_year_id_seq', 1, true);


--
-- Name: checklists_checklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checklists_checklist_id_seq', 1, false);


--
-- Name: class_levels_class_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_levels_class_level_id_seq', 4, true);


--
-- Name: currency_currency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.currency_currency_id_seq', 4, true);


--
-- Name: currency_rates_currency_rate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.currency_rates_currency_rate_id_seq', 1, false);


--
-- Name: e_fields_e_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.e_fields_e_field_id_seq', 1, false);


--
-- Name: employee_designations_employee_designation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_designations_employee_designation_id_seq', 3, true);


--
-- Name: employee_month_employee_month_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_month_employee_month_id_seq', 1, true);


--
-- Name: employee_types_employee_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_types_employee_type_id_seq', 3, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 2, true);


--
-- Name: entity_fields_entity_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_fields_entity_field_id_seq', 1, false);


--
-- Name: entity_orgs_entity_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_orgs_entity_org_id_seq', 1, false);


--
-- Name: entity_reset_entity_reset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_reset_entity_reset_id_seq', 1, false);


--
-- Name: entity_subscriptions_entity_subscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_subscriptions_entity_subscription_id_seq', 8, true);


--
-- Name: entity_types_entity_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_types_entity_type_id_seq', 9, true);


--
-- Name: entity_values_entity_value_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_values_entity_value_id_seq', 1, false);


--
-- Name: entitys_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entitys_entity_id_seq', 7, true);


--
-- Name: entry_forms_entry_form_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entry_forms_entry_form_id_seq', 1, false);


--
-- Name: et_fields_et_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.et_fields_et_field_id_seq', 1, false);


--
-- Name: fee_payments_fee_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fee_payments_fee_payment_id_seq', 1, true);


--
-- Name: fees_structure_fees_structure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fees_structure_fees_structure_id_seq', 3, true);


--
-- Name: fees_structure_vote_heads_fees_structure_vote_head_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fees_structure_vote_heads_fees_structure_vote_head_id_seq', 6, true);


--
-- Name: fields_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fields_field_id_seq', 1, false);


--
-- Name: forms_form_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.forms_form_id_seq', 1, false);


--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.librarians_librarian_id_seq', 4, true);


--
-- Name: orgs_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orgs_org_id_seq', 1, false);


--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_methods_payment_method_id_seq', 1, false);


--
-- Name: payment_modes_payment_mode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_modes_payment_mode_id_seq', 2, true);


--
-- Name: picture_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.picture_id_seq', 1, false);


--
-- Name: publishers_publisher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publishers_publisher_id_seq', 2, true);


--
-- Name: reporting_reporting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_reporting_id_seq', 1, false);


--
-- Name: school_calendar_school_calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.school_calendar_school_calendar_id_seq', 4, true);


--
-- Name: school_terms_school_term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.school_terms_school_term_id_seq', 3, true);


--
-- Name: streams_stream_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.streams_stream_id_seq', 4, true);


--
-- Name: student_fee_invoices_student_fee_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_fee_invoices_student_fee_invoice_id_seq', 3, true);


--
-- Name: students_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_student_id_seq', 11, true);


--
-- Name: sub_fields_sub_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sub_fields_sub_field_id_seq', 1, false);


--
-- Name: sys_access_entitys_sys_access_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_access_entitys_sys_access_entity_id_seq', 1, false);


--
-- Name: sys_access_levels_sys_access_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_access_levels_sys_access_level_id_seq', 1, false);


--
-- Name: sys_apps_sys_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_apps_sys_app_id_seq', 1, false);


--
-- Name: sys_audit_trail_sys_audit_trail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_audit_trail_sys_audit_trail_id_seq', 88, true);


--
-- Name: sys_configs_sys_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_configs_sys_config_id_seq', 1, false);


--
-- Name: sys_dashboard_sys_dashboard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_dashboard_sys_dashboard_id_seq', 1, false);


--
-- Name: sys_emailed_sys_emailed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_emailed_sys_emailed_id_seq', 1, false);


--
-- Name: sys_emails_sys_email_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_emails_sys_email_id_seq', 1, false);


--
-- Name: sys_errors_sys_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_errors_sys_error_id_seq', 1, false);


--
-- Name: sys_files_sys_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_files_sys_file_id_seq', 1, false);


--
-- Name: sys_languages_sys_language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_languages_sys_language_id_seq', 1, false);


--
-- Name: sys_logins_sys_login_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_logins_sys_login_id_seq', 16, true);


--
-- Name: sys_menu_msg_sys_menu_msg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_menu_msg_sys_menu_msg_id_seq', 1, false);


--
-- Name: sys_news_sys_news_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_news_sys_news_id_seq', 1, false);


--
-- Name: sys_queries_sys_queries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_queries_sys_queries_id_seq', 1, false);


--
-- Name: sys_reset_sys_reset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_reset_sys_reset_id_seq', 1, false);


--
-- Name: sys_translations_sys_translation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_translations_sys_translation_id_seq', 1, false);


--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teachers_teacher_id_seq', 1, true);


--
-- Name: vote_heads_vote_head_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vote_heads_vote_head_id_seq', 2, true);


--
-- Name: workflow_logs_workflow_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_logs_workflow_log_id_seq', 1, false);


--
-- Name: workflow_phases_workflow_phase_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_phases_workflow_phase_id_seq', 1, false);


--
-- Name: workflow_sql_workflow_sql_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_sql_workflow_sql_id_seq', 1, false);


--
-- Name: workflow_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_table_id_seq', 1, false);


--
-- Name: workflows_workflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflows_workflow_id_seq', 1, false);


--
-- Name: accountants accountants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accountants
    ADD CONSTRAINT accountants_pkey PRIMARY KEY (accountant_id);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: address_types address_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address_types
    ADD CONSTRAINT address_types_pkey PRIMARY KEY (address_type_id);


--
-- Name: approval_checklists approval_checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_checklists
    ADD CONSTRAINT approval_checklists_pkey PRIMARY KEY (approval_checklist_id);


--
-- Name: approvals approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (approval_id);


--
-- Name: bank_branch bank_branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_branch
    ADD CONSTRAINT bank_branch_pkey PRIMARY KEY (bank_branch_id);


--
-- Name: book_category book_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_category
    ADD CONSTRAINT book_category_pkey PRIMARY KEY (book_category_id);


--
-- Name: book_status book_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_status
    ADD CONSTRAINT book_status_pkey PRIMARY KEY (book_status_id);


--
-- Name: books books_isbn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_isbn_key UNIQUE (isbn);


--
-- Name: books_issuance books_issuance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance
    ADD CONSTRAINT books_issuance_pkey PRIMARY KEY (books_issuance_id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (book_id);


--
-- Name: calendar_year calendar_year_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_year
    ADD CONSTRAINT calendar_year_pkey PRIMARY KEY (calendar_year_id);


--
-- Name: checklists checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT checklists_pkey PRIMARY KEY (checklist_id);


--
-- Name: class_levels class_levels_org_id_class_level_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_levels
    ADD CONSTRAINT class_levels_org_id_class_level_name_key UNIQUE (org_id, class_level_name);


--
-- Name: class_levels class_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_levels
    ADD CONSTRAINT class_levels_pkey PRIMARY KEY (class_level_id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (currency_id);


--
-- Name: currency_rates currency_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency_rates
    ADD CONSTRAINT currency_rates_pkey PRIMARY KEY (currency_rate_id);


--
-- Name: e_fields e_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_fields
    ADD CONSTRAINT e_fields_pkey PRIMARY KEY (e_field_id);


--
-- Name: employee_designations employee_designations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_designations
    ADD CONSTRAINT employee_designations_pkey PRIMARY KEY (employee_designation_id);


--
-- Name: employee_month employee_month_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_month
    ADD CONSTRAINT employee_month_pkey PRIMARY KEY (employee_month_id);


--
-- Name: employee_types employee_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_types
    ADD CONSTRAINT employee_types_pkey PRIMARY KEY (employee_type_id);


--
-- Name: employees employees_org_id_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_org_id_employee_id_key UNIQUE (org_id, employee_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: entity_fields entity_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_fields
    ADD CONSTRAINT entity_fields_pkey PRIMARY KEY (entity_field_id);


--
-- Name: entity_orgs entity_orgs_entity_id_org_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_orgs
    ADD CONSTRAINT entity_orgs_entity_id_org_id_key UNIQUE (entity_id, org_id);


--
-- Name: entity_orgs entity_orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_orgs
    ADD CONSTRAINT entity_orgs_pkey PRIMARY KEY (entity_org_id);


--
-- Name: entity_reset entity_reset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_reset
    ADD CONSTRAINT entity_reset_pkey PRIMARY KEY (entity_reset_id);


--
-- Name: entity_subscriptions entity_subscriptions_entity_id_entity_type_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions
    ADD CONSTRAINT entity_subscriptions_entity_id_entity_type_id_key UNIQUE (entity_id, entity_type_id);


--
-- Name: entity_subscriptions entity_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions
    ADD CONSTRAINT entity_subscriptions_pkey PRIMARY KEY (entity_subscription_id);


--
-- Name: entity_types entity_types_org_id_entity_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_org_id_entity_type_name_key UNIQUE (org_id, entity_type_name);


--
-- Name: entity_types entity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_pkey PRIMARY KEY (entity_type_id);


--
-- Name: entity_values entity_values_entity_id_entity_field_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values
    ADD CONSTRAINT entity_values_entity_id_entity_field_id_key UNIQUE (entity_id, entity_field_id);


--
-- Name: entity_values entity_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values
    ADD CONSTRAINT entity_values_pkey PRIMARY KEY (entity_value_id);


--
-- Name: entitys entitys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_pkey PRIMARY KEY (entity_id);


--
-- Name: entitys entitys_user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_user_name_key UNIQUE (user_name);


--
-- Name: entry_forms entry_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms
    ADD CONSTRAINT entry_forms_pkey PRIMARY KEY (entry_form_id);


--
-- Name: et_fields et_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.et_fields
    ADD CONSTRAINT et_fields_pkey PRIMARY KEY (et_field_id);


--
-- Name: fee_payments fee_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_pkey PRIMARY KEY (fee_payment_id);


--
-- Name: fees_structure fees_structure_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure
    ADD CONSTRAINT fees_structure_pkey PRIMARY KEY (fees_structure_id);


--
-- Name: fees_structure_vote_heads fees_structure_vote_heads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure_vote_heads
    ADD CONSTRAINT fees_structure_vote_heads_pkey PRIMARY KEY (fees_structure_vote_head_id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (field_id);


--
-- Name: forms forms_form_name_version_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_form_name_version_key UNIQUE (form_name, version);


--
-- Name: forms forms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_pkey PRIMARY KEY (form_id);


--
-- Name: librarians librarians_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_pkey PRIMARY KEY (librarian_id);


--
-- Name: orgs orgs_org_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_org_name_key UNIQUE (org_name);


--
-- Name: orgs orgs_org_sufix_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_org_sufix_key UNIQUE (org_sufix);


--
-- Name: orgs orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_pkey PRIMARY KEY (org_id);


--
-- Name: payment_methods payment_methods_org_id_payment_method_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_org_id_payment_method_name_key UNIQUE (org_id, payment_method_name);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (payment_method_id);


--
-- Name: payment_modes payment_modes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_modes
    ADD CONSTRAINT payment_modes_pkey PRIMARY KEY (payment_mode_id);


--
-- Name: publishers publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (publisher_id);


--
-- Name: publishers publishers_publisher_name_publisher_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_publisher_name_publisher_address_key UNIQUE (publisher_name, publisher_address);


--
-- Name: reporting reporting_entity_id_report_to_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting
    ADD CONSTRAINT reporting_entity_id_report_to_id_key UNIQUE (entity_id, report_to_id);


--
-- Name: reporting reporting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting
    ADD CONSTRAINT reporting_pkey PRIMARY KEY (reporting_id);


--
-- Name: school_calendar school_calendar_org_id_school_term_id_school_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar
    ADD CONSTRAINT school_calendar_org_id_school_term_id_school_year_key UNIQUE (org_id, school_term_id, school_year);


--
-- Name: school_calendar school_calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar
    ADD CONSTRAINT school_calendar_pkey PRIMARY KEY (school_calendar_id);


--
-- Name: school_terms school_terms_org_id_school_term_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_terms
    ADD CONSTRAINT school_terms_org_id_school_term_name_key UNIQUE (org_id, school_term_name);


--
-- Name: school_terms school_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_terms
    ADD CONSTRAINT school_terms_pkey PRIMARY KEY (school_term_id);


--
-- Name: streams streams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_pkey PRIMARY KEY (stream_id);


--
-- Name: student_fee_invoices student_fee_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices
    ADD CONSTRAINT student_fee_invoices_pkey PRIMARY KEY (student_fee_invoice_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: sub_fields sub_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_fields
    ADD CONSTRAINT sub_fields_pkey PRIMARY KEY (sub_field_id);


--
-- Name: sys_access_entitys sys_access_entitys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys
    ADD CONSTRAINT sys_access_entitys_pkey PRIMARY KEY (sys_access_entity_id);


--
-- Name: sys_access_entitys sys_access_entitys_sys_access_level_id_entity_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys
    ADD CONSTRAINT sys_access_entitys_sys_access_level_id_entity_id_key UNIQUE (sys_access_level_id, entity_id);


--
-- Name: sys_access_levels sys_access_levels_org_id_sys_access_level_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels
    ADD CONSTRAINT sys_access_levels_org_id_sys_access_level_name_key UNIQUE (org_id, sys_access_level_name);


--
-- Name: sys_access_levels sys_access_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels
    ADD CONSTRAINT sys_access_levels_pkey PRIMARY KEY (sys_access_level_id);


--
-- Name: sys_apps sys_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_apps
    ADD CONSTRAINT sys_apps_pkey PRIMARY KEY (sys_app_id);


--
-- Name: sys_audit_details sys_audit_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_audit_details
    ADD CONSTRAINT sys_audit_details_pkey PRIMARY KEY (sys_audit_trail_id);


--
-- Name: sys_audit_trail sys_audit_trail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_audit_trail
    ADD CONSTRAINT sys_audit_trail_pkey PRIMARY KEY (sys_audit_trail_id);


--
-- Name: sys_configs sys_configs_config_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_configs
    ADD CONSTRAINT sys_configs_config_name_key UNIQUE (config_name);


--
-- Name: sys_configs sys_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_configs
    ADD CONSTRAINT sys_configs_pkey PRIMARY KEY (sys_config_id);


--
-- Name: sys_continents sys_continents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_continents
    ADD CONSTRAINT sys_continents_pkey PRIMARY KEY (sys_continent_id);


--
-- Name: sys_continents sys_continents_sys_continent_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_continents
    ADD CONSTRAINT sys_continents_sys_continent_name_key UNIQUE (sys_continent_name);


--
-- Name: sys_countrys sys_countrys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_countrys
    ADD CONSTRAINT sys_countrys_pkey PRIMARY KEY (sys_country_id);


--
-- Name: sys_countrys sys_countrys_sys_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_countrys
    ADD CONSTRAINT sys_countrys_sys_country_name_key UNIQUE (sys_country_name);


--
-- Name: sys_dashboard sys_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_dashboard
    ADD CONSTRAINT sys_dashboard_pkey PRIMARY KEY (sys_dashboard_id);


--
-- Name: sys_emailed sys_emailed_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emailed
    ADD CONSTRAINT sys_emailed_pkey PRIMARY KEY (sys_emailed_id);


--
-- Name: sys_emails sys_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emails
    ADD CONSTRAINT sys_emails_pkey PRIMARY KEY (sys_email_id);


--
-- Name: sys_errors sys_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_errors
    ADD CONSTRAINT sys_errors_pkey PRIMARY KEY (sys_error_id);


--
-- Name: sys_files sys_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_files
    ADD CONSTRAINT sys_files_pkey PRIMARY KEY (sys_file_id);


--
-- Name: sys_languages sys_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_languages
    ADD CONSTRAINT sys_languages_pkey PRIMARY KEY (sys_language_id);


--
-- Name: sys_languages sys_languages_sys_language_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_languages
    ADD CONSTRAINT sys_languages_sys_language_name_key UNIQUE (sys_language_name);


--
-- Name: sys_logins sys_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_logins
    ADD CONSTRAINT sys_logins_pkey PRIMARY KEY (sys_login_id);


--
-- Name: sys_menu_msg sys_menu_msg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_menu_msg
    ADD CONSTRAINT sys_menu_msg_pkey PRIMARY KEY (sys_menu_msg_id);


--
-- Name: sys_news sys_news_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_news
    ADD CONSTRAINT sys_news_pkey PRIMARY KEY (sys_news_id);


--
-- Name: sys_queries sys_queries_org_id_sys_query_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_queries
    ADD CONSTRAINT sys_queries_org_id_sys_query_name_key UNIQUE (org_id, sys_query_name);


--
-- Name: sys_queries sys_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_queries
    ADD CONSTRAINT sys_queries_pkey PRIMARY KEY (sys_queries_id);


--
-- Name: sys_reset sys_reset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_reset
    ADD CONSTRAINT sys_reset_pkey PRIMARY KEY (sys_reset_id);


--
-- Name: sys_translations sys_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations
    ADD CONSTRAINT sys_translations_pkey PRIMARY KEY (sys_translation_id);


--
-- Name: sys_translations sys_translations_sys_app_id_sys_language_id_org_id_referenc_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations
    ADD CONSTRAINT sys_translations_sys_app_id_sys_language_id_org_id_referenc_key UNIQUE (sys_app_id, sys_language_id, org_id, reference);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);


--
-- Name: use_keys use_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.use_keys
    ADD CONSTRAINT use_keys_pkey PRIMARY KEY (use_key_id);


--
-- Name: vote_heads vote_heads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vote_heads
    ADD CONSTRAINT vote_heads_pkey PRIMARY KEY (vote_head_id);


--
-- Name: workflow_logs workflow_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_logs
    ADD CONSTRAINT workflow_logs_pkey PRIMARY KEY (workflow_log_id);


--
-- Name: workflow_phases workflow_phases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_phases
    ADD CONSTRAINT workflow_phases_pkey PRIMARY KEY (workflow_phase_id);


--
-- Name: workflow_sql workflow_sql_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_sql
    ADD CONSTRAINT workflow_sql_pkey PRIMARY KEY (workflow_sql_id);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (workflow_id);


--
-- Name: accountants_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX accountants_org_id ON public.accountants USING btree (org_id);


--
-- Name: address_address_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_address_type_id ON public.address USING btree (address_type_id);


--
-- Name: address_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_org_id ON public.address USING btree (org_id);


--
-- Name: address_sys_country_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_sys_country_id ON public.address USING btree (sys_country_id);


--
-- Name: address_table_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_table_id ON public.address USING btree (table_id);


--
-- Name: address_table_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_table_name ON public.address USING btree (table_name);


--
-- Name: address_types_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_types_org_id ON public.address_types USING btree (org_id);


--
-- Name: approval_checklists_approval_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_checklists_approval_id ON public.approval_checklists USING btree (approval_id);


--
-- Name: approval_checklists_checklist_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_checklists_checklist_id ON public.approval_checklists USING btree (checklist_id);


--
-- Name: approval_checklists_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_checklists_org_id ON public.approval_checklists USING btree (org_id);


--
-- Name: approvals_app_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_app_entity_id ON public.approvals USING btree (app_entity_id);


--
-- Name: approvals_approve_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_approve_status ON public.approvals USING btree (approve_status);


--
-- Name: approvals_forward_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_forward_id ON public.approvals USING btree (forward_id);


--
-- Name: approvals_org_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_org_entity_id ON public.approvals USING btree (org_entity_id);


--
-- Name: approvals_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_org_id ON public.approvals USING btree (org_id);


--
-- Name: approvals_table_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_table_id ON public.approvals USING btree (table_id);


--
-- Name: approvals_workflow_phase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approvals_workflow_phase_id ON public.approvals USING btree (workflow_phase_id);


--
-- Name: bank_branch_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bank_branch_org_id ON public.bank_branch USING btree (org_id);


--
-- Name: book_category_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX book_category_org_id ON public.book_category USING btree (org_id);


--
-- Name: book_status_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX book_status_org_id ON public.book_status USING btree (org_id);


--
-- Name: books_book_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_book_category_id ON public.books USING btree (book_category_id);


--
-- Name: books_issuance_book_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_issuance_book_id ON public.books_issuance USING btree (book_id);


--
-- Name: books_issuance_librarian_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_issuance_librarian_id ON public.books_issuance USING btree (librarian_id);


--
-- Name: books_issuance_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_issuance_org_id ON public.books_issuance USING btree (org_id);


--
-- Name: books_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_org_id ON public.books USING btree (org_id);


--
-- Name: books_publisher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_publisher_id ON public.books USING btree (publisher_id);


--
-- Name: books_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX books_status_id ON public.books USING btree (book_status_id);


--
-- Name: calendar_year_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX calendar_year_org_id ON public.calendar_year USING btree (org_id);


--
-- Name: checklists_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX checklists_org_id ON public.checklists USING btree (org_id);


--
-- Name: checklists_workflow_phase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX checklists_workflow_phase_id ON public.checklists USING btree (workflow_phase_id);


--
-- Name: class_levels_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX class_levels_org_id ON public.class_levels USING btree (org_id);


--
-- Name: currency_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX currency_org_id ON public.currency USING btree (org_id);


--
-- Name: currency_rates_currency_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX currency_rates_currency_id ON public.currency_rates USING btree (currency_id);


--
-- Name: currency_rates_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX currency_rates_org_id ON public.currency_rates USING btree (org_id);


--
-- Name: e_fields_et_field_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX e_fields_et_field_id ON public.e_fields USING btree (et_field_id);


--
-- Name: e_fields_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX e_fields_org_id ON public.e_fields USING btree (org_id);


--
-- Name: e_fields_table_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX e_fields_table_code ON public.e_fields USING btree (table_code);


--
-- Name: e_fields_table_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX e_fields_table_id ON public.e_fields USING btree (table_id);


--
-- Name: employee_designations_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employee_designations_org_id ON public.employee_designations USING btree (org_id);


--
-- Name: employee_month_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employee_month_employee_id ON public.employee_month USING btree (employee_id);


--
-- Name: employee_month_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employee_month_org_id ON public.employee_month USING btree (org_id);


--
-- Name: employee_types_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employee_types_org_id ON public.employee_types USING btree (org_id);


--
-- Name: employees_bank_branch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_bank_branch_id ON public.employees USING btree (bank_branch_id);


--
-- Name: employees_employee_designation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_employee_designation_id ON public.employees USING btree (employee_designation_id);


--
-- Name: employees_employee_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_employee_type_id ON public.employees USING btree (employee_type_id);


--
-- Name: employees_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_org_id ON public.employees USING btree (org_id);


--
-- Name: employees_payment_mode_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_payment_mode_id ON public.employees USING btree (payment_mode_id);


--
-- Name: entity_fields_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_fields_org_id ON public.entity_fields USING btree (org_id);


--
-- Name: entity_orgs_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_orgs_entity_id ON public.entity_orgs USING btree (entity_id);


--
-- Name: entity_orgs_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_orgs_org_id ON public.entity_orgs USING btree (org_id);


--
-- Name: entity_reset_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_reset_entity_id ON public.entity_reset USING btree (entity_id);


--
-- Name: entity_reset_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_reset_org_id ON public.entity_reset USING btree (org_id);


--
-- Name: entity_subscriptions_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_subscriptions_entity_id ON public.entity_subscriptions USING btree (entity_id);


--
-- Name: entity_subscriptions_entity_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_subscriptions_entity_type_id ON public.entity_subscriptions USING btree (entity_type_id);


--
-- Name: entity_subscriptions_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_subscriptions_org_id ON public.entity_subscriptions USING btree (org_id);


--
-- Name: entity_types_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_types_org_id ON public.entity_types USING btree (org_id);


--
-- Name: entity_types_use_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_types_use_key_id ON public.entity_types USING btree (use_key_id);


--
-- Name: entity_values_entity_field_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_values_entity_field_id ON public.entity_values USING btree (entity_field_id);


--
-- Name: entity_values_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_values_entity_id ON public.entity_values USING btree (entity_id);


--
-- Name: entity_values_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entity_values_org_id ON public.entity_values USING btree (org_id);


--
-- Name: entitys_entity_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entitys_entity_type_id ON public.entitys USING btree (entity_type_id);


--
-- Name: entitys_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entitys_org_id ON public.entitys USING btree (org_id);


--
-- Name: entitys_sys_language_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entitys_sys_language_id ON public.entitys USING btree (sys_language_id);


--
-- Name: entitys_use_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entitys_use_key_id ON public.entitys USING btree (use_key_id);


--
-- Name: entitys_user_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entitys_user_name ON public.entitys USING btree (user_name);


--
-- Name: entry_forms_entered_by_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entry_forms_entered_by_id ON public.entry_forms USING btree (entered_by_id);


--
-- Name: entry_forms_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entry_forms_entity_id ON public.entry_forms USING btree (entity_id);


--
-- Name: entry_forms_form_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entry_forms_form_id ON public.entry_forms USING btree (form_id);


--
-- Name: entry_forms_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX entry_forms_org_id ON public.entry_forms USING btree (org_id);


--
-- Name: et_fields_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX et_fields_org_id ON public.et_fields USING btree (org_id);


--
-- Name: et_fields_table_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX et_fields_table_code ON public.et_fields USING btree (table_code);


--
-- Name: et_fields_table_link; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX et_fields_table_link ON public.et_fields USING btree (table_link);


--
-- Name: fee_payments_accountant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fee_payments_accountant_id ON public.fee_payments USING btree (accountant_id);


--
-- Name: fee_payments_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fee_payments_org_id ON public.fee_payments USING btree (org_id);


--
-- Name: fee_payments_payment_mode_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fee_payments_payment_mode_id ON public.fee_payments USING btree (payment_mode_id);


--
-- Name: fee_payments_school_term_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fee_payments_school_term_id ON public.fee_payments USING btree (school_term_id);


--
-- Name: fee_payments_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fee_payments_student_id ON public.fee_payments USING btree (student_id);


--
-- Name: fees_structure_class_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_class_level_id ON public.fees_structure USING btree (class_level_id);


--
-- Name: fees_structure_fees_structure_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_fees_structure_id ON public.fees_structure_vote_heads USING btree (fees_structure_id);


--
-- Name: fees_structure_fees_structure_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_fees_structure_year ON public.fees_structure USING btree (calendar_year_id);


--
-- Name: fees_structure_fees_vote_head_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_fees_vote_head_id ON public.fees_structure_vote_heads USING btree (vote_head_id);


--
-- Name: fees_structure_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_org_id ON public.fees_structure USING btree (org_id);


--
-- Name: fees_structure_school_term_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_school_term_id ON public.fees_structure USING btree (school_term_id);


--
-- Name: fees_structure_vote_heads_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fees_structure_vote_heads_org_id ON public.fees_structure_vote_heads USING btree (org_id);


--
-- Name: fields_form_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fields_form_id ON public.fields USING btree (form_id);


--
-- Name: fields_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fields_org_id ON public.fields USING btree (org_id);


--
-- Name: forms_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX forms_org_id ON public.forms USING btree (org_id);


--
-- Name: librarians_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX librarians_org_id ON public.librarians USING btree (org_id);


--
-- Name: orgs_currency_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orgs_currency_id ON public.orgs USING btree (currency_id);


--
-- Name: orgs_default_country_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orgs_default_country_id ON public.orgs USING btree (default_country_id);


--
-- Name: orgs_parent_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orgs_parent_org_id ON public.orgs USING btree (parent_org_id);


--
-- Name: payment_methods_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payment_methods_org_id ON public.payment_methods USING btree (org_id);


--
-- Name: payment_modes_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payment_modes_org_id ON public.payment_modes USING btree (org_id);


--
-- Name: publishers_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publishers_org_id ON public.publishers USING btree (org_id);


--
-- Name: reporting_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_entity_id ON public.reporting USING btree (entity_id);


--
-- Name: reporting_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_org_id ON public.reporting USING btree (org_id);


--
-- Name: reporting_report_to_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_to_id ON public.reporting USING btree (report_to_id);


--
-- Name: school_calendar_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX school_calendar_org_id ON public.school_calendar USING btree (org_id);


--
-- Name: school_calendar_school_term_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX school_calendar_school_term_id ON public.school_calendar USING btree (school_term_id);


--
-- Name: school_terms_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX school_terms_org_id ON public.school_terms USING btree (org_id);


--
-- Name: streams_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX streams_org_id ON public.streams USING btree (org_id);


--
-- Name: student_fee_fee_class_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_fee_fee_class_level_id ON public.student_fee_invoices USING btree (class_level_id);


--
-- Name: student_fee_fee_structure_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_fee_fee_structure_id ON public.student_fee_invoices USING btree (fee_structure_id);


--
-- Name: student_fee_invoices_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_fee_invoices_org_id ON public.student_fee_invoices USING btree (org_id);


--
-- Name: student_fee_invoices_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_fee_invoices_student_id ON public.student_fee_invoices USING btree (student_id);


--
-- Name: students_class_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_class_level_id ON public.students USING btree (class_level_id);


--
-- Name: students_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_org_id ON public.students USING btree (org_id);


--
-- Name: students_stream_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_stream_id ON public.students USING btree (stream_id);


--
-- Name: sub_fields_field_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sub_fields_field_id ON public.sub_fields USING btree (field_id);


--
-- Name: sub_fields_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sub_fields_org_id ON public.sub_fields USING btree (org_id);


--
-- Name: sys_access_entitys_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_entitys_entity_id ON public.sys_access_entitys USING btree (entity_id);


--
-- Name: sys_access_entitys_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_entitys_org_id ON public.sys_access_entitys USING btree (org_id);


--
-- Name: sys_access_entitys_sys_access_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_entitys_sys_access_level_id ON public.sys_access_entitys USING btree (sys_access_level_id);


--
-- Name: sys_access_levels_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_levels_org_id ON public.sys_access_levels USING btree (org_id);


--
-- Name: sys_access_levels_sys_country_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_levels_sys_country_id ON public.sys_access_levels USING btree (sys_country_id);


--
-- Name: sys_access_levels_use_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_access_levels_use_key_id ON public.sys_access_levels USING btree (use_key_id);


--
-- Name: sys_countrys_sys_continent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_countrys_sys_continent_id ON public.sys_countrys USING btree (sys_continent_id);


--
-- Name: sys_dashboard_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_dashboard_entity_id ON public.sys_dashboard USING btree (entity_id);


--
-- Name: sys_dashboard_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_dashboard_org_id ON public.sys_dashboard USING btree (org_id);


--
-- Name: sys_emailed_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_emailed_org_id ON public.sys_emailed USING btree (org_id);


--
-- Name: sys_emailed_sys_email_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_emailed_sys_email_id ON public.sys_emailed USING btree (sys_email_id);


--
-- Name: sys_emailed_table_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_emailed_table_id ON public.sys_emailed USING btree (table_id);


--
-- Name: sys_emails_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_emails_org_id ON public.sys_emails USING btree (org_id);


--
-- Name: sys_files_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_files_org_id ON public.sys_files USING btree (org_id);


--
-- Name: sys_files_table_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_files_table_id ON public.sys_files USING btree (table_id);


--
-- Name: sys_logins_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_logins_entity_id ON public.sys_logins USING btree (entity_id);


--
-- Name: sys_news_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_news_org_id ON public.sys_news USING btree (org_id);


--
-- Name: sys_queries_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_queries_org_id ON public.sys_queries USING btree (org_id);


--
-- Name: sys_reset_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_reset_entity_id ON public.sys_reset USING btree (entity_id);


--
-- Name: sys_reset_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_reset_org_id ON public.sys_reset USING btree (org_id);


--
-- Name: sys_translations_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_translations_org_id ON public.sys_translations USING btree (org_id);


--
-- Name: sys_translations_sys_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_translations_sys_app_id ON public.sys_translations USING btree (sys_app_id);


--
-- Name: sys_translations_sys_language_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sys_translations_sys_language_id ON public.sys_translations USING btree (sys_language_id);


--
-- Name: teachers_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX teachers_org_id ON public.teachers USING btree (org_id);


--
-- Name: vote_heads_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vote_heads_org_id ON public.vote_heads USING btree (org_id);


--
-- Name: workflow_logs_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_logs_org_id ON public.workflow_logs USING btree (org_id);


--
-- Name: workflow_phases_approval_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_phases_approval_entity_id ON public.workflow_phases USING btree (approval_entity_id);


--
-- Name: workflow_phases_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_phases_org_id ON public.workflow_phases USING btree (org_id);


--
-- Name: workflow_phases_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_phases_workflow_id ON public.workflow_phases USING btree (workflow_id);


--
-- Name: workflow_sql_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_sql_org_id ON public.workflow_sql USING btree (org_id);


--
-- Name: workflow_sql_workflow_phase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_sql_workflow_phase_id ON public.workflow_sql USING btree (workflow_phase_id);


--
-- Name: workflows_org_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflows_org_id ON public.workflows USING btree (org_id);


--
-- Name: workflows_source_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflows_source_entity_id ON public.workflows USING btree (source_entity_id);


--
-- Name: accountants accountant_login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER accountant_login BEFORE INSERT OR UPDATE ON public.accountants FOR EACH ROW EXECUTE PROCEDURE public.accountants_login();


--
-- Name: entitys aft_entitys; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER aft_entitys AFTER INSERT ON public.entitys FOR EACH ROW EXECUTE PROCEDURE public.aft_entitys();


--
-- Name: address ins_address; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_address BEFORE INSERT OR UPDATE ON public.address FOR EACH ROW EXECUTE PROCEDURE public.ins_address();


--
-- Name: approvals ins_approvals; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_approvals BEFORE INSERT ON public.approvals FOR EACH ROW EXECUTE PROCEDURE public.ins_approvals();


--
-- Name: entitys ins_entitys; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_entitys BEFORE INSERT OR UPDATE ON public.entitys FOR EACH ROW EXECUTE PROCEDURE public.ins_entitys();


--
-- Name: entry_forms ins_entry_forms; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_entry_forms BEFORE INSERT ON public.entry_forms FOR EACH ROW EXECUTE PROCEDURE public.ins_entry_forms();


--
-- Name: fields ins_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_fields BEFORE INSERT ON public.fields FOR EACH ROW EXECUTE PROCEDURE public.ins_fields();


--
-- Name: entitys ins_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_password BEFORE INSERT OR UPDATE ON public.entitys FOR EACH ROW EXECUTE PROCEDURE public.ins_password();


--
-- Name: sub_fields ins_sub_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_sub_fields BEFORE INSERT ON public.sub_fields FOR EACH ROW EXECUTE PROCEDURE public.ins_sub_fields();


--
-- Name: sys_reset ins_sys_reset; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_sys_reset AFTER INSERT ON public.sys_reset FOR EACH ROW EXECUTE PROCEDURE public.ins_sys_reset();


--
-- Name: librarians librarian_login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER librarian_login BEFORE INSERT OR UPDATE ON public.librarians FOR EACH ROW EXECUTE PROCEDURE public.librarian_login();


--
-- Name: employees staff_login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER staff_login BEFORE INSERT OR UPDATE ON public.employees FOR EACH ROW EXECUTE PROCEDURE public.staffs_login();


--
-- Name: students student_login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER student_login BEFORE INSERT OR UPDATE ON public.students FOR EACH ROW EXECUTE PROCEDURE public.student_login();


--
-- Name: teachers teacher_login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER teacher_login BEFORE INSERT OR UPDATE ON public.teachers FOR EACH ROW EXECUTE PROCEDURE public.teacher_login();


--
-- Name: entry_forms upd_action; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_action BEFORE INSERT OR UPDATE ON public.entry_forms FOR EACH ROW EXECUTE PROCEDURE public.upd_action();


--
-- Name: approvals upd_approvals; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_approvals AFTER INSERT OR UPDATE ON public.approvals FOR EACH ROW EXECUTE PROCEDURE public.upd_approvals();


--
-- Name: accountants accountants_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accountants
    ADD CONSTRAINT accountants_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: address address_address_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_address_type_id_fkey FOREIGN KEY (address_type_id) REFERENCES public.address_types(address_type_id);


--
-- Name: address address_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: address address_sys_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_countrys(sys_country_id);


--
-- Name: address_types address_types_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address_types
    ADD CONSTRAINT address_types_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: approval_checklists approval_checklists_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_checklists
    ADD CONSTRAINT approval_checklists_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.approvals(approval_id);


--
-- Name: approval_checklists approval_checklists_checklist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_checklists
    ADD CONSTRAINT approval_checklists_checklist_id_fkey FOREIGN KEY (checklist_id) REFERENCES public.checklists(checklist_id);


--
-- Name: approval_checklists approval_checklists_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_checklists
    ADD CONSTRAINT approval_checklists_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: approvals approvals_app_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_app_entity_id_fkey FOREIGN KEY (app_entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: approvals approvals_org_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_org_entity_id_fkey FOREIGN KEY (org_entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: approvals approvals_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: approvals approvals_workflow_phase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_workflow_phase_id_fkey FOREIGN KEY (workflow_phase_id) REFERENCES public.workflow_phases(workflow_phase_id);


--
-- Name: bank_branch bank_branch_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_branch
    ADD CONSTRAINT bank_branch_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: book_category book_category_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_category
    ADD CONSTRAINT book_category_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: book_status book_status_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_status
    ADD CONSTRAINT book_status_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: books books_book_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_book_category_id_fkey FOREIGN KEY (book_category_id) REFERENCES public.book_category(book_category_id);


--
-- Name: books books_book_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_book_status_id_fkey FOREIGN KEY (book_status_id) REFERENCES public.book_status(book_status_id);


--
-- Name: books_issuance books_issuance_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance
    ADD CONSTRAINT books_issuance_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(book_id);


--
-- Name: books_issuance books_issuance_librarian_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance
    ADD CONSTRAINT books_issuance_librarian_id_fkey FOREIGN KEY (librarian_id) REFERENCES public.librarians(librarian_id);


--
-- Name: books_issuance books_issuance_loanee_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance
    ADD CONSTRAINT books_issuance_loanee_fkey FOREIGN KEY (loanee) REFERENCES public.entitys(entity_id);


--
-- Name: books_issuance books_issuance_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books_issuance
    ADD CONSTRAINT books_issuance_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: books books_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: books books_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publishers(publisher_id);


--
-- Name: calendar_year calendar_year_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_year
    ADD CONSTRAINT calendar_year_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: checklists checklists_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT checklists_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: checklists checklists_workflow_phase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT checklists_workflow_phase_id_fkey FOREIGN KEY (workflow_phase_id) REFERENCES public.workflow_phases(workflow_phase_id);


--
-- Name: class_levels class_levels_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_levels
    ADD CONSTRAINT class_levels_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: currency currency_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: currency_rates currency_rates_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency_rates
    ADD CONSTRAINT currency_rates_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currency(currency_id);


--
-- Name: currency_rates currency_rates_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency_rates
    ADD CONSTRAINT currency_rates_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: e_fields e_fields_et_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_fields
    ADD CONSTRAINT e_fields_et_field_id_fkey FOREIGN KEY (et_field_id) REFERENCES public.et_fields(et_field_id);


--
-- Name: e_fields e_fields_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_fields
    ADD CONSTRAINT e_fields_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: employee_designations employee_designations_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_designations
    ADD CONSTRAINT employee_designations_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: employee_month employee_month_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_month
    ADD CONSTRAINT employee_month_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: employee_month employee_month_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_month
    ADD CONSTRAINT employee_month_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: employee_types employee_types_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_types
    ADD CONSTRAINT employee_types_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: employees employees_bank_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_bank_branch_id_fkey FOREIGN KEY (bank_branch_id) REFERENCES public.bank_branch(bank_branch_id);


--
-- Name: employees employees_employee_designation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_designation_id_fkey FOREIGN KEY (employee_designation_id) REFERENCES public.employee_designations(employee_designation_id);


--
-- Name: employees employees_employee_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_type_id_fkey FOREIGN KEY (employee_type_id) REFERENCES public.employee_types(employee_type_id);


--
-- Name: employees employees_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: employees employees_payment_mode_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_payment_mode_id_fkey FOREIGN KEY (payment_mode_id) REFERENCES public.payment_modes(payment_mode_id);


--
-- Name: entity_fields entity_fields_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_fields
    ADD CONSTRAINT entity_fields_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entity_orgs entity_orgs_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_orgs
    ADD CONSTRAINT entity_orgs_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: entity_orgs entity_orgs_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_orgs
    ADD CONSTRAINT entity_orgs_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entity_reset entity_reset_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_reset
    ADD CONSTRAINT entity_reset_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: entity_reset entity_reset_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_reset
    ADD CONSTRAINT entity_reset_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entity_subscriptions entity_subscriptions_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions
    ADD CONSTRAINT entity_subscriptions_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: entity_subscriptions entity_subscriptions_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions
    ADD CONSTRAINT entity_subscriptions_entity_type_id_fkey FOREIGN KEY (entity_type_id) REFERENCES public.entity_types(entity_type_id);


--
-- Name: entity_subscriptions entity_subscriptions_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_subscriptions
    ADD CONSTRAINT entity_subscriptions_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entity_types entity_types_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entity_types entity_types_use_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_use_key_id_fkey FOREIGN KEY (use_key_id) REFERENCES public.use_keys(use_key_id);


--
-- Name: entity_values entity_values_entity_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values
    ADD CONSTRAINT entity_values_entity_field_id_fkey FOREIGN KEY (entity_field_id) REFERENCES public.entity_fields(entity_field_id);


--
-- Name: entity_values entity_values_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values
    ADD CONSTRAINT entity_values_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: entity_values entity_values_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_values
    ADD CONSTRAINT entity_values_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entitys entitys_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_entity_type_id_fkey FOREIGN KEY (entity_type_id) REFERENCES public.entity_types(entity_type_id);


--
-- Name: entitys entitys_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: entitys entitys_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_languages(sys_language_id);


--
-- Name: entitys entitys_use_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitys
    ADD CONSTRAINT entitys_use_key_id_fkey FOREIGN KEY (use_key_id) REFERENCES public.use_keys(use_key_id);


--
-- Name: entry_forms entry_forms_entered_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms
    ADD CONSTRAINT entry_forms_entered_by_id_fkey FOREIGN KEY (entered_by_id) REFERENCES public.entitys(entity_id);


--
-- Name: entry_forms entry_forms_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms
    ADD CONSTRAINT entry_forms_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: entry_forms entry_forms_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms
    ADD CONSTRAINT entry_forms_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(form_id);


--
-- Name: entry_forms entry_forms_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entry_forms
    ADD CONSTRAINT entry_forms_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: et_fields et_fields_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.et_fields
    ADD CONSTRAINT et_fields_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: fee_payments fee_payments_accountant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_accountant_id_fkey FOREIGN KEY (accountant_id) REFERENCES public.accountants(accountant_id);


--
-- Name: fee_payments fee_payments_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: fee_payments fee_payments_payment_mode_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_payment_mode_id_fkey FOREIGN KEY (payment_mode_id) REFERENCES public.payment_modes(payment_mode_id);


--
-- Name: fee_payments fee_payments_school_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_school_term_id_fkey FOREIGN KEY (school_term_id) REFERENCES public.school_terms(school_term_id);


--
-- Name: fee_payments fee_payments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: fees_structure fees_structure_class_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure
    ADD CONSTRAINT fees_structure_class_level_id_fkey FOREIGN KEY (class_level_id) REFERENCES public.class_levels(class_level_id);


--
-- Name: fees_structure fees_structure_fees_structure_year_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure
    ADD CONSTRAINT fees_structure_fees_structure_year_fkey FOREIGN KEY (calendar_year_id) REFERENCES public.calendar_year(calendar_year_id);


--
-- Name: fees_structure fees_structure_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure
    ADD CONSTRAINT fees_structure_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: fees_structure fees_structure_school_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure
    ADD CONSTRAINT fees_structure_school_term_id_fkey FOREIGN KEY (school_term_id) REFERENCES public.school_terms(school_term_id);


--
-- Name: fees_structure_vote_heads fees_structure_vote_heads_fees_structure_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure_vote_heads
    ADD CONSTRAINT fees_structure_vote_heads_fees_structure_id_fkey FOREIGN KEY (fees_structure_id) REFERENCES public.fees_structure(fees_structure_id);


--
-- Name: fees_structure_vote_heads fees_structure_vote_heads_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure_vote_heads
    ADD CONSTRAINT fees_structure_vote_heads_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: fees_structure_vote_heads fees_structure_vote_heads_vote_head_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fees_structure_vote_heads
    ADD CONSTRAINT fees_structure_vote_heads_vote_head_id_fkey FOREIGN KEY (vote_head_id) REFERENCES public.vote_heads(vote_head_id);


--
-- Name: fields fields_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(form_id);


--
-- Name: fields fields_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: forms forms_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: librarians librarians_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: orgs orgs_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currency(currency_id);


--
-- Name: orgs orgs_default_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_default_country_id_fkey FOREIGN KEY (default_country_id) REFERENCES public.sys_countrys(sys_country_id);


--
-- Name: orgs orgs_parent_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_parent_org_id_fkey FOREIGN KEY (parent_org_id) REFERENCES public.orgs(org_id);


--
-- Name: payment_methods payment_methods_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: payment_modes payment_modes_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_modes
    ADD CONSTRAINT payment_modes_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: publishers publishers_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: reporting reporting_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting
    ADD CONSTRAINT reporting_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: reporting reporting_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting
    ADD CONSTRAINT reporting_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: reporting reporting_report_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting
    ADD CONSTRAINT reporting_report_to_id_fkey FOREIGN KEY (report_to_id) REFERENCES public.entitys(entity_id);


--
-- Name: school_calendar school_calendar_calendar_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar
    ADD CONSTRAINT school_calendar_calendar_year_id_fkey FOREIGN KEY (calendar_year_id) REFERENCES public.calendar_year(calendar_year_id);


--
-- Name: school_calendar school_calendar_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar
    ADD CONSTRAINT school_calendar_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: school_calendar school_calendar_school_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_calendar
    ADD CONSTRAINT school_calendar_school_term_id_fkey FOREIGN KEY (school_term_id) REFERENCES public.school_terms(school_term_id);


--
-- Name: school_terms school_terms_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school_terms
    ADD CONSTRAINT school_terms_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: streams streams_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: student_fee_invoices student_fee_invoices_class_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices
    ADD CONSTRAINT student_fee_invoices_class_level_id_fkey FOREIGN KEY (class_level_id) REFERENCES public.class_levels(class_level_id);


--
-- Name: student_fee_invoices student_fee_invoices_fee_structure_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices
    ADD CONSTRAINT student_fee_invoices_fee_structure_id_fkey FOREIGN KEY (fee_structure_id) REFERENCES public.fees_structure(fees_structure_id);


--
-- Name: student_fee_invoices student_fee_invoices_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices
    ADD CONSTRAINT student_fee_invoices_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: student_fee_invoices student_fee_invoices_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_fee_invoices
    ADD CONSTRAINT student_fee_invoices_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: students students_class_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_class_level_id_fkey FOREIGN KEY (class_level_id) REFERENCES public.class_levels(class_level_id);


--
-- Name: students students_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: students students_stream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_stream_id_fkey FOREIGN KEY (stream_id) REFERENCES public.streams(stream_id);


--
-- Name: sub_fields sub_fields_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_fields
    ADD CONSTRAINT sub_fields_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(field_id);


--
-- Name: sub_fields sub_fields_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_fields
    ADD CONSTRAINT sub_fields_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_access_entitys sys_access_entitys_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys
    ADD CONSTRAINT sys_access_entitys_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: sys_access_entitys sys_access_entitys_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys
    ADD CONSTRAINT sys_access_entitys_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_access_entitys sys_access_entitys_sys_access_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_entitys
    ADD CONSTRAINT sys_access_entitys_sys_access_level_id_fkey FOREIGN KEY (sys_access_level_id) REFERENCES public.sys_access_levels(sys_access_level_id);


--
-- Name: sys_access_levels sys_access_levels_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels
    ADD CONSTRAINT sys_access_levels_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_access_levels sys_access_levels_sys_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels
    ADD CONSTRAINT sys_access_levels_sys_country_id_fkey FOREIGN KEY (sys_country_id) REFERENCES public.sys_countrys(sys_country_id);


--
-- Name: sys_access_levels sys_access_levels_use_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_access_levels
    ADD CONSTRAINT sys_access_levels_use_key_id_fkey FOREIGN KEY (use_key_id) REFERENCES public.use_keys(use_key_id);


--
-- Name: sys_audit_details sys_audit_details_sys_audit_trail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_audit_details
    ADD CONSTRAINT sys_audit_details_sys_audit_trail_id_fkey FOREIGN KEY (sys_audit_trail_id) REFERENCES public.sys_audit_trail(sys_audit_trail_id);


--
-- Name: sys_countrys sys_countrys_sys_continent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_countrys
    ADD CONSTRAINT sys_countrys_sys_continent_id_fkey FOREIGN KEY (sys_continent_id) REFERENCES public.sys_continents(sys_continent_id);


--
-- Name: sys_dashboard sys_dashboard_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_dashboard
    ADD CONSTRAINT sys_dashboard_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: sys_dashboard sys_dashboard_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_dashboard
    ADD CONSTRAINT sys_dashboard_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_emailed sys_emailed_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emailed
    ADD CONSTRAINT sys_emailed_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_emailed sys_emailed_sys_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emailed
    ADD CONSTRAINT sys_emailed_sys_email_id_fkey FOREIGN KEY (sys_email_id) REFERENCES public.sys_emails(sys_email_id);


--
-- Name: sys_emails sys_emails_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_emails
    ADD CONSTRAINT sys_emails_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_files sys_files_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_files
    ADD CONSTRAINT sys_files_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_logins sys_logins_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_logins
    ADD CONSTRAINT sys_logins_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: sys_news sys_news_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_news
    ADD CONSTRAINT sys_news_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_queries sys_queries_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_queries
    ADD CONSTRAINT sys_queries_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_reset sys_reset_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_reset
    ADD CONSTRAINT sys_reset_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entitys(entity_id);


--
-- Name: sys_reset sys_reset_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_reset
    ADD CONSTRAINT sys_reset_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_translations sys_translations_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations
    ADD CONSTRAINT sys_translations_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: sys_translations sys_translations_sys_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations
    ADD CONSTRAINT sys_translations_sys_app_id_fkey FOREIGN KEY (sys_app_id) REFERENCES public.sys_apps(sys_app_id);


--
-- Name: sys_translations sys_translations_sys_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_translations
    ADD CONSTRAINT sys_translations_sys_language_id_fkey FOREIGN KEY (sys_language_id) REFERENCES public.sys_languages(sys_language_id);


--
-- Name: teachers teachers_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: vote_heads vote_heads_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vote_heads
    ADD CONSTRAINT vote_heads_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: workflow_logs workflow_logs_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_logs
    ADD CONSTRAINT workflow_logs_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: workflow_phases workflow_phases_approval_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_phases
    ADD CONSTRAINT workflow_phases_approval_entity_id_fkey FOREIGN KEY (approval_entity_id) REFERENCES public.entity_types(entity_type_id);


--
-- Name: workflow_phases workflow_phases_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_phases
    ADD CONSTRAINT workflow_phases_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: workflow_phases workflow_phases_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_phases
    ADD CONSTRAINT workflow_phases_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(workflow_id);


--
-- Name: workflow_sql workflow_sql_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_sql
    ADD CONSTRAINT workflow_sql_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: workflow_sql workflow_sql_workflow_phase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_sql
    ADD CONSTRAINT workflow_sql_workflow_phase_id_fkey FOREIGN KEY (workflow_phase_id) REFERENCES public.workflow_phases(workflow_phase_id);


--
-- Name: workflows workflows_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(org_id);


--
-- Name: workflows workflows_source_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_source_entity_id_fkey FOREIGN KEY (source_entity_id) REFERENCES public.entity_types(entity_type_id);


--
-- PostgreSQL database dump complete
--

