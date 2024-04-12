-- PARTIE 1

-- 1. Nom des lieux qui finissent par 'um' 


SELECT nom_lieu 
FROM lieu l
WHERE nom_lieu LIKE '%um'

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).


SELECT COUNT(p.id_personnage), l.nom_lieu
FROM  lieu l 
INNER JOIN personnage p
ON l.id_lieu = p.id_lieu
GROUP BY l.nom_lieu

-- 3 Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.


SELECT p.nom_personnage, s.nom_specialite, p.adresse_personnage ,l.nom_lieu
FROM specialite s
INNER JOIN personnage p 
ON p.id_specialite = s.id_specialite
INNER JOIN lieu l
ON p.id_lieu = l.id_lieu
ORDER BY l.nom_lieu DESC, p.nom_personnage DESC

-- 4 Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).


SELECT s.nom_specialite, COUNT(p.id_personnage) AS nb_personnages
FROM specialite s
INNER JOIN personnage p
ON s.id_specialite = p.id_specialite
GROUP BY s.nom_specialite
ORDER by nb_personnages DESC

-- 5 Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).


SELECT b.nom_bataille, l.nom_lieu,  DATE_FORMAT(b.date_bataille, '%d %M %y')
FROM bataille b 
INNER JOIN lieu l
ON b.id_lieu = l.id_lieu
ORDER BY YEAR(b.date_bataille) ASC, MONTH(b.date_bataille) ASC, DAY(b.date_bataille) ASC 

-- 6 Nom des potions + coût de réalisation de la potion (trié par coût décroissant).


SELECT p.nom_potion, SUM(i.cout_ingredient * c.qte) AS cout_total
FROM potion p 
INNER JOIN composer c
ON p.id_potion = c.id_potion
INNER JOIN ingredient i
ON c.id_ingredient = i.id_ingredient
GROUP BY p.nom_potion
ORDER BY cout_total

-- 7 Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'


SELECT p.nom_potion, i.nom_ingredient ,i.cout_ingredient, c.qte, i.cout_ingredient * c.qte
FROM potion p 
INNER JOIN composer c
ON p.id_potion = c.id_potion
INNER JOIN ingredient i
ON c.id_ingredient = i.id_ingredient
WHERE nom_potion = "Santé"

-- 8 Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'


SELECT p.nom_personnage, SUM(pc.qte) AS nb_casques
FROM personnage p, bataille b, prendre_casque pc
WHERE p.id_personnage = pc.id_personnage
AND pc.id_bataille = b.id_bataille
AND b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.id_personnage
HAVING nb_casques >= ALL( -- on retravaille avec les mêmes données pour les comparer
	SELECT SUM(pc.qte)
 	FROM prendre_casque pc, bataille b
 	WHERE b.id_bataille = pc.id_bataille -- jointure en join
 	AND b.nom_bataille = 'Bataille du village gaulois'
 	GROUP BY pc.id_personnage
)
-- Avec create view demander l'utilité et comment voir la table virtuelle :

CREATE VIEW plus_de_casques_pris AS 
SELECT p.nom_personnage, SUM(pc.qte) AS nb_casques
FROM personnage p, bataille b, prendre_casque pc
WHERE p.id_personnage = pc.id_personnage
AND pc.id_bataille = b.id_bataille
AND b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.id_personnage
HAVING nb_casques >= ALL( -- on retravaille avec les données qu'on souhaite comparer via ALL
	SELECT SUM(pc.qte)
 	FROM prendre_casque pc, bataille b
 	WHERE b.id_bataille = pc.id_bataille
 	AND b.nom_bataille = 'Bataille du village gaulois'
 	GROUP BY pc.id_personnage
)

-- Voir la table virtuelle :
SELECT * FROM plus_de_casques_pris;

-- Supprimer la table virtuelle :
DROP VIEW plus_de_casques_pris;

-- 9 Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).


SELECT pot.nom_potion, p.nom_personnage, SUM(b.dose_boire) AS potion_bu 
FROM personnage p
INNER JOIN boire b
ON p.id_personnage = b.id_personnage
INNER JOIN potion pot
ON pot.id_potion = b.id_potion
GROUP BY p.id_personnage, pot.nom_potion
ORDER BY potion_bu ASC 

-- 10 Nom de la bataille où le nombre de casques pris a été le plus important.


SELECT nom_bataille, SUM(qte) AS nbCasques
FROM prendre_casque
INNER JOIN bataille 
ON bataille.id_bataille = prendre_casque.id_bataille
GROUP BY prendre_casque.id_bataille
HAVING nbCasques >= ALL(
    SELECT SUM(qte)
    FROM prendre_casque pc, bataille b
    WHERE pc.id_bataille = b.id_bataille
    GROUP BY pc.id_bataille
    )

-- 11 Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)


SELECT tc.nom_type_casque, COUNT(c.id_casque ) AS nb_casques, SUM(c.cout_casque) AS cout_total
FROM casque c 
LEFT JOIN type_casque tc
ON tc.id_type_casque = c.id_type_casque
GROUP BY tc.nom_type_casque
ORDER BY cout_total DESC 

-- 12 Nom des potions dont un des ingrédients est le poisson frais.


SELECT p.nom_potion
FROM potion p
INNER JOIN composer c
ON p.id_potion = c.id_potion
INNER JOIN ingredient i
ON c.id_ingredient = i.id_ingredient
WHERE i.nom_ingredient = "poisson frais"

-- 13 . Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.


SELECT l.nom_lieu, COUNT(p.nom_personnage) AS nbPersonnage
FROM personnage p
INNER JOIN lieu l
ON p.id_lieu = l.id_lieu
WHERE l.nom_lieu != "Village gaulois"
GROUP BY l.id_lieu
HAVING nbPersonnage >= ALL(
	SELECT COUNT(p.nom_personnage)
	FROM personnage p, lieu l
	WHERE l.id_lieu = p.id_lieu
	AND NOT l.nom_lieu = 'Village gaulois'
	GROUP BY l.id_lieu
    )
	
-- 14 Nom des personnages qui n'ont jamais bu aucune potion


SELECT p.nom_personnage
FROM personnage p
WHERE p.id_personnage NOT IN(
    SELECT id_personnage 
    FROM boire
    )
GROUP BY p.nom_personnage

-- 15 Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.


SELECT p.nom_personnage
FROM personnage p
WHERE p.id_personnage NOT IN(
    SELECT id_personnage 
    FROM autoriser_boire a, potion pot 
    WHERE pot.id_potion = a.id_potion 
    AND pot.nom_potion = "Magique"
    ) 

-- PARTIE 2

-- A Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.


INSERT INTO personnage (nom_personnage, adresse_personnage, id_specialite, id_lieu)
VALUES (
	'Champdeblix', 'Résidant à la ferme Hantassion',
	(SELECT id_specialite FROM specialite WHERE specialite.nom_specialite = 'Agriculteur'), -- On imbrique une requête sql pour prendre la clé égale à agriculteur via "where" plutôt qu'un numéro 
	(SELECT id_lieu FROM lieu WHERE nom_lieu = 'Rotomagus')
)

-- B  Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...


INSERT INTO autoriser_boire (id_personnage, id_potion)
VALUES (
	(SELECT id_personnage FROM personnage WHERE nom_personnage = 'Bonemine'),
	(SELECT id_potion FROM potion WHERE nom_potion = 'Magique')
)

-- C Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.


DELETE FROM casque 
WHERE id_type_casque = (
	SELECT id_type_casque 
	FROM type_casque
	WHERE nom_type_casque = "Grec"
	)
AND id_casque NOT IN (
	SELECT id_casque 
	FROM prendre_casque
	)

-- D Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.

UPDATE personnage p
SET p.adresse_personnage = 'Prison de Condate'
WHERE p.nom_personnage = "Zérozérosix"

--E La potion 'Soupe' ne doit plus contenir de persil.

DELETE composer
FROM composer
LEFT JOIN potion 
ON potion.id_potion = composer.id_potion
LEFT JOIN ingredient 
ON ingredient.id_ingredient = composer.id_ingredient
WHERE potion.nom_potion = "Soupe" 
AND ingredient.nom_ingredient = "Persil"

-- F Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !

UPDATE prendre_casque pc 
SET qte = 42, id_casque = (
    SELECT id_casque 
    FROM casque 
    WHERE nom_casque = 'Weisenau' -- pour ne pas avoir à faire 2 requete avec set ?
    )
WHERE id_personnage = (
    SELECT id_personnage 
    FROM personnage 
    WHERE nom_personnage = 'Obélix' -- condition 1
    ) 
AND id_bataille = (
    SELECT id_bataille 
    FROM bataille 
    WHERE nom_bataille = 'Attaque de la banque postale' -- condition 2
    )