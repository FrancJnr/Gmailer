CREATE TABLE publishers(
    publisher_id        serial primary key,
    org_id              integer references orgs,
    publisher_name      varchar(120),
    publisher_address   text,
    UNIQUE(publisher_name, publisher_address)
);
CREATE INDEX publishers_org_id ON publishers(org_id);

CREATE TABLE librarians(
    librarian_id        serial primary key,
    librarian_name      varchar(120),
    org_id              integer references orgs,
    telno               varchar(20),
    gender              varchar(2),
    email               varchar(50),
    is_active           boolean default true,
    details             text
);
CREATE INDEX librarians_org_id ON librarians(org_id);

CREATE TABLE book_status(
    book_status_id      serial primary key,
    book_status_name    varchar(120),
    org_id              integer references orgs,
    details             text
);
CREATE INDEX book_status_org_id ON book_status(org_id);

CREATE TABLE book_category(
    book_category_id    serial primary key,
    book_category_name  varchar(120),
    org_id              integer references orgs,
    details             text
);
CREATE INDEX book_category_org_id ON book_category(org_id);

CREATE TABLE books(
    book_id             serial primary key,
    org_id              integer references orgs,
    book_category_id    integer references book_category,
    isbn                varchar(20),
    book_title          varchar(120),
    author              varchar(120),
    book_edition        varchar(50),
    publisher_id        integer references publishers,
    book_status_id      integer references book_status,
    is_borrowed         boolean default false,            
    details             text,
    UNIQUE(isbn)   
);
CREATE INDEX books_org_id ON books(org_id);
CREATE INDEX books_book_category_id ON books(book_category_id);
CREATE INDEX books_status_id ON books(book_status_id);
CREATE INDEX books_publisher_id ON books(publisher_id);

CREATE TABLE books_issuance(
    books_issuance_id   serial primary key,
    org_id              integer references orgs,
    book_id             integer references books,
    librarian_id        integer references librarians,
    loanee              integer references entitys,
    issuance_date       date,
    return_date         date,
    days_exceeded       integer,
    is_returned         boolean default false,
    return_condition    varchar(50),
    details             text
);
CREATE INDEX books_issuance_org_id ON books_issuance(org_id);
CREATE INDEX books_issuance_librarian_id ON books_issuance(librarian_id);
CREATE INDEX books_issuance_book_id ON books_issuance(book_id);



CREATE OR REPLACE VIEW vw_books AS
    SELECT book_category.book_category_id, books.org_id, book_category.book_category_name, book_status.book_status_id,
    book_status.book_status_name,  books.book_id, books.isbn, books.book_title, publishers.publisher_name, publishers.publisher_address,
    books.book_edition, books.author, books.is_borrowed, books.details
    FROM books
    INNER JOIN book_category ON books.book_category_id = book_category.book_category_id
    INNER JOIN book_status ON books.book_status_id = book_status.book_status_id
    LEFT JOIN publishers ON books.publisher_id = publishers.publisher_id; 

CREATE OR REPLACE VIEW vw_books_issuance AS
    SELECT vw_books.book_id,  vw_books.book_category_name, vw_books.book_status_name, vw_books.book_title, vw_books.isbn, vw_books.is_borrowed, 
    books_issuance.org_id, entitys.entity_id, entitys.entity_name, entitys.entity_type_id,
    librarians.librarian_id, librarians.librarian_name, librarians.telno, librarians.email, librarians.is_active,  books_issuance.books_issuance_id, 
    books_issuance.loanee, books_issuance.issuance_date, books_issuance.return_date, books_issuance.days_exceeded, 
    books_issuance.is_returned, books_issuance.return_condition, books_issuance.details,
    (CASE WHEN (vw_books.is_borrowed = false)THEN 'Pending' ELSE 'Issued' END) AS status
    FROM books_issuance
    INNER JOIN vw_books ON books_issuance.book_id = vw_books.book_id
    INNER JOIN entitys ON books_issuance.loanee = entitys.entity_id
    INNER JOIN librarians ON books_issuance.librarian_id = librarians.librarian_id;
CREATE OR REPLACE FUNCTION issue_book(varchar(120), varchar(120), varchar(120)) RETURNS varchar(120) AS $$
DECLARE
    msg                 varchar(120);
BEGIN
    UPDATE books SET is_borrowed = true 
    FROM
    (SELECT book_id FROM 
        books_issuance WHERE books_issuance_id = $1::int
    ) as a
    WHERE books.book_id = a.book_id;
    msg:='Book issued';
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION mark_book_return(varchar(120), varchar(120), varchar(120)) RETURNS varchar(120) AS $$
DECLARE
    msg                 varchar(120);
BEGIN
    UPDATE books SET is_borrowed = false 
    FROM
    (SELECT book_id FROM 
        books_issuance WHERE books_issuance_id = $1::int
    ) as a
    WHERE books.book_id = a.book_id;
    msg:='Book Returned';
END;
$$ LANGUAGE PLPGSQL;

INSERT INTO use_keys(
            use_key_id, use_key_name, use_function)
    VALUES (7, 'students', 0),(8, 'teachers', 0), (9, 'non teaching staff', 0);
INSERT INTO entity_types( use_key_id, org_id, entity_type_name, entity_role)
    VALUES (7, 0, 'students', 'student'), (8, 0, 'teachers', 'teacher'), (9, 0, 'non teaching staff', 'non teaching staff');