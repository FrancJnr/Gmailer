CREATE EXTENSION IF NOT EXISTS dblink ;

INSERT INTO use_keys (use_key_id, use_key_name, use_function) VALUES
(7,'Student',0),
(8,'Lecturer',0),
(9,'superAdmin',0);

INSERT INTO entity_types (org_id, entity_type_id, entity_type_name, entity_role, use_key_id, start_view) VALUES
(0, 7, 'Student', 'student', 7, null),
(0, 8, 'Lecturer', 'lecturer', 8, null),
(0, 9, 'SuperAdmin', 'rootadmin', 9, null);

UPDATE orgs SET org_name='Adventist University Of Africa' WHERE org_id=0;

INSERT INTO sys_access_levels (sys_access_level_id, use_key_id, sys_country_id, org_id, sys_access_level_name, access_tag, acess_details) VALUES (1, 6, NULL, 0, 'Users', 'Users', NULL),
 (2, 1, NULL, 0, 'Staff', 'Staff', NULL),
 (3, 2, NULL, 0, 'Client', 'Client', NULL),
 (4, 3, NULL, 0, 'Supplier', 'Supplier', NULL),
 (5, 4, NULL, 0, 'Applicant', 'Applicant', NULL),
 (6, 5, NULL, 0, 'Subscription', 'Subscription', NULL),
 (7, 7, NULL, 0, 'Student', 'Student', NULL),
 (8, 8, NULL, 0, 'Lecturer', 'Lecturer', NULL),
 (9, 8, NULL, 0, 'major advisor', 'major advisor', NULL),
 (10, 8, NULL, 0, 'faculty head', 'faculty head', NULL),
 (11, 8, NULL, 0, 'department head', 'department head', NULL),
 (12, 8, NULL, 0, 'Student dean', 'student dean', NULL),
 (13, 8, NULL, 0, 'Student Affairs', 'student affairs', NULL),
 (14, 8, NULL, 0, 'ICT department', 'ict', NULL),
 (15, 8, NULL, 0, 'Housing department', 'housing', NULL),
 (16, 6, NULL, 0, 'Records', 'records', NULL),
 (17, 6, NULL, 0, 'Reports', 'reports', NULL),
 (18, 6, NULL, 0, 'Admissions', 'admissions', NULL),
 (20, 0, NULL, 0, 'Admin', 'admin', NULL),
 (21, 9, NULL, 0, 'SuperAdmin', 'rootadmin', NULL);


INSERT INTO admission_status(admission_status_id, org_id, admission_status_name, description)
VALUES(1, 0, 'Regular', 'Admission without reservations'),
(2, 0, 'Probation', 'Admit student based on reservations'),
(3, 0, 'conditional', 'Admission Based on promise'),
(4, 0, 'provisional', 'Admission on provision');


INSERT INTO request_types(request_type_id, org_id, request_type_name, details)
VALUES
(1, 0, 'Others', 'Make an abitrary Requests' ),
(2, 0, 'Incorrect Details', 'Request for a change of incorrect details'),
(3, 0, 'Finance', 'Finance ammendments'),
(4, 0, 'Housing', 'challenges with room allocations'),
(5, 0, 'Session Registration', 'challenges with session registration and approvals'),
(6, 0, 'Grading', 'Problems with grades and courses');

INSERT INTO religions(religion_id, org_id, religion_name, details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select religionid, 0, religionname, details
FROM religions' 
)AS t1(
 religion_id         varchar(12),
 org_id              integer,
 religion_name       varchar(50),
 details             text

);
INSERT INTO sites(site_id, org_id, site_name, active, details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select center_id, 0, center_name, true, details
FROM centers' 
)AS t1(
 site_id         varchar(12),
 org_id              integer,
 site_name       varchar(50),
 active             boolean,
 details             text
);
INSERT INTO schools(school_id, org_id, school_name, philosopy, vision, mission, objectives, details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select schoolid, 0, schoolname, philosopy, vision, mission, objectives, details
FROM schools' 
)AS t1(
 school_id           varchar(12),
 org_id              integer,
 school_name         varchar(50),
 philosopy           text,
 vision              text,
 mission             text,
 objectives          text,
 details             text

);
INSERT INTO denominations(denomination_id, religion_id, org_id, denomination_name,  details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select denominationid,  religionid, 0, denominationname, details
FROM denominations' 
)AS t1(
 denomination_id    varchar(12),
 religion_id        varchar(12),
 org_id             integer,
 denomination_name  varchar(50),
 details            text

);
INSERT INTO departments(department_id, school_id, org_id, department_name,  philosopy,vision,mission,objectives, oppotunities,details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select departmentid,  schoolid, 0, departmentname, philosopy,vision,mission,objectives,oppotunities,details
FROM departments' 
)AS t1(
	department_id		    varchar(12)  ,
	school_id				varchar(12) ,
	org_id					integer,
	department_name	    	varchar(120) ,
	philosopy				text,
	vision					text,
	mission					text,
	objectives				text,
	oppotunities			text,
	details					text

);

INSERT INTO degree_levels(degree_level_id, org_id, degree_level_name,  details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select degreelevelid,  0, degreelevelname, details
FROM degreelevels' 
)AS t1(
 degree_level_id		varchar(12),
 org_id					integer ,
 degree_level_name		varchar(50) ,
 details                text
);

INSERT INTO degrees(degree_id, degree_level_id, school_id, org_id, degree_name,  details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select degreeid, degreelevelid, ''THSM'', 0, degreename, details
FROM degrees' 
)AS t1(
    degree_id				varchar(12),
	degree_level_id			varchar(12),
	school_id				varchar(12),
	org_id					integer,
	degree_name				varchar(50),
	details					text
);

INSERT INTO specializations( specialization_name, org_id, degree_id)
SELECT *FROM dblink('port=5432 dbname=aua.old', ' SELECT DISTINCT ON(majorname) majorname, 0, degreeid
FROM studentmajors
INNER JOIN studentdegrees ON studentdegrees.studentdegreeid=studentmajors.studentdegreeid
INNER JOIN majors ON majors.majorid=studentmajors.majorid
GROUP BY  degreeid, majorname'

)AS t1(
	specialization_name			  varchar(120),
	org_id					integer,
	degree_id				varchar(12)
	
	
);

INSERT INTO majors(major_id, org_id, major_name, major, minor,
full_credit, elective_credit, minor_elective_credit, core_minimum, details)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select majorid, 0, majorname, major, minor, fullcredit ,electivecredit, 15, coreminimum, details
FROM majors' 
)AS t1(
    major_id				varchar(12),
	org_id					integer,
	major_name				varchar(75),
	major					boolean ,
	minor					boolean ,
	full_credit				integer ,
	elective_credit			integer,
	minor_elective_credit			integer,
	core_minimum			real,
	details					text
);

INSERT INTO grades( org_id, grade_name, grade_weight, min_range, max_range, gpa_count, narrative, details
)
SELECT *FROM dblink('port=5432 dbname=aua.old', 'select 0, gradeid, gradeweight, minrange, maxrange, gpacount, narrative, details
FROM grades' 
)AS t1(
	org_id					integer,
	grade_name				varchar(2),
	grade_weight			float ,
	min_range				integer ,
	max_range				integer ,
	gpa_count				boolean ,
	narrative				varchar(240),
	details					text
);

INSERT INTO lecturer_categories(lecturer_category_id, org_id, lecturer_category_name)
VALUES(1,0,'Lecturer'), (2,0,'Major Advisor'), (3, 0, 'Head of department'), (4,0, 'Head of Faculty');

INSERT INTO instructors(instructor_id, lecturer_category_id, school_id, sys_country_id,  org_id,   instructor_name, site_id,  email, phone_number
)
SELECT * FROM 
dblink('port=5432 dbname=aua.old', 'select instructorid, 1, ''PGS'', ''KE'',  0, instructorname, ''Main'', email, telephone
FROM instructors
'
 
)AS t1(
	instructor_id			varchar(12) ,
	lecturer_category_id	integer,
	school_id               varchar(50),			
	sys_country_id			char(2),
	org_id					integer,
	instructor_name			varchar(50),
	site_id				    varchar(50),
	email              		varchar(50),
	phone_number			varchar(50)
);


INSERT INTO assets(asset_id, site_id, org_id, asset_name, building, location, capacity)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT assetid, ''Main'', 0, assetname, building, location, capacity
 FROM
assets'
)AS t1(
	asset_id				integer,
	site_id 				varchar(120),
	org_id					integer ,
	asset_name				varchar(50),
	building				varchar(50),
	location				varchar(50),
	capacity				integer
	);

INSERT INTO course_types(course_type_id, org_id, course_type_name)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT coursetypeid, 0, coursetypename
 FROM
coursetypes'
)AS t1(
	course_type_id				integer,
	org_id					integer,
	course_type_name		varchar(50)
	);

INSERT INTO course_modes(course_mode_id, org_id, course_mode_name)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT coursemodeid, 0, coursemodename
 FROM
coursemodes'
)AS t1(
	course_mode_id			integer,
	org_id					integer,
	course_mode_name		varchar(50)
);


INSERT INTO courses(course_title, course_id, course_mode_id, degree_level_id, course_type_id, school_id, org_id, lab_course, min_credit, max_credit,lecture_hours, practical_hours, credit_hours, is_current, no_gpa, no_repeats, year_taken, details)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT coursetitle, courseid, coursemodeid, degreelevelid, coursetypeid, schoolid, 0,  labcourse, mincredit, maxcredit, lecturehours, practicalhours, credithours, iscurrent, nogpa, norepeats, yeartaken, courses.details
FROM courses
INNER JOIN departments ON departments.departmentid=courses.departmentid'
)AS t1(
	course_title			varchar(120),
	course_id				varchar(12),
	course_mode_id			integer,
	degree_level_id			varchar(12),
	course_type_id			integer,
	school_id               varchar(50),
	org_id					integer,
	lab_course				boolean,
	min_credit				float,
	max_credit				float ,
	lecture_hours			float,
	practical_hours		 	float,
	credit_hours			float,
	is_current				boolean,
	no_gpa					boolean,
	no_repeats				boolean,
	year_taken				integer,
	details					text
);
INSERT INTO sessions(session_id, org_id, session_year, semister, site, session_start, slate_reg, slate_change, slast_drop, session_end, active,  min_credits, max_credits,  details)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT sessionid, 0, sessionyear, semester, center,sstart, slatereg, slatechange, slastdrop, send, active, mincredits, maxcredits, details 
 FROM sessions'
)AS t1(
	session_id				varchar(12),
	org_id					integer ,
	session_year			varchar(9),
	semister				integer,
	site					varchar(50),
	session_start			date,
	slate_reg				date,
	slate_change			date,
	slast_drop				date,
	session_end				date,
	active					boolean,
	min_credits				real,
	max_credits				real,
	details					text
);

INSERT INTO content_types( content_type_id, org_id, content_type_name, elective, prerequisite, pre_major,  details)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT contenttypeid, 0, contenttypename, elective, prerequisite, premajor, details 
FROM contenttypes'
)AS t1(
	content_type_id				integer,
	org_id					integer ,
	content_type_name		varchar(50),
	elective				boolean ,
	prerequisite			boolean,
	pre_major				boolean,
	details					text
);

INSERT INTO sponsor_types( sponsor_type_id, org_id, sponsor_type_name, details)
SELECT *FROM dblink('dbname=aua.old port=5432','SELECT sponsortypeid, 0, sponsortypename, details 
FROM sponsortypes'
)AS t1(
	sponsor_type_id		integer, 
	org_id                  integer,
	sponsor_type_name       varchar(50),
	details					text
);

INSERT INTO sponsor_categorys(sponsor_category_id, org_id, sponsor_category_name, active)
VALUES(1, 0, 'SELF', TRUE),
(2, 0, 'Division', TRUE),
(3, 0, 'Conference', TRUE);

INSERT INTO sponsors(sponsor_id, org_id, sponsor_type_id, sponsor_category_id,  sponsor_name, address, street, postal_code, town, sys_country_id, telno, email, active,  details)
SELECT *

FROM dblink('dbname=aua.old port=5432','SELECT sponsorid, 0 as orgid, sponsortypeid, 2, sponsorname, address, street, postalcode, town, countryid, telno, email, active, details 
 FROM
sponsors'
)AS t1(
	sponsor_id		integer,
	org_id                  integer,
	sponsor_type_id			integer,
	sponsor_category_id		integer,
	sponsor_name			varchar(50),
	address					varchar(50),
	street					varchar(50),
	postal_code				varchar(50),
	town					varchar(50),
	sys_country_id			char(2),
	telno					varchar(50),
	email					varchar(240),
	active					boolean,
	details					text
);

INSERT INTO students(student_id, sponsor_id, school_id, denomination_id, country_code_id, student_name, surname, first_name,
other_names, sex, nationality, marital_status, birth_date, address, zipcode,  tel_no, email, account_number,  alumnae,  
on_probation, onhold, off_campus,  picture_file, details )
SELECT student_id, t1.sponsor_id, school_id, denomination_id, (CASE WHEN country_code_id='ZR' THEN 'CD' ELSE country_code_id END) AS country_code_id, student_name, surname, first_name, other_names,
sex, (CASE WHEN nationality='ZR' THEN 'CD' ELSE nationality END) AS nationality, marital_status, birth_date, t1.address, zipcode,  tel_no, t1.email, t1.account_number,  t1.alumnae,  
t1.on_probation, t1.onhold, t1.off_campus,  t1.picture_file, t1.details
FROM dblink('dbname=aua.old port=5432','SELECT studentid, sponsorid, schoolid, denominationid, countrycodeid, 
studentname, surname, firstname, othernames, sex, nationality,maritalstatus, birthdate, address, zipcode, 
telno, email, accountnumber,  alumnae, onprobation, onhold, offcampus,  picturefile, students.details
FROM students
INNER JOIN departments ON departments.departmentid=students.departmentid'
)AS t1(
    student_id				varchar(12) ,
	sponsor_id				integer ,
	school_id				varchar(150),
	denomination_id			varchar(12),
	country_code_id			char(2),
	student_name			varchar(150),
	surname					varchar(150),
	first_name				varchar(150),
	other_names				varchar(150),
	Sex						varchar(1),
	nationality				varchar(2),
	marital_status			varchar(2),
	birth_date				date ,
	address					varchar(150),
	zipcode					varchar(150),
	tel_no					varchar(150),
	email					varchar(240),
	account_number			varchar(150),
	alumnae					boolean,
	on_probation			boolean,
	onhold					boolean,
	off_campus				boolean,
	picture_file			varchar(240),
	details					text
);


ALTER TABLE student_degrees ALTER COLUMN cohort_id DROP NOT NULL;
ALTER TABLE student_degrees ALTER COLUMN bulletings_id DROP NOT NULL;

INSERT INTO student_degrees(student_degree_id, student_id, site_id, org_id, completed, started, cleared, clear_date,  graduated, graduate_date, drop_out, transfer_in, transfer_out, admission_basis, transcripted, details )
SELECT *
FROM dblink('dbname=aua.old port=5432','SELECT studentdegreeid, studentid, center_id, 0, completed, started, cleared, clearedate,  graduated, graduatedate, dropout, transferin, transferout, admission_basis, false, details 
FROM studentdegrees
'
)AS t1(
	student_degree_id		integer,
    student_id				varchar(12) ,
	site_id				    varchar(12),
	org_id					integer,
	completed				boolean,
	started					date,
	cleared					boolean ,
	clear_date				date,
	graduated				boolean  ,
	graduate_date			date,
	drop_out				boolean  ,
	transfer_in				boolean  ,
	transfer_out			boolean  ,
	admission_basis			varchar(240),
	transcripted			boolean  ,
	details					text
);

INSERT INTO transfered_credits(student_degree_id, course_id, org_id, credit_hours, narrative )
SELECT * 

FROM dblink('dbname=aua.old port=5432','SELECT studentdegreeid, courseid, 0, credithours, narrative
FROM transferedcredits
'
)AS t1(
    student_degree_id		integer,
	course_id				varchar(12),
	org_id					integer,
	credit_hours			float,
	narrative				varchar(240)
);


INSERT INTO residences(site_id, org_id, residence_name, capacity, room_size, default_rate, off_campus, Sex, residence_dean, details )
SELECT * 

FROM dblink('dbname=aua.old port=5432','SELECT ''Main'', 0, residencename, capacity, roomsize, defaultrate, offcampus, sex,
residencedean, residenceid
FROM residences
'
)AS t1(
    site_id					varchar(12),
	org_id					integer,
	residence_name			varchar(50),
	capacity				integer,
	room_size				integer ,
	default_rate			float,
	off_campus				boolean,
	Sex						varchar(1),
	residence_dean			varchar(50),
	details					text
);

INSERT INTO sresidences(sresidence_id, session_id, org_id, residence_option,  active, details, residence_id )
SELECT t1.*, residences.residence_id

FROM dblink('dbname=aua.old port=5432','SELECT sresidenceid, sessionid, 0, residenceoption,  active, residenceid 
FROM sresidences
'
)AS t1(
    sresidence_id			integer,
    session_id				varchar(12),
	org_id					integer,
	residence_option		varchar(50),
	active					boolean,
	details					text
)

INNER JOIN residences ON residences.details=t1.details;
ALTER TABLE scourses DROP CONSTRAINT scourses_instructor_id_course_id_session_id_class_option_or_key;
ALTER TABLE scourses ALTER COLUMN instructor_id DROP NOT NULL;

INSERT INTO scourses(scourse_id, session_id, instructor_id, course_id, site_id, org_id, course_title, class_option, max_class, course_charge, approved, lecture_submit, lecture_submit_date, department_submit, department_submit_date, faculty_submit, faculty_submit_date, attendance, details)

SELECT scourse_id, session_id, instructor_id, course_id, site_id, org_id, course_title, class_option, max_class, course_charge, approved, lecture_submit, lecture_submit_date, department_submit, department_submit_date, faculty_submit, faculty_submit_date, 
attendance, 
details 

FROM dblink('dbname=aua.old port=5432','SELECT scourseid, sessionid, instructorid, courseid, center_id, 0, coursetitle, classoption, maxclass, coursecharge, approved, lecturesubmit, lsdate, departmentsubmit, dsdate, facultysubmit, fsdate, attendance,  details
FROM scourses
'
)AS t1(
    scourse_id				integer,
	session_id				varchar(12) ,
	instructor_id			varchar(50) ,
	course_id				varchar(12) ,
	site_id					varchar(12),
	org_id					integer,
	course_title			varchar(120),
	class_option			varchar(50),
	max_class				integer ,
	course_charge			float ,
	approved				boolean  ,
	lecture_submit			boolean  ,
	lecture_submit_date		timestamp,
	department_submit		boolean  ,
	department_submit_date	timestamp,
	faculty_submit			boolean  ,
	faculty_submit_date		timestamp,
	attendance				integer,
	details                 text
);

ALTER TABLE sstudents ALTER COLUMN sresidence_id DROP NOT NULL; 

ALTER TABLE sstudents ALTER COLUMN student_degree_id DROP NOT NULL; 



INSERT INTO sstudents(sstudent_id, session_id, student_degree_id, sresidence_id, org_id, extra_charges, probation,
off_campus, block_name,  room_id, curr_balance,  study_level, application_time, first_close_time, 
finalised, cleared_finance, finance_approval, major_approval, depart_approval, chaplain_approval, 
student_dean_approval, overload_approval, overload_hours, finance_closed, approved, approved_date, on_probation, Picked,
picked_date, LRF_picked, LRF_picked_date, finance_narrative, no_approval, details)
SELECT sstudent_id, session_id, student_degree_id, sresidence_id, org_id, extra_charges, probation,
off_campus, block_name,  room_id, curr_balance,  study_level, application_time, first_close_time, 
finalised, cleared_finance, finance_approval, major_approval, depart_approval, chaplain_approval, 
student_dean_approval, overload_approval, overload_hours, finance_closed, approved, approved_date, on_probation, Picked,
picked_date, LRF_picked, LRF_picked_date, finance_narrative, no_approval, details

FROM dblink('dbname=aua.old port=5432','SELECT sstudentid, sessionid, studentdegreeid, 
sresidenceid, 0, extacharges, onprobation, offcampus, blockname, roomnumber, currbalance, studylevel, applicationtime, 
firstclosetime, finalised, clearedfinance, finaceapproval, majorapproval, departapproval, chaplainapproval, studentdeanapproval,
overloadapproval, overloadhours, financeclosed,  approved, approveddate, 
onprobation, picked, pickeddate, lrfpicked, lrfpickeddate, financenarrative, noapproval, details
FROM sstudents
'
)AS t1(
    sstudent_id		        integer,
	session_id				varchar(12),
	student_degree_id		integer, 
	sresidence_id			integer,
	org_id					integer,
	extra_charges			real ,
	probation				boolean ,
	off_campus				boolean ,
	block_name				varchar(12),
	room_id			    	integer,
	curr_balance			real,
	study_level				integer,
	application_time		timestamp  ,
	first_close_time		timestamp,
	finalised				boolean ,
	cleared_finance			boolean,
	finance_approval		boolean ,
	major_approval			boolean ,
	depart_approval			boolean,
	chaplain_approval		boolean ,
	student_dean_approval	boolean,
	overload_approval		boolean ,
	overload_hours			float,
	finance_closed			boolean,   
	approved				boolean ,
	approved_date			timestamp,
	on_probation			boolean , 
	Picked					boolean ,
	picked_date				timestamp,
	LRF_picked				boolean ,
	LRF_picked_date			timestamp,
	finance_narrative		text,
	no_approval				text,
	details					text
);

INSERT INTO option_times(option_time_id, org_id, option_time_name, details )
SELECT * 
FROM dblink('dbname=aua.old port=5432','SELECT optiontimeid, 0, optiontimename, details
FROM optiontimes
'
)AS t1(
    option_time_id	     	integer,
	org_id					integer,
	option_time_name		varchar(50),
	details					text
);

ALTER TABLE sgrades ALTER COLUMN scourse_id DROP NOT NULL;
ALTER TABLE sgrades ALTER COLUMN sstudent_id DROP NOT NULL;
INSERT INTO sgrades(sgrade_id, sstudent_id, scourse_id, grade_id, option_time_id, org_id, hours, credit, lecture_marks, department_marks, 
final_marks,  selection_date, approved, approve_date, ask_drop, ask_drop_date, dropped, drop_date, repeated, non_gpa_course, challenge_course, withdraw_date, attendance, narrative )

SELECT sgrade_id, sstudent_id, scourse_id, grades.grade_id, option_time_id, t1.org_id, hours, credit, lecture_marks, department_marks, 
final_marks,  selection_date, approved, approve_date, ask_drop, ask_drop_date, dropped, drop_date, repeated, non_gpa_course, challenge_course, withdraw_date, attendance, t1.narrative

FROM dblink('dbname=aua.old port=5432','SELECT sgradeid, sstudentid, scourseid, gradeid, optiontimeid, 0, hours,
credit, instructormarks,departmentmarks,  finalmarks, selectiondate, approved, approvedate, askdrop, askdropdate, dropped, dropdate, repeated, nongpacourse, challengecourse, withdrawdate,  attendance, narrative
FROM sgrades
'
)AS t1(
    sgrade_id 				integer,
	sstudent_id				integer,
	scourse_id				integer,
	grade_id				varchar(12),
	option_time_id			integer,
	org_id					integer,
	hours					float,
	credit					float ,
	lecture_marks        real,
	department_marks		real,--addition
	final_marks				real,
	selection_date			timestamp,
	approved        		boolean ,
	approve_date			timestamp,
	ask_drop				boolean ,
	ask_drop_date			timestamp,
	dropped					boolean ,
	drop_date				date,
	repeated				boolean ,
	non_gpa_course			boolean ,
	challenge_course		boolean ,
	withdraw_date			date,
	attendance				integer,
	narrative				varchar(240)
)
INNER JOIN grades ON grades.grade_name=t1.grade_id;


INSERT INTO student_majors(student_major_id, student_degree_id, major_id, org_id, major, primary_major, non_degree, details )
SELECT * 
FROM dblink('dbname=aua.old port=5432','SELECT studentmajorid, studentdegreeid, majorid, 0, major, primarymajor, nondegree, details
FROM studentmajors
'
)AS t1(
    student_major_id	     integer,
    student_degree_id		 integer,
	major_id				 varchar(12),
	org_id		             integer,
	major                    boolean,
    primary_major            boolean,
    non_degree               boolean,
    details                  text
);

INSERT INTO student_specializations(student_specialization_id, student_degree_id, specialization_id, org_id, major, primary_major, non_degree, details )

SELECT student_specialization_id, student_degree_id, specialization_id, t1.org_id, t1.major, t1.primary_major, t1.non_degree, t1.details
FROM dblink('dbname=aua.old port=5432','SELECT studentmajorid, studentdegreeid, majorname, 0, studentmajors.major, primarymajor, nondegree, studentmajors.details 
FROM studentmajors
INNER JOIN majors ON majors.majorid=studentmajors.majorid') AS t1(
    student_specialization_id   integer,
	student_degree_id			integer,
	major_name			varchar(50),
	org_id						integer,
	major						boolean,
	primary_major				boolean,
	non_degree					boolean,
    details						text
	
)
INNER JOIN specializations ON specializations.specialization_name=t1.major_name;

INSERT INTO cohorts(degree_id, school_id, site_id, start_date, end_date, is_active)
SELECT *FROM dblink('dbname=aua.old' ,'SELECT DISTINCT ON (degreeid, centers.center_id) degreeid, schoolid, centers.center_id, sessions.sstart, send, active
FROM students
INNER JOIN studentdegrees ON  students.studentid=studentdegrees.studentid
INNER JOIN courses ON students.departmentid=courses.departmentid
INNER JOIN departments ON departments.departmentid=courses.departmentid
INNER JOIN scourses ON courses.courseid=scourses.courseid
INNER JOIN sessions ON sessions.sessionid=scourses.sessionid
INNER JOIN centers ON centers.center_name=sessions.center
WHERE degreeid IS NOT NULL
GROUP BY degreeid, centers.center_id, sessions.sstart, send, active, schoolid
ORDER BY degreeid;') AS t1(
degree_id     varchar(50),
school_id     varchar(50),
site_id	       varchar(50),
start_date     date,
end_date       date,
is_active	boolean
);

UPDATE student_degrees SET cohort_id=a.cohort_id
FROM
(SELECT student_id, t1.degree_id, cohort_id, t1.center_id, student_degree_id
FROM dblink('port=5432 dbname=aua.old', 'select studentdegreeid, (CASE WHEN center_id IS NULL THEN ''Main'' ELSE center_id END), degreeid, studentid 
 from studentdegrees
 GROUP BY center_id, degreeid, studentid, studentdegreeid
 ORDER BY studentid asc
')
as t1 (student_degree_id integer, center_id varchar(50), degree_id varchar(12),student_id varchar(12))
INNER JOIN cohorts ON t1.degree_id=cohorts.degree_id
AND t1.center_id=cohorts.site_id
GROUP BY student_id, t1.degree_id, cohort_id, center_id, student_degree_id) a
WHERE student_degrees.student_degree_id=a.student_degree_id;


UPDATE sessions SET cohort_id=a.cohort_id
FROM
(SELECT sstudents.session_id, student_degrees.student_degree_id, cohort_id
FROM student_degrees 
INNER JOIN sstudents ON sstudents.student_degree_id=student_degrees.student_degree_id) AS 
WHERE sessions.session_id=a.session_id;

UPDATE sessions SET pre_session=false, post_session=true;



UPDATE sessions SET active=false WHERE session_end<current_date;

UPDATE degrees SET school_id=t1.school_id
FROM
dblink('dbname=aua.old','SELECT  DISTINCT ON (studentdegrees.degreeid) degreeid, departments.schoolid
FROM students
INNER JOIN studentdegrees ON students.studentid=studentdegrees.studentid
INNER JOIN departments ON departments.departmentid=students.departmentid
WHERE degreeid IS NOT NULL;
') AS t1 (

degree_id		varchar(50),
school_id		varchar(50)

)
WHERE degrees.degree_id=t1.degree_id;

SELECT setval('student_degrees_student_degree_id_seq', max(student_degree_id)) FROM student_degrees;

