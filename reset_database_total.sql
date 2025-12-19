-- =====================================================
-- RESET TOTAL DATABASE - HAPUS SEMUA DATA
-- =====================================================
-- PERINGATAN: Query ini akan menghapus SEMUA DATA!
-- Hanya akan menyisakan user admin saja (dari tabel users).
-- PASTIKAN SUDAH BACKUP DATABASE SEBELUM MENJALANKAN!
-- =====================================================

-- ========================================
-- BAGIAN 1: BACKUP DATABASE (WAJIB!)
-- ========================================
-- Sebelum menjalankan, lakukan backup dengan mysqldump:
-- mysqldump -u root -p nama_database > backup_$(date +%Y%m%d).sql
--
-- Atau export via phpMyAdmin / MySQL Workbench

-- ========================================
-- BAGIAN 2: CEK DATA YANG AKAN DIHAPUS
-- ========================================

-- Cek jumlah data di setiap tabel
SELECT 'absensi' as tabel, COUNT(*) as jumlah FROM absensi
UNION ALL
SELECT 'barcode', COUNT(*) FROM barcode
UNION ALL
SELECT 'sesi_absensi', COUNT(*) FROM sesi_absensi
UNION ALL
SELECT 'pertemuan', COUNT(*) FROM pertemuan
UNION ALL
SELECT 'kelas_dosen', COUNT(*) FROM kelas_dosen
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM dosen
UNION ALL
SELECT 'kelas', COUNT(*) FROM kelas
UNION ALL
SELECT 'matakuliah', COUNT(*) FROM matakuliah
UNION ALL
SELECT 'users', COUNT(*) FROM users;

-- Cek detail users (lihat siapa saja yang ada)
SELECT id, username, email, level FROM users ORDER BY level, username;

-- ========================================
-- BAGIAN 3: DISABLE FOREIGN KEY CHECKS
-- ========================================
-- Temporary disable untuk mempermudah penghapusan
SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
-- BAGIAN 4: HAPUS SEMUA DATA (URUT DARI CHILD KE PARENT)
-- ========================================
-- GUNAKAN DELETE FROM karena TRUNCATE tidak bisa dengan FK constraint
-- Urutan penting: hapus child dulu, baru parent

-- 1. Hapus semua absensi (child dari sesi dan pertemuan)
DELETE FROM absensi;

-- 2. Hapus semua barcode (child dari sesi)
DELETE FROM barcode;

-- 3. Hapus semua sesi absensi (child dari pertemuan)
DELETE FROM sesi_absensi;

-- 4. Hapus semua pertemuan (child dari kelas)
DELETE FROM pertemuan;

-- 5. Hapus semua relasi kelas_dosen
DELETE FROM kelas_dosen;

-- 6. Hapus semua mahasiswa
DELETE FROM mahasiswa;

-- 7. Hapus semua kelas
DELETE FROM kelas;

-- 8. Hapus semua mata kuliah (harus sebelum dosen karena FK nip_dosen)
DELETE FROM matakuliah;

-- 9. Hapus semua dosen (setelah matakuliah karena ada FK)
DELETE FROM dosen;

-- 10. Hapus user NON-ADMIN dari tabel users
-- Hanya keep user dengan level = 'admin'
DELETE FROM users WHERE level != 'admin';

-- Atau jika ingin keep username tertentu:
-- DELETE FROM users WHERE username NOT IN ('admin', 'superadmin');

-- ========================================
-- BAGIAN 5: RESET AUTO_INCREMENT
-- ========================================
-- Reset counter ID agar mulai dari 1 lagi

ALTER TABLE absensi AUTO_INCREMENT = 1;
ALTER TABLE barcode AUTO_INCREMENT = 1;
ALTER TABLE sesi_absensi AUTO_INCREMENT = 1;
ALTER TABLE pertemuan AUTO_INCREMENT = 1;
ALTER TABLE kelas_dosen AUTO_INCREMENT = 1;
ALTER TABLE mahasiswa AUTO_INCREMENT = 1;
ALTER TABLE dosen AUTO_INCREMENT = 1;
ALTER TABLE kelas AUTO_INCREMENT = 1;
ALTER TABLE matakuliah AUTO_INCREMENT = 1;
-- users AUTO_INCREMENT tidak direset agar ID admin tetap

-- ========================================
-- BAGIAN 6: RE-ENABLE FOREIGN KEY CHECKS
-- ========================================
SET FOREIGN_KEY_CHECKS = 1;

-- ========================================
-- BAGIAN 7: VERIFIKASI PENGHAPUSAN
-- ========================================

-- Cek kembali jumlah data (seharusnya semua 0, kecuali users)
SELECT 'absensi' as tabel, COUNT(*) as jumlah FROM absensi
UNION ALL
SELECT 'barcode', COUNT(*) FROM barcode
UNION ALL
SELECT 'sesi_absensi', COUNT(*) FROM sesi_absensi
UNION ALL
SELECT 'pertemuan', COUNT(*) FROM pertemuan
UNION ALL
SELECT 'kelas_dosen', COUNT(*) FROM kelas_dosen
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM dosen
UNION ALL
SELECT 'kelas', COUNT(*) FROM kelas
UNION ALL
SELECT 'matakuliah', COUNT(*) FROM matakuliah
UNION ALL
SELECT 'users', COUNT(*) FROM users;

-- Cek users yang tersisa (seharusnya hanya admin)
SELECT id, username, email, level FROM users;

-- ========================================
-- BAGIAN 8: INSERT DATA SAMPLE (OPTIONAL)
-- ========================================
-- Jika ingin insert data sample untuk testing

-- Insert mata kuliah sample
INSERT INTO matakuliah (kode_mk, nama_matakuliah, sks) VALUES
('KB001', 'Kecerdasan Buatan', 3),
('PW001', 'Pemrograman Web', 3),
('BD001', 'Basis Data', 3);

-- Insert kelas sample dengan jadwal lengkap
INSERT INTO kelas (nama_kelas, id_matakuliah, hari, jam_mulai, jam_selesai, ruangan) VALUES
('TI-3E', 1, 'Senin', '08:00:00', '10:00:00', 'Lab 1'),
('TIF-3A', 2, 'Selasa', '13:00:00', '15:00:00', 'Lab 2'),
('TIF-3B', 3, 'Rabu', '10:00:00', '12:00:00', 'Lab 3');

-- Insert dosen sample
-- CATATAN: Hash password harus dibuat dengan method yang sama dengan backend
-- Contoh: werkzeug.security.generate_password_hash('password123')
INSERT INTO dosen (nip, nama, email, password, face_registered) VALUES
('198501012010121001', 'Dr. Ahmad Hidayat, M.Kom', 'ahmad@univ.ac.id', 'scrypt:32768:8:1$HASH_HERE', 0),
('198601012010112001', 'Dr. Siti Nurhaliza, M.T', 'siti@univ.ac.id', 'scrypt:32768:8:1$HASH_HERE', 0);

-- Insert mahasiswa sample
INSERT INTO mahasiswa (nim, nama, email, password, id_kelas) VALUES
('202357301085', 'Ichsan Maulana', 'ichsan@student.ac.id', 'scrypt:32768:8:1$HASH_HERE', 1),
('202357301086', 'Budi Santoso', 'budi@student.ac.id', 'scrypt:32768:8:1$HASH_HERE', 1);

-- Assign dosen ke kelas
INSERT INTO kelas_dosen (id_kelas, nip_dosen, id_matakuliah, tahun_ajaran, semester) VALUES
(1, '198501012010121001', 1, '2024/2025', 'Ganjil'),
(2, '198501012010121001', 2, '2024/2025', 'Ganjil'),
(2, '198601012010112001', 2, '2024/2025', 'Ganjil'),
(3, '198601012010112001', 3, '2024/2025', 'Ganjil');

-- ========================================
-- SELESAI!
-- ========================================
-- Setelah menjalankan query ini:
-- 1. Logout dari semua akun di Flutter
-- 2. Hot restart aplikasi Flutter (tekan 'R' di terminal)
-- 3. Login kembali dengan:
--    - Admin: username & password sesuai user admin yang tersisa
--    - Dosen & Mahasiswa: harus dibuat ulang (atau gunakan sample di atas)
--
-- Database sekarang bersih dan siap untuk digunakan dari awal!
-- Hanya user ADMIN yang tersisa, semua data lain sudah dihapus.
-- ========================================
