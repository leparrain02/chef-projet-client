CREATE TABLE customers(
  id CHAR (36) NOT NULL,
  PRIMARY KEY(id),
  prenom VARCHAR(64),
  nom VARCHAR(64),
  tel VARCHAR(64)
);

INSERT INTO customers ( id, prenom, nom, tel ) VALUES ( uuid(), 'Jane', 'Smith', '418-123-4567' );
INSERT INTO customers ( id, prenom, nom, tel ) VALUES ( uuid(), 'Dave', 'Richards', '514-333-4444' );
