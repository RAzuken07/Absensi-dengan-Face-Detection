-- Diagnostic queries untuk masalah "Mata Kuliah" tidak tampil nama yang benar

-- 1. Cek data kelas untuk dosen tertentu (ganti NIP sesuai)
SELECT 
    k.id_kelas,
    k.nama_kelas,
    k.id_matakuliah,
    mk.nama_matakuliah,
    mk.kode_mk,
    kd.tahun_ajaran,
    kd.semester
FROM kelas_dosen kd
JOIN kelas k ON kd.id_kelas = k.id_kelas
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE kd.nip_dosen = '198501012010121001'  -- Ganti dengan NIP dosen yang login
ORDER BY k.nama_kelas;

-- 2. Cek apakah id_matakuliah di tabel kelas valid
SELECT 
    k.id_kelas,
    k.nama_kelas,
    k.id_matakuliah,
    CASE 
        WHEN k.id_matakuliah IS NULL THEN 'NULL - Tidak ada mata kuliah'
        WHEN mk.id_matakuliah IS NULL THEN 'INVALID - Mata kuliah tidak ditemukan'
        ELSE CONCAT('VALID - ', mk.nama_matakuliah)
    END as status_matakuliah
FROM kelas k
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE k.id_kelas IN (
    SELECT id_kelas FROM kelas_dosen WHERE nip_dosen = '198501012010121001'
);

-- 3. Cek semua mata kuliah yang tersedia
SELECT * FROM matakuliah;

-- 4. Fix untuk kelas yang id_matakuliah-nya NULL atau invalid
-- JANGAN jalankan ini dulu, cuma contoh jika perlu fix
-- UPDATE kelas SET id_matakuliah = 1 WHERE id_kelas = 4;  -- Ganti dengan ID yang sesuai
