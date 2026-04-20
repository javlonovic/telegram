📱 Telegram Clone — Flutter & Django

A modern Telegram-inspired messaging application built with Flutter and Django, designed to replicate the core experience of the latest Telegram Android application.

This project focuses on real-time communication, clean architecture, and scalable system design.

🚀 Project Goal

Build a production-ready messaging platform featuring:

Private chats
Groups & Channels
Media messaging
Realtime synchronization
Modern Telegram-style UI
Scalable backend architecture

The project is developed step-by-step following a structured engineering roadmap.

🧱 Tech Stack
📱 Frontend
Flutter (Dart)
Riverpod — State Management
go_router — Navigation
Dio — Networking
WebSocket communication
Material 3 UI
⚙️ Backend
Django
Django REST Framework
Django Channels
Redis (Realtime layer)
PostgreSQL (Database)
🏗 Architecture

The application follows Clean Architecture principles.

lib/
 ├ core/        → themes, constants, utilities
 ├ features/    → app modules (auth, chats, profile)
 ├ shared/      → reusable widgets & models
 ├ services/    → API & websocket services
 └ ui/          → screens and layouts

Backend architecture:

telegram_backend/
 ├ users/
 ├ chats/
 ├ messaging/
 ├ config/
✨ Planned Features
Core Messaging
Real-time text messaging
Message status (sent / delivered / read)
Reply & edit messages
Chat synchronization
Groups
Member roles
Permissions
Invite system
Channels
Broadcast messaging
Subscriber system
Post statistics
Media Support
Images
Videos
Voice messages
Video circle messages
File sharing
User System
Authentication
Profiles
Privacy settings
Online presence
1️⃣ Clone Repository
git clone https://github.com/javlonovic/telegram
cd telegram-clone
2️⃣ Frontend Setup (Flutter)

Install dependencies:

flutter pub get

Run application:

flutter run
3️⃣ Backend Setup (Django)

Create virtual environment:

python -m venv .venv
source .venv/bin/activate

Install requirements:

pip install -r requirements.txt

Run migrations:

python manage.py migrate

Start backend server:

python manage.py runserver
🔌 Environment Variables

Create .env file:

DEBUG=True
SECRET_KEY=your_secret_key
DATABASE_URL=postgresql://user:password@localhost/db
REDIS_URL=redis://127.0.0.1:6379
🎨 UI Philosophy

The interface aims to replicate the latest Telegram Android experience:

minimal design
fluid animations
fast navigation
media-first messaging
clean typography
📸 Screenshots

(Coming Soon)

🧠 Learning Objectives

This project demonstrates:

Large-scale Flutter architecture
Realtime messaging systems
WebSocket integration
Backend scalability concepts
Production mobile UI design
