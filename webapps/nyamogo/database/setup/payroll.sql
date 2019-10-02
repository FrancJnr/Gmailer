CREATE TABLE employee_types (
	employee_type_id		serial primary key,
	org_id 					integer references orgs,
	employee_type_name		varchar(50)
);
CREATE INDEX employee_types_org_id ON employee_types(org_id);

CREATE TABLE employee_designations (
	employee_designation_id		serial primary key,
	org_id 						integer references orgs,
	employee_designation_name 	varchar(50),
	duties					    text
);
CREATE INDEX employee_designations_org_id ON employee_designations(org_id);

CREATE TABLE payment_modes(
	payment_mode_id				serial primary key,
	payment_mode_name			varchar(120),
	org_id 						integer references orgs,
	is_active					boolean default true,
	details 					text
);
CREATE INDEX payment_modes_org_id ON payment_modes(org_id);

CREATE TABLE bank_branch(
	bank_branch_id				serial primary key,
	bank_name					varchar(120),
	org_id 						integer references orgs,
	branch_name 				varchar(120),
	is_active					boolean default true,
	details 					text
);
CREATE INDEX bank_branch_org_id ON bank_branch(org_id);

CREATE TABLE employees (
	employee_id					serial primary key,
	employee_type_id			integer references employee_types not null,
	employee_designation_id		integer references employee_designations not null,
	payment_mode_id 			integer references payment_modes,
	bank_branch_id				integer references bank_branch not null,
	org_id						integer references orgs not null,
	person_title				varchar(7),
	surname						varchar(50) not null,
	first_name					varchar(50) not null,
	middle_name					varchar(50),
	employee_full_name			varchar(120),
	employee_email				varchar(120),
	date_of_birth				date,
	gender						varchar(1),
	phone						varchar(120),
	marital_status 				varchar(2),
	appointment_date			date,
	exit_date					date,
	employment_terms			text,
	identity_card				varchar(50),
	basic_salary				real not null,
	bank_account				varchar(32),
	picture_file				varchar(32),
	active						boolean default true not null,
	language					varchar(320),
	previous_sal_point			varchar(16),
	current_sal_point			varchar(16),
	halt_point					varchar(16),
	field_of_study				text,
	UNIQUE(org_id, employee_id)
);
CREATE INDEX employees_employee_designation_id ON employees (employee_designation_id);
CREATE INDEX employees_payment_mode_id ON employees (payment_mode_id);
CREATE INDEX employees_employee_type_id ON employees (employee_type_id);
CREATE INDEX employees_org_id ON employees(org_id);
CREATE INDEX employees_bank_branch_id ON employees(bank_branch_id);

CREATE TABLE employee_month (
	employee_month_id		serial primary key,
	employee_id				integer references employees not null,
	org_id					integer references orgs,
	employee_month 			varchar(100),
	is_disbursed            boolean default false,
	disbursed_on			timestamp default current_timestamp,
	amount_paid 			real,
	is_paid 				boolean default false,
	doc_no 					varchar(120),		
	details					text
);
CREATE INDEX employee_month_employee_id ON employee_month (employee_id);
CREATE INDEX employee_month_org_id ON employee_month(org_id);


CREATE OR REPLACE VIEW vw_employees AS
	SELECT bank_branch.bank_branch_id, bank_branch.bank_name, bank_branch.branch_name, employee_designations.employee_designation_id,
   employee_designations.employee_designation_name, employee_types.employee_type_id, employee_types.employee_type_name,
   payment_modes.payment_mode_id, payment_modes.payment_mode_name, employees.employee_id, employees.person_title, employees.surname, employees.first_name, employees.middle_name, 
   CONCAT(surname, first_name, middle_name)::VARCHAR(120) AS employee_full_name, employees.employee_email, employees.date_of_birth, employees.gender, employees.phone, employees.marital_status, employees.appointment_date, employees.exit_date, 
   employees.employment_terms, employees.identity_card, employees.basic_salary, employees.bank_account, employees.picture_file, employees.active, employees.language, employees.previous_sal_point,
   employees.current_sal_point, employees.halt_point, employees.field_of_study
	FROM employees
	INNER JOIN bank_branch ON employees.bank_branch_id = bank_branch.bank_branch_id
	INNER JOIN employee_designations ON employees.employee_designation_id = employee_designations.employee_designation_id
	INNER JOIN employee_types ON employees.employee_type_id = employee_types.employee_type_id
	INNER JOIN payment_modes ON employees.payment_mode_id = payment_modes.payment_mode_id;


CREATE OR REPLACE VIEW vw_employee_month AS
	SELECT vw_employees.bank_branch_id, vw_employees.bank_name, vw_employees.branch_name, vw_employees.employee_designation_id, 
	vw_employees.employee_designation_name, vw_employees.employee_type_id, vw_employees.employee_type_name, vw_employees.payment_mode_id, 
	vw_employees.payment_mode_name, vw_employees.employee_id, vw_employees.person_title, vw_employees.surname, vw_employees.first_name, 
	vw_employees.middle_name, vw_employees.employee_full_name, vw_employees.employee_email, vw_employees.date_of_birth, vw_employees.gender,
	vw_employees.phone, vw_employees.marital_status, vw_employees.appointment_date, vw_employees.exit_date, vw_employees.employment_terms, 
	vw_employees.identity_card, vw_employees.basic_salary, vw_employees.bank_account, vw_employees.picture_file, vw_employees.active,
	vw_employees.language, vw_employees.previous_sal_point, vw_employees.current_sal_point, vw_employees.halt_point, vw_employees.field_of_study,
	employee_month.employee_month_id, employee_month.employee_month, 
	employee_month.is_disbursed, employee_month.disbursed_on, employee_month.is_paid, employee_month.doc_no, (vw_employees.basic_salary - employee_month.amount) unpaid,
	employee_month.amount, employee_month.details
	FROM employee_month
	INNER JOIN vw_employees ON employee_month.employee_id = vw_employees.employee_id;


CREATE OR REPLACE VIEW vw_current_periods AS
	SELECT to_char(date_trunc('Month', Month):: date, 'Month') AS period, 'process payroll for this month'
	FROM generate_series
	        ( (SELECT (to_char(current_date, 'YYYY') || '-01-01')::timestamp)
	        , (SELECT (to_char(current_date, 'YYYY') || '-12-01')::timestamp)
	        , '1 month'::interval) Month;


CREATE OR REPLACE FUNCTION process_payroll(varchar(120), varchar(120), varchar(120)) RETURNS VARCHAR (120) AS  $$
BEGIN
	INSERT INTO employee_month(employee_id, org_id, employee_month)
	SELECT employee_id, 0, $1
	FROM employees 
	WHERE employee_id NOT IN (SELECT employee_id FROM employee_month WHERE employee_month = $1);

    RETURN 'Payroll Processed Successfully';
END;
$$LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION process_payment(varchar(120), varchar(120), varchar(120)) RETURNS VARCHAR (120) AS  $$
BEGIN
	UPDATE employee_month 
	SET is_disbursed = TRUE, is_paid = TRUE
	WHERE employee_month_id = $1;

    RETURN 'Add amount';
END;
$$LANGUAGE PLPGSQL;