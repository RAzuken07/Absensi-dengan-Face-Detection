# Sistem Absensi dengan QR Code dan Face Recognition

Aplikasi mobile berbasis Flutter untuk manajemen absensi kampus dengan verifikasi QR Code dan Face Recognition.

## 📱 Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Camera**: camera package
- **QR Code**: qr_flutter, mobile_scanner
- **HTTP Client**: dio

### Backend
- **Framework**: Python Flask
- **Database**: MySQL/MariaDB
- **Face Recognition**: face_recognition library
- **Authentication**: JWT
- **Image Processing**: PIL, OpenCV

---

## 👥 User Roles

### 1. Admin
- Mengelola data dosen, mahasiswa, mata kuliah, dan kelas
- Mengatur jadwal kelas dan assignment dosen
- Full CRUD operations untuk semua entitas

### 2. Dosen
- Membuka dan menutup sesi absensi
- Memverifikasi wajah saat membuka sesi
- Melihat daftar kehadiran mahasiswa
- Mengelola pertemuan kelas

### 3. Mahasiswa
- Scan QR code untuk absensi
- Verifikasi wajah saat absensi
- Melihat daftar pertemuan dan status kehadiran
- Registrasi wajah untuk verifikasi

---

## 🎯 Use Case Diagram

```mermaid
graph TB
    subgraph "Sistem Absensi"
        UC1[Kelola Data Dosen]
        UC2[Kelola Data Mahasiswa]
        UC3[Kelola Mata Kuliah]
        UC4[Kelola Kelas]
        UC5[Assign Dosen ke Kelas]
        
        UC6[Registrasi Wajah Dosen]
        UC7[Buka Sesi Absensi]
        UC8[Tutup Sesi Absensi]
        UC9[Lihat Daftar Kehadiran]
        UC10[Verifikasi Wajah Dosen]
        
        UC11[Registrasi Wajah Mahasiswa]
        UC12[Scan QR Code]
        UC13[Verifikasi Wajah Mahasiswa]
        UC14[Submit Absensi]
        UC15[Lihat Pertemuan]
    end
    
    Admin((Admin))
    Dosen((Dosen))
    Mahasiswa((Mahasiswa))
    
    Admin --> UC1
    Admin --> UC2
    Admin --> UC3
    Admin --> UC4
    Admin --> UC5
    
    Dosen --> UC6
    Dosen --> UC7
    Dosen --> UC8
    Dosen --> UC9
    UC7 --> UC10
    
    Mahasiswa --> UC11
    Mahasiswa --> UC12
    Mahasiswa --> UC14
    Mahasiswa --> UC15
    UC12 --> UC13
    UC14 --> UC13
```

---

## 📊 Alur Kerja Aplikasi (Application Workflow)

### Overview Sistem

```mermaid
graph LR
    subgraph "User Interface"
        MA[Mobile App Flutter]
    end
    
    subgraph "Backend System"
        API[REST API]
        Auth[Authentication]
        FaceRec[Face Recognition]
        QRGen[QR Generator]
    end
    
    subgraph "Database"
        DB[(MySQL)]
    end
    
    MA -->|Login| Auth
    MA -->|CRUD Operations| API
    MA -->|Face Verify| FaceRec
    MA -->|Generate QR| QRGen
    
    Auth --> DB
    API --> DB
    FaceRec --> DB
    QRGen --> DB
```

### Alur Kerja Admin

```mermaid
flowchart TD
    A1([Admin Login]) --> A2[Dashboard Admin]
    A2 --> A3{Pilih Menu}
    
    A3 -->|Kelola Dosen| D1[Management Dosen]
    D1 --> D2[Tambah/Edit/Hapus Dosen]
    D2 --> D3[Simpan ke Database]
    D3 --> A2
    
    A3 -->|Kelola Mahasiswa| M1[Management Mahasiswa]
    M1 --> M2[Tambah/Edit/Hapus Mahasiswa]
    M2 --> M3[Assign ke Kelas]
    M3 --> M4[Simpan ke Database]
    M4 --> A2
    
    A3 -->|Kelola Mata Kuliah| MK1[Management Mata Kuliah]
    MK1 --> MK2[Tambah/Edit/Hapus Mata Kuliah]
    MK2 --> MK3[Assign Dosen Pengampu]
    MK3 --> MK4[Simpan ke Database]
    MK4 --> A2
    
    A3 -->|Kelola Kelas| K1[Management Kelas]
    K1 --> K2[Buat/Edit Kelas]
    K2 --> K3[Input Jadwal:<br/>Hari, Jam, Ruangan]
    K3 --> K4[Simpan ke Database]
    K4 --> A2
    
    A3 -->|Kelola Jadwal| J1[Kelola Jadwal Kelas]
    J1 --> J2[Assign Dosen ke Kelas]
    J2 --> J3[Set Mata Kuliah]
    J3 --> J4[Set Jadwal Spesifik]
    J4 --> J5[Simpan Assignment]
    J5 --> A2
    
    A3 -->|Logout| AE([Selesai])
```

### Alur Kerja Dosen Lengkap

```mermaid
flowchart TD
    Start([Login Dosen]) --> Check{Wajah<br/>Sudah<br/>Terdaftar?}
    
    Check -->|Belum| Reg1[Menu Registrasi Wajah]
    Reg1 --> Reg2[Buka Kamera Depan]
    Reg2 --> Reg3[Posisikan Wajah di Oval]
    Reg3 --> Reg4[Ambil Foto]
    Reg4 --> Reg5[Preview Foto]
    Reg5 --> RegOK{Foto OK?}
    RegOK -->|Tidak| Reg3
    RegOK -->|Ya| Reg6[Upload ke Server]
    Reg6 --> Reg7[Server Encode Wajah]
    Reg7 --> Reg8[Simpan Encoding ke DB]
    Reg8 --> Dashboard
    
    Check -->|Sudah| Dashboard[Dashboard Dosen]
    Dashboard --> ViewKelas[Lihat Daftar Kelas]
    ViewKelas --> SelectKelas[Pilih Kelas]
    SelectKelas --> DetailKelas[Detail Kelas]
    DetailKelas --> Action{Pilih Aksi}
    
    Action -->|Buka Sesi| Verify1[Verifikasi Wajah]
    Verify1 --> Verify2[Buka Kamera]
    Verify2 --> Verify3[Ambil Foto Wajah]
    Verify3 --> Verify4[Kirim ke Server]
    Verify4 --> Verify5[Compare dengan DB]
    Verify5 --> Match{Match?}
    
    Match -->|Tidak| Error1[Error: Wajah<br/>Tidak Cocok]
    Error1 --> Verify1
    
    Match -->|Ya| Open1[Buat Pertemuan Baru]
    Open1 --> Open2[Auto-generate<br/>Pertemuan_ke]
    Open2 --> Open3[Buat Sesi Absensi]
    Open3 --> Open4[Generate Kode Sesi]
    Open4 --> Open5[Generate QR Data]
    Open5 --> Open6[Simpan ke Database]
    Open6 --> Display[Display QR Code]
    Display --> Monitor[Monitor Kehadiran]
    
    Monitor --> MonitorAction{Aksi}
    MonitorAction -->|Lihat Daftar| List[Lihat Daftar<br/>Kehadiran Real-time]
    List --> Monitor
    
    MonitorAction -->|Tutup Sesi| Close1[Konfirmasi Tutup]
    Close1 --> Close2[Update Status = 'selesai']
    Close2 --> Close3[QR Code Tidak Valid]
    Close3 --> Dashboard
    
    Action -->|Lihat Sesi Aktif| Active[Lihat Semua<br/>Sesi Aktif]
    Active --> Dashboard
    
    Action -->|Logout| End([Selesai])
```

### Alur Kerja Mahasiswa Lengkap

```mermaid
flowchart TD
    Start([Login Mahasiswa]) --> CheckReg{Wajah<br/>Sudah<br/>Terdaftar?}
    
    CheckReg -->|Belum| R1[Menu Registrasi Wajah]
    R1 --> R2[Buka Kamera Depan]
    R2 --> R3[Posisikan Wajah di Oval]
    R3 --> R4[Ambil Foto]
    R4 --> R5[Preview Foto]
    R5 --> ROK{Foto OK?}
    ROK -->|Tidak| R3
    ROK -->|Ya| R6[Upload ke Server]
    R6 --> R7[Server Encode Wajah]
    R7 --> R8[Simpan Encoding ke DB]
    R8 --> Dash
    
    CheckReg -->|Sudah| Dash[Dashboard Mahasiswa]
    Dash --> ViewMK[Lihat Daftar<br/>Mata Kuliah]
    ViewMK --> SelectMK[Pilih Mata Kuliah]
    SelectMK --> ViewPert[Lihat 16 Pertemuan]
    ViewPert --> CheckStatus{Status<br/>Pertemuan}
    
    CheckStatus -->|Belum Ada Sesi| Gray[Box Abu-abu<br/>Tidak Bisa Klik]
    Gray --> ViewPert
    
    CheckStatus -->|Sesi Selesai| Green[Box Hijau<br/>Status: Hadir]
    Green --> ViewPert
    
    CheckStatus -->|Sesi Selesai<br/>Tidak Hadir| Red[Box Merah<br/>Status: Tidak Hadir]
    Red --> ViewPert
    
    CheckStatus -->|Sesi Aktif| Blue[Box Biru<br/>Bisa Klik]
    Blue --> Click[Klik Pertemuan]
    Click --> Scan1[Screen Scan QR]
    Scan1 --> Scan2[Buka Kamera Belakang]
    Scan2 --> Scan3[Arahkan ke QR Dosen]
    Scan3 --> Scan4[Detect QR Code]
    Scan4 --> Validate{QR Valid?}
    
    Validate -->|Tidak Valid| Err1[Error: QR Tidak Valid]
    Err1 --> Scan2
    
    Validate -->|Expired| Err2[Error: Sesi Sudah Selesai]
    Err2 --> Dash
    
    Validate -->|Valid| Parse[Parse QR Data]
    Parse --> GetInfo[Get Session Info]
    GetInfo --> InfoOK{Session<br/>OK?}
    
    InfoOK -->|Tidak| Err3[Error: Session Not Found]
    Err3 --> Dash
    
    InfoOK -->|Ya| Face1[Tampilkan Info Sesi]
    Face1 --> Face2[Buka Kamera Depan]
    Face2 --> Face3[Ambil Foto Wajah]
    Face3 --> Face4[Preview Foto]
    Face4 --> FaceOK{Foto OK?}
    
    FaceOK -->|Tidak| Face2
    FaceOK -->|Ya| Loc1[Ambil Lokasi GPS]
    Loc1 --> Submit[Kirim ke Server]
    
    Submit --> Server1[Validate Session]
    Server1 --> Server2[Validate QR Data]
    Server2 --> Server3[Verify Face Match]
    Server3 --> FaceMatch{Face<br/>Match?}
    
    FaceMatch -->|Tidak| Err4[Error: Wajah<br/>Tidak Cocok]
    Err4 --> Face2
    
    FaceMatch -->|Ya| Server4[Validate Location]
    Server4 --> LocOK{Lokasi<br/>Valid?}
    
    LocOK -->|Tidak| Err5[Error: Di Luar<br/>Jangkauan]
    Err5 --> Success
    
    LocOK -->|Ya| Server5[Insert Absensi]
    Server5 --> Server6[Update Database]
    Server6 --> Success[✅ Absensi<br/>Berhasil!]
    Success --> Dash
    
    ViewPert -->|Logout| End([Selesai])
```

### Alur Data Flow

```mermaid
graph TD
    subgraph "Data Input"
        I1[Admin Input Data]
        I2[Dosen Buka Sesi]
        I3[Mahasiswa Absen]
    end
    
    subgraph "Processing"
        P1[Validation Layer]
        P2[Business Logic]
        P3[Face Recognition]
        P4[QR Validation]
    end
    
    subgraph "Storage"
        D1[(Users Table)]
        D2[(Kelas & Jadwal)]
        D3[(Pertemuan & Sesi)]
        D4[(Absensi Records)]
        D5[(Face Encodings)]
    end
    
    subgraph "Output"
        O1[QR Code Display]
        O2[Attendance List]
        O3[Student Dashboard]
        O4[Reports]
    end
    
    I1 --> P1
    I2 --> P1
    I3 --> P1
    
    P1 --> P2
    P2 --> P3
    P2 --> P4
    
    P2 --> D1
    P2 --> D2
    P2 --> D3
    P2 --> D4
    P3 --> D5
    
    D2 --> O1
    D3 --> O1
    D4 --> O2
    D4 --> O3
    D1 --> O4
    D2 --> O4
    D3 --> O4
    D4 --> O4
```

### State Diagram - Sesi Absensi

```mermaid
stateDiagram-v2
    [*] --> Tidak_Ada: Dosen belum buka sesi
    
    Tidak_Ada --> Aktif: Dosen buka sesi<br/>(generate QR, start timer)
    
    Aktif --> Mahasiswa_Scan: Mahasiswa scan QR
    Mahasiswa_Scan --> Validasi_Wajah: QR valid
    Validasi_Wajah --> Submit_Absensi: Wajah cocok
    Submit_Absensi --> Aktif: Rekam kehadiran
    
    Validasi_Wajah --> Aktif: Wajah tidak cocok
    Mahasiswa_Scan --> Aktif: QR tidak valid
    
    Aktif --> Selesai: Dosen tutup sesi<br/>atau Durasi habis
    
    Selesai --> [*]: Data tersimpan
    
    note right of Aktif
        Sesi aktif:
        - QR code valid
        - Mahasiswa bisa absen
        - Timer berjalan
    end note
    
    note right of Selesai
        Sesi selesai:
        - QR tidak valid
        - Tidak bisa absen lagi
        - Data final
    end note
```

---

## 🔄 Activity Diagram

### Flow Absensi Mahasiswa

```mermaid
flowchart TD
    Start([Mahasiswa Login]) --> ViewClass[Lihat Daftar Kelas]
    ViewClass --> SelectClass[Pilih Mata Kuliah]
    SelectClass --> ViewPertemuan[Lihat Daftar Pertemuan]
    ViewPertemuan --> CheckActive{Sesi Aktif?}
    
    CheckActive -->|Tidak| Wait[Tunggu Dosen Buka Sesi]
    Wait --> ViewPertemuan
    
    CheckActive -->|Ya| CheckFace{Wajah<br/>Terdaftar?}
    CheckFace -->|Tidak| RegFace[Registrasi Wajah]
    RegFace --> CaptureFace[Ambil Foto Wajah]
    CaptureFace --> UploadFace[Upload Wajah]
    UploadFace --> ScanQR
    
    CheckFace -->|Ya| ScanQR[Scan QR Code]
    ScanQR --> ValidateQR{QR Valid?}
    
    ValidateQR -->|Tidak| ErrorQR[Tampilkan Error]
    ErrorQR --> ScanQR
    
    ValidateQR -->|Ya| CaptureAbsen[Ambil Foto untuk Absensi]
    CaptureAbsen --> VerifyFace[Verifikasi Wajah]
    VerifyFace --> CheckMatch{Wajah<br/>Cocok?}
    
    CheckMatch -->|Tidak| ErrorFace[Wajah Tidak Cocok]
    ErrorFace --> CaptureAbsen
    
    CheckMatch -->|Ya| CheckLocation{Lokasi<br/>Valid?}
    CheckLocation -->|Tidak| ErrorLoc[Di Luar Jangkauan]
    ErrorLoc --> End([Selesai])
    
    CheckLocation -->|Ya| Submit[Submit Absensi]
    Submit --> Success[Absensi Berhasil]
    Success --> End
```

### Flow Buka Sesi Dosen

```mermaid
flowchart TD
    Start([Dosen Login]) --> ViewKelas[Lihat Daftar Kelas]
    ViewKelas --> SelectKelas[Pilih Kelas]
    SelectKelas --> CheckFaceReg{Wajah<br/>Terdaftar?}
    
    CheckFaceReg -->|Tidak| RegFace[Registrasi Wajah]
    RegFace --> CaptureFace[Ambil Foto Wajah]
    CaptureFace --> UploadFace[Upload Wajah]
    UploadFace --> OpenSesi
    
    CheckFaceReg -->|Ya| VerifyFace[Verifikasi Wajah]
    VerifyFace --> CheckMatch{Wajah<br/>Cocok?}
    
    CheckMatch -->|Tidak| ErrorFace[Verifikasi Gagal]
    ErrorFace --> VerifyFace
    
    CheckMatch -->|Ya| OpenSesi[Buka Sesi Absensi]
    OpenSesi --> GenQR[Generate QR Code]
    GenQR --> DisplayQR[Tampilkan QR Code]
    DisplayQR --> WaitAbsen[Tunggu Mahasiswa Absen]
    WaitAbsen --> ViewList[Lihat Daftar Kehadiran]
    ViewList --> CloseSesi{Tutup<br/>Sesi?}
    
    CloseSesi -->|Tidak| WaitAbsen
    CloseSesi -->|Ya| Close[Tutup Sesi Absensi]
    Close --> End([Selesai])
```

---

## 🏗️ System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        Mobile[Flutter Mobile App]
    end
    
    subgraph "API Layer"
        API[Flask REST API]
        Auth[JWT Authentication]
        Routes[Route Handlers]
    end
    
    subgraph "Business Logic"
        AdminService[Admin Service]
        DosenService[Dosen Service]
        MahasiswaService[Mahasiswa Service]
        AbsensiService[Absensi Service]
        FaceService[Face Recognition Service]
    end
    
    subgraph "Data Layer"
        DB[(MySQL Database)]
        FaceData[Face Encodings Storage]
    end
    
    Mobile -->|HTTP/JSON| API
    API --> Auth
    API --> Routes
    Routes --> AdminService
    Routes --> DosenService
    Routes --> MahasiswaService
    Routes --> AbsensiService
    
    AdminService --> DB
    DosenService --> DB
    DosenService --> FaceService
    MahasiswaService --> DB
    MahasiswaService --> FaceService
    AbsensiService --> DB
    AbsensiService --> FaceService
    
    FaceService --> FaceData
    FaceService --> DB
```

---

## 💾 Database Schema

```mermaid
erDiagram
    users ||--o{ dosen : "level=dosen"
    users ||--o{ mahasiswa : "level=mahasiswa"
    users ||--o{ admin : "level=admin"
    
    matakuliah ||--o{ kelas : "has"
    dosen ||--o{ matakuliah : "teaches"
    
    kelas ||--o{ kelas_dosen : "assigned to"
    dosen ||--o{ kelas_dosen : "teaches"
    matakuliah ||--o{ kelas_dosen : "for"
    
    kelas ||--o{ pertemuan : "has"
    mahasiswa ||--o{ kelas : "enrolled in"
    
    pertemuan ||--|| sesi_absensi : "has"
    pertemuan ||--o{ absensi : "records"
    mahasiswa ||--o{ absensi : "submits"
    
    users {
        int id_user PK
        string username
        string password_hash
        string level
        string created_at
    }
    
    admin {
        int id_admin PK
        int id_user FK
        string nama
        string email
    }
    
    dosen {
        string nip PK
        int id_user FK
        string nama
        string email
        string face_encoding
    }
    
    mahasiswa {
        string nim PK
        int id_user FK
        string nama
        string email
        int id_kelas FK
        string face_encoding
    }
    
    matakuliah {
        int id_matakuliah PK
        string kode_mk
        string nama_matakuliah
        int sks
        string nip_dosen FK
    }
    
    kelas {
        int id_kelas PK
        string nama_kelas
        int id_matakuliah FK
        string tahun_ajaran
        int semester
        string hari
        time jam_mulai
        time jam_selesai
        string ruangan
    }
    
    kelas_dosen {
        int id_kelas_dosen PK
        int id_kelas FK
        string nip_dosen FK
        int id_matakuliah FK
        string hari
        time jam_mulai
        time jam_selesai
        string ruangan
        string tahun_ajaran
        int semester
    }
    
    pertemuan {
        int id_pertemuan PK
        int id_kelas FK
        int pertemuan_ke
        string topik
        date tanggal
    }
    
    sesi_absensi {
        int id_sesi PK
        int id_pertemuan FK
        string kode_sesi
        string qr_data
        datetime waktu_buka
        int durasi_menit
        string status_sesi
    }
    
    absensi {
        int id_absensi PK
        string nim FK
        int id_pertemuan FK
        datetime waktu_absen
        string status
        decimal latitude
        decimal longitude
    }
```

---

## 🔐 Authentication Flow

```mermaid
sequenceDiagram
    participant Client as Flutter App
    participant API as Flask API
    participant DB as Database
    
    Client->>API: POST /auth/login<br/>{username, password}
    API->>DB: Query user by username
    DB-->>API: User data
    API->>API: Verify password hash
    API->>API: Generate JWT token
    API-->>Client: {token, user_data}
    
    Note over Client: Store token in<br/>secure storage
    
    Client->>API: GET /dosen/kelas<br/>Authorization: Bearer {token}
    API->>API: Verify JWT token
    API->>DB: Query kelas by NIP
    DB-->>API: Kelas data
    API-->>Client: {data: [...]}
```

---

## 📸 Face Recognition Flow

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Camera as Camera
    participant API as Flask API
    participant FaceService as Face Service
    participant DB as Database
    
    Note over App,Camera: Registration Phase
    App->>Camera: Open camera
    Camera-->>App: Camera preview
    App->>Camera: Capture photo
    Camera-->>App: Image file
    App->>API: POST /register-face<br/>{nim/nip, image}
    API->>FaceService: Encode face
    FaceService-->>API: Face encoding
    API->>DB: Store encoding
    DB-->>API: Success
    API-->>App: {success: true}
    
    Note over App,Camera: Verification Phase
    App->>Camera: Capture photo
    Camera-->>App: Image file
    App->>API: POST /verify-face<br/>{nim/nip, image}
    API->>DB: Get stored encoding
    DB-->>API: Stored encoding
    API->>FaceService: Compare faces
    FaceService-->>API: Match result
    API-->>App: {match: true/false}
```

---

## 🎫 QR Code Absensi Flow

```mermaid
sequenceDiagram
    participant Dosen as Dosen App
    participant API as Flask API
    participant DB as Database
    participant Mhs as Mahasiswa App
    
    Note over Dosen,DB: Dosen Opens Session
    Dosen->>API: POST /dosen/open-sesi<br/>{id_kelas}
    API->>DB: Create pertemuan
    API->>DB: Create sesi_absensi
    API->>API: Generate kode_sesi
    API->>API: Generate QR data<br/>{id_sesi, kode_sesi, timestamp}
    API-->>Dosen: {qr_data, id_sesi, pertemuan_ke}
    Dosen->>Dosen: Display QR Code
    
    Note over Mhs,DB: Mahasiswa Scans QR
    Mhs->>Mhs: Scan QR Code
    Mhs->>API: GET /sesi-info/{id_sesi}
    API->>DB: Validate session
    DB-->>API: Session data
    API-->>Mhs: {valid: true, session_info}
    
    Mhs->>Mhs: Capture face photo
    Mhs->>API: POST /absensi/submit<br/>{id_sesi, qr_data, face_image, location}
    API->>DB: Verify session active
    API->>API: Verify QR data
    API->>API: Verify face match
    API->>API: Verify location
    API->>DB: Insert absensi record
    DB-->>API: Success
    API-->>Mhs: {success: true}
```

---

## 📁 Project Structure

```
Absensi-main/
├── backend/
│   └── server/
│       ├── app.py                 # Main Flask application
│       ├── database/
│       │   └── db.py             # Database connection
│       ├── routes/
│       │   ├── auth_routes.py    # Authentication endpoints
│       │   ├── admin_routes.py   # Admin CRUD endpoints
│       │   ├── dosen_routes.py   # Dosen endpoints
│       │   ├── mahasiswa_routes.py
│       │   └── absensi_routes.py
│       ├── services/
│       │   ├── admin_service.py
│       │   ├── dosen_service.py
│       │   ├── mahasiswa_service.py
│       │   ├── absensi_service.py
│       │   └── face_service.py   # Face recognition logic
│       └── utils/
│           └── jwt_auth.py       # JWT utilities
│
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── app_colors.dart
│   │   ├── constants.dart
│   │   └── theme.dart
│   ├── models/
│   │   ├── kelas_model.dart
│   │   ├── sesi_model.dart
│   │   └── user_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart    # Riverpod state
│   │   ├── dosen_provider.dart
│   │   └── mahasiswa_provider.dart
│   ├── services/
│   │   ├── auth_service.dart     # API calls
│   │   ├── admin_service.dart
│   │   ├── dosen_service.dart
│   │   └── mahasiswa_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── splash_screen.dart
│   │   ├── admin/
│   │   │   ├── admin_dashboard.dart
│   │   │   ├── dosen_management_screen.dart
│   │   │   ├── mahasiswa_management_screen.dart
│   │   │   ├── matakuliah_management_screen.dart
│   │   │   ├── kelas_management_screen.dart
│   │   │   └── kelas_assignment_screen.dart
│   │   ├── dosen/
│   │   │   ├── dosen_dashboard.dart
│   │   │   ├── kelas_detail_screen.dart
│   │   │   ├── open_sesi_screen.dart
│   │   │   ├── active_sessions_screen.dart
│   │   │   ├── pertemuan_detail_screen.dart
│   │   │   ├── dosen_face_registration_screen.dart
│   │   │   └── dosen_face_verify_screen.dart
│   │   └── mahasiswa/
│   │       ├── mahasiswa_dashboard.dart
│   │       ├── mahasiswa_pertemuan_list_screen.dart
│   │       ├── scan_qr_absensi_screen.dart
│   │       ├── absensi_screen.dart
│   │       └── face_registration_screen.dart
│   └── widgets/
│       └── gradient_background.dart
│
└── database/
    └── absensi_pnl.sql           # Database schema
```

---

## 🚀 Installation & Setup

### Backend Setup

1. **Install Python dependencies:**
```bash
cd backend/server
pip install flask flask-cors pymysql face_recognition pillow pyjwt python-dotenv
```

2. **Configure database:**
```bash
# Import database schema
mysql -u root -p < database/absensi_pnl.sql
```

3. **Update config:**
```python
# backend/server/database/db.py
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',
    'database': 'absensi_pnl'
}
```

4. **Run server:**
```bash
python app.py
# Server runs on http://0.0.0.0:5000
```

### Frontend Setup

1. **Install Flutter dependencies:**
```bash
flutter pub get
```

2. **Update API endpoint:**
```dart
// lib/config/constants.dart
static const String baseUrl = 'http://YOUR_IP:5000';
```

3. **Run app:**
```bash
flutter run
```

---

## 🔑 Default Login Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Dosen | 202357301001 | dosen123 |
| Mahasiswa | 2023573010085 | mahasiswa123 |

---

## ✨ Key Features

### Admin Features
- ✅ CRUD Dosen, Mahasiswa, Mata Kuliah, Kelas
- ✅ Assign dosen ke kelas dengan jadwal spesifik
- ✅ Manajemen multi-assignment (dosen bisa mengajar kelas yang sama di waktu berbeda)

### Dosen Features
- ✅ Face registration & verification sebelum buka sesi
- ✅ Generate QR code untuk sesi absensi
- ✅ Auto-generate pertemuan_ke
- ✅ Monitor kehadiran real-time
- ✅ Lihat daftar kehadiran per pertemuan
- ✅ Tutup sesi absensi

### Mahasiswa Features
- ✅ Face registration untuk verifikasi
- ✅ Scan QR code untuk absensi
- ✅ Face verification saat submit absensi
- ✅ Location verification
- ✅ Lihat daftar 16 pertemuan per mata kuliah
- ✅ Status kehadiran per pertemuan (Hadir/Tidak Hadir/Belum Ada Sesi)

---

## 🎨 UI/UX Features

- ✅ Gradient background consistency across all screens
- ✅ Modern AppBar with proper theming
- ✅ Full-screen camera preview (no black areas)
- ✅ Responsive time pickers for schedule input
- ✅ Card-based layouts with shadows
- ✅ Smooth animations and transitions
- ✅ Color-coded status indicators

---

## 🔒 Security Features

- JWT-based authentication
- Password hashing (bcrypt recommended)
- Face encoding storage (not raw images)
- QR code with timestamp validation
- Session expiration (durasi_menit)
- Location-based verification
- API route protection with decorators

---

## 📊 Business Rules

1. **Pertemuan**: Auto-generated 1-16 per kelas
2. **Sesi Absensi**: Hanya bisa dibuka oleh dosen yang ter-assign
3. **Face Verification**: Required untuk dosen (buka sesi) dan mahasiswa (absensi)
4. **QR Code**: Valid hanya untuk sesi yang aktif
5. **Location**: Mahasiswa harus dalam radius tertentu
6. **Status Sesi**: `aktif` (bisa absen) atau `selesai` (tidak bisa absen)

---

## 🐛 Known Issues & Solutions

### Issue: Session not found
**Solution**: Restart backend, ensure data integrity in `sesi_absensi` table

### Issue: Face not recognized
**Solution**: Re-register face with better lighting and clear frontal photo

### Issue: QR scan timeout
**Solution**: Ensure sesi is still active (check durasi_menit)

---

## 📝 Development Notes

### Recent Updates
- ✅ Fixed schedule display using `kelas_dosen` table
- ✅ Added schedule fields to kelas management form
- ✅ Fixed UI backgrounds to full screen
- ✅ Fixed camera preview aspect ratio
- ✅ Removed unused Riwayat & Statistik features
- ✅ Consistent gradient theming across all screens

### Future Enhancements
- [ ] Push notifications for new sesi
- [ ] Export attendance to Excel
- [ ] Analytics dashboard untuk admin
- [ ] Multi-language support
- [ ] Dark mode toggle

---

## 📞 Support

For issues or questions, contact the development team or create an issue in the repository.

---

## 📄 License

This project is for educational purposes. All rights reserved.

---

**Made with ❤️ for PNL Campus**
