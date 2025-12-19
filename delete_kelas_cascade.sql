-- Query untuk Menghapus Kelas dan Semua Data Terkait
-- PERINGATAN: Akan menghapus semua data termasuk pertemuan, sesi, dan absensi!

-- ========================================
-- BAGIAN 1: CEK DATA SEBELUM DIHAPUS
-- ========================================

-- 1. Lihat semua kelas yang ada
SELECT 
    k.id_kelas,
    k.nama_kelas,
    mk.nama_matakuliah,
    kd.nip_dosen,
    d.nama as nama_dosen,
    COUNT(DISTINCT p.id_pertemuan) as jumlah_pertemuan,
    COUNT(DISTINCT s.id_sesi) as jumlah_sesi,
    COUNT(DISTINCT a.id_absensi) as jumlah_absensi
FROM kelas k
LEFT JOIN kelas_dosen kd ON k.id_kelas = kd.id_kelas
LEFT JOIN dosen d ON kd.nip_dosen = d.nip
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
LEFT JOIN pertemuan p ON p.id_kelas = k.id_kelas
LEFT JOIN sesi_absensi s ON s.id_pertemuan = p.id_pertemuan
LEFT JOIN absensi a ON a.id_pertemuan = p.id_pertemuan
GROUP BY k.id_kelas, k.nama_kelas, mk.nama_matakuliah, kd.nip_dosen, d.nama
ORDER BY k.id_kelas;

-- 2. Cek mahasiswa yang terdaftar di kelas
SELECT 
    k.id_kelas,
    k.nama_kelas,
    COUNT(m.nim) as jumlah_mahasiswa
FROM kelas k
LEFT JOIN mahasiswa m ON m.id_kelas = k.id_kelas
GROUP BY k.id_kelas, k.nama_kelas;

-- ========================================
-- BAGIAN 2: HAPUS KELAS TERTENTU
-- ========================================

-- CONTOH: Hapus kelas "Pemrograman Web - TIF-3A" yang belum ada jadwal
-- Ganti id_kelas sesuai dengan yang ingin dihapus

-- Langkah-langkah penghapusan (CASCADE):
-- 1. Hapus absensi
-- 2. Hapus barcode
-- 3. Hapus sesi_absensi
-- 4. Hapus pertemuan
-- 5. Hapus relasi kelas_dosen
-- 6. Update mahasiswa.id_kelas menjadi NULL
-- 7. Hapus kelas

SET @id_kelas_to_delete = 6;  -- Ganti dengan ID kelas yang ingin dihapus

-- 1. Hapus absensi yang terkait
DELETE a FROM absensi a
INNER JOIN pertemuan p ON a.id_pertemuan = p.id_pertemuan
WHERE p.id_kelas = @id_kelas_to_delete;

-- 2. Hapus barcode yang terkait
DELETE b FROM barcode b
INNER JOIN sesi_absensi s ON b.id_sesi = s.id_sesi
INNER JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
WHERE p.id_kelas = @id_kelas_to_delete;

-- 3. Hapus sesi_absensi yang terkait
DELETE s FROM sesi_absensi s
INNER JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
WHERE p.id_kelas = @id_kelas_to_delete;

-- 4. Hapus pertemuan
DELETE FROM pertemuan WHERE id_kelas = @id_kelas_to_delete;

-- 5. Hapus relasi di kelas_dosen
DELETE FROM kelas_dosen WHERE id_kelas = @id_kelas_to_delete;

-- 6. Set id_kelas mahasiswa menjadi NULL (optional - jika ada mahasiswa terdaftar)
UPDATE mahasiswa SET id_kelas = NULL WHERE id_kelas = @id_kelas_to_delete;

-- 7. Akhirnya, hapus kelas
DELETE FROM kelas WHERE id_kelas = @id_kelas_to_delete;

-- ========================================
-- BAGIAN 3: HAPUS MULTIPLE KELAS SEKALIGUS
-- ========================================

-- Jika ingin hapus beberapa kelas sekaligus (misalnya yang belum ada jadwal)
-- PERINGATAN: Pastikan sudah backup database!

-- Contoh: Hapus semua kelas yang hari = NULL (belum ada jadwal)
-- UNCOMMENT untuk menjalankan:

/*
DELETE a FROM absensi a
INNER JOIN pertemuan p ON a.id_pertemuan = p.id_pertemuan
INNER JOIN kelas k ON p.id_kelas = k.id_kelas
WHERE k.hari IS NULL;

DELETE b FROM barcode b
INNER JOIN sesi_absensi s ON b.id_sesi = s.id_sesi
INNER JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
INNER JOIN kelas k ON p.id_kelas = k.id_kelas
WHERE k.hari IS NULL;

DELETE s FROM sesi_absensi s
INNER JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
INNER JOIN kelas k ON p.id_kelas = k.id_kelas
WHERE k.hari IS NULL;

DELETE p FROM pertemuan p
INNER JOIN kelas k ON p.id_kelas = k.id_kelas
WHERE k.hari IS NULL;

DELETE kd FROM kelas_dosen kd
INNER JOIN kelas k ON kd.id_kelas = k.id_kelas
WHERE k.hari IS NULL;

UPDATE mahasiswa m
INNER JOIN kelas k ON m.id_kelas = k.id_kelas
SET m.id_kelas = NULL
WHERE k.hari IS NULL;

DELETE FROM kelas WHERE hari IS NULL;
*/

-- ========================================
-- BAGIAN 4: VERIFIKASI SETELAH PENGHAPUSAN
-- ========================================

-- Cek kelas yang tersisa
SELECT * FROM kelas ORDER BY id_kelas;

-- Cek kelas_dosen yang tersisa
SELECT * FROM kelas_dosen ORDER BY id_kelas;

-- Cek mahasiswa yang id_kelas-nya NULL
SELECT nim, nama, id_kelas FROM mahasiswa WHERE id_kelas IS NULL;

-- ========================================
-- CARA REFRESH DI FLUTTER
-- ========================================
-- Setelah menjalankan query di atas:
-- 1. Di aplikasi Flutter, pull down untuk refresh (RefreshIndicator)
-- 2. Atau logout dan login kembali
-- 3. Atau hot restart aplikasi

-- TIPS: Sebaiknya buat kelas baru dari Admin Panel
-- dibanding langsung di database untuk memastikan
-- semua relasi terbuat dengan benar!
