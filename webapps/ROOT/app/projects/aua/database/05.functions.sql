--(control panel functions)--

---approve cohort courses ---
CREATE OR REPLACE FUNCTION cohort_name(integer) RETURNS VARCHAR(120)  AS $$
DECLARE 
v_cohrt_name     varchar(120);
BEGIN 
    SELECT degree_id||'('||site_id||')' INTO v_cohrt_name
    FROM cohorts
    WHERE cohorts.id=$1;
    RETURN v_cohrt_name;
END;
$$ LANGUAGE plpgsql;

  --approve courses to be taken in a cohort--
CREATE OR REPLACE FUNCTION approve_course(VARCHAR(12),VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

    UPDATE cohort_courses
    SET approved =true
    WHERE cohort_course_id=$1::int;
    msg:='Approved Successfully';
    RETURN msg;
END;
$$ LANGUAGE plpgsql;
  
---drop cohort courses ---
CREATE OR REPLACE FUNCTION drop_course(VARCHAR(12),VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

    DELETE FROM  course_specializations
    WHERE cohort_course_id=$1::int;
    
    DELETE FROM  cohort_courses 
    WHERE cohort_course_id=$1::int;
    msg:='Dropped Successfully';
    RETURN msg;
END;
$$ LANGUAGE plpgsql;


---(admissions functions)---
					
---approve applicants to continue with the registration process based on finance approval----
CREATE OR REPLACE FUNCTION application_finance_approval(VARCHAR(12), VARCHAR(12),VARCHAR(12))  RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
rec		RECORD;
BEGIN
	UPDATE applications SET 
	finance_approved= true,
	paid= true,
	status='approved',
	narrative='you have been approved to continue with the application'
	WHERE application_id=$1::int;
	
	msg:= 'Approved';
	
   RETURN msg;
END;
$$ LANGUAGE plpgsql;

--reject applications  based on finance disapproval----
CREATE OR REPLACE FUNCTION reject_application_finance_approval(VARCHAR(12),VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
rec		RECORD;
BEGIN

	UPDATE applications SET 
	finance_approved= false,
	paid= false,
	status='Rejected',
	narrative='your application has been rejected based on finance issues'
	where application_id=$1::int;
	msg:= 'Rejected';
RETURN msg;
END;
$$ LANGUAGE plpgsql;

---admit a student on regular basis---
---admit a student on regular basis---
CREATE OR REPLACE FUNCTION ins_new_student(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	my_rec RECORD;
	v_cohort_id INTEGER;
	my_id RECORD;
	base_id VARCHAR(12);
	new_id VARCHAR(12);
	full_name VARCHAR(50);
	gen_first_pass VARCHAR(32);
	gen_student_pass VARCHAR(32);
	v_non_existing_id   INTEGER;
	msg		varchar(120);
BEGIN
	SELECT  schools.school_id,  vw_registrations.application_id, vw_registrations.denomination_id, vw_registrations.sponsor_id, 
	vw_registrations.registration_id, vw_registrations.surname, vw_registrations.middle_name, vw_registrations.first_name,
		vw_registrations.gender, vw_registrations.nationality_id, vw_registrations.marital_status,
		vw_registrations.birth_date, vw_registrations.existing_id, vw_registrations.degree_id,vw_registrations.primary_telephone, 
		vw_registrations.specialization_id, vw_registrations.site_id, zip_code, town, email, address,
		sys_country_id, mobile_number  INTO my_rec
	FROM vw_registrations
	INNER JOIN degrees ON vw_registrations.degree_id = degrees.degree_id
	INNER JOIN schools ON degrees.school_id = schools.school_id
	WHERE vw_registrations.registration_id=$1::int;

	SELECT non_existing_sponsor_id INTO v_non_existing_id
	FROM non_existing_sponsors 
	WHERE application_id=my_rec.application_id
	AND added= FALSE;
	
	SELECT MAX(cohorts.cohort_id) INTO v_cohort_id
	FROM cohorts 
	WHERE  degree_id=my_rec.degree_id
	AND site_id=my_rec.site_id;
	
	SELECT max(cast(substring(student_id from 6 for 3) as int)) as stdno INTO my_id
		FROM students
		WHERE substring(student_id from 2 for 4) = to_char(current_timestamp, 'YYYY');

		if(my_id.stdno is null) then
			base_id := 1;
		else
			base_id := my_id.stdno + 1;
		end if;

		new_id := 'S' || to_char(current_timestamp, 'YYYY') || lpad(cast((base_id) as varchar), 3, '0');
		
	

	IF (my_rec.middle_name IS NULL) THEN
		full_name := upper(trim(my_rec.surname)) || ', ' || upper(trim(my_rec.first_name));
	ELSE
		full_name := upper(trim(my_rec.surname)) || ', ' || upper(trim(my_rec.middle_name)) || ' ' || upper(trim(my_rec.first_name));
	END IF;

	

	IF my_rec.existing_id IS NULL THEN
		 IF(v_cohort_id IS NULL)THEN
			msg:='The cohort for the current programme is not open for admission';
		 ELSE IF(v_non_existing_id IS NOT NULL)THEN
			RAISE EXCEPTION 'The sponoring organisation attached to this student is missing. You must add the sponsor before admitting';
		 ELSE
			INSERT INTO students (student_id, student_name, account_number, surname, other_names, first_name, denomination_id, sex, Nationality,
			marital_status, birth_date, sponsor_id, school_id, address, zipcode, town, country_code_id, tel_no, email, org_id)
			VALUES (new_id, full_name, new_id, my_rec.surname, my_rec.middle_name, my_rec.first_name, my_rec.denomination_id, my_rec.gender, my_rec.nationality_id,
			my_rec.marital_status, my_rec.birth_date, my_rec.sponsor_id, my_rec.school_id, my_rec.address, my_rec.zip_code, my_rec.town,
			my_rec.sys_country_id, my_rec.primary_telephone,my_rec.email, 0);

			INSERT INTO student_degrees (cohort_id,  student_id, started, org_id)
			VALUES (v_cohort_id, new_id, current_date, 0);
			IF(my_rec.specialization_id is not null)THEN
				INSERT INTO student_specializations (student_degree_id, specialization_id, major, non_degree,  primary_major)
				VALUES (get_student_degree_id(new_id), my_rec.specialization_id, true, false,  true);
			END IF;

			IF($3='1')THEN
				UPDATE registrations SET existing_id = new_id, is_accepted=true, accepted_date=current_date, admission_status_id=1,
				details='Admimited on regular basis'
				WHERE (registrations.registration_id=$1::int);
				msg:='New student id:-  '||new_id;
			ELSE IF($3='2')THEN
				UPDATE registrations SET existing_id = new_id, is_accepted=true, accepted_date=current_date, admission_status_id=2,
				details='Admimited on Pobation basis'
				WHERE (registrations.registration_id=$1::int);
				msg:='New student id:-  '||new_id;
			ELSE IF($3='3')THEN
				UPDATE registrations SET existing_id = new_id, is_accepted=true, accepted_date=current_date, admission_status_id=3,
				details='Admimited on conditional basis'
				WHERE (registrations.registration_id=$1::int);
				msg:='New student id:-  '||new_id;
			ELSE IF($3='4')THEN
				UPDATE registrations SET existing_id = new_id, is_accepted=true, accepted_date=current_date, admission_status_id=4,
				details='Admimited on provisional basis'
				WHERE (registrations.registration_id=$1::int);
				msg:='New student id:-  '||new_id;
			END IF;
			END IF;
			END IF;
			END IF;
		END IF;
	END IF;
END IF;
    RETURN msg;
END;
$$ LANGUAGE plpgsql;


---reject student admission based on evaluation---  
CREATE OR REPLACE FUNCTION reject_admit(VARCHAR(12),VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

	UPDATE registrations SET 
	is_rejected= true,
	details='your application has been rejected based on evaluation',
	rejected_on =current_timestamp
	where registration_id=$1::int;
	msg:= 'Rejected';
RETURN msg;
END;
$$ LANGUAGE plpgsql;  

---defer students admission---  
CREATE OR REPLACE FUNCTION defer_admit(VARCHAR(12),VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

	UPDATE registrations SET 
	is_deferred= true,
	details='your application has been defered based on deferral request',
	deferred_on=current_timestamp
	where registration_id=$1::int;
	msg:= 'Defered';
RETURN msg;
END;
$$ LANGUAGE plpgsql; 

--(umis student functions)--

---action on students requests----
CREATE OR REPLACE FUNCTION action_request(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE 
    msg	    VARCHAR(120);
BEGIN
    UPDATE student_requests
    SET actioned=true, date_actioned= now()
    WHERE student_request_id=$1::int;
    msg:='Add reply message';
RETURN msg;
END;
$$ LANGUAGE plpgsql;
  
---approve students requests----  
CREATE OR REPLACE FUNCTION approve_request( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE 
    msg	    VARCHAR(120);
BEGIN
    UPDATE student_requests
    SET actioned=true, date_apploved= now(), reply='Your Request Has been approved'
    WHERE student_request_id=$1::int;
    msg:='Request Approved';
RETURN msg;
END; 
$$ LANGUAGE plpgsql;
  
---add student to probation----    
CREATE OR REPLACE FUNCTION add_probation( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
    msg	    VARCHAR(120);
DECLARE 
BEGIN
    UPDATE students
    SET on_probation=true
    WHERE student_id=$1;
    msg:='probation added';
RETURN msg;
END;
$$ LANGUAGE plpgsql;
  
---remove student from probation---- 
CREATE OR REPLACE FUNCTION remove_probation(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
BEGIN
    UPDATE students
    SET on_probation=false , probation_details=' You have been removed from probation'
    WHERE student_id=$1;
RETURN 'The student Has been removed from probation';
END;
$$ LANGUAGE plpgsql;
  

--(functions on student sessions)--

---check wether there exists an active session in the same cohort and activate the current session---- 				
CREATE OR REPLACE FUNCTION open_session( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
    v_sessions             integer;
    v_cohort_id	           integer;
    msg		               VARCHAR(120);
    
BEGIN

	SELECT cohort_id INTO v_cohort_id 
	FROM sessions
	WHERE session_id=$1;
	
	SELECT COUNT(session_id) INTO v_sessions
	FROM sessions WHERE active=true
	AND cohort_id=v_cohort_id;

	IF(v_sessions > 0 )THEN
		msg:='You cannot have two sessions active for a cohort first close one of the session';
	ELSE
		UPDATE scourses SET approved = true WHERE (session_id = $1);
		UPDATE sessions SET active = true WHERE (session_id = $1);
		msg:='You have successfully opened the session';
	END IF;
	RETURN msg;
	
END;
$$ LANGUAGE plpgsql;
  
----deactivate an active session----
CREATE OR REPLACE FUNCTION close_session(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$

	UPDATE scourses SET approved = false WHERE (session_id = $1);
	UPDATE sessions SET active = false WHERE (session_id = $1);
	SELECT text 'Done' AS mylabel;
	
$$ LANGUAGE sql;

----add a presession to sessions ---
CREATE OR REPLACE FUNCTION ins_session(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
    msg		           VARCHAR(120);
    rec		           RECORD;
    rec_scourses	   RECORD;
BEGIN
	SELECT  course_id, approved INTO rec
	FROM cohort_courses
	WHERE cohort_courses.session_id=$1;

	SELECT  scourse_id, approved INTO rec_scourses
	FROM scourses
	WHERE scourses.session_id=$1;
		IF(rec_scourses.scourse_id is null)THEN 
			IF(rec.course_id is null)THEN
				msg:='There are no courses registered for this cohort wait until the courses are registered';
			ELSE IF(rec.course_id IN (SELECT course_id FROM cohort_courses WHERE cohort_courses.session_id=$1 AND approved=false))THEN 
				msg:='Some courses have not been approved for this session they wont be added';

				INSERT INTO scourses (session_id, instructor_id, course_id, max_class)
				SELECT cohort_courses.session_id, instructor_id , course_id, 200 
				FROM cohort_courses
				INNER JOIN sessions ON sessions.session_id=cohort_courses.session_id
				WHERE cohort_courses.session_id=$1;
				
				UPDATE sessions
				SET pre_session=false
				WHERE session_id=$1;
				msg:='The session has been added successfully';
				
			ELSE
				INSERT INTO scourses (session_id, instructor_id, course_id, max_class)
				SELECT cohort_courses.session_id, instructor_id , course_id, 200 
				FROM cohort_courses
				INNER JOIN sessions ON sessions.session_id=cohort_courses.session_id
				WHERE cohort_courses.session_id=$1;
				
				UPDATE sessions
				SET pre_session=false
				WHERE session_id=$1;
				msg:='The session has been added successfully';
			
			END IF;
			END IF;
		 ELSE
			msg:='This session is already registered';
		END IF;
RETURN msg;

END;
$$ LANGUAGE plpgsql;
  
  

----approve student to be in a session---
CREATE OR REPLACE FUNCTION upd_sapprove(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	my_rec 			    RECORD;
	my_srec 			RECORD;
	ttb 			    RECORD;
	fnar 			    RECORD;
	course_rec 		    RECORD;
	place_rec 		    RECORD;
	prere_rec 		    RECORD;
	student_rec 		RECORD;
	mystr 			    varchar(250);
	my_repeat_approve	varchar(12);
	my_degree_id 		int;
	my_overload 		boolean;
	my_probation 	    boolean;
	v_last_reg		    boolean;
	my_fees_line		real;		
BEGIN

	SELECT student_id, student_degree_id, sstudent_id, finalised, finance_approval,  hours, session_id, sessions,  
		 off_campus, residence_off_campus, overload_approval, degree_level_id, get_cumm_credit(student_degree_id, session_id) as cumm_credit, get_cumm_gpa(student_degree_id, session_id) as cumm_gpa  INTO my_rec
	FROM vw_sstudents
	WHERE (sstudent_id = $1::integer);
	
	my_degree_id := my_rec.student_degree_id;

	SELECT students.full_bursary, students.see_registrar, students.on_probation, 
		students.details as probation_detail, students.address  INTO student_rec
	FROM students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id  
	WHERE (student_degrees.student_degree_id = my_degree_id);

	SELECT sstudents.room_id, sstudents.sresidence_id,  sstudents.overload_approval, 
		sstudents.overload_hours, sstudents.finance_narrative, sstudents.first_instalment, 
		sstudents.first_date, sstudents.second_instalment, sstudents.second_date, sstudents.registrar_approval, 
		sstudents.approve_late_fee, sstudents.late_fee_date, sessions.max_credits INTO my_srec
	FROM sstudents 
	INNER JOIN sessions ON sessions.session_id=sstudents.session_id
	WHERE sstudents.sstudent_id = my_rec.sstudent_id;

	SELECT course_id, course_title INTO course_rec
	FROM vw_selcourses WHERE (sstudent_id = my_rec.sstudent_id) AND (max_class < scourse_students);

	SELECT course_id, course_title, prereq_passed INTO prere_rec
	FROM vw_selected_grades 
	WHERE (sstudent_id = my_rec.sstudent_id) AND ((prereq_passed = false));

	my_overload := get_overload(my_srec.max_credits, my_rec.hours, my_rec.cumm_gpa, my_rec.cumm_credit, my_srec.overload_approval, my_srec.overload_hours);


	SELECT course_title INTO ttb 
	FROM vw_student_timetable WHERE (sstudent_id=my_rec.sstudent_id)
	AND (get_time_count(sstudent_id, start_time, end_time, c_monday, c_tuesday, c_wednesday, c_thursday, c_friday, c_saturday, c_sunday) >1);

	my_repeat_approve := get_repeat_approve(my_rec.sstudent_id);
	
	my_probation := false;
	IF (my_rec.cumm_gpa is not null) THEN
		IF (((my_rec.degree_level_id = 'MAS') OR (upper(my_rec.degree_level_id) = 'PHD')) AND (my_rec.cumm_gpa < 2.99)) THEN
			my_probation := true;
		END IF;
		IF (my_rec.cumm_gpa < 1.99) THEN
			my_probation := true;
		END IF;
	END IF;
	IF (my_srec.registrar_approval = true) THEN
		my_probation := false;
	END IF;

	mystr := '';
	IF (student_rec.on_probation = true) THEN
		mystr := 'Probation issue to be resolved first before approval ';
		IF(student_rec.probation_detail != null) THEN
			mystr := mystr || ' ' || student_rec.probation_detail;
		END IF;
	ELSIF (student_rec.see_registrar = true) THEN
		mystr := 'Probation issue to be resolved first before approval ';
		IF(student_rec.probation_detail != null) THEN
			mystr := mystr || ' ' || student_rec.probation_detail;
		END IF;
	ELSIF (ttb.course_title IS NOT NULL) THEN
		mystr := 'You have a timetable clashing for ' || ttb.course_title;
	ELSIF (course_rec.course_id IS NOT NULL) THEN
		mystr := 'The class ' || course_rec.course_id || ', ' || course_rec.course_title || ' is full';
	ELSIF (prere_rec.course_id IS NOT NULL) THEN
		mystr := 'You need to complete the prerequisites or placement for course , ' || prere_rec.course_id || ', ' || prere_rec.course_title;
	
	ELSIF (my_overload = true) THEN
		mystr := 'You have an overload';
	ELSIF (my_rec.off_campus = false) and (my_rec.residence_off_campus = true) THEN
		mystr := 'You have no clearence to be off campus';
	ELSIF (my_rec.finance_approval = false) THEN
		mystr := 'Your need finance approved before final approval';
	ELSE
		UPDATE sstudents SET approved = true
		WHERE sstudent_id = my_rec.sstudent_id;
		mystr := 'You have successful approved the student';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

 --revoke approvalfor  a  student--- 
CREATE OR REPLACE FUNCTION upd_sunapprove( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	msg					varchar(120);
	v_approved			boolean;
BEGIN
    SELECT approved INTO v_approved FROM sstudents WHERE sstudent_id=$1::int;
    
    IF(v_approved=false)THEN
		msg:='The student has not been approved for the current session';
    ELSE
		UPDATE sstudents SET approved = false
		WHERE sstudent_id = $1::int;
		msg := 'You have successful un approved the student';
	END IF;

    RETURN msg;
END;
$$ LANGUAGE plpgsql;

--(student's approvals functions)--
--student session registarations approval hierachy--
CREATE OR REPLACE FUNCTION student_approvals(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
    msg		VARCHAR(120);
BEGIN
IF ($3='1') THEN
	UPDATE sstudents
    SET student_dean_approval = true
    WHERE sstudent_id=$1::int;
    msg:='Approved Successfully';
    
ELSIF($3='2')THEN
    UPDATE sstudents
    SET registrar_approval = true
    WHERE sstudent_id=$1::int;
    msg:='Approved Successfully';
    
ELSIF($3='3')THEN
    UPDATE sstudents
    SET residence_approval = true
    WHERE sstudent_id=$1::int;
    msg:='Approved Successfully';

ELSIF($3='4')THEN
	UPDATE sstudents
    SET ict_approval = true
    WHERE sstudent_id=$1::int;
    msg:= 'Approved Successfully';
    
ELSIF($3='5')THEN
    UPDATE sstudents
    SET finance_approval = true
    WHERE sstudent_id=$1::int;
    msg:= 'Approved Successfully';
    RETURN msg;
   
 END IF;
 RETURN msg;
END;

$$ LANGUAGE plpgsql;

--(housing department functions)--

--review and approve student residence charges--
CREATE OR REPLACE FUNCTION approve_room_charge(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	
	rec				RECORD;
	
BEGIN 	
		
		SELECT vw_residence_selection.total_charge, vw_sstudents.sstudent_id, vw_sstudents.room_id  INTO rec
		FROM vw_sstudents
		INNER JOIN vw_residence_selection ON vw_sstudents.sstudent_id=vw_residence_selection.sstudent_id
		WHERE vw_sstudents.sstudent_id=$1::int;
   				
        UPDATE sstudents SET extra_charges=round(rec.total_charge::numeric,2)
        WHERE sstudent_id=rec.sstudent_id;
	
		
	RETURN 'Charges Approved sucessfully';	
		
END;
$$LANGUAGE plpgsql;


--(student administration)--

CREATE OR REPLACE FUNCTION del_dup_student(VARCHAR(12),VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	myrec RECORD;
	myreca RECORD;
	myrecb RECORD;
	myrecc RECORD;
	myqtr RECORD;
	new_id VARCHAR(16);
	mystr VARCHAR(120);
BEGIN
	IF($2 is null) THEN 
		SELECT INTO myqtr substring(session_id from 3 for 2) as qid, session_id FROM sessions WHERE active = true;
		new_id := myqtr.qid || substring($1 from 3 for 5);
	ELSE
		new_id := $2;
	END IF;
	
	SELECT INTO myrec student_id, student_name FROM students WHERE (student_id = new_id);
	SELECT INTO myreca student_degree_id, student_id FROM student_degrees WHERE (student_id = $2);
	SELECT INTO myrecb student_degree_id, student_id FROM student_degrees WHERE (student_id = $1);
	SELECT INTO myrecc a.student_degree_id, a.session_id FROM
	((SELECT student_degree_id, session_id FROM sstudents WHERE student_degree_id = myreca.student_degree_id)
	EXCEPT (SELECT student_degree_id, session_id FROM sstudents WHERE student_degree_id = myrecb.student_degree_id)) as a;
	
	IF ($1 = $2) THEN
		mystr := 'That the same ID no change';
	ELSIF (myrecc.session_id IS NOT NULL) THEN
		mystr := 'Conflict in session ' || myrecc.session_id;
	ELSIF (myreca.student_degree_id IS NOT NULL) AND (myrecb.student_degree_id IS NOT NULL) THEN
		UPDATE sstudents SET student_degree_id = myreca.student_degree_id WHERE student_degree_id = myrecb.student_degree_id;
		UPDATE student_requests SET student_id = $2 WHERE student_id = $1;
		DELETE FROM student_majors WHERE student_degree_id = myrecb.student_degree_id;
		DELETE FROM student_degrees WHERE student_degree_id = myrecb.student_degree_id;
		DELETE FROM students WHERE student_id = $1;	
		mystr := 'Changes to ' || $2;
	ELSIF (myrec.student_id is not null) THEN
		UPDATE student_degrees SET student_id = $2 WHERE student_id = $1;
		UPDATE student_requests SET student_id = $2 WHERE student_id = $1;
		DELETE FROM students WHERE student_id = $1;
		mystr := 'Changes to ' || $2;
	ELSIF ($2 is null) THEN
		DELETE FROM student_degrees WHERE student_id is null;
		UPDATE student_degrees SET student_id = null WHERE student_id = $1;
		UPDATE student_requests SET student_id = null WHERE student_id = $1;
		UPDATE students SET student_id = new_id, new_student = false  WHERE student_id = $1;
		UPDATE student_degrees SET student_id = new_id WHERE student_id is null;
		UPDATE student_requests SET student_id = new_id WHERE student_id is null;
		mystr := 'Changes to ' || new_id;
	END IF;
	
	RETURN mystr;
END;
$$
  LANGUAGE plpgsql;
  
  
CREATE OR REPLACE FUNCTION del_student(VARCHAR(12),VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	myrecs 							RECORD;
	myrecdegree 					RECORD;
	myreccourses 					RECORD;
	myrecsession 					RECORD;
	myrecspecialization 			RECORD;
	myapprovals				    	RECORD;
	msg					   	       	varchar(120);
	strd					      	varchar(120);
	myfiles					       	RECORD;
	mymajors					    RECORD;
	v_entity_id				    	integer;
	
BEGIN
	SELECT * INTO myrecs FROM students WHERE student_id=$1;


	SELECT * INTO myrecdegree FROM student_degrees WHERE student_id=$1;

	SELECT * INTO myapprovals FROM approval_list WHERE student_id=$1;

	
	SELECT *  INTO myfiles FROM sys_files WHERE student_id=$1;
	
	SELECT entity_id INTO v_entity_id FROM entitys WHERE user_name=$1;

	SELECT *  INTO myrecspecialization FROM student_specializations
	INNER JOIN student_degrees ON student_degrees.student_degree_id=student_specializations.student_degree_id
	WHERE student_id=$1;

	SELECT *  INTO mymajors FROM student_majors
	INNER JOIN student_degrees ON student_degrees.student_degree_id=student_majors.student_degree_id
	WHERE student_id=$1;
	
	SELECT * INTO myreccourses FROM sgrades
	INNER JOIN sstudents ON sgrades.sstudent_id=sgrades.sstudent_id
	INNER JOIN student_degrees ON student_degrees.student_degree_id=sstudents.student_degree_id
	WHERE student_id=$1;

	SELECT * INTO myrecsession FROM sstudents
	INNER JOIN student_degrees ON student_degrees.student_degree_id=sstudents.student_degree_id
	WHERE student_id=$1;

	IF(myapprovals.student_id is not null)THEN

	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by, narrative)
	VALUES(myapprovals.org_id, 'approval_list', 'DELETE', myapprovals.student_id, $2::int, 'deleted student approvals and requests');
	DELETE FROM approval_list WHERE student_id=$1;
	strd:='Approvals';
	END IF;

	IF(myreccourses.sgrade_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myreccourses.org_id, 'sgrades', 'DELETE', myreccourses.student_id, $2::int, 'Deleted students grades');
	
	DELETE FROM sgrades WHERE sgrade_id IN(SELECT sgrade_id FROM sgrades
	INNER JOIN sstudents ON sgrades.sstudent_id=sgrades.sstudent_id
	INNER JOIN student_degrees ON student_degrees.student_degree_id=sstudents.student_degree_id
	WHERE student_id=$1); 
	
	strd:='Grade'||' '||strd;
	END IF;
	
	IF(myrecsession.sstudent_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myrecsession.org_id, 'sstudents', 'DELETE', myrecsession.student_id, $2::int, 'Deleted student sessions');
	
	DELETE FROM sstudents WHERE sstudent_id IN ( SELECT sstudent_id FROM sstudents 
	INNER JOIN student_degrees ON student_degrees.student_degree_id=sstudents.student_degree_id
	WHERE student_id=$1);
	strd:='sessions'||' '||strd;
	END IF;
	
	IF(myrecspecialization.student_specialization_id is not null)THEN

	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myrecsession.org_id, 'student_specializations', 'DELETE', myrecsession.student_id, $2::int, 'Deleted student specializations');
	
	DELETE FROM student_specializations WHERE student_specialization_id IN (SELECT student_specialization_id FROM student_specializations  
	INNER JOIN student_degrees ON student_degrees.student_degree_id=student_specializations.student_degree_id
	WHERE student_id=$1);
	strd:='specializations'||' '||strd;
	END IF;

	IF(mymajors.student_major_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(mymajors.org_id, 'student_majors', 'DELETE', mymajors.student_id, $2::int, 'Deleted student majors');
	
	DELETE FROM student_majors WHERE student_major_id IN (SELECT student_major_id FROM student_majors  
	INNER JOIN student_degrees ON student_degrees.student_degree_id=student_majors.student_degree_id
	WHERE student_id=$1);
	strd:='Majors'||' '||strd;
	END IF;
	
	IF(myrecdegree.student_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myrecdegree.org_id, 'student_degrees', 'DELETE', myrecdegree.student_id, $2::int, 'Deleted student degrees');
	
	DELETE FROM student_degrees WHERE student_id = $1;
	strd:='degrees'||' '||strd;
	END IF;

	IF(myfiles.sys_file_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myfiles.org_id, 'sys_files', 'DELETE', myfiles.student_id, $2::int, 'Deleted student files');
	
	DELETE FROM sys_files WHERE student_id = $1;
	strd:='Attachments'||' '||strd;
	END IF;
	
	IF(myrecs.student_id is not null)THEN
	INSERT INTO logs.lg_student_management(org_id, table_name, activity, student_id,executed_by,  narrative)
	VALUES(myrecs.org_id, 'students', 'DELETE', myrecs.student_id, $2::int, 'student deleted completely from the database');
	
	DELETE FROM students WHERE student_id = $1;
	strd:='student' ||' '||strd;
	END IF;

	IF(v_entity_id is not null)THEN
	DELETE FROM sys_access_entitys WHERE entity_id = v_entity_id;
	DELETE FROM entity_subscriptions WHERE entity_id = v_entity_id;
	DELETE FROM entitys WHERE entity_id = v_entity_id;
	END IF;
	
RETURN 'student deleted successfully NB: This action cannot be reversed';	
END;
$$ LANGUAGE plpgsql;


--student session registration functions)--
CREATE OR REPLACE FUNCTION sel_sroom(varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(50) AS $$
DECLARE
	mystr VARCHAR(120);
	my_rec RECORD;
	my_stud int;
	srec	RECORD;
	count  integer;
	is_picked   boolean;

BEGIN
	my_stud := get_sstudent_id($2);
	
	
	
	SELECT room_id, rooms.room_type_id, room_type_name, room_name, max_occupants, is_booked, room_count, 
	is_checked_out INTO srec
	FROM rooms
	INNER JOIN room_types ON rooms.room_type_id=room_types.room_type_id
	WHERE room_id=$1::int;
	
	SELECT  sstudent_id, room_id, finalised INTO my_rec 
	FROM sstudents
	WHERE (sstudent_id = my_stud);

	IF(my_rec.room_id is null)THEN
	is_picked=false;
	ELSE
	is_picked=true;
	END IF;

	count:=0;
	
	IF (my_rec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSIF (my_rec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
	  IF(srec.is_booked=false) THEN
		IF(is_picked=false)THEN 
			
			IF(srec.room_count is null OR srec.room_count < srec.max_occupants::int) THEN
			
			
			UPDATE sstudents 
			SET room_id=srec.room_id,
			sresidence_id=$3::int
			WHERE sstudent_id=my_stud;
			count:=count+1;
			
			UPDATE rooms SET room_count= count,
			
			status=count||'/'||srec.max_occupants||' Booked'
			WHERE room_id=$1::int;
			
			END IF;
			IF(count=srec.max_occupants::int)THEN
				UPDATE rooms SET is_booked=true
				WHERE room_id=$1::int;
			END IF;
		
			mystr := 'You have booked room '|| srec.room_name||' '||srec.room_type_name||' waiting confirmation';
		ELSE
			mystr:='You have already picked this room if you want to change first drop your selection';
		END IF;

	  ELSE
	        mystr := 'The room is fully booked try out other rooms';
	
		
	END IF;	
	END IF;

RETURN mystr;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sel_sresidence( VARCHAR(12),  VARCHAR(12),  VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	mystr VARCHAR(120);
	my_rec RECORD;
	my_stud int;
	my_res int;
BEGIN
	my_stud := get_sstudent_id($2);
	my_res := $1::int;

	SELECT INTO my_rec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id=my_stud);

	IF (my_rec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSE IF (my_rec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sstudents SET sresidence_id = my_res WHERE (sstudent_id = my_stud);
		mystr := 'Residence registered awaiting approval';
	END IF;
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION drop_selection( VARCHAR(12),  VARCHAR(12),  VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	mystr VARCHAR(120);
	my_rec RECORD;
	srec  RECORD;
	
	
BEGIN
	SELECT room_id, rooms.room_type_id, room_type_name, room_name, max_occupants, is_booked, room_count, 
	is_checked_out INTO srec
	FROM rooms
	INNER JOIN room_types ON rooms.room_type_id=room_types.room_type_id
	WHERE room_id=$1::int;
	
	SELECT INTO my_rec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id=get_sstudent_id($2));

	IF (my_rec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSE IF (my_rec.finalised = true) THEN
		mystr := 'You have closed the selection request for changes from the admin';
	ELSE
		UPDATE sstudents SET sresidence_id = null, room_id=null WHERE (sstudent_id = get_sstudent_id($2));
		mystr := 'Selection dropped you can now make another selection';

		UPDATE rooms SET room_count=room_count-1, status=room_count||'/'||srec.max_occupants
		WHERE room_id=$1::int;
	END IF;
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_sclose(varchar(12),varchar(12),varchar(12)) RETURNS VARCHAR(12) AS $$
DECLARE
	myrec 			RECORD;
	myqrec 			RECORD;
	ttb 			RECORD;
	fnar 			RECORD;
	courserec 		RECORD;
	placerec 		RECORD;
	prererec 		RECORD;
	studentrec 		RECORD;
	mystr 			varchar(250);
	myrepeatapprove	varchar(12);
	my_degree_id 	int;
	myoverload 		boolean;
	myprobation 	boolean;
	v_last_reg		boolean;
	myfeesline 		real;
BEGIN
	my_degree_id := get_student_degree_id($2);

	SELECT sstudent_id, finalised, finance_approval,vw_scourses.no_gpa, hours, vw_sstudents.session_id ,vw_sstudents.sessions,
		off_campus, overload_approval, sponsor_id, 
		vw_sstudents.degree_level_id, get_cumm_credit(student_degree_id, vw_sstudents.session_id) as cumm_credit,
		get_cumm_gpa(student_degree_id, vw_sstudents.session_id) as cumm_gpa
		INTO myrec
	FROM vw_sstudents
	INNER JOIN vw_scourses ON vw_scourses.session_id=vw_sstudents.session_id
	WHERE (student_degree_id = my_degree_id) AND (vw_sstudents.session_id = $1);

	SELECT  students.full_bursary, students.see_registrar, students.on_probation,
		students.details as probation_detail, students.address
		INTO studentrec
	FROM students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id
	WHERE (student_degrees.student_degree_id = my_degree_id);

	SELECT sstudents.room_id, sstudents.sresidence_id, sstudents.overload_approval,
		sstudents.overload_hours, sstudents.finance_narrative, sstudents.first_instalment,
		sstudents.first_date, sstudents.second_instalment, sstudents.second_date, sstudents.registrar_approval,
		sstudents.approve_late_fee,
		sessions.max_credits
		INTO myqrec
	FROM sstudents INNER JOIN scharges ON sstudents.scharge_id = scharges.scharge_id
		INNER JOIN sessions ON sessions.session_id = sstudents.session_id;

	SELECT course_id, course_title INTO courserec
	FROM vw_selcourses WHERE (sstudent_id = myrec.sstudent_id) AND (max_class < scourse_students);

	SELECT course_id, course_title, prereq_passed INTO prererec
	FROM vw_selected_grades
	WHERE (sstudent_id = myrec.sstudent_id) AND (prereq_passed = false);

	myoverload := get_overload(myqrec.max_credits, myrec.hours, myrec.cumm_gpa, myrec.cumm_credit, myqrec.overload_approval, myqrec.overload_hours);

	SELECT course_title INTO ttb
	FROM vw_student_timetable WHERE (sstudent_id=myrec.sstudent_id)
	AND (get_time_count(sstudent_id, start_time, end_time, c_monday, c_tuesday, c_wednesday, c_thursday, c_friday, c_saturday, c_sunday) >1);

	myrepeatapprove := get_repeat_approve(myrec.sstudent_id);



	myprobation := false;
	IF (myrec.cumm_gpa is not null) THEN
		IF (((myrec.degree_level_id = 'MAS') OR (upper(myrec.degree_level_id) = 'PHD')) AND (myrec.cumm_gpa < 2.99)) THEN
			myprobation := true;
		END IF;
		IF (myrec.cumm_gpa < 1.99) THEN
			myprobation := true;
		END IF;
	END IF;
	IF (myqrec.registrar_approval = true) THEN
		myprobation := false;
	END IF;


	mystr := '';
	IF (studentrec.on_probation = true) THEN
		IF(studentrec.probation_detail != null) THEN
			mystr := '<br/>' || studentrec.probation_detail;
		END IF;
		RAISE EXCEPTION 'See your major adviser for courses you need to pick, get financial approval and the visit records office for approval % ', mystr;
	ELSIF (studentrec.see_registrar = true) THEN
		IF(studentrec.probation_detail != null) THEN
			mystr := '<br/>' || studentrec.probation_detail;
		END IF;
		RAISE EXCEPTION 'Go to records office for clearance  % ', mystr;
	ELSIF (myrec.sstudent_id IS NULL) THEN
		RAISE EXCEPTION 'Please register for the trimester, residence first before closing';
	ELSIF (myrec.finalised = true) THEN
		RAISE EXCEPTION 'The trimester is closed for registration';

	ELSIF (studentrec.address IS NULL) THEN
		RAISE EXCEPTION 'Go to records office for clearance, Wrong Student Address';
	ELSIF (myrec.finalised = true) THEN
		RAISE EXCEPTION 'The trimester is closed for registration';
	ELSIF (myprobation = true) THEN
		RAISE EXCEPTION 'See your major adviser for courses you need to pick, get financial approval and the visit records office for approval';
	ELSIF (v_last_reg = true) THEN
		RAISE EXCEPTION 'You need to clear for late registration with the Registars office';


	ELSIF (myrepeatapprove IS NOT NULL) THEN
		RAISE EXCEPTION 'You need repeat approval for % from the registrar', myrepeatapprove;
	ELSIF (ttb.course_title IS NOT NULL) THEN
		RAISE EXCEPTION 'You have an timetable clashing for % ', ttb.course_title;
	ELSIF (courserec.course_id IS NOT NULL) THEN
		RAISE EXCEPTION 'The class %, % is full', courserec.course_id, courserec.course_title;

	ELSIF (myoverload = true) THEN
		RAISE EXCEPTION 'You have an overload';
		UPDATE sstudents SET finalised = true, finance_approval = true WHERE sstudent_id = myrec.sstudent_id;
		UPDATE sstudents SET first_close_time = now() WHERE (first_close_time is null) AND (sstudent_id = myrec.sstudent_id);
		mystr := 'You have successful closed trimester based on bursary status';
	ELSIF (myrec.finance_approval = true) THEN
		UPDATE sstudents SET finalised = true WHERE sstudent_id = myrec.sstudent_id;
		UPDATE sstudents SET first_close_time = now() WHERE (first_close_time is null) AND (sstudent_id = myrec.sstudent_id);
		mystr := 'Successful trimester closed based on financial approval';
	
	ELSE
		UPDATE sstudents SET finalised = true, major_approval= true, overload_approval= true  WHERE sstudent_id = myrec.sstudent_id;
		UPDATE sstudents SET first_close_time = now() WHERE (first_close_time is null) AND (sstudent_id = myrec.sstudent_id);
		mystr := 'You have successful Closed trimester, Check required approvals';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;


--(finance functions)--
CREATE OR REPLACE FUNCTION finance_approval(varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

    UPDATE sstudents
    SET finance_approval = true
    WHERE sstudent_id=get_sstudent_id($1,$3);
    msg:= 'Approved Successfully';
    RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION revoke_finance_approval(varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
msg		VARCHAR(120);
BEGIN

    UPDATE sstudents
    SET finance_approval = false
    WHERE sstudent_id=get_sstudent_id($1,$3);
    msg:='Approval Revoke Successfully';
    RETURN msg;
END;
$$ LANGUAGE plpgsql;

--(common functions)--

  
CREATE OR REPLACE FUNCTION check_grade(integer, double precision) RETURNS bigint AS $$

	SELECT count(sgrades.sgrade_id)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
	INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true) AND (sgrades.dropped = false)
		AND (grades.grade_weight < $2) AND (grades.gpa_count = true);
		
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION check_grade(integer, VARCHAR(12), double precision) RETURNS bigint AS $$
	SELECT count(sgrades.sgrade_id)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
	INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (substring(sstudents.session_id from 1 for 9) = $2) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.grade_weight < $3) AND (grades.gpa_count = true);
$$ LANGUAGE sql;

  
CREATE OR REPLACE FUNCTION check_honors( double precision, double precision, double precision, double precision) RETURNS integer AS $$
DECLARE
	myhonors       int;
	gpa            float;
	pgpa           float;
	i              int;
BEGIN
	myhonors := 0;

	pgpa := 0;
	FOR i IN 1..4 LOOP
		if(i = 1) then gpa := $1; end if;
		if(i = 2) then gpa := $2; end if;
		if(i = 3) then gpa := $3; end if;
		if(i = 4) then gpa := $4; end if;

		IF (gpa IS NOT NULL) THEN
    		IF ((gpa >= 3.5) AND (pgpa >= 3.5)) THEN
				myhonors := myhonors + 1;
			END IF;
			pgpa := gpa; 
		END IF;
	END LOOP;

    RETURN myhonors;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_incomplete(integer) RETURNS bigint AS $$

	SELECT count(sgrades.sgrade_id)
	FROM sgrades 
	INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id
	INNER JOIN grades ON grades.grade_id = sgrades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true)
		AND (grades.grade_name = 'IW') AND (sgrades.dropped = false);
		
$$ LANGUAGE sql;
  


CREATE OR REPLACE FUNCTION compute_student_charge(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
BEGIN 	
    UPDATE sstudents SET charges= a.charge
        FROM																																(SELECT ROUND((0.15* wage_factor::NUMERIC * get_cumm_credit(student_degree_id, session_id)::NUMERIC),2) AS charge, sstudent_id, session_id
        FROM vw_sstudents  
        WHERE session_id=$1
        ) AS a
		 
		 WHERE sstudents.sstudent_id=a.sstudent_id;

	RETURN 'Charges computed sucessfully';	
		
END;
$$LANGUAGE plpgsql;

  
CREATE OR REPLACE FUNCTION get_cohort_session(VARCHAR(12))RETURNS VARCHAR(120)  AS $$

    SELECT session_id FROM sessions 
    INNER JOIN cohorts ON cohorts.cohort_id=sessions.cohort_id
    WHERE sessions.active=true 
    AND degree_id=$1;
    
$$ LANGUAGE sql; 
  
CREATE OR REPLACE FUNCTION get_core_major(integer) RETURNS VARCHAR(120)  AS $$
    SELECT max(specializations.specialization_name)
    FROM student_specializations INNER JOIN specializations ON student_specializations.specialization_id = specializations.specialization_id
    WHERE (student_specializations.student_degree_id = $1) AND (student_specializations.primary_major = true);
    
$$ LANGUAGE sql; 
  
CREATE OR REPLACE FUNCTION get_course_cohort(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT  course_id
	FROM degrees
	INNER JOIN cohorts ON cohorts.degree_id=degrees.degree_id
	INNER JOIN sessions ON sessions.cohort_id=cohorts.cohort_id
	INNER JOIN courses ON degrees.school_id=courses.school_id
	WHERE session_id=$1;

$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_course_done( VARCHAR(12), VARCHAR(12)) RETURNS double precision AS $$
	
	SELECT max(grades.grade_weight)
	FROM (((scourses INNER JOIN sgrades ON scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id)
		INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (sstudents.finance_approval = true) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
	AND (student_degrees.student_id = $1) AND (scourses.course_id = $2);
	
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_course_repeat(integer, VARCHAR(12)) RETURNS bigint AS $$

	SELECT count(scourses.scourse_id)
	FROM (sgrades INNER JOIN (scourses INNER JOIN courses ON scourses.course_id = courses.course_id) ON sgrades.scourse_id = scourses.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id
	WHERE (sgrades.grade_id <> '13')  AND (sgrades.grade_id <> '14')
		AND (sgrades.dropped = false) AND (sstudents.approved = true) AND (courses.no_repeats = false)
		AND (sstudents.student_degree_id = $1) AND (scourses.course_id = $2);
$$ LANGUAGE sql;
  
  
CREATE OR REPLACE FUNCTION get_course_session(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
    SELECT session_id FROM scourses WHERE (scourse_id = CAST($1 as INT));
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_course_title(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$ 
SELECT MAX(course_title) FROM courses WHERE (course_id = $1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_course_transfered( VARCHAR(12), VARCHAR(12)) RETURNS double precision AS $$
	SELECT sum(transfered_credits.credit_hours)
	FROM transfered_credits INNER JOIN student_degrees ON transfered_credits.student_degree_id = student_degrees.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (transfered_credits.course_id = $2);
$$ LANGUAGE sql;  


  
CREATE OR REPLACE FUNCTION get_cumm_gpa(integer, VARCHAR(12)) RETURNS double precision AS $$

	SELECT (CASE sum(sgrades.credit) WHEN 0 THEN 0 ELSE (sum(grades.grade_weight * sgrades.credit)/sum(sgrades.credit)) END)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (sstudents.session_id <= $2) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.gpa_count = true) 
		AND (sgrades.repeated = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_curr_credit(integer) RETURNS double precision AS $$

	SELECT sum(sgrades.credit)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true)
		AND (grades.gpa_count = true) AND (sgrades.dropped = false) 
		AND (sgrades.repeated = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;  
  
CREATE OR REPLACE FUNCTION get_curr_gpa(integer) RETURNS double precision AS $$
	SELECT (CASE sum(sgrades.credit) WHEN 0 THEN 0 ELSE (sum(grades.grade_weight * sgrades.credit)/sum(sgrades.credit)) END)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true)
		AND (grades.gpa_count = true) AND (sgrades.dropped = false) 
		AND (sgrades.repeated = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_curr_hours(integer) RETURNS double precision AS $$
	SELECT sum(sgrades.hours)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
	INNER JOIN grades ON sgrades.grade_id=grades.grade_id
	WHERE (sstudents.sstudent_id = $1) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;  
  
CREATE OR REPLACE FUNCTION get_curr_sstudent_id(VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudent_id) 
	FROM vw_sstudent_list INNER JOIN sessions ON vw_sstudent_list.session_id = sessions.session_id 
	WHERE (student_id = $1) AND (sessions.active = true);
$$ LANGUAGE sql;
  
  CREATE OR REPLACE FUNCTION get_current_year(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT to_char(current_date, 'YYYY'); 
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_default_country(integer) RETURNS character AS $$
	SELECT default_country_id::varchar(2)
	FROM orgs
	WHERE (org_id = $1);
$$ LANGUAGE sql; 

CREATE OR REPLACE FUNCTION get_student_degree_id(varchar(12)) RETURNS integer AS $$
	SELECT max(student_degree_id) FROM student_degrees WHERE (student_id=$1) AND (completed=false);
$$ LANGUAGE SQL;
  
CREATE OR REPLACE FUNCTION get_degree_level_id(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT degrees.degree_level_id
	FROM degrees
	INNER JOIN cohorts ON cohorts.degree_id = degrees.degree_id
	INNER JOIN student_degrees ON cohorts.cohort_id = cohorts.cohort_id
	WHERE (student_degrees.student_degree_id = get_student_degree_id($1));
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_exam_time_count(integer, date, time without time zone, time without time zone) RETURNS bigint AS $$
	SELECT count(scourse_id) FROM vw_sexam_timetables
	INNER JOIN sstudents ON sstudents.session_id=vw_sexam_timetables.session_id
	WHERE (sstudent_id = $1) AND (exam_date = $2) AND (((start_time, end_time) OVERLAPS ($3, $4))=true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_first_session_id(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT min(session_id)
	FROM sstudents INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (student_id = $1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_first_session_id(integer) RETURNS VARCHAR(120)  AS $$
	SELECT min(session_id)
	FROM sstudents
	WHERE (student_degree_id = $1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_grade_id(integer) RETURNS integer AS $$
	SELECT CASE WHEN max(grade_id) is null THEN 1  WHEN $1 = -1 THEN 10 ELSE max(grade_id) END
	FROM grades 
	WHERE (min_range <= $1) AND (max_range >= $1);
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_grade_id(real) RETURNS integer AS $$
	SELECT max(grade_id)
	FROM grades 
	WHERE (min_range <= $1) AND (max_range >= $1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_grade_name(integer) RETURNS VARCHAR(120)  AS $$
	SELECT grade_name
	FROM grades 
	WHERE grade_id=$1;
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_instructor_department(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT school_id::varchar(120)
	FROM instructors
	WHERE (instructor_id = $1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_overload(real, double precision, double precision, double precision, boolean, double precision) RETURNS  boolean AS $$
DECLARE
	myoverload boolean;
BEGIN
	myoverload := false;

	IF ($1=14) THEN
		IF (($3<1.99) AND ($2<>9)) THEN
			myoverload := true;
		ELSIF ($3 is null) AND ($2 > 14) THEN
			myoverload := true;
		ELSIF (($4>=110) AND ($3>=2.70) AND ($2<=17)) THEN
			myoverload := false;
		ELSE
			IF (($3<3) AND ($2>14)) THEN
				myoverload := true;
			ELSIF (($3<3.5) AND ($2>15)) THEN
				myoverload := true;
			ELSIF ($2>16) THEN
				myoverload := true;
			END IF;
		END IF;
	ELSE
		IF($2 > $1)THEN
			myoverload := true;
		END IF;
	END IF;

	IF (myoverload = true) THEN
		IF ($5 = true) AND ($2 <= $6) THEN
			myoverload := false;
		END IF;
	END IF;

    RETURN myoverload;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION get_prereq_passed( VARCHAR(12), VARCHAR(12)) RETURNS boolean AS $$
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
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION get_prereq_passed( VARCHAR(12), VARCHAR(12), integer, boolean) RETURNS boolean AS $$
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
  
CREATE OR REPLACE FUNCTION get_prereq_passed(VARCHAR(12), VARCHAR(12), integer) RETURNS boolean AS $$
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
  
CREATE OR REPLACE FUNCTION get_prev_credit(integer, VARCHAR(12)) RETURNS double precision AS $$
	SELECT sum(sgrades.credit)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (sstudents.session_id = $2) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.gpa_count = true) 
		AND (sgrades.repeated = false) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_prev_gpa( integer, VARCHAR(12)) RETURNS double precision AS $$
	SELECT (CASE sum(sgrades.credit) WHEN 0 THEN 0 ELSE (sum(grades.grade_weight * sgrades.credit)/sum(sgrades.credit)) END)
	FROM (sgrades INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sstudents.student_degree_id = $1) AND (sstudents.session_id = $2) AND (sstudents.major_approval = true)
		AND (sgrades.dropped = false) AND (grades.gpa_count = true) AND (sgrades.repeated = false) 
		AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW');
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_prev_session(integer, VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT max(sstudents.session_id)
	FROM sstudents
	WHERE (sstudents.student_degree_id = $1) AND (sstudents.session_id < $2);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_repeat_approve(integer) RETURNS VARCHAR(120)  AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(12);
BEGIN
	mystr := null;
	FOR myrec IN SELECT course_id, get_course_repeat(student_degree_id, course_id), crs_approved, get_course_done(student_id, course_id)
		FROM vw_student_grades 
		WHERE (sstudent_id = $1) AND (get_course_repeat(student_degree_id, course_id) > 0) 
		AND (crs_approved = false) AND (dropped = false) LOOP
	
		IF (myrec.get_course_done > 1.67) THEN
			mystr := myrec.course_id;
		END IF;
		IF (myrec.get_course_repeat > 1) THEN
			mystr := myrec.course_id;
		END IF;
	END LOOP;
	
    RETURN mystr;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION get_s_resident_id(VARCHAR(12),VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sresidence_id) 
	FROM sresidences 
	WHERE (residence_id = $1::integer) AND (session_id  = $2);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_sresident_id(VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sresidences.sresidence_id) 
	FROM sresidences INNER JOIN sessions ON sresidences.session_id =sessions.session_id 
	WHERE (sresidences.residence_id = $1::integer) AND (sessions.active = true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_sstudent_id( integer, VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudents.sstudent_id)
	FROM sstudents
	WHERE (student_degree_id = $1) AND (session_id = $2);
$$ LANGUAGE sql;
  
  
CREATE OR REPLACE FUNCTION get_sstudent_id( VARCHAR(12), VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (sstudents.session_id = $2);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_sstudent_id(VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM (student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (student_degrees.student_id = $1) AND (sessions.active = true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_student_degree_id(VARCHAR(12)) RETURNS integer AS $$
	SELECT max(student_degree_id) FROM student_degrees WHERE (student_id=$1) AND (completed=false);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_student_degree_id(VARCHAR(12), VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudents.student_degree_id)
	FROM student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (sstudents.session_id = $2);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_student_id(integer) RETURNS VARCHAR(120)  AS $$
DECLARE
v_student_id	VARCHAR(12);
BEGIN
SELECT student_id INTO v_student_id FROM vw_sstudents
WHERE sstudent_id=$1;
RETURN v_student_id;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION get_student_session(VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
	SELECT  session_id 
	FROM vw_sessions
	INNER JOIN student_degrees ON student_degrees.cohort_id=vw_sessions.cohort_id
	WHERE student_id=$1 AND vw_sessions.active=true
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_study_level(integer) RETURNS integer AS $$
	SELECT max(study_level)
	FROM sstudents
	WHERE (student_degree_id = $1) AND (approved = true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_time_asset_count(
    integer,
    time without time zone,
    time without time zone,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean,
    VARCHAR(12))
  RETURNS bigint AS $$
	SELECT count(stimetable_id) FROM vw_stimetables
	WHERE (asset_id = $1) AND (((start_time, end_time) OVERLAPS ($2, $3))=true)
	AND ((c_monday and $4) OR (c_tuesday and $5) OR (c_wednesday and $6) OR (c_thursday and $7) OR (c_friday and $8) OR (c_saturday and $9) OR (c_sunday and $10))
	AND (session_id = $11);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION get_time_count(
    integer,
    time without time zone,
    time without time zone,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean,
    boolean)
  RETURNS bigint AS $$
	SELECT count(stimetable_id) FROM vw_student_timetable
	WHERE (sstudent_id=$1) AND (((start_time, end_time) OVERLAPS ($2, $3))=true)
	AND ((c_monday and $4) OR (c_tuesday and $5) OR (c_wednesday and $6) OR (c_thursday and $7) OR (c_friday and $8) OR (c_saturday and $9) OR (c_sunday and $10));
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION getcoremajor(integer) RETURNS VARCHAR(120)  AS $$
    SELECT max(majors.major_name)
    FROM student_majors INNER JOIN majors ON student_majors.major_id = majors.major_id
    WHERE (student_majors.student_degree_id = $1) AND (student_majors.primary_major = true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION getcoursecredits(integer) RETURNS double precision AS $$
	SELECT (CASE courses.no_gpa WHEN true THEN 0 ELSE courses.credit_hours END)
	FROM courses INNER JOIN scourses ON courses.course_id = scourses.course_id
	WHERE (scourse_id=$1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION getcoursehours(integer) RETURNS double precision AS $$
	SELECT courses.credit_hours
	FROM courses INNER JOIN scourses ON courses.course_id = scourses.course_id
	WHERE (scourse_id=$1);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION gets_student_id(VARCHAR(12)) RETURNS integer AS $$
	SELECT max(sstudents.sstudent_id)
	FROM (student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (student_degrees.student_id = $1) AND (sessions.active = true);
$$ LANGUAGE sql;
  
CREATE OR REPLACE FUNCTION grade_updates(VARCHAR(12), VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
BEGIN
	IF($3 = '1')THEN
		UPDATE sgrades SET grade_id = 8, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (sgrades.grade_id = 14)
			AND (sstudents.exam_clear = true) AND (sstudents.session_id = $1);

		UPDATE sgrades SET grade_id = 12, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (sgrades.grade_id = 14)
			AND (sstudents.finace_approval = true) AND (sstudents.exam_clear = false) AND (sstudents.session_id = $1);
	END IF;

	IF($3 = '2')THEN
		UPDATE sgrades SET grade_id = 8, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (sgrades.grade_id = 12)
			AND (sstudents.session_id = $1);
	END IF;

	IF($3 = '3')THEN
		UPDATE sgrades SET grade_id = 13, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (grade_id = 10)
			AND (sstudents.session_id = $1);
	END IF;
	
	IF($3 = '4')THEN
		UPDATE sgrades SET grade_id = 8, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (grade_id = 11)
			AND (sstudents.session_id = $1);
	END IF;
	
	IF($3 = '5')THEN
		UPDATE sgrades SET grade_id = 13, sys_audit_trail_id = $4::integer
		FROM sstudents WHERE (sgrades.sstudent_id = sstudents.sstudent_id) 
			AND (sgrades.dropped = false) AND (grade_id = 12)
			AND (sstudents.session_id = $1);
	END IF;

	RETURN 'Grade updates';
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION getchargedays(date, date) RETURNS integer AS $$
DECLARE
	cdays integer;
	mydays integer;
BEGIN
	cdays := 0;
	mydays := $2 - $1;

	FOR i IN 0..mydays LOOP
		IF not ((date_part('DOW', ($1 + i)) = 0) OR (date_part('DOW', ($1 + i)) = 6)) THEN
			cdays := cdays + 1;
		END IF;
	END LOOP;

	RETURN cdays;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION ins_sstudent( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	my_stud RECORD;
	my_rec RECORD;
	my_course RECORD;
	my_session RECORD;
	my_specialization RECORD;
	my_str VARCHAR(120);
	mydegree_id int;
	credit_count real;
	my_currs int;
	my_study_level int;
	my_sresident_id int;
	my_late_fees real;
	my_curr_balance real;
	my_narrative VARCHAR(120);


BEGIN
	SELECT INTO my_stud on_probation, see_registrar, sponsor_id,
		curr_balance, account_number
	FROM students
	WHERE (student_id = $2);
	
	mydegree_id := get_student_degree_id($2);
	my_study_level := get_study_level(mydegree_id);

	SELECT  min_level, max_level INTO my_specialization FROM
	specializations INNER JOIN student_specializations ON specializations.specialization_id = student_specializations.specialization_id
	WHERE (student_specializations.student_degree_id = mydegree_id);

	SELECT INTO my_rec sstudent_id FROM sstudents
	WHERE (student_degree_id = mydegree_id) AND (session_id = $1);

	SELECT INTO my_session slate_reg, slast_drop,  getchargedays(slate_reg, current_date) as late_days,

		session_id, substring(session_id from 11 for 1) as session
	FROM sessions WHERE (session_id = $1);

	
	IF (my_stud.curr_balance IS NOT NULL) THEN
		my_curr_balance := my_stud.curr_balance;

	END IF;

	my_late_fees := 0;
	my_narrative := '';


	IF (my_study_level is null) AND (my_specialization.min_level is not null) THEN
		my_study_level := my_specialization.min_level;
	ELSIF (my_study_level is null) THEN
		my_study_level := 100;
	ELSIF (substring($2 from 11 for 1) = '1') THEN
			my_study_level := my_study_level + 100;
	END IF;

	IF (my_specialization.max_level is not null) THEN
		IF (my_study_level > my_specialization.max_level) THEN
			my_study_level := my_specialization.max_level;
		END IF;
	ELSE
		IF (my_study_level > 500) THEN
			my_study_level := 500;
		END IF;
	END IF;

	IF (my_session.slast_drop < current_date) THEN
		my_str := 'The registration is closed for this session.';
	ELSIF (my_stud.on_probation = true) THEN
		my_str := 'Student on Probation cannot proceed.';
	ELSIF (my_stud.see_registrar = true) THEN
		my_str := 'Cannot Proceed, See Registars office.';
	ELSIF (my_stud.account_number IS NULL) THEN
		my_str := 'You must have an account number, contact Finance office.';
	ELSIF (mydegree_id IS NULL) THEN
		my_str := 'No Degree Indicated contact Registrars Office';
	
	ELSIF (my_rec.sstudent_id IS NULL) THEN
		
			INSERT INTO sstudents(session_id, student_degree_id, study_level, curr_balance, charges, finance_narrative, payment_type)
			VALUES ($1, mydegree_id, my_study_level, my_curr_balance, my_late_fees, my_narrative, 1);

			INSERT INTO sgrades(sstudent_id, scourse_id, hours, credit, approved)
			SELECT MAX(sstudent_id), scourse_id, getcoursehours(scourse_id), getcoursecredits(scourse_id), true
			FROM scourses
			INNER JOIN sstudents ON scourses.session_id=sstudents.session_id
			WHERE sstudents.session_id=$1
			GROUP BY scourse_id, getcoursehours(scourse_id), getcoursecredits(scourse_id);
			
		my_currs := get_sstudent_id($2);
		credit_count := 0;
		FOR my_course IN SELECT year_taken, course_id, min(scourse_id) as scourse_id, max(credit_hours) as credit_hours
			FROM vw_scourse_check_pass
			WHERE (elective = false) AND (course_passed = false) AND (prereq_passed = true)
				AND (year_taken <= (my_study_level/100)) AND (student_id = $2)
			GROUP BY year_taken, course_id
			ORDER BY year_taken, course_id
		LOOP
			
			
			
		END LOOP;
		
			IF(my_stud.sponsor_id<>1)THEN
			   my_str := 'Semester registered Attach Your Sponsorship Letter for Financial approval If you are not self sponsored';
			ELSE
			   my_str := 'Semester registered  waiting for approvals';
			END IF;
	ELSE		   
	
		my_str := 'Semester already registered';
	END IF;

    RETURN my_str;
END;
$$
  LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION open_scourse_department(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
BEGIN
	UPDATE scourses SET submit_grades = false
	WHERE (scourse_id = CAST($1 as int));
	
	RETURN 'Course opened for lecturer to correct';
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION open_scourse_department(VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
BEGIN
	UPDATE scourses SET lecture_submit = false
	WHERE (scourse_id = CAST($2 as int));

	RETURN 'Course opened for lecturer to correct';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sel_sresidence( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	mystr VARCHAR(120);
	my_rec RECORD;
	my_stud int;
	my_res int;
BEGIN
	my_stud := get_sstudent_id($2);
	my_res := $1::int;

	SELECT INTO my_rec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id=my_stud);

	IF (my_rec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSE IF (my_rec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sstudents SET sresidence_id = my_res WHERE (sstudent_id = my_stud);
		mystr := 'Residence registered awaiting approval';
	END IF;
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION upd_approve_grade(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	v_sgrade_id		integer;
	msg				varchar(240);
BEGIN
	SELECT sgrade_id INTO v_sgrade_id
	FROM sgrades
	WHERE (scourse_id = CAST($1 as int)) AND ((lecture_marks + lecture_cat_mark) > 100);

	IF(v_sgrade_id is null)THEN
		UPDATE sgrades SET final_marks = lecture_marks + lecture_cat_mark, grade_id = lecture_grade_id,
			sys_audit_trail_id = CAST($4 as int)
		WHERE (scourse_id = CAST($1 as int)) AND (lecture_grade_id <> 14);

		UPDATE scourses SET approved_grades = true, approve_date = now(), grade_submited = true
		WHERE (scourse_id = CAST($1 as int));

		msg := 'Grade Submitted to Registry Correctly';
	ELSE
		msg := 'Some marks add up to more than 100';
		RAISE EXCEPTION 'Some marks add up to more than 100';
	END IF;
	
	RETURN msg;
END;
$$
  LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION upd_approve_grade(VARCHAR(12), VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	v_sgrade_id		integer;
	msg				varchar(240);
BEGIN
	SELECT sgrade_id INTO v_sgrade_id
	FROM sgrades
	WHERE (scourse_id = CAST($1 as int)) AND ((lecture_marks + lecture_cat_mark) > 100);

	IF(v_sgrade_id is null)THEN
		UPDATE sgrades SET final_marks = lecture_marks + lecture_cat_mark, grade_id = lecture_grade_id,
			sys_audit_trail_id = CAST($4 as int)
		WHERE (scourse_id = CAST($1 as int)) AND (lecture_grade_id <> 14);

		UPDATE scourses SET approved_grades = true, approve_date = now(), grade_submited = true
		WHERE (scourse_id = CAST($1 as int));

		msg := 'Grade Submitted to Registry Correctly';
	ELSE
		msg := 'Some marks add up to more than 100';
		RAISE EXCEPTION 'Some marks add up to more than 100';
	END IF;
	
	RETURN msg;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION upd_scourse_grade(VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	v_sgrade_id		integer;
	msg				varchar(240);
BEGIN
	SELECT sgrade_id INTO v_sgrade_id
	FROM sgrades
	WHERE (scourse_id = CAST($1 as int)) AND ((lecture_marks + lecture_cat_mark) > 100);

	IF(v_sgrade_id is null)THEN
		UPDATE scourses SET submit_grades = true, submit_date = now()
		WHERE (scourse_id = CAST($1 as int));

		msg := 'Grade Submitted to Department Correctly';
	ELSE
		msg := 'Some marks add up to more than 100';
		RAISE EXCEPTION 'Some marks add up to more than 100';
	END IF;
	
	RETURN msg;
END;
$$ LANGUAGE plpgsql;
  
CREATE OR REPLACE FUNCTION upd_student_add( VARCHAR(12), VARCHAR(12), VARCHAR(12)) RETURNS VARCHAR(120)  AS $$
DECLARE
	mystr VARCHAR(50);
BEGIN

	mystr := upd_student_add();

	UPDATE students SET country_code_id = 'KE' WHERE country_code_id is null;
	UPDATE students SET g_country_code_id = 'KE' WHERE g_country_code_id is null;
	
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;
  


CREATE OR REPLACE FUNCTION change_student_id(varchar(50), varchar(50), varchar(50)) RETURNS varchar(120) AS $$
DECLARE
msg         	   varchar(250);
rec	    	       RECORD;
existingrec        RECORD;
v_entity_id        integer;

BEGIN
 SELECT current_id, new_id INTO rec 
 FROM student_id_change_list 
 WHERE student_id_change_list_id=$1::int;

 SELECT student_id, student_name INTO existingrec
 FROM students 
 WHERE student_id=rec.new_id;
 
 IF(rec.new_id IS NULL)THEN 
 msg:='You cannot change Student: '||rec.current_id||' To null, you must add a valid student id';
 ELSIF(existingrec IS NOT NULL)THEN
 msg:='A student with ID '||existingrec.student_id||', '||existingrec.student_name|| ' exists you cannot have duplicates,
  you can alternatively change the id now added in the list';
 INSERT INTO student_id_change_list(org_id, current_id,	narrative)
 VALUES(0, existingrec.student_id, 'There will be a duplicate in this id due to changes in another id, you have to change this one first');
 ELSE

    ALTER TABLE student_scharges DROP CONSTRAINT student_scharges_student_id_fkey;
    UPDATE student_scharges 
    SET student_id=rec.new_id 
    WHERE student_id=rec.current_id;

    ALTER TABLE approval_list DROP CONSTRAINT approval_list_student_id_fkey;
    UPDATE approval_list 
    SET student_id=rec.new_id 
    WHERE student_id=rec.current_id;
 
    ALTER TABLE student_requests DROP CONSTRAINT student_requests_student_id_fkey;
    UPDATE student_requests 
    SET student_id=rec.new_id 
    WHERE student_id=rec.current_id;

    ALTER TABLE student_degrees DROP CONSTRAINT student_degrees_student_id_fkey;
    UPDATE student_degrees 
    SET student_id=rec.new_id 
    WHERE student_id=rec.current_id;

    
    UPDATE entitys 
    SET user_name=rec.new_id 
    WHERE user_name=rec.current_id;

    ALTER TABLE student_id_change_list DROP CONSTRAINT student_id_change_list_current_id_fkey;
    UPDATE student_id_change_list
    SET current_id=rec.new_id, narrative='Student id has been successfully changed', changed=TRUE 
    WHERE current_id=rec.current_id;
    
    UPDATE students 
    SET student_id=rec.new_id 
    WHERE student_id=rec.current_id;

  ALTER TABLE student_scharges
  ADD CONSTRAINT student_scharges_student_id_fkey FOREIGN KEY (student_id)
  REFERENCES students (student_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
  ALTER TABLE approval_list
  ADD CONSTRAINT approval_list_student_id_fkey FOREIGN KEY (student_id)
  REFERENCES students (student_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
  ALTER TABLE student_requests
  ADD CONSTRAINT student_requests_student_id_fkey FOREIGN KEY (student_id)
  REFERENCES students (student_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
  ALTER TABLE student_degrees
  ADD CONSTRAINT student_degrees_student_id_fkey FOREIGN KEY (student_id)
  REFERENCES students (student_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
  ALTER TABLE student_id_change_list
  ADD CONSTRAINT student_id_change_list_student_id_fkey FOREIGN KEY (current_id)
  REFERENCES students (student_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

   msg:='ID Succesfully changed';
    
END IF;
RETURN msg;
END;
$$LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION apply_for_id_change(varchar(50), varchar(50), varchar(50)) RETURNS varchar(120) AS $$
DECLARE
msg         	   varchar(250);
rec	    	       RECORD;
existingrec        RECORD;

BEGIN
 SELECT current_id, new_id INTO rec 
 FROM student_id_change_list 
 WHERE student_id_change_list_id=$1::int;

 SELECT student_id, student_name INTO existingrec
 FROM students 
 WHERE student_id=rec.new_id;
 
 IF(rec.new_id IS NULL)THEN 
 msg:='You cannot change Student: '||rec.current_id||' To null, you must add a valid student id';
 ELSIF(existingrec IS NOT NULL)THEN
 msg:='A student with ID '||existingrec.student_id||', '||existingrec.student_name|| ' exists you cannot have duplicates,
  you can alternatively change the id now added in the list';
 INSERT INTO student_id_change_list(org_id, current_id,	narrative)
 VALUES(0, existingrec.student_id, 'There will be a duplicate in this id due to changes in another id, you have to change this one first');
 ELSE
  UPDATE student_id_change_list SET applied=true, narrative='Applied, waiting for change'
  WHERE student_id_change_list_id=$1::int;
  msg:='applied waiting for change...';
END IF;
RETURN msg;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_from_list(varchar(50), varchar(50), varchar(50)) RETURNS varchar(120) AS $$
DECLARE
msg         	   varchar(250);
BEGIN
 DELETE FROM student_id_change_list 
 WHERE student_id_change_list_id=$1::int;
 msg:='Removed from list';
RETURN msg;
END;
$$LANGUAGE plpgsql;
