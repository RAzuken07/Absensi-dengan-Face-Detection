-- Fix Schedule Data untuk Kelas
-- Masalah: hari, jam_mulai, jam_selesai kosong/NULL

-- LANGKAH 1: Cek data jadwal kelas saat ini
SELECT 
    id_kelas,
    nama_kelas,
    hari,
    jam_mulai,
    jam_selesai,
    ruangan
FROM kelas
WHERE id_kelas IN (4, 6);  -- TI-3E dan TIF-3A

-- LANGKAH 2: Update jadwal untuk kelas TI-3E (id_kelas = 4)
UPDATE kelas
SET 
    hari = 'Senin',           -- Sesuaikan dengan jadwal sebenarnya
    jam_mulai = '08:00:00',   -- Format TIME: HH:MM:SS
    jam_selesai = '10:00:00',
    ruangan = 'Lab 1'         -- Opsional
WHERE id_kelas = 4;

-- LANGKAH 3: Update jadwal untuk kelas TIF-3A (id_kelas = 6)  
UPDATE kelas
SET 
    hari = 'Selasa',          -- Sesuaikan dengan jadwal sebenarnya
    jam_mulai = '13:00:00',
    jam_selesai = '15:00:00',
    ruangan = 'Lab 2'
WHERE id_kelas = 6;

-- LANGKAH 4: Verifikasi hasil
SELECT 
    k.id_kelas,
    k.nama_kelas,
    k.hari,
    k.jam_mulai,
    k.jam_selesai,
    k.ruangan,
    mk.nama_matakuliah
FROM kelas k
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
WHERE k.id_kelas IN (4, 6);

-- ===== CONTOH UPDATE MULTIPLE KELAS SEKALIGUS =====
-- Jika semua kelas belum punya jadwal, bisa update batch:

-- Update semua kelas dengan jadwal default
UPDATE kelas
SET 
    hari = CASE id_kelas
        WHEN 4 THEN 'Senin'
        WHEN 6 THEN 'Selasa'
        ELSE hari
    END,
    jam_mulai = CASE id_kelas  
        WHEN 4 THEN '08:00:00'
        WHEN 6 THEN '13:00:00'
        ELSE jam_mulai
    END,
    jam_selesai = CASE id_kelas
        WHEN 4 THEN '10:00:00'
        WHEN 6 THEN '15:00:00'
        ELSE jam_selesai
    END
WHERE id_kelas IN (4, 6);

-- Setelah update, restart aplikasi Flutter untuk melihat perubahan!
