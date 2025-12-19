-- Add face recognition columns to dosen table
-- Run this migration if face_descriptor and face_registered columns don't exist

ALTER TABLE dosen 
ADD COLUMN IF NOT EXISTS face_descriptor LONGTEXT NULL,
ADD COLUMN IF NOT EXISTS face_registered TINYINT(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Update existing records to have updated_at
UPDATE dosen SET updated_at = CURRENT_TIMESTAMP WHERE updated_at IS NULL;
