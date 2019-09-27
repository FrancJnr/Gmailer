-----add presession------------
CREATE OR REPLACE FUNCTION add_pre_ssesion() RETURNS TRIGGER AS $$
DECLARE
msg		VARCHAR(50);
rec_cohort	RECORD;

BEGIN
SELECT cohort_id, start_date, site_id, end_date, cohort_open INTO rec_cohort
	FROM cohorts;

IF(TG_OP='INSERT') THEN
	IF((NEW.session_start<rec_cohort.start_date AND NEW.cohort_id=rec_cohort.cohort_id) OR (NEW.session_start>rec_cohort.end_date AND NEW.cohort_id=rec_cohort.cohort_id))THEN
	RAISE EXCEPTION 'The session is beyond the cohort date range i.e';

	ELSE
	NEW.session_year=EXTRACT(YEAR FROM NEW.session_start);
	END IF;

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_pre_session
BEFORE INSERT OR UPDATE ON sessions
FOR EACH ROW EXECUTE PROCEDURE add_pre_ssesion();

--create login credentials for instructors---
CREATE OR REPLACE FUNCTION aft_instructors()
  RETURNS trigger AS
$$
DECLARE
    v_role        varchar(240);
    v_no_org    boolean;
    v_instructor_id    varchar(50);
BEGIN
    
    IF(TG_OP = 'INSERT')THEN
    
        INSERT INTO entitys (org_id, entity_type_id,  user_name, entity_name, Entity_Leader, Super_User, no_org, primary_email, function_role)
        VALUES (NEW.org_id, 8,  NEW.instructor_id, NEW.instructor_name, false, false, false, NEW.email, 'lecturer');
    ELSE
        UPDATE entitys SET function_role = v_role, no_org = v_no_org WHERE user_name = NEW.instructorid;
    END IF;

    RETURN NEW;
END;
$$
  LANGUAGE plpgsql;

--DROP TRIGGER aft_instructors ON instructors;
  CREATE TRIGGER aft_instructors
AFTER INSERT OR UPDATE ON instructors
FOR EACH ROW EXECUTE PROCEDURE aft_instructors();  

  
CREATE OR REPLACE FUNCTION bf_add_charge() RETURNS trigger AS $$
DECLARE
v_fees		             real;
v_scharge_id	         integer;
rec		                 RECORD;
v_existing	             RECORD;
BEGIN
    IF(TG_OP='INSERT')THEN

    v_scharge_id := nextval('scharges_scharge_id_seq');

    NEW.scharge_id:=v_scharge_id;


    SELECT  sstudents.session_id, sponsor_id, wage_factor, sponsor_country_id INTO rec
    FROM vw_student_degrees 
    INNER JOIN sstudents ON sstudents.student_degree_id=vw_student_degrees.student_degree_id
    WHERE sstudents.student_degree_id=NEW.student_degree_id;

    IF (rec.sponsor_id NOT IN (SELECT sponsor_id FROM scharges WHERE session_id=rec.session_id AND sponsor_country=rec.sponsor_country_id )) THEN 

    INSERT INTO scharges(scharge_id,org_id,sponsor_id,sponsor_country, wage_factor)
    VALUES (v_scharge_id,  0, rec.sponsor_id, rec.sponsor_country_id, rec.wage_factor);

    END IF;	
    END IF;	
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_charge
  BEFORE INSERT OR UPDATE
  ON sstudents
  FOR EACH ROW
  EXECUTE PROCEDURE bf_add_charge();

  /*
CREATE OR REPLACE FUNCTION compute_scharges() RETURNS trigger AS $$
DECLARE
	msg					varchar(120);
	rec 				RECORD;
	scharge_rec			RECORD;
	my_credits			real;
	v_fees				real;
BEGIN 	
	IF(TG_OP='INSERT')THEN
		SELECT vw_students.student_id, vw_students.sponsor_id, vw_students.sponsor_type_id, vw_students.wage_factor INTO rec
		FROM vw_students
		INNER JOIN student_degrees ON student_degrees.student_id=vw_students.student_id
		WHERE student_degree_id= NEW.student_degree_id;

		SELECT scharge_id, fees, session_active, session_closed, lab_charges, exam_fees, general_fees, degree_level_id,
		residence_stay INTO scharge_rec
		FROM scharges
		WHERE session_id=NEW.session_id;
		IF(scharge_rec.scharge_id is null)THEN
		    RAISE EXCEPTION 'Charges For this session have not been set';
		END IF;
		IF(rec.sponsor_type_id<>1)THEN
			my_credits:=get_cumm_credit(NEW.student_degree_id, NEW.session_id);
			
			v_fees:=0.15*my_credits*rec.wage_factor;

			INSERT INTO student_scharges(student_id,scharge_id,fees)
			VALUES(rec.student_id,scharge_rec.scharge_id,v_fees);
		ELSE
				v_fees:=scharge_rec.lab_charges+scharge_rec.exam_fees+scharge_rec.general_fees;
				
				INSERT INTO student_scharges(student_id,scharge_id,fees)
				VALUES(rec.student_id,scharge_rec.scharge_id,v_fees);
		END IF;
				
		
	END IF;
			

	RETURN NEW;
		
END;
$$ LANGUAGE plpgsql;
  */
CREATE OR REPLACE FUNCTION ins_cohort_name() RETURNS trigger AS $$
DECLARE 
	rec		RECORD;			  
BEGIN

IF(TG_OP='INSERT') THEN
	SELECT degree_name INTO rec FROM degrees
	WHERE degree_id=NEW.degree_id;
	
	NEW.cohort_name:=rec.degree_name||'('||NEW.site_id||')';
	
END IF;
 RETURN NEW;
END;
$$  LANGUAGE plpgsql;

CREATE TRIGGER ins_cohort_name
  BEFORE INSERT OR UPDATE
  ON cohorts
  FOR EACH ROW
  EXECUTE PROCEDURE ins_cohort_name();
  
  
CREATE OR REPLACE FUNCTION ins_scourse() RETURNS trigger AS $$
DECLARE
	
	myrec RECORD;
	mystr VARCHAR(120);
	v_scourse_id  integer;   
BEGIN

	SELECT scourse_id INTO v_scourse_id
	FROM scourses 
	WHERE session_id=NEW.session_id;

	SELECT sgrades.sgrade_id, sstudents.sstudent_id, sgrades.scourse_id, dropped, scourses.session_id INTO myrec
	FROM sgrades 
	INNER JOIN sstudents ON sgrades.sstudent_id=sstudents.sstudent_id
	INNER JOIN scourses ON scourses.scourse_id=sgrades.scourse_id
	WHERE sstudents.session_id=NEW.session_id AND sstudents.sstudent_id=NEW.sstudent_id;
	
	IF(v_scourse_id IS NULL) THEN
	RAISE EXCEPTION 'There are no available courses for %', NEW.session_id;
	ELSE IF(myrec.dropped=false)THEN
	RAISE EXCEPTION 'Courses for this session has already been registered you can request to drop if you have not';
	ELSE IF(myrec IS NULL) THEN
	INSERT INTO sgrades(sstudent_id, scourse_id, hours, credit, approved) VALUES (NEW.sstudent_id, v_scourse_id, getcoursehours(v_scourse_id::int), getcoursecredits(v_scourse_id::int), true);
	mystr := 'Course registered awaiting approval';
	ELSE
	UPDATE sgrades SET dropped=false, ask_drop=false, approved=false, hours=getcoursehours(v_scourse_id::int), credit=getcoursecredits(v_scourse_id::int) 
	WHERE sgrade_id = myrec.sgrade_id;
	mystr := 'Course registered awaiting approval';
	END IF;
   END IF;
END IF;
RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

--CREATE TRIGGER ins_scourse
--AFTER INSERT OR UPDATE ON sstudents
--FOR EACH ROW EXECUTE PROCEDURE ins_scourse();

  
CREATE OR REPLACE FUNCTION ins_students() RETURNS trigger AS $$
DECLARE
	v_entity_id		integer;
	v_student_name		VARCHAR(120);
BEGIN

	SELECT entity_id INTO v_entity_id
	FROM entitys
	WHERE (user_name = upper(trim(NEW.student_id)));

	v_student_name:=(SELECT CONCAT(NEW.surname,' , ', NEW.other_names,' ', NEW.first_name));
	NEW.student_name:=UPPER(v_student_name);
	IF(v_entity_id is null)THEN
		IF(NEW.student_name is null) THEN
			INSERT INTO entitys (org_id, entity_type_id, use_key_id, entity_name, user_name, primary_email)
			VALUES(0, 7, 7, v_student_name, upper(trim(NEW.student_id)), NEW.email);
		ELSE 
			INSERT INTO entitys (org_id, entity_type_id, use_key_id, entity_name, user_name, primary_email)
			VALUES(0, 7, 7, NEW.student_name, upper(trim(NEW.student_id)), NEW.email);
		END IF;
	END IF;
	
	IF(NEW.identification_no is null)THEN
		NEW.student_edit := 'allow';
	ELSIF(NEW.email is null)THEN
		NEW.student_edit := 'allow';
	ELSIF((NEW.address is null) OR (NEW.town is null) OR (NEW.country_code_id is null) OR (NEW.tel_no is null) ) THEN
		NEW.student_edit := 'allow';

	ELSIF(NEW.nationality is null) THEN
		NEW.student_edit := 'allow';
	ELSIF(NEW.disability is null) THEN
		NEW.student_edit := 'allow';
	ELSE
		NEW.student_edit := 'none';
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_students
  BEFORE INSERT OR UPDATE
  ON students
  FOR EACH ROW
  EXECUTE PROCEDURE ins_students();
  

  
CREATE OR REPLACE FUNCTION upd_cohort_courses() RETURNS trigger AS $$
DECLARE
rec	RECORD;

BEGIN
SELECT course_id,cohort_courses.cohort_id,session_id,cohort_name INTO rec
FROM cohort_courses
INNER JOIN cohorts ON cohorts.cohort_id=cohort_courses.cohort_id;
IF((NEW.course_id=rec.course_id) AND (NEW.cohort_id=rec.cohort_id) AND (NEW.session_id=rec.session_id))
	THEN
	 RAISE unique_violation USING MESSAGE = rec.course_id||' is already registered for ' || rec.cohort_name;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_courses BEFORE INSERT OR UPDATE
ON cohort_courses FOR EACH ROW EXECUTE PROCEDURE upd_cohort_courses();

CREATE OR REPLACE FUNCTION add_access_matrix() RETURNS TRIGGER AS $$
DECLARE
access          integer;
BEGIN
IF(TG_OP='INSERT')THEN
IF(NEW.can_delete=true)THEN
 NEW.access_matrix:= ARRAY[7, 7, 7];
 ELSIF(NEW.can_modify=true)THEN
 NEW.access_matrix:= ARRAY[0, 7, 7];
 ELSIF(NEW.can_read=true)THEN
 NEW.access_matrix:= ARRAY[0, 0, 7];
 END IF;
END IF;
RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_access_matrix
BEFORE INSERT OR UPDATE ON sys_access_rights
FOR EACH ROW EXECUTE PROCEDURE add_access_matrix();
