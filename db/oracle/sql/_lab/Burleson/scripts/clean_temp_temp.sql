/*  */
rem Used to clean up temp segments in temporary tablespace
rem x is the temp tablespace number in TS$ plus 1
rem
ALTER SESSION SET EVENTS 'IMMEDIATE TRACE NAME DROP_SEGMENTS LEVEL &x';
