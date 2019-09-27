CREATE OR REPLACE VIEW vw_sstudent_summary AS
	SELECT student_id, student_name, session_id, approved, student_degree_id,degree_name, sstudent_id,nationality_country, school_name,hours,
		sex, Nationality, Marital_Status, study_level,
		get_curr_credit(sstudent_id) as credit, get_curr_gpa(sstudent_id) as gpa,
		get_cumm_credit(student_degree_id, session_id) as cumm_credit,
		get_cumm_gpa(student_degree_id, session_id) as cumm_gpa 
	FROM vw_sstudents;
	
CREATE OR REPLACE VIEW vw_student_session_list AS
	SELECT religion_id, religion_name, vw_sstudents.denomination_id, vw_sstudents.denomination_name, vw_sstudents.school_id, vw_sstudents.school_name, student_id, student_name, address, zipcode,
		town, address_country, tel_no, email, approved, sponsor_type_id, sponsor_type_name, sponsor_id, sponsor_name,
		sponsor_address, sponsor_street, sponsor_postal_code, sponsor_town, sponsor_telno, sponsor_email, 
		sponsor_country_id, sponsor_country_name,
		account_number, Nationality, nationality_country, Sex, marital_status, birth_date, alumnae, post_contacts,
		on_probation, off_campus, current_contact, current_email, current_tel, degree_level_id, degree_level_name,
		  
		vw_sstudents.degree_id, vw_sstudents.degree_name, student_degree_id, completed, started, cleared, clear_date,
		graduated, graduate_date, drop_out, transfer_in, transfer_out,
		vw_sstudents.session_id, vw_sessions.session_year, vw_sessions.sessions, vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.slast_drop,
		vw_sessions.session_end, vw_sessions.active,   
		residence_id, residence_name, capacity, default_rate, residence_off_campus, residence_sex, residence_dean,
		sresidence_id, sstudent_id, major_approval, probation, 
		 overload_approval, finalised, 
		get_curr_hours(sstudent_id) as hours,		
		get_curr_credit(sstudent_id) as credit, 
		get_curr_gpa(sstudent_id) as gpa,
		get_cumm_credit(student_degree_id, vw_sessions.session_id) as cumm_credit,
		get_cumm_gpa(student_degree_id, vw_sessions.session_id) as cumm_gpa,
		get_prev_session(student_degree_id, vw_sessions.session_id) as prev_session,
		(CASE WHEN (get_prev_session(student_degree_id, vw_sessions.session_id) is null) THEN true ELSE false END) as new_student, cohort_name
	FROM   vw_sstudents
	INNER JOIN vw_sessions ON vw_sessions.session_id=vw_sstudents.session_id;

CREATE OR REPLACE VIEW vw_student_session_summary AS
	SELECT religion_id, religion_name, denomination_id, denomination_name, school_id, school_name, student_id, student_name, address, zipcode,
		sponsor_type_id, sponsor_type_name, sponsor_id, sponsor_name,
		sponsor_address, sponsor_street, sponsor_postal_code, sponsor_town, sponsor_telno, sponsor_email, 
		sponsor_country_id, sponsor_country_name,
		town, address_country, tel_no, email,  account_number, Nationality, nationality_country, Sex, marital_status, birth_date,  alumnae, post_contacts,
		on_probation, off_campus, current_contact, current_email, current_tel, degree_level_id, degree_level_name,
		 
		degree_id, degree_name, student_degree_id, completed, started, cleared, clear_date,
		graduated, graduate_date, drop_out, transfer_in, transfer_out, 
		session_id, session_year, sessions, session_start, slate_reg, slate_change, slast_drop,
		session_end, active,   
		residence_id, residence_name, capacity, default_rate, residence_off_campus, residence_sex, residence_dean,
		sresidence_id,  sstudent_id, major_approval, probation, approved,
		  overload_approval, finalised, 		
		hours, gpa, credit, cumm_credit, cumm_gpa, prev_session, new_student, 
		get_prev_credit(student_degree_id, prev_session) as prev_credit, 
		get_prev_gpa(student_degree_id, prev_session) as prev_gpa
	FROM vw_student_session_list;

CREATE OR REPLACE VIEW vw_course_summary_a AS
	SELECT vw_student_grades.degree_level_id, vw_student_grades.degree_level_name,   
		crs_school_id, crs_school_name, 
		vw_student_grades.session_id, sstudents.inter_session, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option,
		
		count(vw_student_grades.grade_id) as enrolment, sum(charge_hours) as sum_charge_hours
	FROM  vw_student_grades
	
	INNER JOIN sstudents ON vw_student_grades.student_id=(sstudents.sstudent_id)::character varying
	INNER JOIN grades ON vw_student_grades.grade_id=grades.grade_id
	WHERE (sstudents.finance_approval = true) AND (dropped = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
		AND (vw_student_grades.withdraw = false) AND (vw_student_grades.ac_withdraw = false)
	GROUP BY degree_level_id, degree_level_name, 
		crs_school_id, crs_school_name, sstudents.inter_session,
		vw_student_grades.session_id, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option;
	
CREATE OR REPLACE VIEW vw_course_summary_b AS
	SELECT degree_level_id, degree_level_name, crs_school_id, crs_school_name, 
		vw_student_grades.session_id, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option,
		
		count(vw_student_grades.grade_id) as enrolment, sum(charge_hours) as sum_charge_hours
	FROM vw_student_grades
	INNER JOIN grades ON grades.grade_id=vw_student_grades.grade_id
	INNER JOIN sstudents ON (sstudents.sstudent_id)::character varying=vw_student_grades.student_id
	WHERE (sstudents.finance_approval = true) AND (dropped = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
		AND (vw_student_grades.withdraw = false) AND (vw_student_grades.ac_withdraw = false)
	GROUP BY degree_level_id, degree_level_name, crs_school_id, crs_school_name, 
		vw_student_grades.session_id, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option;
		
		
CREATE OR REPLACE VIEW vw_course_summary_c AS
	SELECT crs_school_id, crs_school_name, crs_degree_level_id, crs_degree_level_name,
		vw_student_grades.session_id, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option,
		
		count(vw_student_grades.grade_id) as enrolment, sum(charge_hours) as sum_charge_hours
	FROM vw_student_grades
	INNER JOIN grades ON grades.grade_id=vw_student_grades.grade_id
	INNER JOIN sstudents ON (sstudents.sstudent_id)::character varying=vw_student_grades.student_id
	WHERE (sstudents.finance_approval = true) AND (dropped = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
		AND (vw_student_grades.withdraw = false) AND (vw_student_grades.ac_withdraw = false)
	GROUP BY crs_school_id, crs_school_name,  crs_degree_level_id, crs_degree_level_name,
		vw_student_grades.session_id, scourse_id, course_type_id, course_type_name, course_id, credit_hours, is_current, instructor_name, course_title, class_option;

CREATE OR REPLACE VIEW vw_sstudent_major_summary AS
	SELECT vw_student_specializations.school_id, vw_student_specializations.school_name, 
		vw_student_specializations.degree_level_id, vw_student_specializations.degree_level_name,  
		vw_student_specializations.specialization_id, vw_student_specializations.specialization_name,  
		vw_student_specializations.student_degree_id, 
		vw_student_specializations.sex, vw_sstudents.session_id, count(vw_student_specializations.student_degree_id) as student_count
	FROM vw_student_specializations
	INNER JOIN vw_sstudents ON (vw_sstudents.sstudent_id)::character varying = vw_student_specializations.student_id
	GROUP BY vw_student_specializations.school_id, vw_student_specializations.school_name, 
		vw_student_specializations.degree_level_id, vw_student_specializations.degree_level_name, 
		vw_student_specializations.specialization_id, vw_student_specializations.student_degree_id , vw_student_specializations.specialization_name, vw_student_specializations.sex, vw_sstudents.session_id;

CREATE OR REPLACE VIEW vw_nationality AS
	SELECT nationality, nationality_country
	FROM vw_students
	GROUP BY nationality, nationality_country
	ORDER BY nationality_country;

CREATE OR REPLACE VIEW vw_nationality_countrys AS
	SELECT nationality, sys_country_name
	FROM students INNER JOIN sys_countrys ON students.Nationality = sys_countrys.sys_country_id
	GROUP BY nationality, sys_country_name
	ORDER BY sys_country_name;

CREATE OR REPLACE VIEW vw_grade_year AS
	SELECT EXTRACT(YEAR FROM vw_student_degrees.graduate_date) as graduation_year
	FROM vw_student_degrees
	WHERE (vw_student_degrees.graduated = true)
	GROUP BY EXTRACT(YEAR FROM vw_student_degrees.graduate_date)
	ORDER BY EXTRACT(YEAR FROM vw_student_degrees.graduate_date);

CREATE OR REPLACE VIEW vw_gender AS
	(SELECT 'M' as sex) UNION (SELECT 'F' as sex);

CREATE OR REPLACE VIEW vw_ssummary_a AS
	SELECT session_id, session_year, sessions, Sex, count(student_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, Sex;
	
CREATE OR REPLACE VIEW vw_ssummary_b AS
	SELECT session_id, session_year, sessions, degree_level_name, Sex, count(student_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, degree_level_name, Sex;
	
CREATE OR REPLACE VIEW vw_ssummary_c AS
	SELECT session_id, session_year, sessions,  Sex, count(student_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, Sex;

CREATE OR REPLACE VIEW vw_ssummary_d AS
	SELECT session_year, Sex, count(student_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_year, Sex;

CREATE OR REPLACE VIEW vw_schoolsummary AS
	SELECT session_id, session_year, sessions, school_name, sex, varchar 'School' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, school_name, sex
	ORDER BY session_id, session_year, sessions, school_name, sex;

CREATE OR REPLACE VIEW vw_level_summary AS
	SELECT session_id, session_year, sessions, degree_level_name, sex, varchar 'Degree Level' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, degree_level_name, sex
	ORDER BY session_id, session_year, sessions, degree_level_name, sex;

CREATE OR REPLACE VIEW vw_sub_level_summary AS
	SELECT session_id, session_year, sessions,  sex, varchar 'Sub Level' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions,  sex
	ORDER BY session_id, session_year, sessions,  sex;

CREATE OR REPLACE VIEW vw_new_student_summary AS
	SELECT session_id, session_year, sessions, (CASE WHEN new_student=true THEN 'New' ELSE 'Continuing' END) as status, sex, varchar 'Student Status' as "defination", count(sstudent_id) as student_count
	FROM vw_student_session_summary
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, new_student, sex
	ORDER BY session_id, session_year, sessions, new_student, sex;

CREATE OR REPLACE VIEW vw_religion_summary AS
	SELECT session_id, session_year, sessions, religion_name, sex, varchar 'Religion' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, religion_name, sex
	ORDER BY session_id, session_year, sessions, religion_name, sex;

CREATE OR REPLACE VIEW vw_denomination_summary AS
	SELECT session_id, session_year, sessions, denomination_name, sex, varchar 'Denomination' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, denomination_name, sex
	ORDER BY session_id, session_year, sessions, denomination_name, sex;

CREATE OR REPLACE VIEW vw_nationality_summary AS
	SELECT session_id, session_year, sessions, nationality_country, sex, varchar 'Nationality' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, nationality_country, sex
	ORDER BY session_id, session_year, sessions, nationality_country, sex;

CREATE OR REPLACE VIEW vw_residence_summary AS
	SELECT session_id, session_year, sessions, residence_name, sex, varchar 'Residence' as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions, residence_name, sex
	ORDER BY session_id, session_year, sessions, residence_name, sex;

CREATE OR REPLACE VIEW vw_school_major_summary AS
	SELECT vw_sstudents.session_id, substring(session_id from 1 for 9) as session_year, 
		substring(session_id from 11 for 2) as session, vw_specializations.school_name, vw_student_specializations.sex, 
		varchar 'School' as "defination", count(sstudent_id) as student_count
	FROM vw_student_specializations
	INNER JOIN vw_sstudents ON vw_sstudents.student_id=vw_student_specializations.student_id
	INNER JOIN vw_specializations ON vw_specializations.specialization_id = vw_student_specializations.specialization_id
	GROUP BY vw_sstudents.session_id, substring(session_id from 1 for 9), substring(session_id from 11 for 2),vw_specializations.school_name,vw_student_specializations.sex
	ORDER BY vw_sstudents.session_id, substring(session_id from 1 for 9), substring(session_id from 11 for 2),vw_specializations.school_name,vw_student_specializations.sex;

CREATE OR REPLACE VIEW vw_location_summary AS
	SELECT session_id, session_year, sessions,  sex, 'Location'::varchar as "defination", count(sstudent_id) as student_count
	FROM vw_sstudents
	WHERE (major_approval = true)
	GROUP BY session_id, session_year, sessions,  sex
	ORDER BY session_id, session_year, sessions,  sex;


	

CREATE OR REPLACE VIEW vw_session_stats AS
	(SELECT 1 as stat_id, text 'Opened Applications' AS "narrative", count(sstudent_id) AS student_count, session_id
	FROM sstudents GROUP BY session_id)
	UNION
	(SELECT 2, text 'Paid Full Fees' AS "narrative", count(vw_sstudents.sstudent_id), vw_sstudents.session_id
	FROM vw_sstudents 
	INNER JOIN sstudents ON vw_sstudents.student_id=(sstudents.sstudent_id)::character varying
	WHERE (vw_sstudents.curr_balance >= (-2000)) AND (sstudents.finance_approval = true) 
	
		GROUP BY vw_sstudents.session_id)
	UNION
	(SELECT 3, text 'Within Allowed Balance' AS "narrative", count(vw_sstudents.sstudent_id), vw_sstudents.session_id
		FROM vw_sstudents 
		INNER JOIN sstudents ON vw_sstudents.student_id=(sstudents.sstudent_id)::character varying
		WHERE (sstudents.curr_balance < (-2000))  AND (sstudents.finance_approval = true)
		GROUP BY vw_sstudents.session_id)
	UNION
	(SELECT 4, text 'Above Allowed Balance' AS "narrative", count(vw_sstudents.sstudent_id), vw_sstudents.session_id
		FROM vw_sstudents
		INNER JOIN sstudents ON vw_sstudents.student_id=(sstudents.sstudent_id)::character varying
		 WHERE (sstudents.finance_approval = true)
		GROUP BY vw_sstudents.session_id)
	UNION
	(SELECT 5, text 'Below Allowed Balance' AS "narrative", count(sstudent_id), session_id
		FROM vw_sstudents WHERE (curr_balance < ((-1)))
		GROUP BY session_id)
	UNION
	(SELECT 6, text 'Financially Approved' AS "narrative", count(sstudent_id), session_id 
		FROM sstudents WHERE (finance_approval = true)
		GROUP BY session_id)
	UNION
	(SELECT 7, text 'Approved and Below Allowed Balance' AS "narrative", count(vw_sstudents.sstudent_id), vw_sstudents.session_id
		FROM vw_sstudents 
		INNER JOIN sstudents ON vw_sstudents.student_id=(sstudents.sstudent_id)::character varying
		WHERE (vw_sstudents.curr_balance < ((-1)) AND (sstudents.finance_approval = true)) 
		GROUP BY vw_sstudents.session_id)
	UNION
	(SELECT 8, text 'Not Approved and Above Allowed Balance' AS "narrative", count(vw_sstudents.sstudent_id), vw_sstudents.session_id
		FROM vw_sstudents
		INNER JOIN sstudents ON vw_sstudents.student_id=(sstudents.sstudent_id)::character varying
		 WHERE (vw_sstudents.curr_balance >= ((-1) ) AND (sstudents.finance_approval = true)) 
		GROUP BY vw_sstudents.session_id)
	UNION
	(SELECT 9, text 'Closed Applications' AS "narrative", count(sstudent_id), session_id 
		FROM sstudents
		WHERE (finalised = true) GROUP BY session_id)
	UNION
	(SELECT 10, text 'Closed and not Finacially approved' AS "narrative", count(sstudent_id), session_id 
		FROM sstudents WHERE (finalised = true) AND (finance_approval = false) GROUP BY session_id)
	UNION
	(SELECT 11, text 'approved  Applications' AS "narrative", count(sstudent_id), vw_applications.session_id 
		FROM vw_applications
		INNER JOIN sstudents ON sstudents.session_id=vw_applications.session_id
		 WHERE (sstudents.approved = true) GROUP BY vw_applications.session_id);
	


	
CREATE OR REPLACE FUNCTION get_sstudent_id(int, varchar(12)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id)
	FROM sstudents
	WHERE (student_degree_id = $1) AND (session_id = $2);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION check_incomplete(int) RETURNS bigint AS $$
	SELECT count(sgrades.sgrade_id)
	FROM sgrades 
	INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id
	INNER JOIN grades ON grades.grade_id = sgrades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true)
		AND (grades.grade_name = 'IW') AND (sgrades.dropped = false);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION check_grade(int, float) RETURNS bigint AS $$
	SELECT count(sgrades.sgrade_id)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
	INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true) AND (sgrades.dropped = false)
		AND (grades.grade_weight < $2) AND (grades.gpa_count = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION check_grade(int, varchar(10), float) RETURNS bigint AS $$
	SELECT count(sgrades.sgrade_id)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
	INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (substring(sstudents.session_id from 1 for 9) = $2) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.grade_weight < $3) AND (grades.gpa_count = true);
$$ LANGUAGE SQL;


CREATE OR REPLACE VIEW slocation_stats AS 
	SELECT stat_id, narrative, student_count, vw_session_stats.session_id
	FROM vw_session_stats
	INNER JOIN vw_sstudents ON vw_sstudents.session_id=vw_session_stats.session_id;

CREATE OR REPLACE VIEW vw_deans_list AS 
	SELECT student_id, student_name, degree_name,  sex, sstudent_id, session_id
	FROM vw_student_session_list
	ORDER BY sstudent_id;

CREATE OR REPLACE VIEW vw_apply_grad_year AS
 SELECT vw_student_degrees.graduation_apply AS apply_grad_year
   FROM vw_student_degrees
  WHERE (vw_student_degrees.graduated = true)
  GROUP BY vw_student_degrees.graduation_apply
  ORDER BY vw_student_degrees.graduation_apply;

 CREATE OR REPLACE VIEW vw_grad_year AS 
	SELECT DISTINCT EXTRACT (YEAR FROM vw_student_degrees.graduate_date) AS grad_year
	FROM vw_student_degrees
	WHERE vw_student_degrees.graduated = true
	AND graduate_date IS NOT NULL;
	
CREATE OR REPLACE VIEW vw_school_degrees AS 
	SELECT school_id, degree_id, degree_name, school_name
	FROM vw_degrees
	GROUP BY school_id, degree_id, degree_name, school_name
	ORDER BY school_id
