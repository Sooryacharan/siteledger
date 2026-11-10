-- Names an area revision in the audit log. Projects and Units writes one row per changed area.
ALTER TYPE "RecordRef" ADD VALUE IF NOT EXISTS 'UNIT_AREA_REVISION';
