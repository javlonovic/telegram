# 📱 Telegram Clone — Flutter & Django

> A modern **Telegram-inspired messaging application** built using **Flutter** and **Django**, focused on realtime communication, clean architecture, and scalable system design.

---

## 🚀 Project Overview

This project recreates the **core experience of the latest Telegram Android application**, combining modern mobile UI with a realtime backend infrastructure.

✨ **Main Goals**

* 💬 Private messaging
* 👥 Groups & Channels
* 🎥 Media messaging
* ⚡ Realtime synchronization
* 🎨 Telegram-style modern UI
* 🧱 Scalable backend architecture

---

## 🧱 Tech Stack

### 📱 Frontend

* Flutter (Dart)
* Riverpod — State Management
* go_router — Navigation
* Dio — Networking Layer
* WebSockets — Realtime Communication
* Material 3 UI

### ⚙️ Backend

* Django
* Django REST Framework
* Django Channels
* Redis (Realtime Layer)
* PostgreSQL (Database)

---

## 🏗 Architecture

The application follows **Clean Architecture** principles.

### Flutter Structure

```
lib/
├── core/        # themes, constants, utilities
├── features/    # auth, chats, profile modules
├── shared/      # reusable widgets & models
├── services/    # API & websocket services
└── ui/          # screens & layouts
```

### Backend Structure

```
telegram_backend/
├── users/
├── chats/
├── messaging/
└── config/
```

---

## ✨ Planned Features

### 💬 Core Messaging

* Real-time text messaging
* Message status (Sent ✓ Delivered ✓✓ Read ✓✓)
* Reply & Edit messages
* Chat synchronization

### 👥 Groups

* Member roles & permissions
* Invite system
* Group administration tools

### 📢 Channels

* Broadcast messaging
* Subscriber system
* Post statistics

### 🎥 Media Support

* Images
* Videos
* Voice messages
* Video circle messages
* File sharing

### 👤 User System

* Authentication
* User profiles
* Privacy settings
* Online presence tracking

---

## ⚡ Getting Started

### 1️⃣ Clone Repository

```bash
git clone https://github.com/javlonovic/telegram
cd telegram-clone
```

---

### 2️⃣ Frontend Setup (Flutter)

Install dependencies:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

---

### 3️⃣ Backend Setup (Django)

Create virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
```

Install requirements:

```bash
pip install -r requirements.txt
```

Run migrations:

```bash
python manage.py migrate
```

Start backend server:

```bash
python manage.py runserver
```

---

## 🔌 Environment Variables

Create a `.env` file:

```env
DEBUG=True
SECRET_KEY=your_secret_key
DATABASE_URL=postgresql://user:password@localhost/db
REDIS_URL=redis://127.0.0.1:6379
```

---

## 🎨 UI Philosophy

Inspired by the **latest Telegram Android design**:

* Minimal interface
* Smooth animations
* Fast navigation
* Media-first messaging
* Clean typography

---

## 📸 Screenshots

🚧 *Coming Soon*

---

## 🧠 Learning Objectives

This project demonstrates:

* Large-scale Flutter architecture
* Realtime messaging systems
* WebSocket integration
* Backend scalability concepts
* Production mobile UI design

---

## 📌 Project Status

🚧 **Active Development — Phase 1 (Foundation)**

---

## 🤝 Contributions

Ideas, suggestions, and discussions are welcome.

---

## 📄 License

MIT License
