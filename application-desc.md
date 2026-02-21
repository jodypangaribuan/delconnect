# DelConnect

**Platform Proyek**  
- Mobile App (Android & iOS)

**Versi Saat Ini**  
1.0.0 (Beta)

**Status Proyek**  
Dalam Pengembangan Aktif

**Tanggal Pembaruan Terakhir**  
21 Februari 2026

**Executive Summary**  
DelConnect adalah platform media sosial interaktif berbentuk mobile application yang dirancang secara spesifik untuk membangun komunitas dan memfasilitasi komunikasi antar individu di kampus Institut Teknologi Del. Aplikasi ini memungkinkan pengguna untuk berbagi cerita, berinteraksi secara real-time, dan mengelola profil digital mereka dengan menggunakan arsitektur cloud backend yang scalable.

---

## Latar Belakang Proyek
Di era digitalisasi saat ini, kebutuhan untuk terhubung dan membagikan momen harian di dalam komunitas sivitas akademika menjadi sangat penting (khususnya di lingkungan kampus Institut Teknologi Del). DelConnect dibangun untuk memberikan ruang eksplorasi, interaksi, dan sarana komunikasi real-time yang modern dengan User Experience yang terpusat dan mulus.

## Permasalahan Bisnis yang Diatasi
- Kurangnya platform spesifik yang memfasilitasi komunikasi antar anggota dalam sebuah komunitas tertutup/terbatas.
- Tidak ada tempat sentralisasi untuk berbagi pengalaman dan berita komunitas secara cepat.
- Kebutuhan notifikasi real-time jika ada interaksi (seperti pesan atau like).

## Tujuan Bisnis & Objectives (SMART)
- Menyediakan aplikasi komunikasi yang andal, aman, dan mudah digunakan dalam waktu 3 bulan.
- Mengadopsi setidaknya 1.000 pengguna aktif di bulan pertama pasca perilisan.
- Menjaga latensi pengambilan data feed di bawah 500ms.
- Mencapai Crash-free rate > 99%.

## Target Audience & User Persona
- Mahasiswa Institut Teknologi Del (IT Del)
- Alumni IT Del yang ingin tetap terhubung
- Dosen & Staf Akademik IT Del
- Moderator / Admin Komunitas

## Stakeholders
- Product Owner & Developer: Jody
- End Users: Anggota Komunitas (Mahasiswa, Alumni, dll)
- Cloud Provider: Firebase & Supabase

## Ruang Lingkup Proyek (Scope)

### In Scope
- Mobile App (Android & iOS) native UI & UX
- Fitur Social Feed (Home, Explore)
- Fitur Autentikasi dan Profiling
- Real-time notification & Messaging
- Dark Mode / Light Mode terintegrasi

### Out of Scope
- Web App / PWA
- Desktop Application
- Fitur Video Call
- E-Commerce / Payment Gateway terintegrasi (saat ini)

## Fitur Utama

### Fitur Penunjang Sosial
- **Authentication**: Login & Register dengan Email/Password dan Google Sign-In.
- **Home Feed**: Menampilkan post dari pengguna lain dengan fitur Pull-to-Refresh.
- **Interaksi**: Like, Share, dan Messaging (Real-time).
- **Post Creation**: Upload gambar/foto dari galeri menggunakan `image_picker` dan custom caption.
- **Penyimpanan Media**: Gambar dan post media diunggah ke *Supabase Storage*.
- **Dark/Light Mode**: Kustomisasi tema aplikasi sesuai preferensi sistem/pengguna.
- **Push Notification**: Sistem push notification dengan `firebase_messaging` & `flutter_local_notifications`.

## Persyaratan Fungsional (Functional Requirements)
- Pengguna harus bisa membuat akun baru dan masuk dengan akun Google.
- Pengguna dapat membuat post berisikan teks dan foto.
- Aplikasi harus memuat infinite scrolling atau auto-update saat feed ditarik/refresh.
- Sistem dapat mengirimkan pop-up saat ada pesan baru (`message`).

## Persyaratan Non-Fungsional (NFR)
- **Performance**: Scroll mulus di 60 FPS.
- **Scalability**: Database mampu menangani ratusan postingan per harinya tanpa read/write latency.
- **Availability**: 99% uptime melalui layanan BaaS (Firebase/Supabase).
- **Usability**: UI/UX modern dengan efek blur, transisi halus, dan animasi kustom.

## Tech Stack (Lengkap)

| Layer              | Technology                                      | Keterangan                          |
|--------------------|--------------------------------------------------|-------------------------------------|
| **Mobile**         | Flutter (Dart)                                   | Cross-platform framework SDK        |
| **Database**       | Firebase Cloud Firestore                         | NoSQL real-time document database   |
| **Authentication** | Firebase Auth + Google Sign In                   | Identitas dan otorisasi pengguna    |
| **Storage**        | Supabase Storage                                 | Object storage untuk unggahan media |
| **Push Notif**     | Firebase Cloud Messaging (FCM)                   | Layanan distribusi notifikasi       |
| **State Mgmt**     | Provider                                         | Mengelola *theme* dan rotasi state  |
| **UI Components**  | Google Fonts, Iconsax, Liquid Pull To Refresh    | Material Design & custom asset      |

## Arsitektur Sistem
- **Client-Server Architecture**: Flutter Client me-request data ke layanan Firebase / Supabase.
- **Backend as a Service (BaaS)**: Menggunakan Firebase untuk Firestore DB dan Auth, serta Supabase untuk file image storage.
- **Service Layering**: Akses database dan cloud diabstraksikan melalui kelas-*Service* terpusat (contoh: `PostService`).

## Keamanan & Compliance
- Data pengguna (password) di-*hash* oleh Firebase Auth.
- Firestore Security Rules diimplementasikan (hanya *authenticated users* yang bisa menulis post).
- JWT (JSON Web Tokens) ditangani otomatis oleh SDK internal Firebase & Supabase.

## Git Workflow
- Local development di `main` dengan conventional commit standards.

## Testing Strategy
- Widget Testing & Unit Testing (via `flutter_test`).
- Manual Testing pada Simulator (iOS) dan Emulator (Android).

## Deployment & Infrastructure
- **iOS**: Cocoapods & Xcode Build (menargetkan iOS 13.0+).
- **Android**: Gradle & Android SDK.
- **Platform Distribusi**: Disiapkan untuk TestFlight (iOS) dan Play Console (Android).

## Success Metrics / KPIs
- Waktu masuk (Login/Load Feed) awal < 2 detik.
- Pertumbuhan interaksi (Like/Post) > 20% secara MoM (Month over Month).

## Roadmap & Future Enhancements
**Phase 2**  
- Implementasi fitur "Comments" di dalam Post secara *nested*.  
- Optimasi Cache Images dengan CDN Lanjutan.  

**Phase 3**  
- Fitur Explore algoritma rekomendasi (AI-based post sorting).  
- Chat / Group Messaging system secara full-featured.

---

**Dibuat oleh**: Developer Tim DelConnect
**Approved by**: Product Owner

---
