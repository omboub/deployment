DELETE FROM faculte;
DELETE FROM universite;
DELETE FROM etape;
DELETE FROM departement;
DELETE FROM matiere;
DELETE FROM groupe;
DELETE FROM classe;
DELETE FROM type_seance;
DELETE FROM type_salle;
DELETE FROM salle;
DELETE FROM commentaire;
DELETE FROM seance;
DELETE FROM enseignant;
DELETE FROM seance_enseignant;



INSERT INTO universite VALUES (10,'Université Angers','Angers');


INSERT INTO faculte (code_faculte,nom_faculte, lieu_faculte,code_universite) VALUES
(1,'Sciences', 'Belle-beille',10),
(2,'Economie', 'Saint serger',10);



INSERT INTO departement VALUES
(100,"Informatique",1),
(200,"Maths",1);


INSERT INTO etape VALUES
(1,"L1 Informatique",100),
(2,"L2 Informatique",100),
(3,"L3 Informatique",100),
(4,"M1 Informatique",100),
(5,"M2 Informatique",100),
(6,"L1 Maths",200),
(7,"L2 Maths",200),
(8,"L3 Maths",200),
(9,"M1 Maths",200),
(10,"M2 Maths",200);








INSERT INTO matiere (code_matiere,libelle_matiere,ects_matiere,charge_cm_matiere,charge_tp_matiere) VALUES
(1,"JAVA",10,1,20),
(2,"Maths",10,1,20),
(3,"Anglais",10,1,20),
(4,"Dev Mobile",10,1,20),
(5,"Opti ineaire",10,1,20),
(6,"Design Pattern",10,1,20);

INSERT INTO groupe (numero_groupe,libelle_groupe,code_etape) VALUES
(1,"Groupe 1",3),
(2,"Groupe 2",3);

INSERT INTO classe(code_classe,code_matiere,code_groupe) VALUES
(1,1,1),
(2,2,1),
(3,3,1),
(4,4,2),
(5,5,2),
(6,6,2);


INSERT INTO type_seance VALUES
(1, 'Jaune', 'Cours Magistral'),
(2, 'Vert', 'Travaux Dirigés'),
(3, 'Orange', 'Travaux Pratiques'),
(4, 'Rouge', 'Examen');


INSERT INTO type_salle VALUES 
(1,"H001"),
(2,"H002"),
(3,"H003");

INSERT INTO salle(code_salle,code_type_salle,code_departement,capacite_salle) VALUES
(1,1,100,40),
(2,2,100,40),
(3,3,100,40);

INSERT INTO commentaire VALUES
(1,"Ceci est un commentaire");

INSERT INTO seance (code_seance,code_classe,code_type_seance,code_salle,numero_commentaire,date_seance,duree_seance) VALUES
(1,1,1,1,1,'2020-11-16T10:00:00','02:00:00'),
(2,2,1,1,1,'2020-11-16T16:00:00','02:00:00'),
(3,3,2,1,1,'2020-11-18T10:00:00','02:00:00'),
(4,4,2,2,1,'2020-11-18T14:00:00','02:00:00'),
(5,5,3,2,1,'2020-11-19T08:00:00','02:00:00'),
(6,6,3,3,1,'2020-11-20T14:00:00','02:00:00');


INSERT INTO enseignant (matricule_enseignant,nom_enseignant,prenom_enseignant,email_enseignant,obligation_theorique_enseignent,code_departement) VALUES
(1,"Goudet","Olivier","O.G@univ-angers.fr",1,100),
(2,"Lardeux","Frédéric","F.L@univ-angers.fr",1,100);

INSERT INTO seance_enseignant VALUES
(1,1),
(2,2),
(2,1),
(3,1);










