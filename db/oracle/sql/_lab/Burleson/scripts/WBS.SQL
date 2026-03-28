/*  */
rem: Reports on write batch size
rem: (average write queue length)
SELECT kviival write_batch_size
FROM x$kvii
WHERE kviidsc = 'DB writer IO clump'
OR kviitag = 'kcbswc'
/
