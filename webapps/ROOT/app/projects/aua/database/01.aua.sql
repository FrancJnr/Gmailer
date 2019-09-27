
-- Define all religions
CREATE TABLE religions (
	religion_id				 varchar(12) primary key,
	org_id					 integer references orgs,
	religion_name			 varchar(50) not null,
	details					 text,
	UNIQUE(org_id, religion_name)
);
CREATE INDEX religions_org_id ON religions(org_id);

---define campuses for the university ---
CREATE TABLE sites (
	site_id					varchar(12) primary key,
	org_id 					integer references orgs,
	site_name				varchar(120),
	active					boolean default true,
	details					text
);
CREATE INDEX sites_org_id ON sites (org_id);

--- Define all schools
CREATE TABLE schools (
	school_id			   	 varchar(12) primary key,
	org_id					 integer references orgs,
	school_name			     varchar(50) not null,
	philosopy			   	 text,
	vision				  	 text,
	mission				  	 text,
	objectives			   	 text,
	details				   	 text,
	UNIQUE(org_id, school_name)
);
CREATE INDEX schools_org_id ON schools(org_id);

-- Define the denominations it links religion
CREATE TABLE denominations (
	denomination_id			varchar(12) primary key,
	religion_id				varchar(12) not null references religions,
	org_id					integer references orgs,
	denomination_name		varchar(50) not null,
	details					text,
	UNIQUE(org_id, denomination_name)
);
CREATE INDEX denominations_religion_id ON denominations (religion_id);
CREATE INDEX denominations_org_id ON denominations (org_id);


--- Defines departments linked to schools
CREATE TABLE departments (
	department_id		    varchar(12) primary key,
	school_id				varchar(12) not null references schools,
	org_id					integer references orgs,
	department_name	    	varchar(120) not null,
	philosopy				text,
	vision					text,
	mission					text,
	objectives				text,
	exposures				text,
	oppotunities			text,
	details					text,
	UNIQUE(org_id, department_name)
);
CREATE INDEX departments_school_id ON departments (school_id);
CREATE INDEX departments_org_id ON departments (org_id);

--- Define the degree leves like pre-university, Undergradate, masters, doctrate
CREATE TABLE degree_levels (
	degree_level_id			varchar(12) primary key,
	org_id					integer references orgs,
	degree_level_name		varchar(50) not null,
	freshman				integer default 46 not null,
	sophomore				integer default 94 not null,
	junior					integer default 142 not null ,
	senior					integer default 190 not null,
	details					text,
	UNIQUE(org_id, degree_level_name)
);
CREATE INDEX degree_levels_org_id ON degree_levels (org_id);


--- Define the degrees like B.SC, B.TECH, B.ED
CREATE TABLE degrees (
	degree_id				varchar(12) primary key,
	degree_level_id			varchar(12) not null references degree_levels,
	school_id				varchar(12) not null references schools,
	org_id					integer references orgs,
	degree_name				varchar(50) not null,
	details					text,
	UNIQUE(org_id, degree_name)
);
CREATE INDEX degrees_degree_level_id ON degrees (degree_level_id);
CREATE INDEX degrees_school_id ON degrees (school_id);
CREATE INDEX degrees_org_id ON degrees (org_id);

--- Define all specializations
CREATE TABLE specializations (
	specialization_id		serial primary key,
	org_id					integer references orgs,
	degree_id				varchar(12) references degrees,
	specialization_name		varchar(75) not null unique,
	min_level				real not null default 100,
	max_level 				real default 400,
	details					text,
	UNIQUE(org_id, degree_id, specialization_name)
);
CREATE INDEX specializations_degree_id ON specializations (degree_id);
CREATE INDEX specializations_org_id ON specializations(org_id);

--- Define all majors
CREATE TABLE majors (
	major_id				varchar(12) primary key,
	org_id					integer references orgs,
	major_name				varchar(75) not null unique,
	major					boolean default false not null,
	minor					boolean default false not null,
	full_credit				integer default 200 not null,
	elective_credit			integer not null,
	minor_elective_credit	integer not null,
	major_minimal			real,
	minor_minimum			real,
	core_minimum			real,
	min_level				integer not null default 100,
	max_level				integer not null default 400,
	details					text,

	UNIQUE(org_id, major_name)
);
CREATE INDEX majors_org_id ON majors(org_id);

--- Define all grades
CREATE TABLE grades (
	grade_id				serial primary key,
	org_id					integer references orgs,
	grade_name				varchar(2),
	grade_weight			float default 0 not null,
	min_range				integer default 0,
	max_range				integer default 0,
	gpa_count				boolean default true not null,
	narrative				varchar(240),
	details					text,
	UNIQUE(org_id, grade_name)
);
CREATE INDEX grades_org_id ON grades (org_id);

--- Define marks and marks weight used in high school
CREATE TABLE marks (
	mark_id					serial primary key,
	org_id					integer references orgs,
	grade					varchar(2) not null,
	mark_weight				integer default 0 not null,
	narrative				varchar(240)
);
CREATE INDEX marks_org_id ON marks (org_id);

--- Define the subjects used in high school
CREATE TABLE subjects (
	subject_id				integer primary key,
	org_id					integer references orgs,
	subject_name			varchar(25) not null,
	narrative				varchar(240),
	UNIQUE(org_id, subject_name)
);
CREATE INDEX subjects_org_id ON subjects (org_id);


--- Define all campuses for the university
CREATE TABLE level_locations (
	level_location_id		serial primary key,
	org_id					integer references orgs,
	level_location_name		varchar(50) not null,
	details					text,

	UNIQUE(org_id, level_location_name)
);
CREATE INDEX level_locations_org_id ON level_locations(org_id);

--- Define all instructors categories
CREATE TABLE lecturer_categories (
	lecturer_category_id	serial primary key,
	org_id					integer references orgs,
	lecturer_category_name	varchar(50) not null,
	details					text,

	UNIQUE(org_id, lecturer_category_name)
);
CREATE INDEX lecturer_categories_org_id ON lecturer_categories(org_id);

CREATE TABLE instructors (
	instructor_id			varchar(12) primary key,
	lecturer_category_id	integer references lecturer_categories,
	school_id               varchar(50) references schools,			
	sys_country_id			char(2) references sys_countrys,
	entity_id				integer references entitys,
	org_id					integer references orgs,
	site_id   				varchar(12) references sites default 'Main',
	instructor_name			varchar(50) not null,
	photo_file				varchar(120),
	post_office_box			varchar(50),
	postal_code				varchar(12),
	premises				varchar(120),
	street					varchar(120),
	town					varchar(50),
	phone_number			varchar(150),
	mobile					varchar(150),
	email					varchar(120),
	details					text
);

CREATE INDEX instructors_school_id ON instructors (school_id);
CREATE INDEX instructors_sys_country_id ON instructors(sys_country_id);
CREATE INDEX instructors_site_id ON instructors(site_id);
CREATE INDEX instructors_org_id ON instructors(org_id);


---define cohort groups----
CREATE TABLE cohorts (
	cohort_id	 			serial primary key,
	degree_id				varchar(12) references degrees,
	school_id	 			varchar(12) references schools,
	org_id		 			integer references orgs,
	cohort_name	 			varchar(120) not null,
	site_id	 			    varchar(120) references sites,
	max_number				integer,
	start_date				date,
	end_date				date,
	is_active				boolean default false,
	cohort_open			    boolean default false,
	description	 			text,
	UNIQUE(org_id, cohort_name)
);
CREATE INDEX cohorts_degree_id ON cohorts (degree_id);
CREATE INDEX cohorts_school_id ON cohorts (school_id);
CREATE INDEX cohorts_site_id ON cohorts (site_id);
CREATE INDEX cohorts_org_id ON cohorts (org_id);


-- Define all residences
CREATE TABLE residences (
	residence_id			serial primary key,
	site_id					varchar(12) references sites,
	org_id					integer references orgs,
	residence_name			varchar(50) not null,
	capacity				integer default 120 not null,
	room_size				integer default 4 not null,
	default_rate			float default 0 not null,
	off_campus				boolean default false not null ,
	Sex						varchar(1),
	residence_dean			varchar(50),
	details					text,

	UNIQUE(org_id, residence_name)
);
CREATE INDEX residences_org_id ON residences(org_id);

-- Define types of rooms---
CREATE TABLE room_types (
	room_type_id			serial primary key,
	org_id					integer references orgs,
	room_type_name			varchar(50) not null,
	max_occupants			varchar(50) not null,
	details					text,

	UNIQUE(org_id, room_type_name)
);
CREATE INDEX room_types_org_id ON room_types(org_id);

-- Define all rooms housed in a residential hall
CREATE TABLE rooms (
	room_id			        serial primary key,
	residence_id		    integer references residences,
	org_id					integer references orgs,
	room_type_id			integer references room_types,
	room_name				varchar(50) not null,
	room_charge				float default 0 not null,
	is_booked   			boolean default false,
	is_checked_out   		boolean default false,
	checkout_date 			date,
	room_count 				integer,
	status 					varchar(50),
	details					text,

	UNIQUE(org_id, room_name)
);
CREATE INDEX rooms_room_type_id ON rooms(room_type_id);
CREATE INDEX rooms_residence_id ON rooms(residence_id);
CREATE INDEX rooms_org_id ON rooms(org_id);

-- Define all rooms used for study and labs
CREATE TABLE assets (
	asset_id				serial primary key,
	site_id 				varchar(120) references sites,
	org_id					integer references orgs,
	asset_name				varchar(50) not null,
	building				varchar(50),
	location				varchar(50),
	capacity				integer not null,
	details					text,

	UNIQUE(org_id, asset_name)
);
CREATE INDEX assets_org_id ON assets(org_id);


--- Define different course types
CREATE TABLE course_types (
	course_type_id			serial primary key,
	org_id					integer references orgs,
	course_type_name		varchar(50) not null,
	details					text,

	UNIQUE(org_id, course_type_name)
);
CREATE INDEX course_types_org_id ON course_types(org_id);

---define modes of study per course--
CREATE TABLE course_modes (
	course_mode_id			serial primary key,
	org_id					integer references orgs,
	course_mode_name		varchar(50),
	details					text,

	UNIQUE(org_id, course_mode_name)

);
CREATE INDEX course_modes_org_id ON course_modes(org_id);

--- Define all course listed
CREATE TABLE courses (
	course_id				varchar(12) primary key,
	course_mode_id			integer references course_modes,
	degree_level_id			varchar(12) references degree_levels default 'MA',
	course_type_id			integer references course_types default 1,
	school_id               varchar(50) references schools,
	org_id					integer references orgs,
	course_title			varchar(120) not null,
	lab_course				boolean default false not null,
	min_credit				float  default 0 not null,
	max_credit				float  default 5 not null,
	lecture_hours			float not null default 0,
	practical_hours		 	float not null default 0,
	credit_hours			float not null,
	is_current				boolean  default true not null,
	no_gpa					boolean  default false not null,
	no_repeats				boolean  default false not null,
	extra_charge			float default 0 not null,
	year_taken				integer  default 1 not null,
	details					text,

	UNIQUE(org_id, course_id, course_title)
);
CREATE INDEX courses_degree_level_id ON courses (degree_level_id);
CREATE INDEX courses_course_type_id ON courses (course_type_id);
CREATE INDEX courses_course_mode_id ON courses (course_mode_id);
CREATE INDEX courses_org_id ON courses(org_id);
CREATE INDEX courses_school_id ON courses(school_id);

--- Define all academic sessions of the university
CREATE TABLE sessions (
	session_id				varchar(120) primary key,
	cohort_id				integer references cohorts,
	org_id					integer references orgs,
	session_year			varchar(9) not null,
	semister				integer,
	site					varchar(50),
	session_start			date default current_date,
	slate_reg				date  default current_date + interval '3 weeks',
	slate_change			date  default current_date + interval '3 weeks',
	slast_drop				date default current_date + interval '3 weeks',
	session_end				date not null,
	active					boolean default false not null,
	session_closed			boolean default false not null,
	session_name			varchar(32),
	min_credits				real not null default 16,
	max_credits				real not null default 21,
	charge_rate				float  default 75 not null,
	late_registration_fee 	float default 0,
	details					text,
	pre_session 			boolean default true,
	post_session 			boolean default false
);
CREATE INDEX sessions_active ON sessions (active);
CREATE INDEX sessions_org_id ON sessions (org_id);


----define courses for a cohort------
CREATE TABLE cohort_courses(
cohort_course_id 			serial primary key,
org_id						integer references orgs,
cohort_id                   integer references cohorts,
course_id					varchar(12) references courses,
instructor_id				varchar(12) references instructors,
session_id					varchar(12) references sessions

);
CREATE INDEX cohort_courses_org_id ON cohort_courses (org_id);
CREATE INDEX cohort_courses_course_id ON cohort_courses (course_id);
CREATE INDEX cohort_courses_cohort_id ON cohort_courses (cohort_id);
CREATE INDEX cohort_courses_instructor_id ON cohort_courses (instructor_id);
CREATE INDEX cohort_courses_session_id ON cohort_courses (session_id);

----define courses for specializations------
CREATE TABLE course_specializations(
course_specialization_id	serial primary key,
cohort_course_id 			integer references cohort_courses,
specialization_id           integer references specializations,
org_id						integer references orgs
);
CREATE INDEX course_specializations_org_id ON course_specializations (org_id);
CREATE INDEX course_specializations_cohort_course_id ON course_specializations (cohort_course_id);
CREATE INDEX course_specializations_specialization_id ON course_specializations (specialization_id);

--- Define different bulletingss
CREATE TABLE bulletings (
	bulletings_id			serial primary key,
	org_id					integer references orgs,
 	bulletings_name			varchar(50) not null,
	starting_session		varchar(12),
	ending_session			varchar(12),
	active					boolean not null default false,
	details					text,

	UNIQUE(org_id, bulletings_name)
);
CREATE INDEX bulletings_org_id ON bulletings(org_id);

--- Define prerequisites of courses
CREATE TABLE prerequisites (
	prerequisite_id			serial primary key,
	course_id				varchar(12) not null references courses,
	precourse_id			varchar(12) not null references courses,
	grade_id				integer not null references grades,
	org_id					integer references orgs,
	bulletings_id           integer references bulletings,
	option_level			integer  default 1 not null,
	narrative				varchar(120),

	UNIQUE(course_id, precourse_id)
);
CREATE INDEX prerequisites_course_id ON prerequisites (course_id);
CREATE INDEX prerequisites_precourse_id ON prerequisites (precourse_id);
CREATE INDEX prerequisites_grade_id ON prerequisites (grade_id);
CREATE INDEX prerequisites_org_id ON prerequisites(org_id);
CREATE INDEX prerequisites_bulletings_id ON prerequisites(bulletings_id);


--- Define different content types like elective, cognates, premajors
CREATE TABLE content_types (
	content_type_id			serial primary key,
	org_id					integer references orgs,
	content_type_name		varchar(50) not null,
	elective				boolean default false not null,
	prerequisite			boolean default false not null,
	pre_major				boolean default false not null,
	details					text,
	UNIQUE (org_id, content_type_name)
);
CREATE INDEX content_types_org_id ON content_types(org_id);

--- Define requirements for acceptance to a major
CREATE TABLE requirements (
	requirement_id			serial primary key,
	major_id				varchar(12) not null references majors,
	subject_id				integer not null references subjects,
	mark_id					integer references marks,
	org_id					integer references orgs,
	narrative				varchar(240),
	UNIQUE(major_id, subject_id)

);
CREATE INDEX requirements_major_id ON requirements (major_id);
CREATE INDEX requirements_subjectid ON requirements (subject_id);
CREATE INDEX requirements_markid ON requirements (mark_id);
CREATE INDEX requirements_org_id ON requirements(org_id);

--- Define all major courses
CREATE TABLE major_contents (
	major_content_id		serial primary key,
	major_id				varchar(12) not null references majors,
	course_id				varchar(12) not null references courses,
	content_type_id			integer not null references content_types,
	grade_id				integer not null references grades,
	bulletings_id			integer references bulletings,
	org_id					integer references orgs,
	minor					boolean default false not null,
	narrative				varchar(240),
	UNIQUE (major_id, course_id, content_type_id, minor, bulletings_id)
);
CREATE INDEX major_contents_org_id ON major_contents (org_id);
CREATE INDEX major_contents_major_id ON major_contents (major_id);
CREATE INDEX major_contents_course_id ON major_contents (course_id);
CREATE INDEX major_contents_content_type_id ON major_contents (content_type_id);
CREATE INDEX major_contents_grade_id ON major_contents (grade_id);
CREATE INDEX major_contents_bulletings_id ON major_contents (bulletings_id);

---types of sponsors---
CREATE TABLE sponsor_types (
	sponsor_type_id			serial primary key,
	org_id  				integer references orgs,
	sponsor_type_name		varchar(50),
	details					text
);
CREATE INDEX sponsor_types_org_id ON sponsor_types (org_id);

CREATE TABLE sponsor_categorys (
	sponsor_category_id		serial primary key,
	org_id					integer references orgs,
	sponsor_category_name	varchar(120) not null,
	active					boolean default true not null,
	details					text,
	UNIQUE(org_id, sponsor_category_name)
);
CREATE INDEX sponsor_categorys_org_id ON sponsor_categorys(org_id);

 --sponsors---
CREATE TABLE sponsors (
	sponsor_id				serial primary key,
	sponsor_type_id			integer references sponsor_types,
	sponsor_category_id		integer references sponsor_categorys,
	ln_sponsor_id			integer references sponsors,
	org_id					integer references orgs,
	sponsor_name			varchar(50),
	address					varchar(50),
	street					varchar(50),
	postal_code				varchar(50),
	town					varchar(50),
	sys_country_id			char(2) references sys_countrys,
	telno					varchar(50),
	email					varchar(240),
	wage_factor				real not null default 1,
	active					boolean default true not null,
	details					text
);
CREATE INDEX sponsors_ln_sponsor_id ON sponsors (ln_sponsor_id);
CREATE INDEX sponsors_country_id ON sponsors (sys_country_id);
CREATE INDEX sponsors_org_id ON sponsors (org_id);;

--disabilities--
CREATE TABLE disabilitys (
	disabilitys_id			serial primary key,
	org_id					integer references orgs,
	disabilitys_name		varchar(240) not null
);
CREATE INDEX disabilitys_org_id ON disabilitys(org_id);

--- Table for all students it links to school and denomination
CREATE TABLE students (
	student_id				varchar(12) primary key,
	sponsor_id				integer references sponsors,
	school_id				varchar(50) references schools,
	denomination_id			varchar(12) references denominations ,
	residence_id			integer references residences,
	disabilitys_id			integer references disabilitys,
	entity_id				integer references entitys,
	sys_audit_trail_id		integer references sys_audit_trail,
	country_code_id			char(2)  references sys_countrys default 'KE',
	org_id					integer references orgs,
	student_name			varchar(150) not null,
	surname					varchar(150) not null,
	first_name				varchar(150) not null,
	other_names				varchar(150),
	room_number				integer,
	Sex						varchar(1),
	first_pass				varchar(120),
	student_pass			varchar(120),
	new_student				boolean default true not null,
	nationality				varchar(2)  references sys_countrys default 'KE',
	marital_status			varchar(2),
	birth_date				date default current_date,
	address					varchar(250),
	zipcode					varchar(150),
	town					varchar(150),
	tel_no					varchar(150),
	email					varchar(240),
	account_number			varchar(150),
	admission_basis			varchar(240),
	staff					boolean default false not null,
	alumnae					boolean default false not null ,
	post_contacts			boolean default false not null ,
	on_probation			boolean default false not null ,
	onhold					boolean not null default false,
	off_campus				boolean default false not null ,
	full_bursary			boolean default false not null,
	student_edit			varchar(50) default 'none' not null,
	disability              boolean default false,
	disabilitys_details 	text,
	passport				boolean default false,
	national_id				boolean default false,
	identification_no		varchar(20),
	picture_file			varchar(240),
	current_contact			text,
	current_email			varchar(120),
	current_tel				varchar(120),
	balance_time			timestamp,
	curr_balance			real default 0,
	probation_details		text,
	see_registrar			boolean default false not null,
	details					text
);

CREATE INDEX students_school_id ON students (school_id);
CREATE INDEX students_org_id ON students (org_id);
CREATE INDEX students_denomination_id ON students (denomination_id);
CREATE INDEX students_nationality ON students (nationality);
CREATE INDEX students_residence_id ON students (residence_id);
CREATE INDEX students_disabilitys_id ON students (disabilitys_id);
CREATE INDEX students_country_code_id ON students (country_code_id);
CREATE INDEX students_account_number ON students (account_number);
CREATE INDEX students_entity_id ON students (entity_id);
CREATE INDEX students_sys_audit_trail_id ON students (sys_audit_trail_id);

--- Define the degree undertaken by a student----
CREATE TABLE student_degrees (
	student_degree_id		serial primary key,
	cohort_id				integer references cohorts not null,
	student_id				varchar(12) not null references students,
	bulletings_id			integer not null references bulletings,
	site_id					varchar(12) references sites,
	org_id					integer references orgs,
	completed				boolean default false not null ,
	started					date,
	cleared					boolean default false not null ,
	clear_date				date,
	graduation_apply		boolean default false not null ,
	graduated				boolean default false not null ,
	graduate_date			date,
	drop_out				boolean default false not null ,
	transfer_in				boolean default false not null ,
	transfer_out			boolean default false not null ,
	admission_basis			varchar(240),
	transcripted			boolean default false not null ,
	transcript				boolean default false not null ,
	transcript_date			date,
	details					text,

	UNIQUE(student_id, cohort_id, site_id, cleared)
);
CREATE INDEX student_degrees_student_id ON student_degrees (student_id);
CREATE INDEX student_degrees_bulletings_id ON student_degrees (bulletings_id);
CREATE INDEX student_degrees_center_id ON student_degrees (site_id);
CREATE INDEX student_degrees_org_id ON student_degrees (org_id);

--- Keep a log for transcripts printed
CREATE TABLE transcript_print (
	transcript_print_id		serial primary key,
	student_degree_id		integer not null references student_degrees,
	entity_id				integer references entitys,
	org_id					integer references orgs,
	ip_address				varchar(64),
	link_key				varchar(64),
	accepted				boolean default false not null,
	user_id					integer,
	print_date				timestamp default now(),
	narrative				varchar(240)
);
CREATE INDEX transcript_print_student_degree_id ON transcript_print (student_degree_id);
CREATE INDEX transcript_print_entity_id ON transcript_print (entity_id);
CREATE INDEX transcript_print_user_id ON transcript_print (user_id);
CREATE INDEX transcript_print_student_org_id ON transcript_print (org_id);

--- Table for all majors taken by students---
CREATE TABLE student_specializations (
	student_specialization_id  serial primary key,
	student_degree_id			integer not null references student_degrees,
	specialization_id			integer not null references specializations,
	org_id						integer references orgs,
	major						boolean default false not null,
	primary_major				boolean default false not null,
	non_degree					boolean default false not null,
	pre_major					boolean default false not null,
	Details						text,
	UNIQUE(student_degree_id, specialization_id)
);
CREATE INDEX student_specializations_student_degree_id ON student_specializations (student_degree_id);
CREATE INDEX student_specializations_specialization_id ON student_specializations (specialization_id);
CREATE INDEX student_specializations_org_id ON student_specializations (org_id);

--- table to indicate all credit transfers linked to a student----
CREATE TABLE transfered_credits (
	transfered_credit_id	serial primary key,
	student_degree_id		integer not null references student_degrees,
	course_id				varchar(12) not null references courses,
	org_id					integer references orgs,
	credit_hours			float default 0 not null,
	narrative				varchar(240),
	UNIQUE (student_degree_id, course_id)
);
CREATE INDEX transfered_credits_student_degree_id ON transfered_credits (student_degree_id);
CREATE INDEX transfered_credits_course_id ON transfered_credits (course_id);
CREATE INDEX transfered_credits_org_id ON transfered_credits (org_id);

--- Define different request types a student can make----
CREATE TABLE request_types (
	request_type_id			serial primary key,
	org_id					integer references orgs,
	request_type_name		varchar(50) not null,
	request_email			varchar(240),
	to_approve				boolean default false not null ,
	details 				text,
	UNIQUE (org_id, request_type_name)
);
CREATE INDEX request_types_org_id ON request_types (org_id);

--- Table listing all request sent by students and the responses
CREATE TABLE student_requests (
	student_request_id		serial primary key,
	student_id				varchar(12) references students,
	request_type_id			integer references request_types,
	org_id					integer references orgs,
	subject                 varchar(100) not null,
	narrative				varchar(240) not null,
	date_sent				timestamp  default now() not null,
	actioned				boolean default false not null ,
	date_actioned			timestamp,
	approved				boolean default false not null ,
	date_apploved			timestamp,
	details					text,
	reply					text
);
CREATE INDEX student_requests_student_id ON student_requests (student_id);
CREATE INDEX student_requests_request_type_id ON student_requests (request_type_id);
CREATE INDEX student_requests_org_id ON student_requests (org_id);

----define event types----
CREATE TABLE event_types (
	event_type_id			serial primary key,
	org_id					integer references orgs,
	event_type_name			varchar(120),
	details					text
);
CREATE INDEX event_types_org_id ON event_types (org_id);

--- Define the calender for each academic session---
CREATE TABLE scalendars (
	scalendar_id			serial primary key,
	org_id					integer references orgs,
	event_type_id			integer references event_types,
	session_id				varchar(12) references sessions,
	sdate					date not null,
	send_date				date not null,
	event_name				varchar(120),
	details					text
);
CREATE INDEX scalendars_session_id ON scalendars (session_id);
CREATE INDEX scalendars_org_id ON scalendars (org_id);

--- Define residence charges per academic session
CREATE TABLE sresidences (
	sresidence_id			serial	 primary key,
	session_id				varchar(12) not null references sessions,
	residence_id			integer not null references residences,
	org_id					integer references orgs,
	residence_option		varchar(50) not null default 'Full',
	active					boolean not null default true,
	details					text,
	UNIQUE (session_id, residence_id)
);
CREATE INDEX sresidences_session_id ON sresidences (session_id);
CREATE INDEX sresidences_residence_id ON sresidences (residence_id);
CREATE INDEX sresidences_org_id ON sresidences (org_id);

--session scharges----
CREATE TABLE scharges (
	scharge_id				serial primary key,
	session_id				varchar(12) references sessions,
	org_id					integer references orgs,
	sponsor_id				integer references sponsors,
	sponsor_country         varchar(2) references sys_countrys,
	exchange_rate			real default 1 not null,
	accomodation_charge     real,
	wage_factor             real,
	narrative				varchar(120),
	UNIQUE (session_id)
);
CREATE INDEX scharges_session_id ON scharges (session_id);
CREATE INDEX scharges_org_id ON scharges (org_id);

---- Table for details of a student per session----
CREATE TABLE sstudents (
	sstudent_id		        serial primary key,
	session_id				varchar(12) not null references sessions,
	scharge_id				integer references scharges,
	student_degree_id		integer not null references student_degrees,
	sresidence_id			integer not null references sresidences,
	sys_audit_trail_id		integer references sys_audit_trail,
	org_id					integer references orgs,
	extra_charges			float default 0 not null,
	charges					float default 0 not null,
	probation				boolean default false not null,
	off_campus				boolean default false not null,
	block_name				varchar(12),
	room_id			    	integer references rooms,
	curr_balance			real,
	balance_time			timestamp,
	study_level				integer,
	application_time		timestamp  default now() not null,
	first_close_time		timestamp,
	finalised				boolean default false not null,
	residence_fund			float  default 0 not null,
	fee_refund				float  default 0 not null,
	cleared_finance			boolean default false not null,
	finance_approval		boolean default false not null,
	major_approval			boolean default false not null,
	depart_approval			boolean default false not null,
	chaplain_approval		boolean default false not null,
	student_dean_approval	boolean default false not null,
	overload_approval		boolean default false not null,
	overload_hours			float,
	finance_closed			boolean  default false not null,------addition--
	closed					boolean default false not null, ------addition--,
	registrar_approval 		boolean default false not null,------addition--,
	ict_approval   		    boolean default false,
	residence_approval      boolean default false,
	approved				boolean default false not null,
	approved_date			timestamp,
	on_probation			boolean default false not null,
	on_attachment			boolean default false not null,
	Picked					boolean default false not null,
	picked_date				timestamp,
	LRF_picked				boolean default false not null,
	LRF_picked_date			timestamp,
	inter_session			boolean default false not null,
	late_fee_amount			real,
	late_fee_date			date,
	payment_type 			varchar(120), 
	approve_late_fee		boolean default false not null,
	hours					real,
	printed					boolean default false not null,
	record_posted			boolean default false not null,
	post_changed			boolean default false not null,
	request_withdraw		boolean default false not null,
	request_withdraw_date	timestamp,
	withdraw				boolean default false not null,
	ac_withdraw				boolean default false not null,
	withdraw_date			date,
	withdraw_rate			real,
	exam_clear				boolean default false not null,
	exam_clear_date			timestamp,
	exam_clear_balance		real,
	first_instalment		real,
	first_date				date,
	second_instalment		real,
	second_date				date,
	changed_by				integer,
	finance_narrative		text,
	no_approval				text,
	details					text,

	UNIQUE(session_id, student_degree_id)		--- change the constraint
);
CREATE INDEX sstudents_session_id ON sstudents (session_id);
CREATE INDEX sstudents_student_degree_id ON sstudents (student_degree_id);
CREATE INDEX sstudents_charge_id ON sstudents (scharge_id);  --- add the sub charge clause
CREATE INDEX sstudents_org_id ON sstudents (org_id);
CREATE INDEX sstudents_sys_audit_trail_id ON sstudents (sys_audit_trail_id);


--- Posting for all credit to student payments
CREATE TABLE student_payments (
	student_payment_id		serial primary key,
	student_id				varchar not null references students,
	org_id					integer references orgs,
	apply_date				timestamp not null default now(),
	transaction_amount		real not null,
	customer_reference		varchar(25) not null unique,
	transaction_date		date not null,
	value_date				date,
	transaction_detail		varchar(240),
	transaction_type		integer,
	suspence				boolean default false not null,
	approved				boolean not null default false,
	approved_time			timestamp,
	picked					boolean default false not null,
	picked_date				timestamp,
	terminal_id				varchar(12),
	narrative				varchar(240),
	unique(org_id, customer_reference)
);
CREATE INDEX student_payments_student_id ON student_payments (student_id);
CREATE INDEX student_payments_org_id ON student_payments (org_id);

---scholarships types----
CREATE TABLE scholarship_types (
	scholarship_type_id		serial primary key,
	org_id 					integer references orgs,
	scholarship_type_name	varchar(50) not null,
	scholarship_account		varchar(12),
	details					text,

	unique(org_id, scholarship_type_name)
);
CREATE INDEX scholarship_types_org_id ON scholarship_types (org_id);

---scholarships types----
CREATE TABLE scholarships (
	scholarship_id			serial primary key,
	scholarship_type_id		integer references scholarship_types,
	student_id				varchar(12) references students,
	session_id				varchar(12) references sessions,
	entry_date				date not null default current_date,
	payment_date			date not null,
	amount					real not null,
	approved				boolean not null default false,
	Approved_date			timestamp,
	posted					boolean not null default false,
	date_posted				timestamp,
	details					text
);
CREATE INDEX scholarships_scholarship_type_id ON scholarships (scholarship_type_id);
CREATE INDEX scholarships_student_id ON scholarships (student_id);
CREATE INDEX scholarships_session_id ON scholarships (session_id);

-- approval_types--
CREATE TABLE approval_types (
	approval_type_id		serial primary key,
	org_id					integer references orgs,
	approval_type_name		varchar(50) not null,
	is_active				boolean default true not null,
	approval_order			integer default 1 not null,
	details					text,

	UNIQUE(org_id, approval_type_name)
);
CREATE INDEX approval_types_org_id ON approval_types (org_id);

--- Audit list of all aproval done for a students sessions application
CREATE TABLE approval_list (
	approval_id				serial primary key,
	approval_type_id		integer references approval_types,
	student_id				varchar(20) not null references students,
	sstudent_id				integer references sstudents,
	org_id					integer references orgs,
	approved_by				varchar(50),
	approval_type			varchar(25),
	approve_date			timestamp default now(),
	client_ip				varchar(25),
	approved				boolean default false,
	approved_on  			TIMESTAMP,

	UNIQUE(org_id,student_id)
);
CREATE INDEX approval_list_student_id ON approval_list (student_id);
CREATE INDEX approval_list_org_id ON approval_list (org_id);

--- Table for all courses done per in a session---
CREATE TABLE scourses (
	scourse_id				serial primary key,
	session_id				varchar(12) not null references sessions,
	instructor_id			varchar(50) not null references instructors,
	course_id				varchar(12) not null references courses,
	site_id					varchar(12) references sites,
	level_location_id		integer references level_locations, --- addition on course location
	org_id					integer references orgs,
	course_title			varchar(120),
	class_option			varchar(50) default 'Main' not null,
	max_class				integer not null,
	course_charge			float default 0 not null,
	approved				boolean default false not null,
	lecture_submit			boolean default false not null,
	lecture_submit_date		timestamp default now(),
	department_submit		boolean default false not null,
	department_submit_date	timestamp default now(),
	faculty_submit			boolean default false not null,
	faculty_submit_date		timestamp default now(),
	attendance				integer,
	lab_course				boolean default false not null,
	examinable				boolean default false not null,
	clinical_fee			float default 0 not null,
	extra_charge			float default 0 not null,
	full_attendance			integer,
	attachement				boolean default false not null,
	exam_submited			boolean default false not null,
	grade_submited 			boolean default false not null,
	submit_grades			boolean default false not null,
	submit_date				timestamp,
	approved_grades			boolean default false not null,
	approve_date			timestamp,
	department_change		varchar(240),
	registry_change			varchar(240),
	details					text,
	UNIQUE (instructor_id, course_id, session_id, class_option,org_id)
);
CREATE INDEX scourses_session_id ON scourses (session_id);
CREATE INDEX scourses_instructor_id ON scourses (instructor_id);
CREATE INDEX scourses_course_id ON scourses (course_id);
CREATE INDEX scourses_org_id ON scourses (org_id);
CREATE INDEX scourses_level_location_id ON scourses (level_location_id);  --- addition on scourse for location index

--- Table for option for time for the time table
CREATE TABLE option_times (
	option_time_id			serial primary key,
	org_id					integer references orgs,
	option_time_name		varchar(50),
	details					text,
	UNIQUE (org_id)
);
CREATE INDEX option_times_org_id ON option_times (org_id);


--- Table for class timetable for each course in a session
CREATE TABLE stimetables (
	stimetable_id			serial primary key,
	asset_id				integer not null references assets,
	scourse_id				integer not null references scourses,
	option_time_id			integer not null references option_times default 0,
	org_id					integer references orgs,
	c_monday				boolean default false not null ,
	c_tuesday				boolean default false not null ,
	c_wednesday				boolean default false not null ,
	c_thursday				boolean default false not null ,
	c_friday				boolean default false not null ,
	c_saturday				boolean default false not null ,
	c_sunday				boolean default false not null ,
	end_date                date,
	start_date              date,
	start_time				time not null,
	end_time				time not null,
	lab						boolean default false not null ,
	details					text,
	UNIQUE (org_id)
);
CREATE INDEX stimetable_asset_id ON stimetables (asset_id);
CREATE INDEX stimetable_scourse_id ON stimetables (scourse_id);
CREATE INDEX stimetable_option_time_id ON stimetables (option_time_id);
CREATE INDEX stimetable_org_id ON stimetables (org_id);

--- Table for exam time table---
CREATE TABLE sexam_timetable (
	sexam_timetable_id		serial primary key,
	asset_id				integer not null references assets,
	scourse_id				integer not null references scourses,
	option_time_id			integer default 0 not null references option_times ,
	org_id					integer references orgs,
	exam_date				date,
	start_time				time not null,
	end_time				time not null,
	lab						boolean default false not null ,
	details					text,
	UNIQUE (org_id,asset_id)
);
CREATE INDEX sexam_timetable_asset_id ON sexam_timetable (asset_id);
CREATE INDEX sexam_timetable_scourse_id ON sexam_timetable (scourse_id);
CREATE INDEX sexam_timetable_option_time_id ON sexam_timetable (option_time_id);
CREATE INDEX sexam_timetable_org_id ON sexam_timetable (org_id);

--- Table that indicate all courses done by student and the grades----
CREATE TABLE sgrades (
	sgrade_id 				serial primary key,
	sstudent_id				integer not null references sstudents,
	scourse_id				integer not null references scourses,
	grade_id				integer not null references grades DEFAULT 12,
	option_time_id			integer references option_times default 0,
	sys_audit_trail_id		integer references sys_audit_trail,
	org_id					integer references orgs,
	hours					float not null,
	credit					float not null,
	department_marks		real,--addition
	final_marks				real,
	selection_date			timestamp default now(),
	approved        		boolean default false not null ,
	approve_date			timestamp,
	ask_drop				boolean default false not null ,
	ask_drop_date			timestamp,
	dropped					boolean default false not null ,
	drop_date				date,
	repeated				boolean default false not null ,
	non_gpa_course			boolean default false not null ,
	challenge_course		boolean default false not null ,
	repeat_approval			boolean default false not null,
	request_drop			boolean default false not null ,
	request_drop_date		timestamp,
	lecture_marks			real,
	lecture_cat_mark		real default 0 not null,
	lecture_grade_id		integer references grades,
	withdraw_date			date,
	withdraw_rate			real,
	attendance				integer,
	narrative				varchar(240),
	record_posted			boolean default false not null,
	post_changed			boolean default false not null,
	changed_by				integer,
	UNIQUE(sstudent_id, scourse_id,org_id)
);
CREATE INDEX sgrades_sstudent_id ON sgrades (sstudent_id);
CREATE INDEX sgrades_scourse_id ON sgrades (scourse_id);
CREATE INDEX sgrades_grade_id ON sgrades (grade_id);
CREATE INDEX sgrades_option_time_id ON sgrades (option_time_id);
CREATE INDEX sgrades_lecture_grade_id ON sgrades (lecture_grade_id);
CREATE INDEX sgrades_org_id ON sgrades (org_id);
CREATE INDEX sgrades_sys_audit_trail_id ON sgrades (sys_audit_trail_id);

CREATE TABLE student_majors
(
  student_major_id          serial primary key,
  student_degree_id         integer references student_degrees NOT NULL ,
  major_id                  varchar(12) references majors NOT NULL,
  org_id                    integer references orgs,
  major                     boolean NOT NULL DEFAULT false,
  primary_major             boolean NOT NULL DEFAULT false,
  non_degree                boolean NOT NULL DEFAULT false,
  pre_major                 boolean NOT NULL DEFAULT false,
  details text
);
 CREATE INDEX student_majors_student_degree_id ON student_majors(student_degree_id);
 CREATE INDEX student_majors_student_major_id ON student_majors(major_id);
 CREATE INDEX student_majors_student_org_id ON student_majors(org_id);
 
--- Audit table for any changes made to grade
CREATE TABLE grade_change_list (
	grade_change_list_id	serial primary key,
	sgrade_id				integer not null references sgrades,
	entity_id				integer references entitys,
	org_id					integer references orgs,
	changed_by				varchar(50),
	old_grade				varchar(2),
	new_grade				varchar(2),
	change_date				timestamp default now(),
	client_ip				varchar(25),
	UNIQUE(org_id)
);
CREATE INDEX grade_change_list_sgrade_id ON grade_change_list (sgrade_id);
CREATE INDEX grade_change_list_org_id ON grade_change_list (org_id);
CREATE INDEX grade_change_list_entity_id ON grade_change_list (entity_id);

--- Table indicating items for each courses like cats, tests to help compute the grade
CREATE TABLE scourse_items (
	scourse_item_id			serial primary key,
	scourse_id				integer not null references scourses,
	org_id					integer references orgs,
	course_item_name		varchar(50),
	mark_ratio				float not null,
	total_marks				integer not null,
	given					date,
	deadline				date,
	details					text,
	UNIQUE(org_id,course_item_name)
);
CREATE INDEX scourse_items_scourse_id ON scourse_items (scourse_id);
CREATE INDEX scourse_items_org_id ON scourse_items (org_id);

--- Table to list the marks for cats and exams to help compute the course grade
CREATE TABLE scourse_marks (
	scourse_mark_id			serial primary key,
	sgrade_id				integer not null references sgrades,
	scourse_item_id			integer not null references scourse_items,
	org_id					integer references orgs,
	approved        		boolean default false not null ,
	submited				date,
	mark_date				date,
	marks					float  default 0 not null,
	details					text,
	UNIQUE(org_id)
);
CREATE INDEX scourse_marks_sgrade_id ON scourse_marks (sgrade_id);
CREATE INDEX scourse_marks_scourse_item_id ON scourse_marks (scourse_item_id);
CREATE INDEX scourse_marks_org_id ON scourse_marks (org_id);

---define imports from sunplus(student accounting system)
CREATE TABLE sun_imports (
	sun_import_id			serial primary key,
	org_id					integer references orgs,
	account_number 			varchar(125),
	student_name 			varchar(250),
	balance					real,
	download_date			date not null default current_date,
	is_uploaded				boolean not null default false

);
CREATE INDEX sun_imports_org_id ON sun_imports (org_id);


--define types of contacts
CREATE TABLE contact_types(
	contact_type_id				serial primary key,
	org_id						integer references orgs,
	contact_type_name			varchar(50),
	primary_contact				varchar(50),
	narrative 					text 
);	
CREATE INDEX contact_types_org_id ON contact_types(org_id);

--define student session charges 
CREATE TABLE student_scharges(
	student_scharge_id			serial primary key,
	org_id						integer references orgs,
	student_id					varchar(12) references students,
	scharge_id					integer references scharges,
	fees						real
);
CREATE INDEX student_scharges_org_id ON student_scharges(org_id);
CREATE INDEX student_scharges_student_id ON student_scharges(student_id);
CREATE INDEX student_scharges_scharge_id ON student_scharges(scharge_id);


CREATE TABLE database_tables AS
    SELECT  table_name 
    FROM information_schema.tables
    WHERE table_schema not in ('information_schema', 'pg_catalog') AND
    table_type = 'BASE TABLE';
    
ALTER TABLE database_tables ADD PRIMARY KEY (table_name);

CREATE TABLE sys_access_rights(
    sys_access_rights            serial primary key,
    org_id                       integer references orgs,
    entity_id                    integer references entitys,
    can_delete                   boolean default false,
    can_modify                   boolean default false,
    can_read                     boolean default false,
    table_name                   varchar(50) references database_tables,
    access_matrix                integer ARRAY,
    description                  text,
    UNIQUE(entity_id, org_id, table_name)
);

CREATE INDEX sys_access_rights_org_id ON sys_access_rights(org_id);
CREATE INDEX sys_access_rights_entity_id ON sys_access_rights(entity_id);

CREATE SCHEMA logs;

CREATE TABLE logs.lg_student_management
(
  lg_student_management_id          serial NOT NULL,
  org_id                            integer references orgs,
  table_name                        varchar(50),
  activity                          varchar(50),
  trace				    text,
  student_id                         varchar(50),
  executed_by                       integer references entitys,
  executed_on                       timestamp without time zone DEFAULT now(),
  narrative                        varchar(120)
  
);
CREATE INDEX lg_student_management_org_id ON logs.lg_student_management(org_id);
CREATE INDEX lg_student_management_executed_by ON logs.lg_student_management(executed_by);

ALTER TABLE sys_files ADD COLUMN student_id varchar(50) references students;
ALTER TABLE sys_files ADD COLUMN approved boolean default false;
ALTER TABLE sys_files ADD COLUMN disapproval_reason varchar(120);

CREATE TABLE student_id_change_list(
    student_id_change_list_id		serial primary key,
    org_id					        integer references orgs,
    current_id				        varchar(50) references students,
    new_id					        varchar(50),
    requested_by				    integer references entitys,
    changed					        boolean default false,
    declined				        boolean default true,
    applied                         boolean default false,
    narrative				       text
);
CREATE INDEX student_id_change_list_student_id_change_list_id ON student_id_change_list(student_id_change_list_id);
CREATE INDEX student_id_change_list_org_id ON student_id_change_list(org_id);
CREATE INDEX student_id_change_list_current_id ON student_id_change_list(current_id);
CREATE INDEX student_id_change_list_requested_by ON student_id_change_list(requested_by);
