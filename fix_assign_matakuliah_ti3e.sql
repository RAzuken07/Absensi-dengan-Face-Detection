-- Fix Query untuk Assign Mata Kuliah ke Kelas TI-3E
-- Masalah: id_matakuliah = NULL untuk kelas TI-3E (id_kelas = 4)

-- LANGKAH 1: Cek semua mata kuliah yang tersedia
SELECT id_matakuliah, kode_mk, nama_matakuliah, sks 
FROM matakuliah
ORDER BY nama_matakuliah;

-- LANGKAH 2: Update kelas TI-3E dengan mata kuliah "Kecerdasan Buatan"
-- PENTING: Cek dulu ID mata kuliah "Kecerdasan Buatan" dari query LANGKAH 1
-- Contoh jika id_matakuliah untuk "Kecerdasan Buatan" adalah 2:

UPDATE kelas 
SET id_matakuliah = 2  -- Ganti dengan ID yang sesuai dari LANGKAH 1
WHERE id_kelas = 4;

-- LANGKAH 3: Verifikasi hasil update
SELECT 
    k.id_kelas,
    k.nama_kelas,
    k.id_matakuliah,
    mk.nama_matakuliah,
    mk.kode_mk
FROM kelas k
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE k.id_kelas = 4;

-- ===== QUERY LENGKAP (All in one) =====
-- Jika ingin otomatis tanpa cek manual, gunakan ini:
-- Asumsi: Mata kuliah "Kecerdasan Buatan" sudah ada di database

-- Cari ID mata kuliah Kecerdasan Buatan dan update langsung
UPDATE kelas k
SET k.id_matakuliah = (
    SELECT id_matakuliah 
    FROM matakuliah 
    WHERE nama_matakuliah LIKE '%Kecerdasan Buatan%' 
    LIMIT 1
)
WHERE k.id_kelas = 4;

-- Jika belum ada mata kuliah "Kecerdasan Buatan", insert dulu:
INSERT INTO matakuliah (kode_mk, nama_matakuliah, sks)
VALUES ('KB001', 'Kecerdasan Buatan', 3);

-- Lalu update kelas-nya dengan ID yang baru di-insert
UPDATE kelas 
SET id_matakuliah = LAST_INSERT_ID()
WHERE id_kelas = 4;
