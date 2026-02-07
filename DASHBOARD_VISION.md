# Vision Technique & UX : FantomePad Web Dashboard

Ce document résume la stratégie de déploiement et l'expérience utilisateur pour le portail d'activation et de gestion des licences FantomePad.

## 1. Objectif Global
Créer un portail web "Premium" qui automatise la délivrance des licences, réduit le support technique et renforce l'identité de marque "The new standard is here".

---

## 2. Parcours Utilisateur (UX Workflow)

### Étape 0 : Achat (Shopify)
*   Le client achète le Pad physique sur le site.
*   Automatisation : Une ligne est créée dans Supabase (via Webhook) avec son mail et son numéro de commande.

### Étape 1 : Connexion (Simple & Sécurisée)
*   **Interface** : Ultra-minimaliste (Fond noir, champ blanc).
*   **Authentification** : Saisie de l'adresse mail d'achat.
*   **Vérification** : Envoi d'un code OTP (One-Time Password) ou Magic Link par email.
*   **Validation** : Le système vérifie que l'email appartient bien à un acheteur Shopify.

### Étape 2 : Onboarding Interactif (The Stepper)
Une fois connecté, l'utilisateur est guidé pas à pas :
1.  **Choix du Terminal** : Boutons élégants [MetaTrader 4] | [MetaTrader 5].
2.  **Génération du Logiciel** : 
    *   L'utilisateur valide son installation.
    *   **DÉCLENCHEUR** : Le système génère son **Code d'Activation** unique à ce moment précis (évite les codes inutilisés).
    *   Le système propose le téléchargement du fichier correspondant (`.ex4` ou `.ex5`).
3.  **Activation & Tuto** : 
    *   Vidéo tutorielle "Installation en 60 secondes" en grand format.
    *   Affichage du code généré avec bouton "Copier".

### Étape 3 : Le Dashboard (Portail Membre)
Après l'onboarding, l'utilisateur accède à son interface finale :
*   **Logique Conditionnelle** : Si un code existe déjà en base, l'utilisateur saute l'étape 2 et arrive ici directement.
*   **État de la licence** : Live Status (Connecté/Déconnecté via Heartbeat).
*   **Gestion Appareil** : Affiche l'ID de la machine liée.
*   **Self-Healing (Reset)** : Bouton "Réinitialiser pour un nouveau PC" (limité mensuellement).
*   **Upsell** : Possibilité d'acheter des "slots" de licences supplémentaires.

---

## 3. Identité Visuelle
*   **Base** : Noir profond (`#000000`).
*   **Texte** : Blanc pur et Gris subtil pour les notes.
*   **Action** : Bleu électrique FantomePad (`#2962FF`).
*   **Style** : Design "Glassmorphism" léger, typographie espacée, animations fluides (Next.js/Framer Motion).

---

## 4. Architecture Technique (Stack)
*   **Frontend** : Next.js 14 (App Router).
*   **Backend** : Supabase (Auth, Database, Edge Functions).
*   **Intégrations** : API Shopify (Webhooks), Resend/Twilio (Emails/OTP).
*   **Sécurité** : Validation côté serveur de chaque requête via JWT.

---

*Document de référence pour le développement du Dashboard V1.*
