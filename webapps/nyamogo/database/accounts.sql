CREATE TABLE class_levels(
	class_level_id			serial primary key,
	org_id					integer references orgs,
	class_level_name		varchar(100),
	details					text,
	UNIQUE(org_id, class_level_name)

);
CREATE INDEX class_levels_org_id ON class_levels(org_id);

CREATE TABLE streams(
    stream_id           serial primary key,
    stream_name         varchar(120),
    org_id              integer references orgs,
    is_active           boolean default true,
    details             text
);
CREATE INDEX streams_org_id ON streams(org_id);

CREATE TABLE students(
    student_id          serial primary key,
    admission_no        varchar(120),
    org_id              integer references orgs,
    first_name 			varchar(120),
    second_name 		varchar(120),
    surname 			varchar(120),
    gender              varchar(2),
    address				varchar(120),
    dob                 date,
    fname 				varchar(120),
    mname 				varchar(120),
    mphone_no 			varchar(10),
    fphone_no 			varchar(10),
    class_level_id 		integer references class_levels,
    stream_id			integer references streams,
    is_suspended		boolean default false,
    is_active           boolean default true,
    details             text
);
CREATE INDEX students_org_id ON students(org_id);
CREATE INDEX students_class_level_id ON students(class_level_id);
CREATE INDEX students_stream_id ON students(stream_id);

CREATE TABLE accountants(
    accountant_id       serial primary key,
    accountant_name     varchar(120),
    org_id              integer references orgs,
    telno               varchar(20),
    gender              varchar(2),
    email               varchar(50),
    is_active           boolean default true,
    details             text
);
CREATE INDEX accountants_org_id ON accountants(org_id);

CREATE TABLE payment_methods(
	payment_method_id		serial primary key,
	org_id					integer references orgs,
	payment_method_name		varchar(100),
	doc_name				varchar(100),
	is_active 				boolean default true,
	details					text,
	UNIQUE(org_id, payment_method_name)

);
CREATE INDEX payment_methods_org_id ON payment_methods(org_id);

CREATE TABLE school_terms(
	school_term_id			serial primary key,
	org_id					integer references orgs,
	school_term_name		varchar(100),
	details					text,
	UNIQUE(org_id, school_term_name)

);
CREATE INDEX school_terms_org_id ON school_terms(org_id);

CREATE TABLE calendar_year(
	calendar_year_id        serial primary key,
	org_id					integer references orgs,
	calendar_year_name      varchar(20)
);
CREATE INDEX calendar_year_org_id ON calendar_year(org_id);

CREATE TABLE school_calendar(
	school_calendar_id		serial primary key,
	org_id					integer references orgs,
	calendar_year_id        integer references calendar_year,
	school_calendar_name	varchar(100),
	school_term_id 			integer references school_terms,
	start_date				date,
	end_date				date,
	school_year				varchar(4),
	details					text,
	is_current				boolean default true,
	UNIQUE(org_id, school_term_id,school_year)

);
CREATE INDEX school_calendar_org_id ON school_calendar(org_id);
CREATE INDEX school_calendar_school_term_id ON school_calendar(school_term_id);

CREATE TABLE fees_structure(
	fees_structure_id		serial primary key,
	school_term_id 			integer references school_terms,
	org_id 					integer references orgs,
	class_level_id 			integer references class_levels,
	amount					real,
	fees_structure_year		date,
	is_current				boolean default true,
	details 				text
);
CREATE INDEX fees_structure_org_id ON fees_structure(org_id);
CREATE INDEX fees_structure_school_term_id ON fees_structure(school_term_id);
CREATE INDEX fees_structure_class_level_id ON fees_structure(class_level_id);

CREATE TABLE fee_payments(
	fee_payment_id 			serial primary key,
	org_id					integer references orgs,
	school_term_id 			integer references school_terms,
	student_id				integer references students,
	accountant_id			integer references accountants,
	payment_method_id		integer references payment_methods,
	invoice_no				varchar(20),
	doc_no					varchar(100),				
	school_year				varchar(4),
	amount 					real,
	payed_by				varchar(120),
	date_payed				date default current_date,
	details					text

);
CREATE INDEX fee_payments_org_id ON fee_payments(org_id);
CREATE INDEX fee_payments_school_term_id ON fee_payments(school_term_id);
CREATE INDEX fee_payments_student_id ON fee_payments(student_id);
CREATE INDEX fee_payments_accountant_id ON fee_payments(accountant_id);
CREATE INDEX fee_payments_payment_method_id ON fee_payments(payment_method_id);


CREATE OR REPLACE VIEW vw_students AS
	SELECT class_levels.class_level_id, class_levels.class_level_name,  streams.stream_id, streams.stream_name,
	 students.org_id, students.student_id, students.admission_no, students.first_name, students.second_name, 
	 students.surname, CONCAT(students.surname,students.second_name ,students.first_name) AS student_name,
	 students.gender, students.address, students.dob, students.fname, students.mname, students.mphone_no, 
	 students.fphone_no, students.is_suspended, students.is_active, students.details
	FROM students
	INNER JOIN class_levels ON students.class_level_id = class_levels.class_level_id
	INNER JOIN streams ON students.stream_id = streams.stream_id;


CREATE OR REPLACE VIEW vw_school_calendar AS
	SELECT  school_terms.school_term_id, school_terms.school_term_name, school_calendar.school_calendar_id, 
	school_calendar.org_id, school_calendar.school_calendar_name, school_calendar.start_date, school_calendar.end_date, 
	school_calendar.school_year, school_calendar.details, school_calendar.is_current, calendar_year.calendar_year_name,
	calendar_year.calendar_year_id
	FROM school_calendar
	INNER JOIN school_terms ON school_calendar.school_term_id = school_terms.school_term_id
	INNER JOIN calendar_year ON school_calendar.calendar_year_id = school_calendar.calendar_year_id;


CREATE OR REPLACE VIEW vw_fees_structure AS
	SELECT class_levels.class_level_id, class_levels.class_level_name, school_terms.school_term_id, 
	school_terms.school_term_name, fees_structure.fees_structure_id, fees_structure.amount, 
	fees_structure.org_id, fees_structure.fees_structure_year, fees_structure.is_current, fees_structure.details
	FROM fees_structure
	INNER JOIN class_levels ON fees_structure.class_level_id = class_levels.class_level_id
	INNER JOIN school_terms ON fees_structure.school_term_id = school_terms.school_term_id;


CREATE OR REPLACE VIEW vw_fee_payments AS
	SELECT accountants.accountant_id, accountants.accountant_name,  payment_methods.payment_method_id,
	 payment_methods.payment_method_name, school_terms.school_term_id, school_terms.school_term_name, 
	 vw_students.student_id, vw_students.student_name, CONCAT(vw_students.class_level_name, vw_students.stream_name) AS class_name, 
	 fee_payments.org_id, fee_payments.fee_payment_id, fee_payments.invoice_no, 
	 fee_payments.doc_no, fee_payments.school_year, fee_payments.amount, fee_payments.payed_by, 
	 fee_payments.date_payed, fee_payments.details
	FROM fee_payments
	INNER JOIN accountants ON fee_payments.accountant_id = accountants.accountant_id
	INNER JOIN payment_methods ON fee_payments.payment_method_id = payment_methods.payment_method_id
	INNER JOIN school_terms ON fee_payments.school_term_id = school_terms.school_term_id
	INNER JOIN vw_students ON fee_payments.student_id = vw_students.student_id;

CREATE OR REPLACE VIEW calendar_year AS
	SELECT to_char(current_date, 'YYYY')::varchar(4) AS calendar_year;