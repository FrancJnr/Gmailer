

CREATE TABLE applications (
	application_id			serial primary key,
	org_id					integer references orgs default 0,
	session_id 			    varchar(12),
	entity_id 				integer references entitys,
	surname					varchar(50) not null,
	middle_name				varchar(50),
	first_name				varchar(50) not null,
    primary_telephone 		varchar(50),
	email					varchar(120) not null,
	finance_approved        boolean NOT NULL DEFAULT false,
	status 					varchar(12) default 'pending',
	open_application		boolean default false not null,
	closed					boolean default false not null,
	emailed					boolean default false not null,
	paid					boolean default false not null,
	receipt_number			varchar(50),
	confirmation_no			varchar(75),
	application_date    	date default current_date not null,
	Picked					boolean default false not null,
	picked_date				timestamp,
	pay_date				timestamp,
	e_amount				real,
	success					varchar(50),
	payment_code			varchar(50),
	trans_no				varchar(50),
	terminal_id				varchar(16),
	transaction_id			integer,
	card_type				varchar(50),
	paid_time				timestamp,
	is_sponsored  			boolean default false,
	paypal_response 		text,
	form_data 				text,
	narrative				varchar(240),
	UNIQUE(email,org_id)
);

CREATE INDEX applications_session_id ON applications (session_id);
CREATE INDEX applications_org_id ON applications (org_id);
CREATE INDEX applications_entity_id ON applications (entity_id);


---define the status of admission for admitted students
CREATE TABLE admission_status(
	admission_status_id		serial primary key,
	org_id 					integer references orgs,
	admission_status_name	varchar(50),
	description				text

);
CREATE INDEX admission_status_org_id ON admission_status (org_id);

CREATE TABLE admission_basis(
    admission_basis_id	    serial primary key,
    student_id		        varchar(50) references students,
    org_id 					integer references orgs,
    admission_basis		    varchar(120),
    details			        text
);
CREATE INDEX admission_basis_org_id ON admission_basis(org_id);
CREATE INDEX admission_basis_student_id ON admission_basis(student_id);

---records of approved applications
CREATE TABLE registrations (
	registration_id			serial primary key,
	application_id 			integer references applications,
	degree_id				varchar(12) references degrees,
	org_id					integer references orgs,
	sponsor_id 				integer	references sponsors,
	nationality_id			char(2) references sys_countrys,
	denomination_id			varchar(12) references denominations,
	site_id					varchar(12) references sites,
	admission_status_id     integer references admission_status default 1,
	specialization_id       integer references specializations,
	home_address			text,
	phone_number			varchar(50),
	address					varchar(240),
	zip_code				varchar(50),
	town					varchar(50),
	birth_date				date not null,
	gender					varchar(12),
	mobile_number			varchar(50),
	marital_status			varchar(12),
	next_of_kin				varchar(50),
	kin_relationship		varchar(50),
	existing_id				varchar(12),
	application_date    	date not null default current_date,
	submit_date				timestamp,
	is_accepted				boolean default false not null,
	accepted_date 			TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	rejected_on 			timestamp,  
	deferred_on 			timestamp,
	is_reported				boolean default false not null,
	is_deferred				boolean default false not null,
	is_rejected				boolean default false not null,
	evaluation_date			date,
	off_campus				boolean default false not null,
	picture_file			varchar(240),
	account_number			varchar(50),
	details					text,
	
	UNIQUE (org_id,application_id)
);

CREATE INDEX registrations_nationality_id ON registrations (nationality_id);
CREATE INDEX registrations_denomination_id ON registrations (denomination_id);
CREATE INDEX registrations_degree_id ON registrations (degree_id);
CREATE INDEX registrations_site_id ON registrations (site_id);
CREATE INDEX registrations_admission_status_id ON registrations (admission_status_id);
CREATE INDEX registrations_specialization_id ON registrations (specialization_id);
CREATE INDEX registrations_org_id ON registrations (org_id);

--provision for students to add missing sponsors
CREATE TABLE non_existing_sponsors(
	non_existing_sponsor_id	 serial primary key,
	org_id					 integer references orgs,
	application_id         	 integer references applications,
	sponsoring_divison 		 varchar(120),
	sponsoring_organisation	 varchar(120),
	sponsor_country			 varchar(50),
	sponsor_email			 varchar(50),
	sponsor_address			 varchar(120),
	added					 boolean default false
	
);
CREATE INDEX non_existing_sponsors_org_id  ON non_existing_sponsors(org_id);
CREATE INDEX non_existing_sponsors_application_id  ON non_existing_sponsors(application_id);

CREATE OR REPLACE VIEW vw_applications AS
SELECT entitys.entity_id, entitys.entity_name,  sessions.session_id,
	 sessions.session_name, applications.surname, applications.middle_name, applications.first_name, 
	 applications.email, applications.finance_approved, applications.open_application, applications.closed, applications.emailed, 
	 applications.paid, applications.receipt_number, applications.confirmation_no,  
	 applications.application_date, applications.picked, applications.picked_date, applications.pay_date, applications.e_amount, 
	 applications.success, applications.payment_code, applications.trans_no, applications.card_type, applications.terminal_id, 
	 applications.transaction_id,  applications.paid_time, applications.narrative, 
	 applications.primary_telephone, applications.application_id, applications.status, applications.is_sponsored, applications.form_data
	FROM applications
	INNER JOIN entitys ON applications.entity_id = entitys.entity_id
	LEFT JOIN sessions ON applications.session_id = sessions.session_id;

CREATE OR REPLACE VIEW vw_registrations AS 
 SELECT DISTINCT vw_applications.entity_id,
    vw_applications.entity_name,vw_applications.session_id, vw_applications.session_name,vw_applications.surname, vw_applications.middle_name,
    vw_applications.first_name,  vw_applications.email, vw_applications.finance_approved, vw_applications.open_application, vw_applications.closed,
    vw_applications.emailed, vw_applications.paid, vw_applications.receipt_number, vw_applications.confirmation_no, 
     vw_applications.application_date, vw_applications.picked, vw_applications.picked_date, vw_applications.pay_date,
    vw_applications.e_amount, vw_applications.success, vw_applications.payment_code,  vw_applications.trans_no, vw_applications.card_type,  vw_applications.terminal_id,
    vw_applications.transaction_id,    vw_applications.paid_time,  vw_applications.narrative,  vw_applications.primary_telephone,
    vw_applications.application_id,  vw_applications.status,  vw_applications.is_sponsored,  denominations.denomination_id,  denominations.denomination_name,
    a.sys_country_id,  a.sys_country_name,  registrations.registration_id,  registrations.home_address,
    registrations.phone_number,  registrations.address,  registrations.zip_code,  registrations.town,  registrations.birth_date,
    registrations.gender,registrations.mobile_number, registrations.nationality_id, registrations.marital_status, registrations.next_of_kin,
    registrations.kin_relationship, registrations.existing_id, registrations.submit_date,registrations.is_accepted, registrations.is_reported,
    registrations.is_deferred, registrations.is_rejected, registrations.evaluation_date,  registrations.off_campus,
    registrations.picture_file,  registrations.account_number,   registrations.details, registrations.degree_id,  registrations.sponsor_id,
    registrations.accepted_date,   registrations.site_id,   registrations.admission_status_id,
    admission_status.admission_status_name,   registrations.deferred_on,  registrations.rejected_on,  registrations.specialization_id,
    '<a href="a_view_applications.jsp?'|| '&registration_id=' ||  registrations.registration_id || 
         '" target="_blank"><IMG SRC="resources/images/link.png" width=40 height=30 alt="View Report"></a>'
         AS report , vw_applications.form_data, 
         CASE WHEN gender='M' then 'MALE'
		WHEN gender='F' then 'FEMALE'
		WHEN gender='N' then 'N/A'
		END AS sex,
	CASE WHEN registrations.marital_status='M' then 'MARRIED'
		WHEN registrations.marital_status='S' then 'SINGLE'
		WHEN registrations.marital_status='' then 'N/A'
		END AS marital
   FROM registrations
     INNER JOIN vw_applications ON registrations.application_id = vw_applications.application_id
     INNER JOIN degrees ON registrations.degree_id::text = degrees.degree_id::text
     INNER JOIN denominations ON registrations.denomination_id::text = denominations.denomination_id::text
     INNER JOIN admission_status ON registrations.admission_status_id = admission_status.admission_status_id
     LEFT JOIN sys_countrys a ON registrations.nationality_id = a.sys_country_id;

	
	
CREATE OR REPLACE VIEW vw_non_existing_sponsors AS
	SELECT non_existing_sponsors.non_existing_sponsor_id, non_existing_sponsors.sponsoring_divison, non_existing_sponsors.sponsoring_organisation, 
	non_existing_sponsors.sponsor_country, non_existing_sponsors.sponsor_email, non_existing_sponsors.sponsor_address, vw_applications.surname,
	 vw_applications.middle_name, vw_applications.first_name, vw_applications.email, non_existing_sponsors.org_id, non_existing_sponsors.added
	FROM non_existing_sponsors
	INNER JOIN vw_applications ON non_existing_sponsors.application_id=vw_applications.application_id;

	
	
CREATE OR REPLACE FUNCTION bf_application()
  RETURNS trigger AS $$
DECLARE
v_entity_id		integer;
BEGIN
	IF(TG_OP='INSERT') THEN
		IF(NEW.email IN (SELECT user_name FROM entitys)) THEN
			RAISE EXCEPTION 'Email Already Exists Check your email for login password';
		ELSE
			v_entity_id := nextval('entitys_entity_id_seq');
	
			INSERT INTO entitys(entity_id, entity_type_id, use_key_id, org_id, entity_name, user_name, primary_email, primary_telephone)
			VALUES(v_entity_id, 4, 4, 0, NEW.surname || ' ' || NEW.middle_name || ' ' || NEW.first_name, NEW.email, NEW.email, NEW.primary_telephone);
			NEW.entity_id := v_entity_id;
		
		END IF;
	END IF;
	RETURN NEW;
END;
$$
  LANGUAGE plpgsql;
 
CREATE TRIGGER bf_application
  BEFORE INSERT OR UPDATE
  ON applications
  FOR EACH ROW
  EXECUTE PROCEDURE bf_application();
 


CREATE OR REPLACE FUNCTION aft_close() RETURNS TRIGGER AS $$

DECLARE 
v_application_id	integer;
declare_agree  VARCHAR(12); msg VARCHAR(12); gender text; marital_status   text; dob text;
nationality      text; permanent_address text; disability text; accomodation  text;
passport_id_no  text; disability_bool  text; current_address  text; degree   text; sponsored  text;
submitted     boolean; sponsor_id  text; denomination text; v_sponsor_id   text; v_off_campus boolean; v_site text;
v_pgs text; v_thsm text; v_specialization_id text; v_other_sponsors text; v_sponsoring_organisation text; v_organisation_email text;
v_organisation_country text; v_organisation_address text; v_organisation_division text;
BEGIN

	v_application_id:= NEW.application_id;
	SELECT form_data::json ->>'declare_agree' INTO   declare_agree 
	FROM applications
	WHERE application_id=v_application_id;

	IF(declare_agree='on')THEN
	msg:='on';
	UPDATE applications SET closed=true
	WHERE application_id=v_application_id;
	
	SELECT form_data::json ->>'gender' FROM applications INTO gender WHERE application_id=v_application_id;
	SELECT form_data::json ->>'marital_status' FROM applications  INTO   marital_status WHERE application_id=v_application_id; 
	SELECT form_data::json ->>'denomination' FROM applications  INTO   denomination WHERE application_id=v_application_id;
	SELECT form_data::json ->>'dob' FROM applications  INTO   dob WHERE application_id=v_application_id;
	SELECT form_data::json ->>'nationality' FROM applications  INTO   nationality WHERE application_id=v_application_id; 
	SELECT form_data::json ->>'passport_id_no' FROM applications  INTO   passport_id_no WHERE application_id=v_application_id;
	SELECT form_data::json ->>'disability_bool' FROM applications  INTO   disability_bool WHERE application_id=v_application_id; 
	SELECT form_data::json ->>'disability' FROM applications  INTO   disability WHERE application_id=v_application_id; 
	SELECT form_data::json ->>'current_address' FROM applications  INTO   current_address WHERE application_id=v_application_id;  
	SELECT form_data::json ->>'permanent_address' FROM applications  INTO   permanent_address WHERE application_id=v_application_id;   
	SELECT form_data::json ->>'pgs' FROM applications  INTO v_pgs WHERE application_id=v_application_id;
	SELECT form_data::json ->>'thsm' FROM applications INTO v_thsm  WHERE  application_id=v_application_id;
	SELECT form_data::json ->>'accomodation' FROM applications  INTO   accomodation WHERE application_id=v_application_id;
	SELECT form_data::json ->>'sponsored' FROM applications  INTO   sponsored WHERE application_id=v_application_id;
	SELECT form_data::json ->>'sponsores' FROM applications  INTO   sponsor_id WHERE application_id=v_application_id;
	SELECT form_data::json ->>'campus_site' FROM applications  INTO   v_site WHERE application_id=v_application_id;
	SELECT form_data::json ->>'other_sponsors' FROM applications  INTO   v_other_sponsors WHERE application_id=v_application_id;
	SELECT form_data::json ->>'special' FROM applications  INTO   v_specialization_id WHERE application_id=v_application_id;
	SELECT form_data::json ->>'org_name' FROM applications  INTO   v_sponsoring_organisation WHERE application_id=v_application_id;
	SELECT form_data::json ->>'org_email' FROM applications  INTO   v_organisation_email WHERE application_id=v_application_id;
	SELECT form_data::json ->>'org_country' FROM applications  INTO   v_organisation_country WHERE application_id=v_application_id;
	SELECT form_data::json ->>'org_address' FROM applications  INTO   v_organisation_address WHERE application_id=v_application_id;
	SELECT form_data::json ->>'org_sponsoring_division' FROM applications  INTO   v_organisation_division WHERE  application_id=v_application_id;
	
	IF(sponsored='Y')THEN
		IF((sponsor_id IS NOT NULL) AND (SELECT NULLIF(sponsor_id, '') ) !='' AND sponsor_id != '1')THEN
		
		v_sponsor_id:=(SELECT NULLIF(sponsor_id, ''));
		ELSE 
		   IF((v_sponsoring_organisation IS NOT NULL) AND (SELECT NULLIF(v_sponsoring_organisation, '')) != '')THEN
				INSERT INTO non_existing_sponsors(org_id, application_id, sponsoring_divison, sponsoring_organisation, sponsor_country, sponsor_email, sponsor_address)
				VALUES(0, v_application_id, v_organisation_division, v_sponsoring_organisation, v_organisation_country, v_organisation_email, v_organisation_address);
			ELSE RAISE EXCEPTION 'If you are sponsored you must indicate the sponsor';
			END IF;
		  END IF;
	ELSE IF(sponsored='N')THEN
	v_sponsor_id:=1;
	END IF;
	END IF;

	IF(accomodation='Y')THEN
	v_off_campus:=false;
	ELSE IF(accomodation='N')THEN
	v_off_campus:=true;
	END IF;
	END IF;

	IF((v_pgs = '') )THEN
	degree:=v_thsm;
	ELSE IF((v_thsm = '') )THEN
	degree:=v_pgs;
	ELSE 
	RAISE EXCEPTION 'NO DEGREE SELECTED';
	END IF;
	END IF;
	
	
	INSERT INTO registrations(application_id, degree_id,  org_id,  
	address, home_address, birth_date, gender, denomination_id, marital_status,  off_campus, sponsor_id, nationality_id, site_id, specialization_id)
	VALUES(v_application_id::int , degree ,0, 
	current_address, permanent_address, dob::date, gender, denomination, marital_status,  v_off_campus, 1, nationality, v_site, v_specialization_id::int );
	msg:='inserted';
	END IF;
	
	
RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER aft_close
AFTER INSERT OR UPDATE OF form_data ON applications
FOR EACH ROW EXECUTE PROCEDURE aft_close();


CREATE OR REPLACE FUNCTION approve(varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	msg					varchar(120);
	rec					RECORD;
BEGIN
	SELECT paid, is_sponsored INTO rec 
	FROM applications
	WHERE application_id=$1::int;

	IF(rec.is_sponsored=false AND rec.paid=false) THEN
	msg:='The student has not paid application fees you cannot make the approval';
	ELSE
	UPDATE applications 
	SET finance_approved=true,
	narrative='You have been approved to continue with the application',
	status='approved'
	WHERE application_id=$1::int;
	msg:='The student has been approved';	
	END IF;
    RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION revoke_approval(varchar(12),varchar(12),varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	msg					varchar(120);
BEGIN

	UPDATE applications SET finance_approved=false,
	narrative='Your application has been revoked:',
	status='revoked'
	WHERE application_id=$1::int;
	msg:='The student approval has been revoked';	
	
    RETURN msg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION reject_application(varchar(12),varchar(12),varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	msg					varchar(120);
	
BEGIN
	UPDATE applications 
	SET narrative='Your application has been rejected:',
	status='rejected'
	WHERE application_id=$1::int;
	msg:='The student approval has been rejected';	
	
    RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_sponsor(varchar(12),varchar(12),varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	msg						varchar(120);
	v_sponsor_type_id		integer;
	rec 				    RECORD;
	
	
BEGIN

	SELECT * INTO rec FROM non_existing_sponsors WHERE non_existing_sponsor_id=$1::int;
	
	
	with v_sponsor_types as (
		INSERT INTO sponsor_types (org_id, sponsor_type_name) 
		VALUES(0,rec.sponsoring_divison)
		RETURNING sponsor_type_id
	)

		INSERT INTO sponsors (sponsor_type_id, org_id, sponsor_name, address, street, postal_code, town, telno, email,  sponsor_category_id, active)
		VALUES ((select sponsor_type_id from v_sponsor_types),0,rec.sponsoring_organisation, rec.sponsor_address,'','','','',rec.sponsor_email, 2, TRUE);
	
	msg:='Sponsor added';
    RETURN msg;
END;
$$ LANGUAGE plpgsql;





