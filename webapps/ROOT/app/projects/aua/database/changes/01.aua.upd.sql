ALTER TABLE students ADD old_student_id varchar(12);

-- Change a students ID Number
CREATE OR REPLACE FUNCTION change_student_id(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	myrec RECORD;
	myreca RECORD;
	myrecb RECORD;
	myrecc RECORD;
	myqtr RECORD;
	newid VARCHAR(12);
	mystr VARCHAR(120);
BEGIN
	IF($2 is null) THEN 
		newid := $3 || substring($1 from 3 for 5);
	ELSE
		newid := $2;
	END IF;
	
	SELECT INTO myrec studentid, studentname FROM students WHERE (studentid = newid);
	SELECT INTO myreca studentdegreeid, studentid FROM studentdegrees WHERE (studentid = $2);
	SELECT INTO myrecb studentdegreeid, studentid FROM studentdegrees WHERE (studentid = $1);
	SELECT INTO myrecc a.studentdegreeid, a.sessionid FROM
	((SELECT studentdegreeid, sessionid FROM sstudents WHERE studentdegreeid = myreca.studentdegreeid)
	EXCEPT (SELECT studentdegreeid, sessionid FROM sstudents WHERE studentdegreeid = myrecb.studentdegreeid)) as a;
	
	IF ($1 = $2) THEN
		mystr := 'That the same ID no change';
	ELSIF (myrecc.sessionid IS NOT NULL) THEN
		mystr := 'Conflict in session ' || myrecc.sessionid;
	ELSIF (myreca.studentdegreeid IS NOT NULL) AND (myrecb.studentdegreeid IS NOT NULL) THEN
		UPDATE sstudents SET studentdegreeid = myreca.studentdegreeid WHERE studentdegreeid = myrecb.studentdegreeid;
		UPDATE studentrequests SET studentid = $2 WHERE studentid = $1;
		DELETE FROM studentmajors WHERE studentdegreeid = myrecb.studentdegreeid;
		DELETE FROM studentdegrees WHERE studentdegreeid = myrecb.studentdegreeid;
		DELETE FROM students WHERE studentid = $1;	
		mystr := 'Changes to ' || $2;
	ELSIF (myrec.studentid is not null) THEN
		UPDATE studentdegrees SET studentid = $2 WHERE studentid = $1;
		UPDATE studentrequests SET studentid = $2 WHERE studentid = $1;
		DELETE FROM students WHERE studentid = $1;
		mystr := 'Changes to ' || $2;
	ELSIF ($2 is null) THEN
		DELETE FROM studentdegrees WHERE studentid is null;
		UPDATE studentdegrees SET studentid = null WHERE studentid = $1;
		UPDATE studentrequests SET studentid = null WHERE studentid = $1;
		
		UPDATE students SET studentid = newid, old_student_id = $1
		WHERE studentid = $1;
		UPDATE studentdegrees SET studentid = newid WHERE studentid is null;
		UPDATE studentrequests SET studentid = newid WHERE studentid is null;
		UPDATE entitys SET user_name = newid WHERE user_name = $1;
		mystr := 'Changes to ' || newid;
	ELSIF ($2 is not null) AND (newid is not null) THEN
		DELETE FROM studentdegrees WHERE studentid is null;
		UPDATE studentdegrees SET studentid = null WHERE studentid = $1;
		UPDATE studentrequests SET studentid = null WHERE studentid = $1;
		
		UPDATE students SET studentid = newid, old_student_id = $1
		WHERE studentid = $1;
		UPDATE studentdegrees SET studentid = newid WHERE studentid is null;
		UPDATE studentrequests SET studentid = newid WHERE studentid is null;
		UPDATE entitys SET user_name = newid WHERE user_name = $1;
		mystr := 'Changes to ' || newid;
	END IF;
	
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;


SELECT change_student_id('S2018071', 'S2017173', null);
SELECT change_student_id('S2018083', 'S2017175', null);
SELECT change_student_id('S2018075', 'S2017176', null);
SELECT change_student_id('S2018076', 'S2017177', null);
SELECT change_student_id('S2018078', 'S2017178', null);
SELECT change_student_id('S2018079', 'S2017179', null);
SELECT change_student_id('S2018080', 'S2017180', null);
SELECT change_student_id('S2018070', 'S2017194', null);
SELECT change_student_id('S2018073', 'S2017193', null);
SELECT change_student_id('S2018077', 'S2017182', null);
SELECT change_student_id('S2018081', 'S2017191', null);
SELECT change_student_id('S2018082', 'S2017195', null);
SELECT change_student_id('S2017082', 'S2017080', null);
SELECT change_student_id('S2017084', 'S2017082', null);
SELECT change_student_id('S2017085', 'S2017083', null);
SELECT change_student_id('S2017086', 'S2017084', null);
SELECT change_student_id('S2017087', 'S2017085', null);
SELECT change_student_id('S2018085', 'S2017108', null);
SELECT change_student_id('S2018086', 'S2017109', null);
SELECT change_student_id('S2018087', 'S2017110', null);
SELECT change_student_id('S2018090', 'S2017112', null);
SELECT change_student_id('S2018091', 'S2017113', null);
SELECT change_student_id('S2018092', 'S2017114', null);
SELECT change_student_id('S2018093', 'S2017115', null);
SELECT change_student_id('S2018094', 'S2017116', null);
SELECT change_student_id('S2018096', 'S2017118', null);
SELECT change_student_id('S2018097', 'S2017119', null);
SELECT change_student_id('S2018098', 'S2017120', null);
SELECT change_student_id('S2018002', 'S2017121', null);
SELECT change_student_id('S2018099', 'S2017122', null);
SELECT change_student_id('S2018003', 'S2017123', null);
SELECT change_student_id('S2018004', 'S2017124', null);
SELECT change_student_id('S2018100', 'S2017125', null);
SELECT change_student_id('S2018006', 'S2017126', null);
SELECT change_student_id('S2018007', 'S2017127', null);
SELECT change_student_id('S2018008', 'S2017128', null);
SELECT change_student_id('S2018009', 'S2017129', null);
SELECT change_student_id('S2018010', 'S2017130', null);
SELECT change_student_id('S2018013', 'S2017133', null);
SELECT change_student_id('S2018014', 'S2017134', null);
SELECT change_student_id('S2018015', 'S2017189', null);
SELECT change_student_id('S2017014', 'S2017030', null);
SELECT change_student_id('S2018054', 'S2017196', null);
SELECT change_student_id('S2018055', 'S2017197', null);
SELECT change_student_id('S2018056', 'S2017198', null);
SELECT change_student_id('S2018057', 'S2017199', null);
SELECT change_student_id('S2018058', 'S2017200', null);
SELECT change_student_id('S2018059', 'S2017201', null);
SELECT change_student_id('S2018060', 'S2017202', null);
SELECT change_student_id('S2018016', 'S2017135', null);
SELECT change_student_id('S2018017', 'S2017136', null);
SELECT change_student_id('S2018018', 'S2017137', null);
SELECT change_student_id('S2018019', 'S2017138', null);
SELECT change_student_id('S2018020', 'S2017139', null);
SELECT change_student_id('S2018021', 'S2017140', null);
SELECT change_student_id('S2018022', 'S2017141', null);
SELECT change_student_id('S2018023', 'S2017142', null);
SELECT change_student_id('S2018024', 'S2017143', null);
SELECT change_student_id('S2018025', 'S2017144', null);
SELECT change_student_id('S2018026', 'S2017145', null);
SELECT change_student_id('S2018027', 'S2017146', null);
SELECT change_student_id('S2018028', 'S2017147', null);
SELECT change_student_id('S2018029', 'S2017148', null);
SELECT change_student_id('S2018030', 'S2017149', null);
SELECT change_student_id('S2018031', 'S2017150', null);
SELECT change_student_id('S2018032', 'S2017151', null);
SELECT change_student_id('S2018033', 'S2017152', null);
SELECT change_student_id('S2018034', 'S2017153', null);
SELECT change_student_id('S2018035', 'S2017154', null);
SELECT change_student_id('S2018036', 'S2017155', null);
SELECT change_student_id('S2018037', 'S2017156', null);
SELECT change_student_id('S2018038', 'S2017157', null);
SELECT change_student_id('S2018039', 'S2017158', null);
SELECT change_student_id('S2018040', 'S2017159', null);
SELECT change_student_id('S2018041', 'S2017160', null);
SELECT change_student_id('S2018042', 'S2017161', null);
SELECT change_student_id('S2018043', 'S2017162', null);
SELECT change_student_id('S2018044', 'S2017163', null);
SELECT change_student_id('S2018045', 'S2017164', null);
SELECT change_student_id('S2018046', 'S2017165', null);
SELECT change_student_id('S2018047', 'S2017166', null);
SELECT change_student_id('S2018048', 'S2017167', null);
SELECT change_student_id('S2018049', 'S2017168', null);
SELECT change_student_id('S2018050', 'S2017169', null);
SELECT change_student_id('S2018051', 'S2017170', null);
SELECT change_student_id('S2018052', 'S2017171', null);
SELECT change_student_id('S2018053', 'S2017172', null);

