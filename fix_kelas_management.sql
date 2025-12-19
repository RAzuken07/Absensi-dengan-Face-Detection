-- ============================================
-- DATABASE MIGRATION: Fix Kelas Management
-- ============================================
-- This script fixes the class management issues by making id_matakuliah nullable
-- Run this script in your MySQL database before updating the application code

-- Step 1: Check current table structure
-- SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'kelas' AND COLUMN_NAME = 'id_matakuliah';

-- Step 2: Make id_matakuliah nullable in kelas table
-- This allows kelas to be created without requiring a mata kuliah
-- Course assignments will be managed through kelas_dosen table instead
ALTER TABLE kelas MODIFY COLUMN id_matakuliah INT NULL;

-- Step 3: Remove any invalid foreign key constraints if they exist
-- (This is optional - only run if you have issues with the above command)
-- ALTER TABLE kelas DROP FOREIGN KEY kelas_ibfk_1; -- adjust constraint name if different

-- Step 4: Set existing records with invalid id_matakuliah to NULL (if any)
UPDATE kelas SET id_matakuliah = NULL WHERE id_matakuliah = 0;

-- Step 5: Verify the change
SELECT 
    id_kelas,
    nama_kelas,
    id_matakuliah,
    tahun_ajaran,
    semester
FROM kelas
LIMIT 10;

-- ============================================
-- NOTES:
-- ============================================
-- 1. This makes id_matakuliah optional in the kelas table
-- 2. Course assignments should be managed via kelas_dosen table
-- 3. Backward compatible - existing data with id_matakuliah will remain
-- 4. After running this, restart your backend server
-- ============================================
