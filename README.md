# Urban Relevé - Application Flutter de Relevé Cartographique

Urban Relevé est une application mobile développée en **Flutter** pour la **gestion et le suivi des constructions urbaines**. Elle permet de dessiner des polygones sur une carte, d’ajouter des informations attributaires et de consulter les constructions existantes.

---

## **Fonctionnalités principales**

- Authentification des utilisateurs.
- Affichage d’une carte OpenStreetMap.
- Ajout d’une construction :
  - Dessin d’un polygone sur la carte.
  - Saisie des attributs : nom, adresse, type, contact.
- Consultation des constructions :
  - Carte plein écran avec tous les polygones.
  - Liste des constructions avec détails.
- Navigation fluide entre la carte et la liste des constructions.
- Enregistrement des données dans **SQLite** pour persistance locale.

---

## **Architecture**

- **Flutter** : frontend mobile.
- **SQLite** : base de données locale pour stocker les constructions.
- **Flutter Map + Leaflet** : affichage et interaction avec la carte.
- **Structure des dossiers** :
lib/
models/ # Modèles de données (Construction, User)
services/ # Services (DBHelper)
screens/ # Écrans de l'application (Home, DrawMap, FullMap, List, Form)
