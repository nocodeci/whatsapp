# Explication : Workflow Assistant de Réunion Automatisé

Ce workflow n8n est un **assistant de réunion intelligent** qui prépare automatiquement l'utilisateur pour ses réunions à venir en collectant et résumant des informations sur les participants.

## 🎯 Objectif principal

Le workflow envoie des **notifications WhatsApp intelligentes** avant chaque réunion avec :
- Un résumé de la réunion
- Les dernières correspondances avec chaque participant
- Les activités récentes LinkedIn des participants
- Des points de discussion suggérés

## 📋 Fonctionnement étape par étape

### 1. Déclenchement périodique
**Nœud : Schedule Trigger**
- Se déclenche **toutes les heures**
- Vérifie s'il y a des réunions dans l'heure à venir

### 2. Vérification des réunions à venir
**Nœud : Check For Upcoming Meetings (Google Calendar)**
- Interroge Google Calendar
- Recherche les réunions dans la prochaine heure
- Récupère les détails : date, heure, participants, description, lien de visioconférence

### 3. Extraction des informations des participants
**Nœud : Extract Attendee Information (Information Extractor)**
- Utilise l'IA pour extraire depuis la description de la réunion :
  - Noms des participants
  - Emails des participants
  - URLs LinkedIn des participants
- Format structuré pour traitement ultérieur

### 4. Recherche d'informations sur chaque participant

Le workflow lance deux recherches en parallèle pour chaque participant :

#### A. Recherche des correspondances email
**Sous-workflow : Get Correspondance**
- **Get Last Correspondence (Gmail)** : Récupère le dernier email échangé avec le participant
- **Get Message Contents** : Récupère le contenu complet de l'email
- **Simplify Emails** : Formate les données (date, sujet, expéditeur, destinataire, texte)
- **Correspondance Recap Agent (LLM)** : Utilise l'IA pour résumer la correspondance et identifier les points importants

#### B. Recherche du profil LinkedIn
**Sous-workflow : Get LinkedIn Profile & Activity**
- **APIFY Web Scraper** : Scrape le profil LinkedIn du participant (nécessite des cookies LinkedIn)
- **Extract Profile Metadata** : Extrait les métadonnées (nom, tagline, localisation, nombre de connexions)
- **Get Sections** : Extrait les sections "About" et "Activity"
- **Extract Activities** : Extrait les activités récentes (posts, réactions, commentaires)
- **LinkedIn Summarizer Agent (LLM)** : Résume le profil et les activités récentes pour identifier des points de discussion

### 5. Génération de la notification intelligente
**Nœud : Attendee Research Agent (LLM)**
- Combine toutes les informations collectées :
  - Détails de la réunion (date, heure, lien, description)
  - Liste des participants
  - Résumés des correspondances email
  - Résumés des profils LinkedIn
- Génère un message de notification structuré avec :
  - Résumé de la réunion
  - Points importants de chaque correspondance
  - Points de discussion basés sur l'activité LinkedIn
  - Format SMS/WhatsApp (ton décontracté, bullet points)

### 6. Envoi de la notification
**Nœud : WhatsApp Business Cloud**
- Envoie le message généré via WhatsApp Business API
- Le destinataire reçoit une notification complète avant la réunion

## 🔄 Flux complet

```
Schedule Trigger (toutes les heures)
    ↓
Check For Upcoming Meetings (Google Calendar)
    ↓
Extract Attendee Information (IA)
    ↓
Pour chaque participant :
    ├─→ Get Correspondance (Email)
    │   ├─→ Get Last Correspondence (Gmail)
    │   ├─→ Get Message Contents
    │   ├─→ Simplify Emails
    │   └─→ Correspondance Recap Agent (LLM)
    │
    └─→ Get LinkedIn Profile & Activity
        ├─→ APIFY Web Scraper
        ├─→ Extract Profile Metadata
        ├─→ Get Sections (About + Activity)
        ├─→ Extract Activities
        └─→ LinkedIn Summarizer Agent (LLM)
    ↓
Merge Attendee with Summaries
    ↓
Attendee Research Agent (LLM) - Génère la notification
    ↓
WhatsApp Business Cloud - Envoie la notification
```

## 🛠️ Technologies utilisées

- **Google Calendar API** : Récupération des réunions
- **Gmail API** : Récupération des emails
- **Apify.com** : Scraping LinkedIn
- **OpenAI GPT-4** : Génération de résumés intelligents
- **WhatsApp Business API** : Envoi des notifications

## 💡 Cas d'usage

Ce workflow est idéal pour :
- **Professionnels très occupés** qui ont beaucoup de réunions
- **Personnes qui voyagent** et ont besoin de se préparer rapidement
- **Ventes/Business Development** qui veulent faire bonne impression
- **Managers** qui veulent être bien préparés pour leurs réunions d'équipe

## ⚙️ Configuration requise

1. **Google Calendar** : Accès au calendrier avec les réunions
2. **Gmail** : Accès aux emails pour récupérer les correspondances
3. **Apify.com** : Compte avec cookies LinkedIn (pour le scraping)
4. **OpenAI API** : Clé API pour les modèles GPT-4
5. **WhatsApp Business API** : Configuration WhatsApp Business Cloud

## 🔧 Personnalisation possible

- **Fréquence de vérification** : Modifier le Schedule Trigger (actuellement 1 heure)
- **Période de recherche** : Modifier `timeMax` dans Check For Upcoming Meetings
- **Format du message** : Modifier le prompt dans "Attendee Research Agent"
- **Canal de notification** : Remplacer WhatsApp par Slack, Telegram, Email, etc.
- **Sources de données** : Ajouter CRM, base de données clients, etc.

## 📊 Exemple de notification générée

```
📅 Réunion dans 30 minutes avec Jean Dupont et Marie Martin
🔗 Lien : https://meet.google.com/xxx-yyyy-zzz

📧 Dernière correspondance avec Jean :
• Discussion sur le projet X
• Engagement à finaliser le rapport avant vendredi
• À mentionner : Statut du rapport

💼 Profil LinkedIn de Jean :
• Expert en IA et Machine Learning
• A récemment publié sur les nouvelles tendances IA
• Point de discussion : Demander son avis sur les dernières innovations

📧 Dernière correspondance avec Marie :
• Échange sur le budget Q4
• À mentionner : Validation du budget

💼 Profil LinkedIn de Marie :
• Directrice Marketing chez TechCorp
• A partagé un article sur les stratégies marketing digitales
• Point de discussion : Nouveaux canaux marketing
```

## ⚠️ Points d'attention

1. **Cookies LinkedIn** : Nécessite de fournir les cookies LinkedIn dans "Set LinkedIn Cookie"
2. **Coûts Apify** : Le scraping LinkedIn utilise Apify (gratuit jusqu'à $5/mois)
3. **Coûts OpenAI** : Utilise GPT-4 qui peut être coûteux avec beaucoup de réunions
4. **Respect de la vie privée** : S'assurer d'avoir le consentement pour scraper LinkedIn
5. **Rate limiting** : Gérer les limites d'API (Gmail, Google Calendar, WhatsApp)

## 🚀 Améliorations possibles

- Ajouter la récupération depuis un CRM (Salesforce, HubSpot)
- Intégrer avec des outils de notes de réunion
- Ajouter la génération automatique d'un ordre du jour
- Envoyer des rappels de suivi après la réunion
- Créer un dashboard pour visualiser les préparations

---

## 📝 Résumé

Ce workflow automatise complètement la **préparation aux réunions** en :
1. ✅ Détectant automatiquement les réunions à venir
2. ✅ Collectant des informations contextuelles sur les participants
3. ✅ Générant intelligemment un résumé avec l'IA
4. ✅ Envoyant une notification WhatsApp pratique

C'est un excellent exemple d'**automatisation intelligente** qui fait gagner du temps et améliore la préparation aux réunions professionnelles.

