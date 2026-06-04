
# Schéma de la Base de Données (Club Data)



Voici les scripts SQL DDL de création des tables pour le schéma `cd`.



## 1. Table des Membres (`cd.members`)

Cette table stocke les informations sur les membres du club, incluant une auto-référence pour le système de parrainage.



```sql

CREATE TABLE cd.members (

  memid integer NOT NULL, 

  surname character varying(200) NOT NULL, 

  firstname character varying(200) NOT NULL, 

  address character varying(300) NOT NULL, 

  zipcode integer NOT NULL, 

  telephone character varying(20) NOT NULL, 

  recommendedby integer, 

  joindate timestamp NOT NULL, 

  CONSTRAINT members_pk PRIMARY KEY (memid), 

  CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) REFERENCES cd.members(memid) ON DELETE SET NULL

);

CREATE TABLE cd.facilities (

  facid integer NOT NULL, 

  name character varying(100) NOT NULL, 

  membercost numeric NOT NULL, 

  guestcost numeric NOT NULL, 

  initialoutlay numeric NOT NULL, 

  monthlymaintenance numeric NOT NULL, 

  CONSTRAINT facilities_pk PRIMARY KEY (facid)

);

CREATE TABLE cd.bookings (

  bookid integer NOT NULL, 

  facid integer NOT NULL, 

  memid integer NOT NULL, 

  starttime timestamp NOT NULL, 

  slots integer NOT NULL, 

  CONSTRAINT bookings_pk PRIMARY KEY (bookid), 

  CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid), 

  CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)

);

