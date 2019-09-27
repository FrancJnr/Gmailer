CREATE OR REPLACE VIEW vw_schools AS
	SELECT orgs.org_id, orgs.org_name, schools.school_id, schools.school_name, schools.philosopy, schools.vision, schools.mission, schools.objectives, schools.details
	FROM schools
	INNER JOIN orgs ON schools.org_id = orgs.org_id;


CREATE OR REPLACE VIEW vw_grades AS
	SELECT orgs.org_id, orgs.org_name, grades.grade_id, grades.grade_name, ROUND(grades.grade_weight::numeric,2) as grade_weight, grades.min_range, grades.max_range, 
	grades.gpa_count, grades.narrative, grades.details
	FROM grades
	INNER JOIN orgs ON grades.org_id = orgs.org_id;
	
---view assets and sites where they belong---
CREATE OR REPLACE VIEW vw_assets AS
	SELECT orgs.org_id, orgs.org_name, sites.site_id, sites.site_name, assets.asset_id, assets.asset_name, assets.building, assets.location, 
		assets.capacity, assets.details
	FROM assets
	INNER JOIN sites ON assets.site_id = sites.site_id
	INNER JOIN orgs ON assets.org_id = orgs.org_id;

--linking denominations to religions--
CREATE OR REPLACE VIEW vw_denominations AS
	SELECT orgs.org_id, orgs.org_name, religions.religion_id, religions.religion_name, religions.details as religion_details,
		denominations.denomination_id, denominations.denomination_name, denominations.details as denomination_details
	FROM religions
	INNER JOIN denominations ON religions.religion_id = denominations.religion_id
	INNER JOIN orgs ON denominations.org_id = orgs.org_id;

	
--view degree departments and their degree levels--
CREATE OR REPLACE VIEW  vw_degrees AS
	SELECT vw_schools.org_id, vw_schools.org_name, vw_schools.school_id, vw_schools.school_name, degree_levels.degree_level_id, degree_levels.degree_level_name,  
	 degrees.degree_id, degrees.degree_name, degrees.details
	FROM degrees
	INNER JOIN degree_levels ON degrees.degree_level_id = degree_levels.degree_level_id
	INNER JOIN vw_schools ON vw_schools.school_id = degrees.school_id;
	
--view degree specializations--	
CREATE OR REPLACE VIEW vw_specializations AS
	SELECT vw_degrees.org_id, vw_degrees.org_name, vw_degrees.degree_level_id, vw_degrees.degree_level_name,  
	vw_degrees.school_id, vw_degrees.school_name, vw_degrees.degree_id, vw_degrees.degree_name, vw_degrees.details AS degree_details,
	specializations.specialization_id, specializations.specialization_name, specializations.details AS specializations_details
	FROM specializations
	INNER JOIN vw_degrees ON specializations.degree_id = vw_degrees.degree_id;

--view major details--
CREATE OR REPLACE VIEW vw_majors AS
	SELECT orgs.org_id, orgs.org_name, majors.major_id, majors.major_name, majors.major, majors.minor, majors.full_credit, majors.elective_credit, 
	 majors.minor_elective_credit,majors.major_minimal, majors.minor_minimum, majors.core_minimum, 
	 majors.details, majors.min_level, majors.max_level
	FROM majors
	INNER JOIN orgs ON majors.org_id = orgs.org_id;
		
--view cohort details--
CREATE OR REPLACE VIEW vw_cohorts AS 
	SELECT vw_degrees.org_id, vw_degrees.org_name, cohorts.cohort_id, cohorts.cohort_name, vw_degrees.school_name, cohorts.max_number,
		cohorts.start_date, cohorts.end_date,cohorts.is_active, sites.site_id,sites.site_name,vw_degrees.degree_level_id, vw_degrees.degree_level_name, vw_degrees.school_id,  
		vw_degrees.degree_id, vw_degrees.degree_name, vw_degrees.details, cohorts.cohort_open,
		(CASE WHEN cohorts.cohort_open =TRUE THEN 'admitting' ELSE 'ongoing' 
		END) AS current_satus
	FROM cohorts 
		INNER JOIN schools ON schools.school_id=cohorts.school_id
		INNER JOIN vw_degrees ON vw_degrees.degree_id=cohorts.degree_id
		INNER JOIN sites ON sites.site_id=cohorts.site_id;
		
--view types of rooms 
CREATE OR REPLACE VIEW vw_room_types AS
	SELECT orgs.org_id, orgs.org_name, room_types.room_type_id, room_types.room_type_name, room_types.max_occupants, room_types.details
	FROM room_types
	INNER JOIN orgs ON room_types.org_id = orgs.org_id;

--view existing residential areas with their respective locations--
CREATE OR REPLACE VIEW vw_residences AS
	SELECT orgs.org_id, orgs.org_name, residences.residence_id, residences.residence_name, residences.capacity, residences.room_size,
		residences.default_rate, residences.off_campus, residences.Sex, residences.residence_dean, residences.details, 
		sites.site_id, sites.site_name, sites.details AS site_details, 
		(CASE WHEN sex='M' then 'MALE' WHEN sex='F' then 'FEMALE' WHEN sex='N' then 'N/A' END) AS gender
	FROM residences
		LEFT JOIN sites ON sites.site_id = residences.site_id
		INNER JOIN orgs ON sites.org_id = orgs.org_id;
		
--view rooms in a residence and their details		
CREATE OR REPLACE VIEW vw_rooms AS
	SELECT vw_residences.org_id, vw_residences.org_name, vw_residences.residence_id, vw_residences.residence_name,
	vw_residences.capacity, vw_residences.room_size, vw_residences.default_rate, vw_residences.off_campus, vw_residences.gender, 
	vw_residences.residence_dean, vw_residences.details AS residence_details, vw_residences.site_id, vw_residences.site_name, 
	vw_residences.site_details, room_types.room_type_id, room_types.room_type_name, room_types.details AS room_type_details, 
	rooms.room_id, rooms.room_name, rooms.room_charge, rooms.details, 
	room_types.max_occupants, 
	(CASE WHEN max_occupants::int=1 then room_types.max_occupants||' '||'occupant'
	     WHEN max_occupants::int>1 then room_types.max_occupants||' '||'occupants'
	END) AS room_capacity, sresidences.sresidence_id, is_booked, is_checked_out, status, room_count		
	FROM rooms
        INNER JOIN vw_residences ON rooms.residence_id = vw_residences.residence_id
        INNER JOIN sresidences ON sresidences.residence_id = vw_residences.residence_id
        INNER JOIN room_types ON rooms.room_type_id = room_types.room_type_id;
            
--view instructors in a school and their departments--
CREATE OR REPLACE VIEW vw_lecturer_categories AS
	SELECT orgs.org_id, orgs.org_name, lecturer_categories.lecturer_category_id, lecturer_categories.lecturer_category_name, lecturer_categories.details
	FROM lecturer_categories
        INNER JOIN orgs ON lecturer_categories.org_id = orgs.org_id;


--view instructors in a school and their departments--
CREATE OR REPLACE VIEW vw_instructors AS
	SELECT instructors.org_id,  vw_schools.school_id, vw_schools.school_name,  entitys.entity_id, entitys.entity_name, lecturer_categories.lecturer_category_id, lecturer_categories.lecturer_category_name, lecturer_categories.details, instructors.instructor_id, instructors.instructor_name, sys_countrys.sys_country_id, sys_countrys.sys_country_name, instructors.post_office_box, instructors.postal_code, instructors.premises, instructors.street, instructors.town, instructors.phone_number, instructors.mobile, instructors.email, instructors.site_id, sites.site_name
	FROM vw_schools
		INNER JOIN instructors ON vw_schools.school_id = instructors.school_id
		INNER JOIN sites ON instructors.site_id = sites.site_id
		LEFT JOIN entitys ON entitys.entity_id = instructors.entity_id
		LEFT JOIN sys_countrys ON sys_countrys.sys_country_id=instructors.sys_country_id
		LEFT JOIN lecturer_categories ON lecturer_categories.lecturer_category_id = instructors.lecturer_category_id;

--view courses details --
CREATE OR REPLACE VIEW vw_courses AS
	SELECT   vw_schools.school_id, vw_schools.school_name, degree_levels.degree_level_id, degree_levels.degree_level_name, 
		course_types.course_type_id, course_types.course_type_name,
		courses.course_id, courses.course_title,courses.lab_course, courses.min_credit, courses.max_credit, courses.lecture_hours, courses.practical_hours,
		courses.credit_hours, courses.is_current, courses.no_gpa, courses.no_repeats,courses.extra_charge,
		courses.year_taken,courses.details,course_modes.course_mode_id, course_modes.course_mode_name
	FROM ((vw_schools
		INNER JOIN courses ON vw_schools.school_id = courses.school_id)
		INNER JOIN degree_levels ON courses.degree_level_id = degree_levels.degree_level_id)
		INNER JOIN course_types ON courses.course_type_id = course_types.course_type_id
		INNER JOIN course_modes ON course_modes.course_mode_id=courses.course_mode_id;


---prereq view--
CREATE OR REPLACE VIEW vw_prereq AS
	SELECT orgs.org_id, orgs.org_name, courses.course_id, courses.course_title, prerequisites.prerequisite_id,  prerequisites.precourse_id,
		prerequisites.option_level, prerequisites.narrative, grades.grade_id, grades.grade_weight,
		bulletings.bulletings_id, bulletings.bulletings_name, bulletings.starting_session, bulletings.ending_session,major_content_id,grades.grade_name
	FROM ((courses INNER JOIN prerequisites ON courses.course_id = prerequisites.course_id)
		INNER JOIN grades ON prerequisites.grade_id = grades.grade_id)
		LEFT JOIN bulletings ON prerequisites.bulletings_id = bulletings.bulletings_id
		LEFT JOIN major_contents ON major_contents.course_id=courses.course_id
		INNER JOIN orgs ON courses.org_id = orgs.org_id;

--prerequisite view--
CREATE OR REPLACE VIEW vw_prerequisite AS
	SELECT vw_prereq.org_id, vw_prereq.org_name, courses.course_id as precourse_id, courses.course_title as precourse_title,
		vw_prereq.course_id, vw_prereq.course_title,  vw_prereq.prerequisite_id,
		vw_prereq.option_level, vw_prereq.narrative, vw_prereq.grade_id, vw_prereq.grade_weight,
		vw_prereq.bulletings_id, vw_prereq.bulletings_name, vw_prereq.starting_session, vw_prereq.ending_session, vw_prereq.grade_name, vw_prereq.major_content_id
	FROM courses
		INNER JOIN vw_prereq ON courses.course_id = vw_prereq.precourse_id
	ORDER BY vw_prereq.course_id, vw_prereq.option_level;
	
		
--requirements view--
CREATE OR REPLACE VIEW vw_requirements AS
	SELECT orgs.org_id, orgs.org_name, subjects.subject_id, subjects.subject_name, marks.mark_id,marks.grade, requirements.requirement_id, requirements.narrative
	FROM ((vw_majors
            INNER JOIN requirements ON vw_majors.major_id = requirements.major_id)
            INNER JOIN subjects ON requirements.subject_id = subjects.subject_id)
        INNER JOIN marks ON requirements.mark_id = marks.mark_id
        INNER JOIN orgs ON subjects.org_id = orgs.org_id;

--view contents of a major --
CREATE OR REPLACE VIEW vw_major_contents AS
	SELECT vw_majors.org_id, vw_majors.org_name, vw_majors.major_id, vw_majors.major_name,
		vw_majors.elective_credit, courses.course_id, courses.course_title, courses.credit_hours, courses.no_gpa,
		courses.year_taken, courses.details as course_details,
		content_types.content_type_id, content_types.content_type_name, content_types.elective, content_types.prerequisite,
		content_types.pre_major, major_contents.major_content_id, major_contents.minor, major_contents.grade_id, major_contents.narrative,
		bulletings.bulletings_id, bulletings.bulletings_name, bulletings.starting_session, bulletings.ending_session,
		bulletings.active
	FROM (((vw_majors
			INNER JOIN major_contents ON vw_majors.major_id = major_contents.major_id)
			INNER JOIN courses ON major_contents.course_id = courses.course_id)
			INNER JOIN content_types ON major_contents.content_type_id = content_types.content_type_id)
		INNER JOIN bulletings ON major_contents.bulletings_id = bulletings.bulletings_id;


----view sponsors details---
CREATE OR REPLACE VIEW vw_sponsors AS
	SELECT  sponsor_types.sponsor_type_id, sponsor_types.sponsor_type_name, sponsors.sponsor_id, sponsors.org_id,
		sponsors.sponsor_name, sponsors.address, sponsors.street, sponsors.postal_code,
		sponsors.town, sponsors.telno, sponsors.email, sponsors.active, sponsors.details,
		sys_countrys.sys_country_id, sys_countrys.sys_country_name, ln_sponsors.ln_sponsor_id, sponsor_categorys.sponsor_category_id, 
		sponsor_categorys.sponsor_category_name, sponsor_categorys.details AS sponsor_categorys_setails, sponsors.wage_factor
	FROM sponsors
		LEFT JOIN sponsors as ln_sponsors ON ln_sponsors.ln_sponsor_id = sponsors.ln_sponsor_id
		LEFT JOIN sponsor_types ON sponsor_types.sponsor_type_id = sponsors.sponsor_type_id
		LEFT JOIN sponsor_categorys ON sponsor_categorys.sponsor_category_id = sponsors.sponsor_category_id
		INNER JOIN sys_countrys ON sys_countrys.sys_country_id = sponsors.sys_country_id;
		

--view students details--
CREATE OR REPLACE VIEW vw_students AS
	SELECT vw_denominations.religion_id, vw_denominations.religion_name, 
		vw_denominations.denomination_id, vw_denominations.denomination_name,
		vw_schools.school_id, vw_schools.school_name,  
		vw_sponsors.sponsor_type_id, vw_sponsors.sponsor_type_name, vw_sponsors.sponsor_id, vw_sponsors.sponsor_name,
		vw_sponsors.address as sponsor_address, vw_sponsors.street as sponsor_street, vw_sponsors.postal_code as sponsor_postal_code,
		vw_sponsors.town as sponsor_town, vw_sponsors.telno as sponsor_telno, vw_sponsors.email as sponsor_email,
		vw_sponsors.sys_country_id as sponsor_country_id, vw_sponsors.sys_country_name as sponsor_country_name,
		residences.residence_id, residences.residence_name, c1.sys_country_name as address_country, students.org_id, students.student_id, students.student_name, students.room_number, students.address, students.zipcode, students.town, students.tel_no, students.email,
		students.account_number,students.admission_basis, students.Nationality, c3.sys_country_name as nationality_country, students.Sex,
		students.marital_status, students.birth_date, students.alumnae, students.post_contacts, students.on_probation, students.off_campus, students.current_contact, students.current_email, students.current_tel, students.full_bursary, students.details, students.staff, students.onhold, students.student_edit, students.disabilitys_details, students.passport, students.national_id, students.identification_no, students.picture_file, students.balance_time, students.curr_balance,
		students.probation_details, vw_sponsors.wage_factor, vw_registrations.admission_status_id, vw_registrations.admission_status_name,
		(CASE WHEN students.sex='M' then 'MALE'
            WHEN students.sex='F' then 'FEMALE'
            WHEN students.sex='N' then 'N/A'
		END) AS gender,
		(CASE WHEN students.marital_status='M' then 'MARRIED'
            WHEN students.marital_status='S' then 'SINGLE'
            WHEN students.marital_status='' then 'N/A'
		END) AS marital
	FROM ((((vw_denominations
			LEFT JOIN students ON vw_denominations.denomination_id = students.denomination_id)
			LEFT JOIN vw_schools ON vw_schools.school_id = students.school_id)
		  	INNER JOIN vw_sponsors ON students.sponsor_id=vw_sponsors.sponsor_id)
			LEFT JOIN residences ON students.residence_id = residences.residence_id)
		LEFT JOIN sys_countrys as c1 ON students.country_code_id = c1.sys_country_id
		LEFT JOIN sys_countrys as c3 ON students.Nationality = c3.sys_country_id
		 LEFT JOIN vw_registrations ON students.student_id::text = vw_registrations.existing_id::text;

--view students degrees details--
CREATE OR REPLACE VIEW vw_student_degrees AS
	SELECT  vw_cohorts.cohort_id, vw_cohorts.cohort_name, vw_cohorts.max_number, vw_cohorts.start_date, vw_cohorts.end_date, vw_cohorts.is_active, vw_cohorts.site_id, vw_cohorts.site_name, vw_cohorts.degree_level_id, vw_cohorts.degree_level_name, vw_cohorts.school_id,  vw_cohorts.degree_id, vw_cohorts.degree_name,
	
    vw_students.religion_id, vw_students.religion_name, vw_students.denomination_id, vw_students.denomination_name,
    vw_students.sponsor_type_id, vw_students.sponsor_type_name, vw_students.sponsor_id, vw_students.sponsor_name,
    vw_students.sponsor_address, vw_students.sponsor_street, vw_students.sponsor_postal_code,
    vw_students.sponsor_town, vw_students.sponsor_telno, vw_students.sponsor_email,
    vw_students.sponsor_country_id, vw_students.sponsor_country_name, vw_students.wage_factor,
    vw_students.school_name, vw_students.student_id, vw_students.student_name, vw_students.address, vw_students.zipcode,
    vw_students.town, vw_students.address_country, vw_students.tel_no, vw_students.email, vw_students.staff,vw_students.onhold,
    vw_students.student_edit,vw_students.disabilitys_details,vw_students.passport,
    vw_students.national_id,vw_students.identification_no,vw_students.picture_file,vw_students.balance_time,vw_students.curr_balance,
    vw_students.account_number, vw_students.Nationality, vw_students.nationality_country, vw_students.Sex,
    vw_students.marital_status, vw_students.birth_date, vw_students.alumnae, vw_students.post_contacts,
    vw_students.on_probation, vw_students.off_campus, vw_students.current_contact, vw_students.current_email, vw_students.current_tel,
    vw_students.org_id,
    
    student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.cleared, student_degrees.clear_date,
    student_degrees.graduated, student_degrees.graduate_date,student_degrees.graduation_apply, student_degrees.drop_out, student_degrees.transfer_in, student_degrees.transfer_out,
    student_degrees.details, vw_students.gender, vw_students.marital
	FROM (vw_students
			INNER JOIN student_degrees ON vw_students.student_id = student_degrees.student_id)
		LEFT JOIN vw_cohorts ON student_degrees.cohort_id = vw_cohorts.cohort_id;

--view sessions 
CREATE OR REPLACE VIEW vw_sessions AS
	SELECT vw_cohorts.org_id, vw_cohorts.org_name, vw_cohorts.cohort_id, vw_cohorts.cohort_name, vw_cohorts.school_name, vw_cohorts.max_number, sessions.post_session, vw_cohorts.start_date, vw_cohorts.end_date, vw_cohorts.is_active, vw_cohorts.degree_id, vw_cohorts.degree_name, vw_cohorts.site_id, vw_cohorts.site_name, 
	
	sessions.session_id,  sessions.semister, sessions.site,
	sessions.session_start, sessions.slate_reg, sessions.slate_change, sessions.slast_drop, sessions.session_end, sessions.active,
	sessions.session_name, sessions.min_credits, sessions.max_credits, sessions.charge_rate, sessions.details, sessions.session_closed, sessions.pre_session, sessions.late_registration_fee, sessions.session_year::text,
    trim(SUBSTRING(sessions.session_id from 1 for 9)) AS sessions
    
	FROM sessions
	INNER JOIN vw_cohorts ON vw_cohorts.cohort_id=sessions.cohort_id
	ORDER BY session_id desc;

--view residence details for the session--
CREATE OR REPLACE VIEW vw_sresidences AS
	SELECT vw_sessions.session_year, vw_sessions.session_start, vw_sessions.session_end, 
	vw_sessions.active,vw_sessions.session_name,sresidences.org_id, sresidences.sresidence_id, 
	sresidences.session_id, vw_residences.residence_id, vw_residences.residence_name, 
	vw_residences.capacity, vw_residences.room_size, vw_residences.default_rate, vw_residences.off_campus, vw_residences.sex, 
	vw_residences.residence_dean, vw_residences.details, vw_residences.site_id, vw_residences.site_name, vw_residences.site_details, 
	vw_residences.gender 
	FROM (sresidences
		INNER JOIN vw_residences ON vw_residences.residence_id = sresidences.residence_id)
	INNER JOIN vw_sessions ON sresidences.session_id = vw_sessions.session_id;

----view session charges-----
CREATE OR REPLACE VIEW vw_scharges AS
	SELECT vw_sessions.org_id, vw_sessions.org_name,  vw_sessions.session_id,
	 vw_sessions.semister, vw_sessions.site,
	 vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, 
	 vw_sessions.slast_drop, vw_sessions.session_end, vw_sessions.active, vw_sessions.session_name, vw_sessions.min_credits, vw_sessions.max_credits, 
	 vw_sessions.charge_rate, vw_sessions.late_registration_fee, vw_sessions.cohort_id, 
	 vw_sessions.cohort_name, vw_sessions.school_name, vw_sessions.max_number, vw_sessions.start_date, vw_sessions.end_date, vw_sessions.is_active AS session_active, 
	 vw_sessions.degree_id, vw_sessions.degree_name, vw_sessions.site_id, vw_sessions.site_name, vw_sessions.session_year, vw_sessions.sessions,
	 
	 vw_sponsors.sponsor_name, vw_sponsors.address, vw_sponsors.street, vw_sponsors.postal_code, vw_sponsors.town, vw_sponsors.telno, 
	 vw_sponsors.email, vw_sponsors.active AS sponsor_active, vw_sponsors.details, vw_sponsors.sys_country_id, vw_sponsors.sys_country_name, vw_sponsors.ln_sponsor_id, 
	 vw_sponsors.sponsor_category_id, vw_sponsors.sponsor_category_name, vw_sponsors.sponsor_categorys_setails, vw_sponsors.wage_factor AS sponsor_wage_factor, 
	 vw_sponsors.sponsor_type_name,

	 scharges.scharge_id, scharges.sponsor_country, scharges.wage_factor AS scharge_wagefactor, scharges.accomodation_charge, scharges.exchange_rate, scharges.narrative
	
	FROM scharges
	INNER JOIN vw_sessions ON scharges.session_id = vw_sessions.session_id
	INNER JOIN vw_sponsors ON scharges.sponsor_id = vw_sponsors.sponsor_id;
	
---view session students details----
CREATE OR REPLACE VIEW vw_sstudents AS
	SELECT vw_student_degrees.religion_id, vw_student_degrees.religion_name, vw_student_degrees.denomination_id,
		vw_student_degrees.denomination_name, vw_student_degrees.degree_level_id, vw_student_degrees.degree_level_name,
		vw_student_degrees.sponsor_type_id, vw_student_degrees.sponsor_type_name, vw_student_degrees.sponsor_id, vw_student_degrees.sponsor_name,
		vw_student_degrees.sponsor_address, vw_student_degrees.sponsor_street, vw_student_degrees.sponsor_postal_code,
		vw_student_degrees.sponsor_town, vw_student_degrees.sponsor_telno, vw_student_degrees.sponsor_email,
		vw_student_degrees.sponsor_country_id, vw_student_degrees.sponsor_country_name, vw_student_degrees.wage_factor,
		vw_student_degrees.school_id, vw_student_degrees.school_name, vw_student_degrees.student_id, vw_student_degrees.student_name, vw_student_degrees.address, vw_student_degrees.zipcode,
		vw_student_degrees.town, vw_student_degrees.address_country, vw_student_degrees.tel_no, vw_student_degrees.email,
		vw_student_degrees.account_number, vw_student_degrees.Nationality, vw_student_degrees.nationality_country, vw_student_degrees.Sex,
		vw_student_degrees.marital_status, vw_student_degrees.birth_date, vw_student_degrees.alumnae, vw_student_degrees.post_contacts,
		vw_student_degrees.on_probation,  vw_student_degrees.off_campus, vw_student_degrees.current_contact, vw_student_degrees.current_email, vw_student_degrees.current_tel, vw_student_degrees.degree_id, vw_student_degrees.degree_name, vw_student_degrees.student_degree_id, vw_student_degrees.completed, vw_student_degrees.started, vw_student_degrees.cleared, vw_student_degrees.clear_date, vw_student_degrees.graduated, vw_student_degrees.graduate_date, vw_student_degrees.drop_out, vw_student_degrees.transfer_in, vw_student_degrees.transfer_out, vw_student_degrees.marital, 
		
		vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.slast_drop, vw_sessions.session_end, vw_sessions.active, vw_sessions.session_year, vw_sessions.sessions, vw_sessions.session_name, 
	
		
		vw_sresidences.residence_id, vw_sresidences.residence_name, vw_sresidences.capacity, vw_sresidences.default_rate, vw_sresidences.off_campus AS residence_off_campus, vw_sresidences.Sex AS residence_sex, vw_sresidences.residence_dean, vw_sresidences.sresidence_id, 
		 
		sstudents.org_id, sstudents.sstudent_id, sstudents.extra_charges AS additional_charges, sstudents.probation,
		sstudents.room_id, sstudents.curr_balance,  sstudents.major_approval,
		sstudents.exam_clear, sstudents.exam_clear_date, sstudents.exam_clear_balance,sstudents.inter_session,
		sstudents.request_withdraw, sstudents.request_withdraw_date, sstudents.withdraw, sstudents.ac_withdraw,
		sstudents.withdraw_date, sstudents.withdraw_rate, sstudents.approved,sstudents.no_approval, sstudents.study_level,
		sstudents.overload_approval, sstudents.finalised, sstudents.student_dean_approval, sstudents.chaplain_approval, sstudents.depart_approval, sstudents.details, sstudents.finance_approval, sstudents.hours,
		sstudents.first_instalment, sstudents.first_date, sstudents.second_instalment, sstudents.second_date, sstudents.LRF_picked,
		sstudents.LRF_picked_date, sstudents.on_attachment, sstudents.session_id, sstudents.overload_hours, sstudents.registrar_approval, sstudents.ict_approval, sstudents.residence_approval, vw_student_degrees.gender, 
		sstudents.charges, sstudents.extra_charges, sstudents.application_time
	FROM (((vw_student_degrees
			INNER JOIN sstudents ON vw_student_degrees.student_degree_id = sstudents.student_degree_id)
			LEFT JOIN vw_sessions ON sstudents.session_id = vw_sessions.session_id)
			LEFT JOIN vw_sresidences ON sstudents.sresidence_id = vw_sresidences.sresidence_id);

--view active sstudents-------------
CREATE OR REPLACE VIEW vw_current_sstudents AS	
	SELECT vw_sstudents.religion_id, vw_sstudents.religion_name, vw_sstudents.denomination_id, vw_sstudents.denomination_name, 
		vw_sstudents.sponsor_type_id, vw_sstudents.sponsor_type_name, vw_sstudents.sponsor_id, vw_sstudents.sponsor_name, 
		vw_sstudents.sponsor_address,vw_sstudents.sponsor_street, vw_sstudents.sponsor_postal_code, vw_sstudents.sponsor_town, 
		vw_sstudents.sponsor_telno, vw_sstudents.sponsor_email, vw_sstudents.sponsor_country_id, vw_sstudents.sponsor_country_name, 
		vw_sstudents.school_id, vw_sstudents.school_name, vw_sstudents.student_id, vw_sstudents.student_name, vw_sstudents.address, 
		vw_sstudents.zipcode, vw_sstudents.town, vw_sstudents.address_country, vw_sstudents.tel_no, vw_sstudents.email, 
		vw_sstudents.account_number, vw_sstudents.nationality, vw_sstudents.nationality_country, vw_sstudents.sex, vw_sstudents.marital_status, vw_sstudents.birth_date,
		vw_sstudents.alumnae, vw_sstudents.post_contacts, vw_sstudents.on_probation, vw_sstudents.off_campus, vw_sstudents.current_contact, 
		vw_sstudents.current_email,  vw_sstudents.degree_id, vw_sstudents.degree_name, vw_sstudents.student_degree_id,
		vw_sstudents.completed, vw_sstudents.started, vw_sstudents.cleared, vw_sstudents.clear_date, vw_sstudents.graduated, 
		vw_sstudents.graduate_date, vw_sstudents.drop_out, vw_sstudents.transfer_in, vw_sstudents.transfer_out, vw_sstudents.session_start,
		vw_sstudents.slate_reg, vw_sstudents.slate_change, vw_sstudents.slast_drop, vw_sstudents.session_end, 
		vw_sstudents.active, vw_sstudents.session_year, vw_sstudents.sessions, vw_sstudents.session_name, 
        vw_sstudents.residence_id, vw_sstudents.residence_name, vw_sstudents.capacity, vw_sstudents.default_rate, vw_sstudents.residence_off_campus, vw_sstudents.residence_sex, vw_sstudents.residence_dean, vw_sstudents.sresidence_id, 
		vw_sstudents.org_id, vw_sstudents.sstudent_id, vw_sstudents.additional_charges, vw_sstudents.probation, vw_sstudents.room_id, vw_sstudents.curr_balance, vw_sstudents.major_approval, vw_sstudents.exam_clear, vw_sstudents.exam_clear_date, vw_sstudents.exam_clear_balance, vw_sstudents.inter_session, vw_sstudents.request_withdraw, vw_sstudents.request_withdraw_date,
		vw_sstudents.withdraw, vw_sstudents.ac_withdraw, vw_sstudents.withdraw_date, vw_sstudents.withdraw_rate, vw_sstudents.approved, vw_sstudents.no_approval, vw_sstudents.study_level, vw_sstudents.overload_approval, vw_sstudents.finalised, vw_sstudents.student_dean_approval, vw_sstudents.chaplain_approval, vw_sstudents.depart_approval, vw_sstudents.details, vw_sstudents.finance_approval, vw_sstudents.hours, vw_sstudents.first_instalment, vw_sstudents.first_date, vw_sstudents.second_instalment, vw_sstudents.second_date, vw_sstudents.lrf_picked, vw_sstudents.lrf_picked_date, vw_sstudents.on_attachment, vw_sstudents.session_id, vw_sstudents.overload_hours, vw_sstudents.ict_approval, vw_sstudents.residence_approval, vw_sstudents.registrar_approval
	FROM vw_sstudents
        INNER JOIN sessions ON vw_sstudents.session_id=sessions.session_id
	WHERE sessions.active=true;
	
--view students session degrees details----
CREATE OR REPLACE VIEW vw_sstudent_degrees AS
	SELECT  vw_sstudents.student_id, vw_sstudents.student_name,
		vw_sstudents.address, vw_sstudents.zipcode, vw_sstudents.town, vw_sstudents.address_country, vw_sstudents.tel_no, vw_sstudents.email, vw_sstudents.account_number, vw_sstudents.nationality, vw_sstudents.nationality_country, vw_sstudents.sex, vw_sstudents.marital_status, vw_sstudents.birth_date, vw_sstudents.alumnae, vw_sstudents.post_contacts, vw_sstudents.on_probation, 
		vw_sstudents.current_contact, vw_sstudents.current_email, vw_sstudents.student_degree_id, vw_sstudents.completed, vw_sstudents.started, vw_sstudents.cleared, vw_sstudents.clear_date, vw_sstudents.graduated, vw_sstudents.graduate_date, vw_sstudents.drop_out, vw_sstudents.transfer_in, vw_sstudents.transfer_out, vw_sstudents.session_start, vw_sstudents.slate_reg, vw_sstudents.slate_change, vw_sstudents.slast_drop, vw_sstudents.session_end, vw_sstudents.active, vw_sstudents.session_year, vw_sstudents.sessions, vw_sstudents.residence_off_campus, vw_sstudents.overload_approval, vw_sstudents.finalised, 
        vw_sstudents.student_dean_approval, vw_sstudents.chaplain_approval, vw_sstudents.depart_approval,  vw_sstudents.finance_approval, 
        vw_sstudents.hours, vw_sstudents.first_instalment, vw_sstudents.first_date, vw_sstudents.second_instalment, vw_sstudents.second_date, vw_sstudents.lrf_picked, vw_sstudents.lrf_picked_date, vw_sstudents.on_attachment, vw_sstudents.session_id, vw_sstudents.approved, vw_sstudents.org_id, vw_sstudents.sstudent_id, vw_sstudents.additional_charges, vw_sstudents.overload_hours,vw_sstudents.no_approval, vw_sstudents.probation, vw_sstudents.room_id, vw_sstudents.curr_balance, vw_sstudents.major_approval, vw_sstudents.exam_clear, vw_sstudents.exam_clear_date, vw_sstudents.exam_clear_balance, vw_sstudents.inter_session, vw_sstudents.request_withdraw,
        
		vw_sresidences.residence_id, vw_sresidences.residence_name, vw_sresidences.capacity, vw_sresidences.default_rate,
		vw_sresidences.off_campus, vw_sresidences.Sex as residence_sex, vw_sresidences.residence_dean, vw_sresidences.sresidence_id, vw_sresidences.session_name,
		
		vw_cohorts.cohort_id, vw_cohorts.cohort_name, vw_cohorts.school_name, vw_cohorts.school_id, vw_cohorts.max_number, vw_cohorts.start_date, vw_cohorts.end_date, vw_cohorts.is_active, vw_cohorts.site_id, vw_cohorts.site_name, vw_cohorts.degree_level_id, vw_cohorts.degree_level_name, vw_cohorts.degree_id, vw_cohorts.degree_name, vw_cohorts.details

	FROM students
		INNER JOIN student_degrees ON student_degrees.student_id = students.student_id
		INNER JOIN vw_cohorts ON vw_cohorts.cohort_id = student_degrees.cohort_id
		INNER JOIN vw_sstudents ON vw_sstudents.student_degree_id = student_degrees.student_degree_id
		INNER JOIN vw_sresidences ON vw_sstudents.sresidence_id = vw_sresidences.sresidence_id;

--view students transcript print details --
CREATE OR REPLACE VIEW vw_transcript_prints AS
	SELECT  orgs.org_id, entitys.entity_id, entitys.entity_name, entitys.user_name, transcript_print.transcript_print_id,
		transcript_print.student_degree_id, transcript_print.print_date, transcript_print.narrative,
		transcript_print.ip_address, transcript_print.accepted
	FROM transcript_print
		INNER JOIN entitys ON transcript_print.entity_id = entitys.entity_id
		INNER JOIN orgs ON transcript_print.org_id = orgs.org_id;

--view students specialization details --
CREATE OR REPLACE VIEW vw_student_specializations AS
	SELECT vw_student_degrees.cohort_id, vw_student_degrees.cohort_name, vw_student_degrees.max_number, vw_student_degrees.start_date, 
		vw_student_degrees.end_date, vw_student_degrees.is_active, vw_student_degrees.site_id, vw_student_degrees.site_name, 
		vw_student_degrees.degree_level_id, vw_student_degrees.degree_level_name,  
		vw_student_degrees.degree_id, vw_student_degrees.degree_name, vw_student_degrees.religion_id, vw_student_degrees.religion_name, 
		vw_student_degrees.denomination_id, vw_student_degrees.denomination_name, vw_student_degrees.sponsor_type_id, 
		vw_student_degrees.sponsor_type_name, vw_student_degrees.sponsor_id, vw_student_degrees.sponsor_name, vw_student_degrees.sponsor_address, vw_student_degrees.sponsor_street, vw_student_degrees.sponsor_postal_code, vw_student_degrees.sponsor_town, vw_student_degrees.sponsor_telno, vw_student_degrees.sponsor_email,
		vw_student_degrees.sponsor_country_id, vw_student_degrees.sponsor_country_name, vw_student_degrees.school_id, vw_student_degrees.school_name, vw_student_degrees.student_id, vw_student_degrees.student_name, vw_student_degrees.address, vw_student_degrees.zipcode, vw_student_degrees.town, vw_student_degrees.address_country, vw_student_degrees.tel_no, vw_student_degrees.email, vw_student_degrees.staff, vw_student_degrees.onhold,
		vw_student_degrees.student_edit, vw_student_degrees.disabilitys_details, vw_student_degrees.passport, vw_student_degrees.national_id, vw_student_degrees.identification_no, vw_student_degrees.picture_file, vw_student_degrees.balance_time, vw_student_degrees.curr_balance, vw_student_degrees.account_number, vw_student_degrees.nationality, vw_student_degrees.nationality_country, vw_student_degrees.sex,
		vw_student_degrees.marital_status, vw_student_degrees.birth_date, vw_student_degrees.alumnae, vw_student_degrees.post_contacts,
		vw_student_degrees.on_probation, vw_student_degrees.off_campus, vw_student_degrees.current_contact, vw_student_degrees.current_email,
		vw_student_degrees.current_tel, vw_student_degrees.org_id, vw_student_degrees.student_degree_id, vw_student_degrees.completed, 
		vw_student_degrees.started, vw_student_degrees.cleared, vw_student_degrees.clear_date, vw_student_degrees.graduated,
		vw_student_degrees.graduate_date, vw_student_degrees.graduation_apply, vw_student_degrees.drop_out, vw_student_degrees.transfer_in, 
		vw_student_degrees.transfer_out, 
		
		  
        vw_specializations.degree_details, 
		vw_specializations.specialization_id, vw_specializations.specialization_name, vw_specializations.specializations_details as specialization_details, student_specialization_id
	FROM ((vw_student_degrees
			LEFT JOIN student_specializations ON vw_student_degrees.student_degree_id = student_specializations.student_degree_id)
		LEFT JOIN vw_specializations ON student_specializations.specialization_id = vw_specializations.specialization_id);
	
--view primary specializations
CREATE OR REPLACE VIEW vw_primary_specializations AS
	SELECT schools.org_id, schools.school_id, schools.school_name,  
		specializations.specialization_id, specializations.specialization_name, student_specializations.student_degree_id	
	FROM ((schools INNER JOIN departments ON schools.school_id = departments.school_id) 
		INNER JOIN degrees ON departments.school_id = degrees.school_id
		INNER JOIN specializations ON degrees.school_id = specializations.degree_id)
		INNER JOIN student_specializations ON specializations.specialization_id = student_specializations.specialization_id
	WHERE (student_specializations.major = true) AND (student_specializations.primary_major = true); 


--view students primary specializations
CREATE OR REPLACE VIEW vw_students_primary_specializations AS
	SELECT students.org_id, students.student_id, students.student_name, students.account_number, students.Nationality, 
		students.sex, students.Marital_Status, students.birth_date, students.on_probation, students.off_campus,
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.graduated,
		 vw_primary_specializations.school_name, vw_primary_specializations.school_id, 
		vw_primary_specializations.specialization_id, vw_primary_specializations.specialization_name
	FROM (students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN vw_primary_specializations ON student_degrees.student_degree_id = vw_primary_specializations.student_degree_id
	WHERE (student_degrees.completed = false);

--view primary majors
CREATE OR REPLACE VIEW vw_primary_major AS
	SELECT schools.org_id,  schools.school_name, departments.school_id, departments.department_name, 
		specializations.specialization_id, specializations.specialization_name, student_specializations.student_degree_id	
	FROM ((schools INNER JOIN departments ON schools.school_id = departments.school_id) 
		INNER JOIN degrees ON departments.school_id = degrees.school_id
		INNER JOIN specializations ON degrees.school_id = departments.school_id)
		INNER JOIN student_specializations ON specializations.specialization_id = student_specializations.specialization_id
	WHERE (student_specializations.major = true) AND (student_specializations.primary_major = true); 

--view students primary specializations
CREATE OR REPLACE VIEW vw_student_pri_specializations AS
	SELECT students.org_id, students.student_id, students.student_name, students.account_number, students.Nationality, 
		students.sex, students.Marital_Status, students.birth_date, students.on_probation, students.off_campus,
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.graduated,
		vw_primary_major.school_id, vw_primary_major.school_name,  
		vw_primary_major.specialization_id, vw_primary_major.specialization_name
	FROM (students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN vw_primary_major ON student_degrees.student_degree_id = vw_primary_major.student_degree_id;
		
--view students session primary specializations
CREATE OR REPLACE VIEW vw_sprimajor_students AS
	SELECT vw_student_pri_specializations.org_id, vw_student_pri_specializations.student_id, vw_student_pri_specializations.student_name,      vw_student_pri_specializations.account_number, 
		vw_student_pri_specializations.Nationality, vw_student_pri_specializations.Sex,
		vw_student_pri_specializations.Marital_Status, vw_student_pri_specializations.birth_date, vw_student_pri_specializations.on_probation, vw_student_pri_specializations.off_campus,
		vw_student_pri_specializations.student_degree_id, vw_student_pri_specializations.completed, vw_student_pri_specializations.started, vw_student_pri_specializations.graduated,
        vw_student_pri_specializations.specialization_id, vw_student_pri_specializations.specialization_name,
		vw_student_pri_specializations.school_id, vw_student_pri_specializations.school_name,
		
		sstudents.sstudent_id, sstudents.session_id, sstudents.major_approval, sstudents.depart_approval, sstudents.no_approval
	FROM vw_student_pri_specializations INNER JOIN (sstudents INNER JOIN sessions ON sstudents.session_id = sessions.session_id)
		ON vw_student_pri_specializations.student_degree_id = sstudents.student_degree_id 
	WHERE (sessions.active = true) AND (sstudents.finalised = true) AND (sstudents.major_approval = false);



CREATE OR REPLACE VIEW vw_spri_specialization_students AS
	SELECT vw_student_pri_specializations.org_id, vw_student_pri_specializations.student_id, vw_student_pri_specializations.student_name, vw_student_pri_specializations.account_number, vw_student_pri_specializations.Nationality, vw_student_pri_specializations.Sex,
		vw_student_pri_specializations.Marital_Status, vw_student_pri_specializations.birth_date, vw_student_pri_specializations.on_probation, vw_student_pri_specializations.off_campus, vw_student_pri_specializations.student_degree_id, vw_student_pri_specializations.completed, vw_student_pri_specializations.started, vw_student_pri_specializations.graduated, vw_student_pri_specializations.school_id,  vw_student_pri_specializations.specialization_id, vw_student_pri_specializations.specialization_name, vw_student_pri_specializations.school_name,
		
		sstudents.sstudent_id, sstudents.session_id, sstudents.major_approval, sstudents.depart_approval, sstudents.no_approval
	FROM vw_student_pri_specializations INNER JOIN (sstudents INNER JOIN sessions ON sstudents.session_id = sessions.session_id)
		ON vw_student_pri_specializations.student_degree_id = sstudents.student_degree_id 
	WHERE (sessions.active = true) AND (sstudents.finalised = true) AND (sstudents.major_approval = false);

--view transfered credits
CREATE OR REPLACE VIEW vw_transfered_credits AS
	SELECT
		student_degrees.org_id, student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.cleared, student_degrees.clear_date,
		student_degrees.graduated, student_degrees.graduate_date, student_degrees.drop_out,student_degrees.student_id, student_degrees.transfer_in,student_degrees.graduation_apply, student_degrees.transfer_out,
		student_degrees.details,
		transfered_credits.transfered_credit_id,transfered_credits.course_id,transfered_credits.credit_hours,transfered_credits.narrative,courses.course_title, degrees.degree_name
	FROM student_degrees
		INNER JOIN transfered_credits ON student_degrees.student_degree_id=transfered_credits.student_degree_id
		INNER JOIN degrees ON (student_degrees.student_degree_id)::varchar=degrees.degree_id
		INNER JOIN courses ON (student_degrees.student_degree_id)::varchar =degrees.degree_id
		INNER JOIN degree_levels ON courses.degree_level_id=degrees.degree_level_id;

	
--view student requests---
CREATE OR REPLACE VIEW vw_student_requests AS
	SELECT  students.student_id, students.student_name, request_types.request_type_id, request_types.request_type_name, request_types.to_approve, request_types.details as type_details, student_requests.org_id, student_requests.student_request_id, student_requests.subject, student_requests.narrative, student_requests.date_sent, student_requests.actioned, student_requests.date_actioned, student_requests.approved, student_requests.date_apploved, student_requests.details, student_requests.reply
	FROM (students
			INNER JOIN student_requests ON students.student_id = student_requests.student_id)
		INNER JOIN request_types ON student_requests.request_type_id = request_types.request_type_id;


--view Active sessions--
CREATE OR REPLACE VIEW vw_active_sessions AS
	SELECT vw_sessions.org_id, session_year, session_start, slate_reg, slate_change, session_name, 
	   slast_drop, session_end, active, charge_rate, vw_sessions.details , vw_cohorts.cohort_id, vw_cohorts.cohort_name, vw_cohorts.school_name,
	   vw_cohorts.max_number, vw_cohorts.start_date, vw_cohorts.end_date, vw_cohorts.is_active, vw_cohorts.site_id, 
	   vw_cohorts.site_name, vw_cohorts.degree_level_id, vw_cohorts.degree_level_name, vw_cohorts.school_id, 
	   vw_cohorts.degree_id, vw_cohorts.degree_name
	FROM vw_sessions
	INNER JOIN vw_cohorts ON vw_cohorts.cohort_id=vw_sessions.cohort_id
	WHERE (vw_sessions.active = true);

--view session years--
CREATE OR REPLACE VIEW vw_years AS
	SELECT org_id, session_year
	FROM vw_sessions
	GROUP BY session_year, org_id
	ORDER BY session_year desc;

--view session calendars--
CREATE OR REPLACE VIEW vw_scalendars AS
	SELECT event_types.org_id, event_types.event_type_id, event_types.event_type_name, scalendars.scalendar_id, 
	scalendars.sdate, scalendars.send_date, scalendars.event_name, scalendars.details AS scalendar_details, vw_sessions.session_id, vw_sessions.semister, vw_sessions.site, vw_sessions.session_start, vw_sessions.slate_reg, 
	vw_sessions.slate_change, vw_sessions.slast_drop, vw_sessions.session_end, vw_sessions.active, vw_sessions.session_name, 
	vw_sessions.min_credits, vw_sessions.max_credits, vw_sessions.charge_rate, vw_sessions.details, vw_sessions.session_closed, 
	vw_sessions.late_registration_fee, vw_sessions.cohort_id, vw_sessions.cohort_name, vw_sessions.school_name, vw_sessions.max_number, 
	vw_sessions.start_date, vw_sessions.end_date, vw_sessions.is_active, vw_sessions.degree_id, vw_sessions.degree_name, vw_sessions.site_id, 
	vw_sessions.site_name, vw_sessions.session_year, vw_sessions.sessions, vw_sessions.pre_session, vw_sessions.post_session
	FROM scalendars
	INNER JOIN event_types ON scalendars.event_type_id = event_types.event_type_id
	INNER JOIN vw_sessions ON vw_sessions.session_id = scalendars.session_id;

--view scholarships---
CREATE OR REPLACE VIEW vw_scholarships AS
	SELECT students.org_id, students.student_id, students.student_name, students.account_number, students.Nationality, students.Sex,
		scholarship_types.scholarship_type_id, scholarship_types.scholarship_type_name, scholarship_types.scholarship_account,
		scholarships.session_id, scholarships.scholarship_id, scholarships.entry_date, scholarships.payment_date,
		scholarships.amount, scholarships.approved, scholarships.posted, scholarships.date_posted
	FROM (students
		 INNER JOIN scholarships ON students.student_id = scholarships.student_id)
	INNER JOIN scholarship_types ON scholarships.scholarship_type_id = scholarship_types.scholarship_type_id;


---view approval lists---
CREATE OR REPLACE VIEW vw_approval_lists AS
		SELECT vw_students.org_id, vw_students.student_id, vw_students.student_name,
		
		approval_list.approval_id, approval_list.approval_type_id, approval_list.sstudent_id, approval_types.is_active, approval_types.approval_order, approval_types.details, approval_types.approval_type_name, approval_list.approved_by,
		approval_list.approval_type, approval_list.approve_date, approval_list.client_ip, approved, approved_on
		
		FROM vw_students
		INNER JOIN approval_list ON vw_students.student_id=approval_list.student_id
		LEFT JOIN approval_types ON approval_list.approval_type_id=approval_types.approval_type_id;

---view  courses available for the session--
CREATE OR REPLACE VIEW vw_scourses AS
	SELECT  vw_courses.school_name, vw_courses.school_id, 
		vw_courses.degree_level_id, vw_courses.degree_level_name, vw_courses.course_type_id, vw_courses.course_type_name,
		vw_courses.course_id,vw_courses.course_title, vw_courses.credit_hours, vw_courses.max_credit, vw_courses.is_current,
		vw_courses.no_gpa, vw_courses.year_taken, vw_courses.details, vw_courses.min_credit,

		scourses.org_id, scourses.instructor_id, instructors.instructor_name,scourses.scourse_id, scourses.class_option, scourses.max_class, scourses.lab_course, scourses.clinical_fee, scourses.extra_charge, scourses.department_submit, scourses.department_submit_date, scourses.faculty_submit, scourses.faculty_submit_date,	scourses.attendance, scourses.approved,
		scourses.full_attendance, scourses.attachement, scourses.submit_grades, scourses.submit_date, scourses.approved_grades, scourses.approve_date, scourses.exam_submited, scourses.examinable, scourses.department_change, scourses.registry_change, scourses.grade_submited,

		vw_sessions.session_id, vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.slast_drop,
		vw_sessions.session_end, vw_sessions.active, vw_sessions.charge_rate, vw_sessions.session_name, vw_sessions.session_year, vw_sessions.sessions,

        scourses.site_id
	FROM (((vw_courses
			INNER JOIN scourses ON vw_courses.course_id = scourses.course_id)
			INNER JOIN instructors ON scourses.instructor_id = (instructors.instructor_id))
		INNER JOIN vw_sessions ON scourses.session_id = vw_sessions.session_id);
		
--view a list of students in a session--
CREATE OR REPLACE VIEW vw_sstudent_list AS
	SELECT vw_students.religion_id, vw_students.religion_name, vw_students.denomination_id, vw_students.denomination_name, vw_students.school_id, vw_students.school_name,  vw_students.sponsor_type_id, vw_students.sponsor_type_name, 
		vw_students.sponsor_id, vw_students.sponsor_name, vw_students.sponsor_address, vw_students.sponsor_street, vw_students.sponsor_postal_code, vw_students.sponsor_town, vw_students.sponsor_telno, vw_students.sponsor_email, vw_students.sponsor_country_id, vw_students.sponsor_country_name, vw_students.residence_id, vw_students.residence_name, vw_students.address_country, vw_students.org_id, vw_students.student_id, vw_students.student_name, 
        vw_students.address, vw_students.zipcode, vw_students.town, vw_students.tel_no, vw_students.email, vw_students.account_number, 
		vw_students.admission_basis, vw_students.nationality, vw_students.nationality_country, vw_students.sex, vw_students.marital_status, vw_students.birth_date, vw_students.alumnae, vw_students.post_contacts, vw_students.on_probation, vw_students.off_campus, vw_students.current_contact, vw_students.current_email, vw_students.current_tel, vw_students.full_bursary, vw_students.details, vw_students.staff, vw_students.onhold, vw_students.student_edit, vw_students.disabilitys_details, vw_students.passport, vw_students.national_id, vw_students.identification_no, vw_students.picture_file, vw_students.balance_time,
		
		sstudents.sstudent_id, sstudents.session_id, sstudents.extra_charges, sstudents.probation,
		sstudents.room_id, sstudents.curr_balance,
		sstudents.first_instalment, sstudents.first_date, sstudents.second_instalment, sstudents.second_date,
		sstudents.finance_narrative,  sstudents.fee_refund, sstudents.finalised,
		sstudents.major_approval, sstudents.overload_approval,
		sstudents.overload_hours,
		SUBSTRING(sstudents.session_id from 1 for 9) as academic_year
	FROM (vw_students
			INNER JOIN student_degrees ON vw_students.student_id = student_degrees.student_id)
		INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id;

---view course load----
CREATE OR REPLACE VIEW vw_course_load AS
	SELECT vw_scourses.school_id,  vw_scourses.school_name, 
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.course_id, vw_scourses.credit_hours, vw_scourses.max_credit, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken, vw_scourses.org_id, vw_scourses.instructor_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class, vw_scourses.lab_course, vw_scourses.clinical_fee, vw_scourses.extra_charge,
		vw_scourses.approved, vw_scourses.attendance, vw_scourses.full_attendance, vw_scourses.attachement, vw_scourses.submit_grades, vw_scourses.submit_date, vw_scourses.approved_grades, vw_scourses.approve_date, vw_scourses.exam_submited, vw_scourses.examinable,
		vw_scourses.department_change, vw_scourses.registry_change, vw_scourses.instructor_name, vw_scourses.course_title,
        vw_scourses.session_id, vw_scourses.session_start, vw_scourses.slate_reg, vw_scourses.slate_change, vw_scourses.slast_drop,
		vw_scourses.session_end, vw_scourses.active, vw_scourses.charge_rate,
        vw_scourses.session_name, vw_scourses.session_year, vw_scourses.sessions,
		a.course_load
	FROM vw_scourses INNER JOIN
		(SELECT scourse_id, count(sgrade_id) as course_load FROM sgrades WHERE (dropped = false) GROUP BY scourse_id) as a
		ON vw_scourses.scourse_id = a.scourse_id;


--view session timetable--
CREATE OR REPLACE VIEW vw_stimetables AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity,
		vw_scourses.scourse_id,vw_scourses.course_title, vw_scourses.course_id, vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.session_id, vw_scourses.max_class, vw_scourses.class_option,

		option_times.option_time_id, option_times.option_time_name,

		stimetables.org_id, stimetables.stimetable_id, stimetables.start_time, stimetables.end_time, stimetables.lab,
		stimetables.details, stimetables.c_monday, stimetables.c_tuesday, stimetables.c_wednesday, stimetables.c_thursday,
		stimetables.c_friday, stimetables.c_saturday, stimetables.c_sunday, stimetables.start_date, stimetables.end_date
	FROM ((assets
			INNER JOIN stimetables ON assets.asset_id = stimetables.asset_id)
			INNER JOIN vw_scourses ON stimetables.scourse_id = vw_scourses.scourse_id)
		INNER JOIN option_times ON stimetables.option_time_id = option_times.option_time_id
	ORDER BY stimetables.start_time;


--session exam timetables--
CREATE OR REPLACE VIEW vw_sexam_timetables AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity,
		vw_scourses.scourse_id, vw_scourses.course_id,vw_scourses.course_title, vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.session_id, vw_scourses.max_class, vw_scourses.class_option,
		option_times.option_time_id, option_times.option_time_name,
		sexam_timetable.org_id, sexam_timetable.sexam_timetable_id, sexam_timetable.start_time, sexam_timetable.end_time,
		sexam_timetable.lab, sexam_timetable.exam_date, sexam_timetable.details
	FROM ((assets
			INNER JOIN sexam_timetable ON assets.asset_id = sexam_timetable.asset_id)
			INNER JOIN vw_scourses ON sexam_timetable.scourse_id = vw_scourses.scourse_id)
		INNER JOIN option_times ON sexam_timetable.option_time_id = option_times.option_time_id
	ORDER BY sexam_timetable.exam_date, sexam_timetable.start_time;


--function returning time schedule for assests--
CREATE OR REPLACE FUNCTION get_time_asset_count(integer, time, time, boolean, boolean, boolean, boolean, boolean, boolean, boolean, varchar(12)) RETURNS bigint AS $$
	SELECT count(stimetable_id) FROM vw_stimetables
	WHERE (asset_id = $1) AND (((start_time, end_time) OVERLAPS ($2, $3))=true)
	AND ((c_monday and $4) OR (c_tuesday and $5) OR (c_wednesday and $6) OR (c_thursday and $7) OR (c_friday and $8) OR (c_saturday and $9) OR (c_sunday and $10))
	AND (session_id = $11);
$$ LANGUAGE SQL;

--view assets time schedule--
CREATE OR REPLACE VIEW vw_sasset_timetables AS
	SELECT asset_id, asset_name, org_id, location, building, capacity, scourse_id,course_title, course_id,  instructor_id, instructor_name,
		 session_id, max_class, class_option, option_time_id, option_time_name,
		stimetable_id, start_time, end_time, lab, details, c_monday, c_tuesday, c_wednesday, c_thursday,
		c_friday, c_saturday, c_sunday,
		get_time_asset_count(asset_id, start_time, end_time, c_monday, c_tuesday, c_wednesday, c_thursday, c_friday, c_saturday, c_sunday, session_id) as time_asset_count
	FROM vw_stimetables
	ORDER BY asset_id;

--view current timetables--
CREATE OR REPLACE VIEW vw_curr_timetables AS
	SELECT vw_stimetables.asset_id, vw_stimetables.asset_name, vw_stimetables.location, vw_stimetables.building, vw_stimetables.capacity,
		vw_stimetables.scourse_id, vw_stimetables.course_id, vw_stimetables.course_title, vw_stimetables.instructor_id, vw_stimetables.instructor_name,
		vw_stimetables.session_id, vw_stimetables.max_class, vw_stimetables.class_option,
		vw_stimetables.option_time_id, vw_stimetables.option_time_name,
		vw_stimetables.org_id, vw_stimetables.stimetable_id, vw_stimetables.start_time, vw_stimetables.end_time, vw_stimetables.lab,
		vw_stimetables.details, vw_stimetables.c_monday, vw_stimetables.c_tuesday, vw_stimetables.c_wednesday, vw_stimetables.c_thursday,
		vw_stimetables.c_friday, vw_stimetables.c_saturday, vw_stimetables.c_sunday
	FROM vw_stimetables INNER JOIN sessions ON vw_stimetables.session_id = sessions.session_id
	WHERE (sessions.active = false)
	ORDER BY vw_stimetables.start_time;

--view session course items--
CREATE OR REPLACE VIEW vw_scourse_items AS
	SELECT vw_scourses.org_id, vw_scourses.scourse_id, vw_scourses.course_id, vw_scourses.course_title,
		vw_scourses.session_id,vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.class_option, scourse_items.scourse_item_id, scourse_items.course_item_name, scourse_items.mark_ratio,
		scourse_items.total_marks, scourse_items.given, scourse_items.deadline, scourse_items.details
	FROM vw_scourses
		INNER JOIN scourse_items ON vw_scourses.scourse_id = scourse_items.scourse_id;

--view session grades--
CREATE OR REPLACE VIEW vw_sgrades AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name, vw_scourses.credit_hours, vw_scourses.is_current,vw_scourses.year_taken,
		vw_scourses.no_gpa,vw_scourses.course_id, vw_scourses.course_title, vw_scourses.instructor_id, vw_scourses.instructor_name, vw_scourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.clinical_fee, vw_scourses.attendance as crs_attendance,
		vw_scourses.full_attendance, vw_scourses.attachement, vw_scourses.examinable, vw_scourses.submit_grades, vw_scourses.submit_date, vw_scourses.approved_grades, vw_scourses.department_change, vw_scourses.registry_change,

		sgrades.org_id, sgrades.sgrade_id, sgrades.sstudent_id, sgrades.hours, sgrades.credit, sgrades.approved as crs_approved, sgrades.approve_date, sgrades.ask_drop, sgrades.ask_drop_date, sgrades.dropped, sgrades.drop_date, sgrades.repeated, sgrades.attendance, sgrades.narrative, sgrades.challenge_course, sgrades.non_gpa_course, sgrades.lecture_marks, sgrades.lecture_cat_mark, sgrades.lecture_grade_id,sgrades.withdraw_date,sgrades.record_posted,sgrades.post_changed,sgrades.changed_by,
		sgrades.request_drop, sgrades.request_drop_date, sgrades.withdraw_rate as course_withdraw_rate,

		grades.grade_id, grades.grade_weight,grades.grade_name, grades.min_range, grades.max_range, grades.gpa_count, grades.narrative as grade_narrative,
		(CASE sgrades.repeated WHEN true THEN 0 ELSE (grades.grade_weight * sgrades.credit) END) as gpa,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW') OR (grades.gpa_count = false) OR (sgrades.repeated = true) OR (sgrades.non_gpa_course=true)) THEN 0 ELSE sgrades.credit END) as gpa_hours,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW')) THEN sgrades.hours * sgrades.withdraw_rate  ELSE sgrades.hours END) as charge_hours
	FROM (vw_scourses INNER JOIN sgrades ON vw_scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id;


--view active grades--
  CREATE OR REPLACE VIEW vw_sgrade AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, 
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.course_id, vw_scourses.course_title, vw_scourses.credit_hours, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken,
		vw_scourses.instructor_id,vw_scourses.instructor_name, vw_scourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.clinical_fee,
		vw_scourses.attendance as crs_attendance,
		vw_scourses.full_attendance,
		vw_scourses.attachement, vw_scourses.examinable,
		vw_scourses.submit_grades, vw_scourses.submit_date, vw_scourses.approved_grades, vw_scourses.approve_date,
		vw_scourses.department_change, vw_scourses.registry_change,

		sgrades.sgrade_id, sgrades.org_id, sgrades.grade_id, sgrades.sstudent_id, sgrades.hours, sgrades.credit, sgrades.approved as crs_approved,  sgrades.ask_drop,
		sgrades.ask_drop_date, sgrades.dropped, sgrades.drop_date, sgrades.repeated, sgrades.attendance, sgrades.narrative,
		sgrades.challenge_course, sgrades.non_gpa_course, sgrades.lecture_marks, sgrades.lecture_cat_mark,
		sgrades.lecture_grade_id, g.grade_name AS lecturer_grade_name, 
		sgrades.request_drop, sgrades.request_drop_date, sgrades.withdraw_rate as course_withdraw_rate,

		grades.grade_weight, grades.min_range, grades.max_range, grades.gpa_count,
		grades.narrative as grade_narrative,
		(CASE sgrades.repeated WHEN true THEN 0 ELSE (grades.grade_weight * sgrades.credit) END) as gpa,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW') OR (grades.gpa_count = false) OR (sgrades.repeated = true) OR (sgrades.non_gpa_course=true)) THEN 0 ELSE sgrades.credit END) as gpa_hours,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW')) THEN sgrades.hours * sgrades.withdraw_rate  ELSE sgrades.hours END) as charge_hours, grades.grade_name
	FROM (vw_scourses INNER JOIN sgrades ON vw_scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
		LEFT JOIN grades AS g ON sgrades.lecture_grade_id = g.grade_id
	WHERE (sgrades.dropped = false);

	
CREATE OR REPLACE VIEW vw_curr_scourses AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, 
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.org_id, vw_scourses.course_id, vw_scourses.credit_hours, vw_scourses.max_credit, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken, vw_scourses.instructor_id, vw_scourses.session_id, vw_scourses.scourse_id,
		vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.approved, vw_scourses.attendance, 
		vw_scourses.full_attendance, vw_scourses.instructor_name, vw_scourses.course_title
		
	FROM vw_scourses
	WHERE (vw_scourses.active = true) AND (vw_scourses.approved = false);


CREATE OR REPLACE VIEW vw_student_grades AS 
 SELECT vw_sstudents.religion_id, vw_sstudents.religion_name, vw_sstudents.denomination_id, vw_sstudents.denomination_name,
    vw_sstudents.sponsor_type_id, vw_sstudents.sponsor_type_name, vw_sstudents.sponsor_id, vw_sstudents.sponsor_name,
    vw_sstudents.sponsor_address, vw_sstudents.sponsor_street, vw_sstudents.sponsor_postal_code, vw_sstudents.sponsor_town, vw_sstudents.sponsor_telno, vw_sstudents.sponsor_email, vw_sstudents.sponsor_country_id,
    vw_sstudents.sponsor_country_name, vw_sstudents.school_id, vw_sstudents.school_name, vw_sstudents.student_name, vw_sstudents.address, vw_sstudents.zipcode, vw_sstudents.town, vw_sstudents.address_country, vw_sstudents.tel_no, vw_sstudents.email, vw_sstudents.account_number, vw_sstudents.nationality, vw_sstudents.nationality_country, vw_sstudents.sex, vw_sstudents.marital_status,
    vw_sstudents.birth_date, vw_sstudents.post_contacts, vw_sstudents.on_probation, vw_sstudents.off_campus, vw_sstudents.current_contact, vw_sstudents.current_email, vw_sstudents.chaplain_approval, vw_sstudents.student_dean_approval,
    vw_sstudents.inter_session, vw_sstudents.lrf_picked, vw_sstudents.lrf_picked_date, vw_sstudents.degree_id, vw_sstudents.degree_name, vw_sstudents.student_degree_id, vw_sstudents.degree_level_id, vw_sstudents.degree_level_name, 
    vw_sstudents.completed, vw_sstudents.started, vw_sstudents.cleared,
    vw_sstudents.clear_date, vw_sstudents.graduated, vw_sstudents.graduate_date, vw_sstudents.drop_out, vw_sstudents.transfer_in,
    vw_sstudents.transfer_out, vw_sstudents.session_id, vw_sstudents.session_year,
    vw_sstudents.sessions, vw_sstudents.session_start, vw_sstudents.slate_reg, vw_sstudents.slate_change,
    vw_sstudents.slast_drop, vw_sstudents.session_end, vw_sstudents.active, vw_sstudents.residence_name,    	vw_sstudents.capacity, vw_sstudents.default_rate, vw_sstudents.residence_off_campus, vw_sstudents.residence_sex, vw_sstudents.residence_dean,
    vw_sstudents.residence_id,
    vw_sstudents.org_id, vw_sstudents.student_id, vw_sstudents.additional_charges, vw_sstudents.probation,
    vw_sstudents.room_id, vw_sstudents.curr_balance, vw_sstudents.major_approval, vw_sstudents.approved,
    vw_sstudents.overload_approval, vw_sstudents.finalised, vw_sstudents.finance_approval,
    vw_sstudents.exam_clear, vw_sstudents.exam_clear_date,  vw_sstudents.sstudent_id,
    vw_sstudents.exam_clear_balance, vw_sstudents.request_withdraw, vw_sstudents.request_withdraw_date,
    vw_sstudents.withdraw, vw_sstudents.ac_withdraw, vw_sstudents.withdraw_date, vw_sstudents.withdraw_rate,
    
    vw_sgrade.school_name AS crs_school_name, vw_sgrade.school_id AS crs_school_id, vw_sgrade.degree_level_id AS crs_degree_level_id,
    vw_sgrade.degree_level_name AS crs_degree_level_name, vw_sgrade.course_type_id,
    vw_sgrade.course_type_name, vw_sgrade.course_id,
    vw_sgrade.course_title, vw_sgrade.credit_hours, vw_sgrade.is_current, vw_sgrade.no_gpa, vw_sgrade.year_taken, vw_sgrade.instructor_id,
    vw_sgrade.instructor_name, vw_sgrade.scourse_id, vw_sgrade.class_option, vw_sgrade.max_class, vw_sgrade.lab_course,
    vw_sgrade.attendance AS crs_attendance, vw_sgrade.full_attendance, vw_sgrade.grade_id, vw_sgrade.hours, vw_sgrade.credit,
    vw_sgrade.crs_approved, vw_sgrade.ask_drop, vw_sgrade.ask_drop_date, vw_sgrade.dropped, vw_sgrade.drop_date, vw_sgrade.repeated, vw_sgrade.attendance, vw_sgrade.narrative, vw_sgrade.grade_weight, vw_sgrade.min_range, vw_sgrade.max_range, vw_sgrade.gpa_count, vw_sgrade.grade_narrative, vw_sgrade.gpa, vw_sgrade.gpa_hours, vw_sgrade.charge_hours, vw_sgrade.attachement, vw_sgrade.lecture_marks, vw_sgrade.lecture_cat_mark, vw_sgrade.lecture_grade_id, vw_sgrade.course_withdraw_rate, vw_sgrade.submit_grades, vw_sgrade.submit_date, vw_sgrade.approved_grades, vw_sgrade.approve_date, vw_sgrade.department_change, vw_sgrade.registry_change, vw_sgrade.clinical_fee, vw_sgrade.extra_charge,
    
   vw_sgrade.grade_name, vw_sgrade.sgrade_id, vw_sgrade.lecturer_grade_name
   FROM vw_sstudents
     INNER JOIN vw_sgrade ON vw_sgrade.sstudent_id = vw_sstudents.sstudent_id;
     

CREATE OR REPLACE VIEW vw_course_specializations AS
	SELECT cohort_courses.cohort_course_id,  orgs.org_id, orgs.org_name, course_specializations.course_specialization_id,
	 course_specializations.specialization_id, specializations.specialization_name
	FROM course_specializations
        INNER JOIN cohort_courses ON course_specializations.cohort_course_id = cohort_courses.cohort_course_id
        INNER JOIN specializations ON course_specializations.specialization_id = specializations.specialization_id
        INNER JOIN orgs ON course_specializations.org_id = orgs.org_id;  
	
 ALTER TABLE cohort_courses ADD COLUMN approved boolean default false;	
CREATE OR REPLACE VIEW vw_cohort_courses AS
	SELECT instructors.org_id, instructors.instructor_id, instructors.instructor_name,  vw_sessions.session_id, vw_sessions.semister,                   
        vw_sessions.site, vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, 
		vw_sessions.slast_drop, vw_sessions.session_end, vw_sessions.active, vw_sessions.session_name, vw_sessions.min_credits, vw_sessions.max_credits, vw_sessions.charge_rate, vw_sessions.details, vw_sessions.session_closed, vw_sessions.late_registration_fee, vw_sessions.cohort_id, vw_sessions.cohort_name, 
		vw_sessions.max_number, vw_sessions.start_date, vw_sessions.end_date, vw_sessions.is_active, vw_sessions.degree_id, 
		vw_sessions.degree_name, vw_sessions.site_id, vw_sessions.site_name, vw_sessions.session_year, vw_sessions.sessions, vw_sessions.pre_session, 
		
		vw_courses.school_id, vw_courses.school_name, vw_courses.degree_level_id, vw_courses.degree_level_name, vw_courses.course_type_id, vw_courses.course_type_name, vw_courses.course_id, vw_courses.course_title, vw_courses.lab_course, vw_courses.min_credit, vw_courses.max_credit, vw_courses.lecture_hours, vw_courses.practical_hours, vw_courses.credit_hours, vw_courses.is_current, vw_courses.no_gpa, vw_courses.no_repeats, vw_courses.extra_charge, vw_courses.year_taken, vw_courses.course_mode_id, vw_courses.course_mode_name, 
		
		cohort_courses.cohort_course_id, cohort_courses.approved,
		vw_course_specializations.specialization_name
	FROM cohort_courses
	
	LEFT JOIN vw_course_specializations ON cohort_courses.cohort_course_id = vw_course_specializations.cohort_course_id
	INNER JOIN vw_courses ON cohort_courses.course_id = vw_courses.course_id
	INNER JOIN instructors ON cohort_courses.instructor_id = instructors.instructor_id
	INNER JOIN vw_sessions ON cohort_courses.session_id = vw_sessions.session_id;
	

CREATE OR REPLACE VIEW vw_lg_student_management AS
	SELECT table_name, logs.lg_student_management.org_id, activity, student_id, executed_by, executed_on, entity_name, narrative, lg_student_management_id
	
	 FROM logs.lg_student_management
	 INNER JOIN entitys ON logs.lg_student_management.executed_by=entitys.entity_id;
	 

CREATE OR REPLACE VIEW vw_student_cohort_sessions AS 
	SELECT student_degrees.student_id, vw_sessions.cohort_id, vw_sessions.cohort_name, vw_sessions.session_id, vw_sessions.session_start, 
	vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.session_end, 
	vw_sessions.active, vw_sessions.pre_session, sstudent_id,  
	(CASE WHEN vw_sessions.slate_reg<current_date THEN 'The session is closed for registration contact the registrar' WHEN sstudent_id IS NULL THEN 'You have '||date_part('day',age(vw_sessions.slate_reg, current_date))||' Days Remaining To register for the session' 
	WHEN closed=TRUE THEN 'Session Registered waiting for approvals' 
	WHEN approved=TRUE THEN 'You have been fully approved' ELSE 'Checking Status' END) AS registration_status 
	FROM vw_sessions
	INNER JOIN student_degrees ON student_degrees.cohort_id=vw_sessions.cohort_id
	LEFT JOIN sstudents ON student_degrees.student_degree_id=sstudents.student_degree_id;
	
CREATE OR REPLACE VIEW vw_selcourses AS
	SELECT courses.course_id, courses.course_title, courses.credit_hours, courses.no_gpa, courses.year_taken,
		scourses.scourse_id, scourses.session_id, scourses.class_option, scourses.max_class, scourses.lab_course,
		instructors.instructor_id, instructors.instructor_name, scourses.scourse_id as scourse_students, instructors.org_id,
		sgrades.grade_id, sgrades.sstudent_id,sgrades.hours, sgrades.credit, sgrades.approved,
		sgrades.approve_date, sgrades.ask_drop, sgrades.ask_drop_date, sgrades.dropped,	sgrades.drop_date,
		sgrades.repeated, sgrades.withdraw_date, sgrades.attendance, sgrades.option_time_id, sgrades.narrative
	FROM (((courses INNER JOIN scourses ON courses.course_id = scourses.course_id)
		INNER JOIN instructors ON scourses.instructor_id::varchar = instructors.instructor_id)
		INNER JOIN sgrades ON sgrades.scourse_id = scourses.scourse_id)
		INNER JOIN sessions ON scourses.session_id = sessions.session_id
	WHERE (sessions.active = true) AND (sgrades.dropped = false);

--function returning courses done--
CREATE OR REPLACE FUNCTION get_course_done(varchar(12), varchar(12)) RETURNS float AS $$
	SELECT max(grades.grade_weight)
	FROM (((scourses INNER JOIN sgrades ON scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id)
		INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (sstudents.finance_approval = true) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
	AND (student_degrees.student_id = $1) AND (scourses.course_id = $2);
$$ LANGUAGE SQL;

--function returning transferred courses--
CREATE OR REPLACE FUNCTION get_course_transfered(varchar(12), varchar(12)) RETURNS float AS $$
	SELECT sum(transfered_credits.credit_hours)
	FROM transfered_credits INNER JOIN student_degrees ON transfered_credits.student_degree_id = student_degrees.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (transfered_credits.course_id = $2);
$$ LANGUAGE SQL;

--function returning passed prerequisites--
CREATE OR REPLACE FUNCTION get_prereq_passed(varchar(12), varchar(12), integer, boolean) RETURNS boolean AS $$
DECLARE
	passed boolean;
	myrec RECORD;
BEGIN
	passed := false;

	FOR myrec IN SELECT option_level, precourse_id, grade_weight
		FROM vw_prereq
		WHERE (vw_prereq.course_id = $2) AND (vw_prereq.option_level = 0) AND (vw_prereq.bulletings_id = $3)
	ORDER BY vw_prereq.option_level LOOP
		IF (get_course_done($1, myrec.pre_course_id) >= myrec.grade_weight) THEN
			passed := true;
		END IF;
		IF (get_course_transfered($1, myrec.precourse_id) is not null) THEN
			passed := true;
		END IF;
	END LOOP;

	IF ($4 = true) THEN
		passed := true;
	END IF;

    RETURN passed;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_prereq_passed(varchar(12), varchar(12), integer) RETURNS boolean AS $$
DECLARE
	passed boolean;
	hasprereq boolean;
	myrec RECORD;
	order_id int;
BEGIN
	passed := false;
	hasprereq := false;
	order_id := 1;

	FOR myrec IN SELECT option_level, precourse_id, grade_weight
		FROM vw_prereq
		WHERE (vw_prereq.course_id = $2) AND (vw_prereq.option_level > 0) AND (vw_prereq.bulletings_id = $3)
	ORDER BY vw_prereq.option_level LOOP
		hasprereq :=  true;
		IF(order_id <> myrec.option_level) THEN
			order_id := myrec.option_level;
			passed := false;
		END IF;

		IF (get_course_done($1, myrec.precourse_id) >= myrec.grade_weight) THEN
			passed := true;
		END IF;
		IF (get_course_transfered($1, myrec.precourse_id) is not null) THEN
			passed := true;
		END IF;
	END LOOP;

	IF (hasprereq = false) THEN
		passed := true;
	END IF;

    RETURN passed;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION public.get_prereq_passed(
    varchar,
    varchar)
  RETURNS boolean AS
$BODY$
DECLARE
	passed boolean;
	hasprereq boolean;
	myrec RECORD;
	order_id int;
BEGIN
	passed := false;
	hasprereq := false;
	order_id := 1;

	FOR myrec IN SELECT option_level, precourse_id, grade_weight
		FROM vw_prereq
		WHERE (vw_prereq.course_id = $2) AND (vw_prereq.option_level > 0) 
	ORDER BY vw_prereq.option_level LOOP
		hasprereq :=  true;
		IF(order_id <> myrec.option_level) THEN
			order_id := myrec.option_level;
			passed := false;
		END IF;

		IF (get_course_done($1, myrec.precourse_id) >= myrec.grade_weight) THEN
			passed := true;
		END IF;
		IF (get_course_transfered($1, myrec.precourse_id) is not null) THEN
			passed := true;
		END IF;
	END LOOP;

	IF (hasprereq = false) THEN
		passed := true;
	END IF;

    RETURN passed;
END;
$BODY$
  LANGUAGE plpgsql;
--view selected courses---
CREATE OR REPLACE VIEW vw_selected_grades AS
	SELECT vw_selcourses.course_id, vw_selcourses.course_title, vw_selcourses.credit_hours, vw_selcourses.no_gpa, vw_selcourses.year_taken,
		vw_selcourses.scourse_id, vw_selcourses.session_id, vw_selcourses.class_option, vw_selcourses.max_class, vw_selcourses.lab_course,
		vw_selcourses.instructor_id, vw_selcourses.instructor_name, vw_selcourses.scourse_students,
		vw_selcourses.grade_id, vw_selcourses.sstudent_id, vw_selcourses.hours, vw_selcourses.credit, vw_selcourses.approved,
		vw_selcourses.approve_date, vw_selcourses.ask_drop, vw_selcourses.ask_drop_date, vw_selcourses.dropped,	vw_selcourses.drop_date,
		vw_selcourses.repeated, vw_selcourses.withdraw_date, vw_selcourses.attendance, vw_selcourses.option_time_id, vw_selcourses.narrative,
		student_degrees.student_degree_id, student_degrees.student_id, students.student_name, students.sex, 

		get_prereq_passed(student_degrees.student_id, vw_selcourses.course_id) as prereq_passed,
		sstudents.org_id
	FROM ((vw_selcourses INNER JOIN sstudents ON vw_selcourses.sstudent_id = sstudents.sstudent_id)
		INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id)
		INNER JOIN students ON student_degrees.student_id = students.student_id;

--view student timetables---
CREATE OR REPLACE VIEW vw_student_timetable AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity,
	
		vw_selected_grades.course_id, vw_selected_grades.course_title, vw_selected_grades.credit_hours, vw_selected_grades.no_gpa, vw_selected_grades.year_taken, vw_selected_grades.scourse_id, vw_selected_grades.session_id, vw_selected_grades.class_option, vw_selected_grades.max_class, vw_selected_grades.lab_course, vw_selected_grades.instructor_id, vw_selected_grades.instructor_name, vw_selected_grades.student_degree_id, vw_selected_grades.student_id, vw_selected_grades.grade_id, vw_selected_grades.sstudent_id,  vw_selected_grades.hours, vw_selected_grades.credit, vw_selected_grades.approved,
		vw_selected_grades.approve_date, vw_selected_grades.ask_drop, vw_selected_grades.ask_drop_date, vw_selected_grades.dropped, vw_selected_grades.drop_date, vw_selected_grades.repeated, vw_selected_grades.withdraw_date, vw_selected_grades.attendance, vw_selected_grades.narrative,
		
		stimetables.org_id, stimetables.stimetable_id, stimetables.start_time, stimetables.end_time, stimetables.lab,
		stimetables.details, stimetables.c_monday, stimetables.c_tuesday, stimetables.c_wednesday, stimetables.c_thursday,
		stimetables.c_friday, stimetables.c_saturday, stimetables.c_sunday,sexam_timetable.exam_date,
		
		option_times.option_time_id, option_times.option_time_name
	FROM (assets INNER JOIN (stimetables INNER JOIN option_times ON stimetables.option_time_id = option_times.option_time_id) ON assets.asset_id = stimetables.asset_id)
		INNER JOIN vw_selected_grades ON (stimetables.scourse_id = vw_selected_grades.scourse_id AND stimetables.option_time_id =  vw_selected_grades.option_time_id)
		INNER JOIN sexam_timetable ON sexam_timetable.scourse_id=stimetables.scourse_id
	ORDER BY stimetables.start_time;

--view student session exam timetables---
CREATE OR REPLACE VIEW vw_student_sexam_timetable AS
	SELECT vw_scourses.course_id, vw_scourses.school_id, vw_scourses.school_name, 
		vw_scourses.instructor_id, sexam_timetable.org_id, sexam_timetable.sexam_timetable_id, sexam_timetable.exam_date, sexam_timetable.start_time, sexam_timetable.end_time, sexam_timetable.lab,
		
		sessions.session_id, sessions.active
	FROM (vw_scourses INNER JOIN sexam_timetable ON vw_scourses.scourse_id = sexam_timetable.scourse_id)
		INNER JOIN sessions ON vw_scourses.session_id = sessions.session_id;

--view student course marks--
CREATE OR REPLACE VIEW vw_course_marks AS
	SELECT vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, vw_student_grades.student_name,  
        vw_student_grades.email, vw_student_grades.degree_level_id, vw_student_grades.degree_level_name, 
		vw_student_grades.degree_id, vw_student_grades.degree_name, vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started, vw_student_grades.cleared, vw_student_grades.clear_date, vw_student_grades.session_id,
		vw_student_grades.full_attendance, vw_student_grades.class_option, vw_student_grades.grade_id, vw_student_grades.hours, vw_student_grades.credit, vw_student_grades.crs_approved, vw_student_grades.dropped, vw_student_grades.grade_weight, vw_student_grades.min_range, vw_student_grades.max_range, vw_student_grades.gpa_count,
		vw_student_grades.submit_grades, vw_student_grades.submit_date, vw_student_grades.approved_grades, vw_student_grades.approve_date,
		vw_student_grades.department_change, vw_student_grades.registry_change,

		scourse_marks.scourse_mark_id, scourse_marks.approved, scourse_marks.submited, scourse_marks.mark_date, scourse_marks.marks,
		scourse_marks.details, scourse_marks.org_id, scourse_items.scourse_item_id, scourse_items.course_item_name, scourse_items.mark_ratio, scourse_items.total_marks, scourse_items.given, scourse_items.deadline, scourse_items.details as item_details
	FROM (vw_student_grades INNER JOIN scourse_marks ON vw_student_grades.grade_id = scourse_marks.sgrade_id)
		INNER JOIN scourse_items ON scourse_marks.scourse_item_id =  scourse_items.scourse_item_id;

---view students session grades---
CREATE OR REPLACE VIEW vw_sstudents_grades AS
	SELECT vw_student_grades.org_id, vw_student_grades.religion_id, vw_student_grades.religion_name, vw_student_grades.denomination_id, 
        vw_student_grades.denomination_name, vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_name, vw_student_grades.address, vw_student_grades.zipcode, vw_student_grades.town, vw_student_grades.address_country, vw_student_grades.tel_no, vw_student_grades.email, vw_student_grades.account_number, vw_student_grades.Nationality, vw_student_grades.nationality_country, vw_student_grades.Sex, vw_student_grades.marital_status, vw_student_grades.birth_date,
		vw_student_grades.on_probation, vw_student_grades.off_campus, vw_student_grades.current_contact, vw_student_grades.current_email, 
		vw_student_grades.degree_level_id, vw_student_grades.degree_level_name,
		vw_student_grades.degree_id, vw_student_grades.degree_name, vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started, vw_student_grades.cleared, vw_student_grades.clear_date, vw_student_grades.graduated, vw_student_grades.graduate_date, vw_student_grades.drop_out, vw_student_grades.transfer_in, vw_student_grades.transfer_out,
		vw_student_grades.session_id, vw_student_grades.session_year, vw_student_grades.sessions, vw_student_grades.session_start, vw_student_grades.slate_reg, vw_student_grades.slate_change, vw_student_grades.slast_drop,
		vw_student_grades.session_end, vw_student_grades.active, vw_student_grades.residence_name, vw_student_grades.capacity, vw_student_grades.default_rate, vw_student_grades.residence_off_campus, vw_student_grades.residence_sex, vw_student_grades.residence_dean, vw_student_grades.residence_id, vw_student_grades.student_id,  vw_student_grades.probation,vw_student_grades.inter_session, vw_student_grades.major_approval, vw_student_grades.finance_approval,
		vw_student_grades.overload_approval, vw_student_grades.finalised, vw_student_grades.approved,
		
		

		(CASE sum(vw_student_grades.gpa_hours) WHEN 0 THEN 0 ELSE (sum(vw_student_grades.gpa)/sum(vw_student_grades.gpa_hours)) END) as gpa,

		sum(vw_student_grades.gpa_hours) as credit, sum(vw_student_grades.charge_hours) as hours,
		bool_and(vw_student_grades.attachement) as on_attachment

	FROM vw_student_grades
	INNER JOIN grades ON grades.grade_id=vw_student_grades.grade_id
	WHERE (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
	GROUP BY vw_student_grades.org_id, vw_student_grades.religion_id, vw_student_grades.religion_name, vw_student_grades.denomination_id, vw_student_grades.denomination_name,
		vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, vw_student_grades.student_name, vw_student_grades.address, vw_student_grades.zipcode,
		vw_student_grades.town, vw_student_grades.address_country, vw_student_grades.tel_no, vw_student_grades.email,
		vw_student_grades.account_number, vw_student_grades.Nationality, vw_student_grades.nationality_country, vw_student_grades.Sex,
		vw_student_grades.marital_status, vw_student_grades.birth_date,
		vw_student_grades.on_probation, vw_student_grades.off_campus, vw_student_grades.current_contact, vw_student_grades.current_email, 
		vw_student_grades.degree_level_id, vw_student_grades.degree_level_name,
		vw_student_grades.degree_id, vw_student_grades.degree_name,
		vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started, vw_student_grades.cleared, vw_student_grades.clear_date,
		vw_student_grades.graduated, vw_student_grades.graduate_date, vw_student_grades.drop_out, vw_student_grades.transfer_in, vw_student_grades.transfer_out,
		vw_student_grades.session_id, vw_student_grades.session_year, vw_student_grades.sessions, vw_student_grades.session_start, vw_student_grades.slate_reg, vw_student_grades.slate_change, vw_student_grades.slast_drop,
		vw_student_grades.session_end, vw_student_grades.active,
		vw_student_grades.residence_id, vw_student_grades.residence_name, vw_student_grades.capacity, vw_student_grades.default_rate,
		vw_student_grades.residence_off_campus, vw_student_grades.residence_sex, vw_student_grades.residence_dean,
		vw_student_grades.residence_id, 
		vw_student_grades.student_id,  vw_student_grades.probation,
		 vw_student_grades.major_approval,
		vw_student_grades.overload_approval, vw_student_grades.finalised,
		 vw_student_grades.exam_clear_balance, 
		vw_student_grades.request_withdraw, vw_student_grades.request_withdraw_date, vw_student_grades.withdraw, vw_student_grades.ac_withdraw,
		vw_student_grades.withdraw_date, vw_student_grades.withdraw_rate,vw_student_grades.inter_session,vw_student_grades.finance_approval,vw_student_grades.approved;


--view course outline--
CREATE OR REPLACE VIEW vw_course_outlines (
	order_id, student_id, student_degree_id,
	degree_id,
	description,
	course_id,
	course_title,
	minor,
	elective,
	credit_hours,
	no_gpa,
	grade_id,
	grade_weight
) AS
	(SELECT 1, vw_student_degrees.student_id, vw_student_degrees.student_degree_id, vw_student_degrees.degree_id, majors.major_name, vw_major_contents.course_id,
		vw_major_contents.course_title, vw_major_contents.minor, vw_major_contents.elective, vw_major_contents.credit_hours,
		vw_major_contents.no_gpa, vw_major_contents.grade_id, grades.grade_weight, vw_student_degrees.org_id
	FROM (((majors INNER JOIN vw_major_contents ON majors.major_id = vw_major_contents.major_id)
		INNER JOIN student_majors ON vw_major_contents.major_id = student_majors.major_id)
		INNER JOIN vw_student_degrees ON (student_majors.student_degree_id = vw_student_degrees.student_degree_id) )
		INNER JOIN grades ON vw_major_contents.grade_id = grades.grade_id
	WHERE ((not student_majors.pre_major and vw_major_contents.pre_major)=false) AND ((not student_majors.non_degree and vw_major_contents.prerequisite)=false)
		and (vw_student_degrees.completed=false) and (vw_student_degrees.drop_out=false));
	
--view corecourseoutline--
CREATE OR REPLACE VIEW vw_core_course_outline AS
	(SELECT 1 AS order_id, vw_student_degrees.student_id, vw_student_degrees.student_degree_id, vw_student_degrees.degree_id,
		majors.major_name AS description, vw_major_contents.content_type_id, vw_major_contents.content_type_name,
		vw_major_contents.course_id, vw_major_contents.course_title, vw_major_contents.minor,
		vw_major_contents.elective, vw_major_contents.credit_hours, vw_major_contents.no_gpa, vw_major_contents.grade_id,
		grades.grade_weight, majors.org_id
	FROM majors
		INNER JOIN vw_major_contents ON majors.major_id = vw_major_contents.major_id
		INNER JOIN student_majors ON vw_major_contents.major_id = student_majors.major_id
		INNER JOIN vw_student_degrees ON (student_majors.student_degree_id = vw_student_degrees.student_degree_id) 
		INNER JOIN grades ON vw_major_contents.grade_id = grades.grade_id
		WHERE (student_majors.major = true) AND ((NOT student_majors.pre_major AND vw_major_contents.pre_major) = false) AND ((NOT student_majors.non_degree AND vw_major_contents.prerequisite) = false) AND (vw_student_degrees.drop_out = false));
	
	--view course check lists--
CREATE OR REPLACE VIEW vw_course_check_lists AS
	SELECT DISTINCT vw_course_outlines.org_id, vw_course_outlines.order_id, vw_course_outlines.student_id, vw_course_outlines.student_degree_id, 	vw_course_outlines.degree_id, vw_course_outlines.description, vw_course_outlines.course_id,
		vw_course_outlines.course_title, vw_course_outlines.minor, vw_course_outlines.elective, vw_course_outlines.credit_hours, vw_course_outlines.no_gpa, vw_course_outlines.grade_id,
		vw_course_outlines.grade_weight, get_course_done(vw_course_outlines.student_id, vw_course_outlines.course_id) as courseweight,
		(CASE WHEN (get_course_done(vw_course_outlines.student_id, vw_course_outlines.course_id) >= vw_course_outlines.grade_weight) THEN true ELSE false END) as course_passed,
		get_prereq_passed(vw_course_outlines.student_id, vw_course_outlines.course_id, vw_course_outlines.student_degree_id) as prereq_passed
	FROM vw_course_outlines;

	--view students checklists--
CREATE OR REPLACE VIEW vw_student_check_lists AS
	SELECT vw_course_check_lists.org_id, vw_course_check_lists.order_id, vw_course_check_lists.student_id, vw_course_check_lists.student_degree_id, vw_course_check_lists.degree_id, vw_course_check_lists.description, vw_course_check_lists.course_id,
    vw_course_check_lists.course_title, vw_course_check_lists.minor, vw_course_check_lists.elective, vw_course_check_lists.credit_hours, vw_course_check_lists.no_gpa, vw_course_check_lists.grade_id,
    vw_course_check_lists.courseweight, vw_course_check_lists.course_passed, vw_course_check_lists.prereq_passed,
    
    students.student_name
	FROM vw_course_check_lists
		INNER JOIN students ON vw_course_check_lists.student_id = students.student_id;

	--view session course check pass--
CREATE OR REPLACE VIEW vw_scourse_check_pass AS
    SELECT vw_course_check_lists.order_id, vw_course_check_lists.student_id, vw_course_check_lists.student_degree_id, 
        vw_course_check_lists.degree_id, vw_course_check_lists.description, vw_course_check_lists.minor, vw_course_check_lists.elective, vw_course_check_lists.grade_id, vw_course_check_lists.grade_weight, vw_course_check_lists.courseweight, vw_course_check_lists.course_passed, vw_course_check_lists.prereq_passed, vw_scourses.org_id, vw_scourses.school_id, vw_scourses.school_name, vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name, vw_scourses.course_id, vw_scourses.course_title, vw_scourses.credit_hours, vw_scourses.max_credit, vw_scourses.is_current, vw_scourses.no_gpa, vw_scourses.year_taken, vw_scourses.instructor_id, vw_scourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class, vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.approved, vw_scourses.attendance, vw_scourses.full_attendance
	FROM vw_course_check_lists
		INNER JOIN vw_scourses ON vw_course_check_lists.course_id = vw_scourses.course_id
	WHERE (vw_scourses.active = true) AND (vw_scourses.approved = false)
		AND (vw_course_check_lists.course_passed = false) AND (vw_course_check_lists.prereq_passed = true);

--view core grades--
CREATE OR REPLACE VIEW vw_core_grades AS
	SELECT vw_student_grades.org_id, vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, 
        vw_student_grades.student_name, vw_student_grades.sex, vw_student_grades.degree_id, vw_student_grades.degree_name, vw_student_grades.student_degree_id, vw_student_grades.session_id, vw_student_grades.session_year,
		vw_student_grades.sessions, vw_student_grades.course_type_id, vw_student_grades.course_type_name, vw_student_grades.course_id, vw_student_grades.no_gpa, vw_student_grades.instructor_id, vw_student_grades.scourse_id, vw_student_grades.class_option, vw_student_grades.lab_course,  vw_student_grades.grade_id, vw_student_grades.hours, vw_student_grades.credit, vw_student_grades.gpa, vw_student_grades.repeated, vw_student_grades.gpa_hours, vw_student_grades.charge_hours,
		vw_core_course_outline.description, vw_core_course_outline.minor, vw_core_course_outline.elective,
		vw_core_course_outline.content_type_id, vw_core_course_outline.content_type_name
	FROM vw_core_course_outline INNER JOIN vw_student_grades ON (vw_core_course_outline.student_degree_id = vw_student_grades.student_degree_id) AND (vw_core_course_outline.course_id = vw_student_grades.course_id)
	WHERE (vw_student_grades.major_approval = true) AND (vw_core_course_outline.minor = false);

--view grade count--
CREATE OR REPLACE VIEW vw_grade_counts AS
	SELECT sstudents.org_id, sstudents.student_degree_id, scourses.course_id, count(scourses.scourse_id) as course_count
	FROM (sgrades INNER JOIN (scourses INNER JOIN courses ON scourses.course_id = courses.course_id) ON sgrades.scourse_id = scourses.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id
		INNER JOIN grades ON grades.grade_id=sgrades.grade_id
	WHERE (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW') AND (grades.grade_name <> 'NG') AND (sgrades.dropped = false)
		AND (repeated = false) AND (sstudents.major_approval = true) AND (courses.no_repeats = false)
	GROUP BY sstudents.student_degree_id,  scourses.course_id, sstudents.org_id;

--view current students residences--
CREATE OR REPLACE VIEW vw_current_residences AS
	SELECT residences.residence_id, residences.residence_name, residences.capacity, residences.default_rate,
		residences.off_campus, residences.Sex, residences.residence_dean,
		sresidences.sresidence_id, sresidences.session_id, 
		sresidences.details, sresidences.org_id,

		students.student_id, students.student_name
	FROM ((residences INNER JOIN sresidences ON residences.residence_id = sresidences.residence_id)
	INNER JOIN vw_sessions ON sresidences.session_id = vw_sessions.session_id)
	INNER JOIN students ON ((residences.Sex = students.Sex) OR (residences.Sex='N'))
		AND (residences.off_campus = students.off_campus)
	WHERE (vw_sessions.active = true);

	--function returns first_session_id---
CREATE OR REPLACE FUNCTION get_first_session_id(varchar(12)) RETURNS varchar(12) AS $$
	SELECT min(session_id)
	FROM sstudents INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (student_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_first_session_id(integer) RETURNS varchar(12) AS $$
	SELECT min(session_id)
	FROM sstudents
	WHERE (student_degree_id = $1);
$$ LANGUAGE SQL;

--view students first session---
CREATE OR REPLACE VIEW vw_student_first_sessions AS
	SELECT vw_student_degrees.org_id, students.student_id, students.student_name, students.Nationality, students.Sex, 
        students.marital_status,
		vw_student_degrees.student_degree_id, vw_student_degrees.completed, vw_student_degrees.started, vw_student_degrees.graduated,
		vw_student_degrees.degree_name, get_first_session_id(students.student_id) as first_session_id,
		SUBSTRING(get_first_session_id(vw_student_degrees.student_degree_id) from 1 for 9) as first_year,
		SUBSTRING(get_first_session_id(vw_student_degrees.student_degree_id) from 11 for 1) as first_session
	FROM (students INNER JOIN vw_student_degrees ON students.student_id = vw_student_degrees.student_id);
		

--view dualcourselevels---
CREATE OR REPLACE VIEW vw_dual_course_levels AS
	SELECT org_id, student_id, student_name, student_degree_id, degree_name, session_id, crs_degree_level_id, crs_degree_level_name
	FROM vw_student_grades
	GROUP BY student_id, student_name, student_degree_id, degree_name, session_id, org_id, crs_degree_level_id, crs_degree_level_name;


CREATE OR REPLACE VIEW vw_scurr_student_degrees AS
	SELECT vw_sstudent_degrees.org_id, vw_sstudent_degrees.student_id, vw_sstudent_degrees.school_id, vw_sstudent_degrees.student_name,    
        vw_sstudent_degrees.sex,
		vw_sstudent_degrees.nationality, vw_sstudent_degrees.marital_status, vw_sstudent_degrees.birth_date, vw_sstudent_degrees.email,
		vw_sstudent_degrees.student_degree_id, vw_sstudent_degrees.degree_id, vw_sstudent_degrees.sstudent_id,
		vw_sstudent_degrees.session_id, vw_sstudent_degrees.probation, vw_sstudent_degrees.curr_balance, vw_sstudent_degrees.finance_approval, vw_sstudent_degrees.finalised, vw_sstudent_degrees.major_approval,
        vw_sstudent_degrees.overload_approval, vw_sstudent_degrees.student_dean_approval, vw_sstudent_degrees.overload_hours, vw_sstudent_degrees.inter_session, vw_sstudent_degrees.approved, vw_sstudent_degrees.no_approval,
		vw_sstudent_degrees.exam_clear, vw_sstudent_degrees.exam_clear_date, vw_sstudent_degrees.exam_clear_balance,
		vw_sstudent_degrees.sresidence_id, vw_sstudent_degrees.residence_id, vw_sstudent_degrees.residence_name, vw_sstudent_degrees.room_id

	FROM vw_sstudent_degrees
	JOIN sessions ON vw_sstudent_degrees.session_id = sessions.session_id
	WHERE sessions.active = true;

CREATE OR REPLACE VIEW vw_student_majors AS
	SELECT vw_student_degrees.cohort_id, vw_student_degrees.cohort_name, vw_student_degrees.max_number, vw_student_degrees.start_date, 
		vw_student_degrees.end_date, vw_student_degrees.is_active, vw_student_degrees.site_id, vw_student_degrees.site_name, 
		vw_student_degrees.degree_level_id, vw_student_degrees.degree_level_name,  
		vw_student_degrees.degree_id, vw_student_degrees.degree_name, vw_student_degrees.religion_id, vw_student_degrees.religion_name, 
		vw_student_degrees.denomination_id, vw_student_degrees.denomination_name, vw_student_degrees.sponsor_type_id, 
		vw_student_degrees.sponsor_type_name, vw_student_degrees.sponsor_id, vw_student_degrees.sponsor_name, vw_student_degrees.sponsor_address, vw_student_degrees.sponsor_street, vw_student_degrees.sponsor_postal_code, vw_student_degrees.sponsor_town, vw_student_degrees.sponsor_telno, vw_student_degrees.sponsor_email,
		vw_student_degrees.sponsor_country_id, vw_student_degrees.sponsor_country_name, vw_student_degrees.school_id, vw_student_degrees.school_name, vw_student_degrees.student_id, vw_student_degrees.student_name, vw_student_degrees.address, vw_student_degrees.zipcode, vw_student_degrees.town, vw_student_degrees.address_country, vw_student_degrees.tel_no, vw_student_degrees.email, vw_student_degrees.staff, vw_student_degrees.onhold,
		vw_student_degrees.student_edit, vw_student_degrees.disabilitys_details, vw_student_degrees.passport, vw_student_degrees.national_id, vw_student_degrees.identification_no, vw_student_degrees.picture_file, vw_student_degrees.balance_time, vw_student_degrees.curr_balance, vw_student_degrees.account_number, vw_student_degrees.nationality, vw_student_degrees.nationality_country, vw_student_degrees.sex,
		vw_student_degrees.marital_status, vw_student_degrees.birth_date, vw_student_degrees.alumnae, vw_student_degrees.post_contacts,
		vw_student_degrees.on_probation, vw_student_degrees.off_campus, vw_student_degrees.current_contact, vw_student_degrees.current_email, vw_student_degrees.current_tel, vw_student_degrees.org_id, vw_student_degrees.student_degree_id, vw_student_degrees.completed, vw_student_degrees.started, vw_student_degrees.cleared, vw_student_degrees.clear_date, vw_student_degrees.graduated, vw_student_degrees.graduate_date, vw_student_degrees.graduation_apply, vw_student_degrees.drop_out, vw_student_degrees.transfer_in, vw_student_degrees.transfer_out, 
		
		vw_majors.major_id, vw_majors.major_name, vw_majors.major as do_major, vw_majors.minor as do_minor,
		vw_majors.elective_credit, vw_majors.major_minimal, vw_majors.minor_minimum, vw_majors.core_minimum,
		student_majors.student_major_id, student_majors.major, student_majors.non_degree, student_majors.pre_major,
		student_majors.primary_major
	FROM ((vw_student_degrees
			INNER JOIN student_majors ON vw_student_degrees.student_degree_id = student_majors.student_degree_id)
		INNER JOIN vw_majors ON student_majors.major_id = vw_majors.major_id);
		

CREATE OR REPLACE VIEW vw_sys_files AS
	SELECT  sys_files.sys_file_id, sys_files.table_id, sys_files.table_name, sys_files.file_name, sys_files.file_type, sys_files.file_size,  
	 sys_files.narrative, sys_files.approved, sys_files.disapproval_reason, 
	 
	 vw_students.religion_id, vw_students.religion_name, 
	 vw_students.denomination_id, vw_students.denomination_name, vw_students.school_id, vw_students.school_name,
	 vw_students.sponsor_type_id, vw_students.sponsor_type_name, 
	 vw_students.sponsor_id, vw_students.sponsor_name, vw_students.sponsor_address, 
	 vw_students.sponsor_street, vw_students.sponsor_postal_code, vw_students.sponsor_town, vw_students.sponsor_telno, 
	 vw_students.sponsor_email, vw_students.sponsor_country_id, vw_students.sponsor_country_name, vw_students.residence_id, 
	 vw_students.residence_name, vw_students.address_country, vw_students.org_id, vw_students.student_id, vw_students.student_name, 
	 vw_students.room_number, vw_students.address, vw_students.zipcode, 
	 vw_students.town, vw_students.tel_no, vw_students.email, vw_students.account_number, vw_students.admission_basis, 
	 vw_students.nationality, vw_students.nationality_country, vw_students.sex, vw_students.marital_status, vw_students.birth_date, 
	 vw_students.alumnae, vw_students.post_contacts, vw_students.on_probation, vw_students.off_campus, vw_students.current_contact, 
	 vw_students.current_email, vw_students.current_tel, 
	 vw_students.full_bursary, vw_students.details, vw_students.staff, vw_students.onhold, vw_students.student_edit, 
	 vw_students.disabilitys_details, vw_students.passport, vw_students.national_id, vw_students.identification_no,
	 vw_students.picture_file, vw_students.balance_time, vw_students.curr_balance, vw_students.probation_details
	FROM sys_files
	INNER JOIN vw_students ON sys_files.student_id = vw_students.student_id;
	

CREATE OR REPLACE VIEW vw_session_courses AS 
	SELECT vw_scourses.school_id, vw_scourses.course_title, vw_scourses.course_id,  
	vw_scourses.scourse_id, vw_scourses.session_id, vw_sstudents.degree_name, vw_sstudents.degree_id, 
	vw_sstudents.student_degree_id, vw_sstudents.student_id, vw_sstudents.sstudent_id
	FROM vw_scourses  
INNER JOIN vw_sstudents ON vw_sstudents.session_id=vw_scourses.session_id;

CREATE OR REPLACE VIEW vw_residence_selection AS 
	SELECT vw_sstudents.sstudent_id, vw_sstudents.student_id, vw_sstudents.student_name, sessions.session_start, sessions.session_id, sessions.session_end, sessions.active,
	vw_rooms.room_name, vw_rooms.room_type_name, vw_rooms.status, vw_rooms.room_id, vw_rooms.room_charge, vw_sresidences.sresidence_id, vw_sresidences.residence_name,
	 vw_sresidences.residence_dean, 
	(sessions.session_end-sessions.session_start)*vw_rooms.room_charge AS total_charge 
	FROM vw_sstudents
		INNER JOIN vw_sresidences ON vw_sstudents.sresidence_id=vw_sresidences.sresidence_id
		INNER JOIN vw_rooms ON vw_sstudents.room_id=vw_rooms.room_id
		INNER JOIN sessions ON vw_sstudents.session_id=sessions.session_id
		GROUP BY vw_sstudents.sstudent_id, vw_sstudents.student_id, vw_sstudents.student_name, sessions.session_start, sessions.session_end,
		vw_rooms.room_name, vw_rooms.room_type_name, vw_rooms.room_id, vw_rooms.room_charge, vw_sresidences.sresidence_id, vw_sresidences.residence_name, 
		vw_sresidences.residence_dean, sessions.active, sessions.session_id,vw_rooms.status;
		
CREATE OR REPLACE FUNCTION get_cumm_credit(integer, varchar) RETURNS double precision AS $$
	SELECT sum(sgrades.credit)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (sstudents.major_approval = true)
		AND (sstudents.session_id <= $2) AND (sgrades.dropped = false)
		AND (grades.gpa_count = true) AND (sgrades.repeated = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;


CREATE OR REPLACE VIEW vw_charge_sheet AS 
	SELECT DISTINCT sponsor_id,  ROUND(CAST(wage_factor AS numeric),2) as wage_factor,  ROUND((get_cumm_credit(student_degree_id, vw_sstudents.session_id)*0.15*wage_factor)::numeric,2) AS v_fees, 
	vw_residence_selection.total_charge AS room_charge, vw_sstudents.sstudent_id, sponsor_name, vw_sstudents.sponsor_country_name, vw_sstudents.session_id, vw_sstudents.org_id
	FROM vw_sstudents
		LEFT JOIN vw_residence_selection ON vw_sstudents.sstudent_id=vw_residence_selection.sstudent_id
		GROUP BY sponsor_id, wage_factor,student_degree_id, vw_sstudents.session_id, vw_residence_selection.total_charge, vw_sstudents.sstudent_id, sponsor_name,
		vw_sstudents.sponsor_country_name, vw_sstudents.session_id, vw_sstudents.org_id;
		
CREATE OR REPLACE VIEW vw_rooms AS 
    SELECT vw_residences.org_id, vw_residences.org_name, vw_residences.residence_id, vw_residences.residence_name, vw_residences.capacity, vw_residences.room_size, vw_residences.default_rate, vw_residences.off_campus, vw_residences.gender, vw_residences.residence_dean, vw_residences.details AS residence_details, vw_residences.site_id, vw_residences.site_name, vw_residences.site_details,
    
    room_types.room_type_id, room_types.room_type_name, room_types.details AS room_type_details, rooms.room_id, rooms.room_name, rooms.room_charge, rooms.details,
    room_types.max_occupants,
        CASE
            WHEN room_types.max_occupants::integer = 1 THEN (room_types.max_occupants::text || ' '::text) || 'occupant'::text
            WHEN room_types.max_occupants::integer > 1 THEN (room_types.max_occupants::text || ' '::text) || 'occupants'::text
            ELSE NULL::text
        END AS room_capacity,
    sresidences.sresidence_id,rooms.is_booked,rooms.is_checked_out,rooms.status,rooms.room_count
   FROM rooms
     JOIN vw_residences ON rooms.residence_id = vw_residences.residence_id
     JOIN sresidences ON sresidences.residence_id = vw_residences.residence_id
     JOIN room_types ON rooms.room_type_id = room_types.room_type_id;
     
CREATE OR REPLACE FUNCTION get_courses_registered(integer) RETURNS bigint AS $$
	SELECT count(sgrade_id)
	FROM sgrades
	WHERE sstudent_id=$1;
	
$$ LANGUAGE SQL;     

CREATE OR REPLACE VIEW vw_student_session_charges AS
	SELECT vw_sstudents.sstudent_id, ROUND(vw_sstudents.extra_charges::NUMERIC,2)||' USD' AS accomodation_charge, vw_sstudents.student_id, vw_sstudents.student_name, 
	ROUND(vw_sstudents.charges::NUMERIC,2)|| 'USD' AS fees, vw_sstudents.sponsor_id,
	vw_sstudents.sponsor_name, vw_sstudents.sponsor_address, vw_sstudents.sponsor_email, vw_sstudents.sponsor_telno, vw_sstudents.sponsor_country_name, 
	vw_sstudents.sponsor_type_name, vw_sstudents.address_country,
	ROUND((vw_sstudents.extra_charges+vw_sstudents.charges)::NUMERIC,2)||' USD' AS totalcharges, vw_sstudents.session_id,
	get_cumm_credit(vw_sstudents.student_degree_id, vw_sstudents.session_id) AS total_credits, get_courses_registered(vw_sstudents.sstudent_id) AS courses_registered
	FROM vw_sstudents;
	
CREATE VIEW vw_student_profile_image AS 
	SELECT existing_id, file_name, sys_files.narrative  
	FROM vw_registrations 
	INNER JOIN sys_files ON vw_registrations.application_id=sys_files.table_id
	WHERE sys_files.narrative='profile_image';
			
