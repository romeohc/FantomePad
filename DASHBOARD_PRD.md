# PRD - FantomePad Web Dashboard (V1.0)

## 1. Executive Summary
Le Dashboard FantomePad est la plaque tournante du business. Il assure la transition entre l'achat (Shopify) et l'utilisation (MetaTrader). Son rôle est de sécuriser la distribution des licences tout en offrant une expérience utilisateur "Apple-like".

---

## 2. User Personas
*   **Le Nouveau Client** : Vient de recevoir son Pad. Veut installer le logiciel en moins de 3 minutes.
*   **Le Trader Nomade** : Change de PC ou de VPS. Veut réinitialiser sa licence sans contacter le support.
*   **L'Admin (Toi)** : Veut voir la liste des utilisateurs actifs et révoquer des accès si nécessaire.

---

## 3. Spécifications Fonctionnelles (MVP)

### A. Système d'Auth (Zero Password)
*   Saisie de l'email.
*   Envoi d'un code OTP via Resend (Email).
*   Pas de compte à créer manuellement : l'accès est débloqué par la présence de l'email dans la table `licenses`.

### B. Onboarding interactif (The Stepper)
*   **Step 1** : Choix Platform (MT4/MT5).
*   **Step 2** : Génération du code de licence (au clic) + Téléchargement dynamique du fichier `.ex4` ou `.ex5`.
*   **Step 3** : Activation Code (Persistent) + Vidéo d'installation.

### C. Dashboard Gestion (Conditional UI)
*   **Logic** : Si `activation_code` != null -> Bypass Stepper.
*   Affichage de la licence active.
*   Status en temps réel (Heartbeat de l'EA).
*   Bouton "Reset Hardware ID" (avec cooldown).

---

## 4. Stack Technique & Rationale

| Technologie | Rôle | Pourquoi ce choix ? |
| :--- | :--- | :--- |
| **Next.js 14** | Framework Frontend | SSR pour la vitesse, App Router pour la navigation, déploiement Netlify compatible. |
| **Supabase** | Backend / DB / Auth | **L'Unification** : On utilise déjà Supabase pour l'EA. Centraliser la DB permet une communication directe EA <-> Dashboard. |
| **Tailwind CSS** | Styling | **Vitesse & Design System** : Permet de créer l'interface sombre monochrome très rapidement sans bugs cross-browser. |
| **Framer Motion** | Animations | **Effet Premium** : Pour les transitions d'onboarding fluides. |
| **Resend** | Emailing | **Délivrabilité** : Le meilleur service actuel pour envoyer les codes OTP instantanément. |

### Alternatives considérées :
*   *Vite + React* : Plus léger, mais demande de gérer manuellement le routing et le SEO. Pour un Onboarding, Next.js est plus robuste.
*   *Firebase* : Bonne alternative à Supabase, mais moins flexible sur les requêtes SQL complexes dont on a besoin pour les statistiques de licences.

---

## 5. Plan d'exécution Étape par Étape

### Phase 1 : Infrastructure (Jour 1)
1.  Initialisation du Repo Next.js.
2.  Configuration des variables d'environnement Supabase.
3.  Mise en place du Middleware de sécurité (protéger les pages).

### Phase 2 : Onboarding & Auth (Jour 2-3)
1.  Design de la page Login (Monochrome UI).
2.  Logique OTP (Envoi email + vérification).
3.  Développement du Stepper (MT4/MT5 select -> Download -> Code).

### Phase 3 : Intégration Shopify (Jour 4)
1.  Création de l'Edge Function `shopify-webhook`.
2.  Test de réception de commande et création de licence automatique.

### Phase 4 : Polish & Déploiement (Jour 5)
1.  Optimisation mobile (importante pour consulter son code sur téléphone).
2.  Déploiement sur Vercel (URL : `app.fantomepad.com`).

---

## 6. KPI de succès
*   **Taux d'onboarding** : 95% des utilisateurs doivent activer leur licence sans envoyer de mail au support.
*   **Vitesse** : Chargement de la page de login en moins de 1.5s.
