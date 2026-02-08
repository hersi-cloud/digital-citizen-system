# Digital Citizen Registration System (DCRS) 🇸🇴

A comprehensive mobile and web solution for digitizing National ID and Birth Certificate issuance in Somalia.
Built with **Flutter** (Mobile) and **Node.js** (Backend).

## 📱 Features

- **User Registration:** Secure sign-up with personal details.
- **Digital ID Request:** Request National ID with photo integration.
- **Birth Registration:** Register birth certificates digitally.
- **Real-time Status:** Track application status (Pending/Approved).
- **PDF Generation:** Download official, high-fidelity ID Cards and Birth Certificates directly.
- **Admin Panel:** Manage and approve requests.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js, Express.js
- **Database:** MongoDB
- **Tools:** Provider (State Management), PDF/Printing (Document Generation)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Node.js & npm installed
- MongoDB running locally or Atlas URI

### 1. Backend Setup

```bash
cd backend
npm install
# Update .env file with your MONGO_URI and JWT_SECRET
npm start
```

_Server runs on port 5000 by default._

### 2. Mobile App Setup

```bash
cd mobile_app
flutter pub get
flutter run
```

## 📂 Project Structure

- `/mobile_app`: Flutter source code
  - `/lib/screens`: UI Screens (Login, Dashboard, Profile, forms)
  - `/lib/services`: API & PDF services
  - `/lib/providers`: State management logic
- `/backend`: Node.js Server
  - `/models`: Database Schemas (User, Request)
  - `/controllers`: Business Logic
  - `/routes`: API Endpoints

## 📄 Documentation

- **Final Report:** See `final_report.md` for detailed project analysis.
- **Design System:** See `design_system.md` for UI/UX specifications.
- **Presentation:** Use generated assets in `design_prompts.md`.

---

_Group J Project - Software Engineering_
