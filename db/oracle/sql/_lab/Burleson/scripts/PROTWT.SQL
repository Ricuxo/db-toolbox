/*  */
rem
rem FUNCTION SHow average wait time for MTS
rem
column protocol 				format a10
column "Average Wait Time per Response" 	format a40
rem
SELECT 
	network     "Protocol",
   	DECODE( SUM(totalq), 0, 'No Responses',
      		SUM(wait)/SUM(totalq) || ' hundredths of seconds')
   	"Average Wait Time per Response"
   FROM 
	v$queue q, 
	v$dispatcher d
   WHERE 
	q.type = 'DISPATCHER'
      	AND q.paddr = d.paddr
   GROUP BY 
	network
/
clear columns
