clear screen
prompt  #    ########     ###    ########    ###    ########     ###     ######  ########      #
prompt  #    ##     ##   ## ##      ##      ## ##   ##     ##   ## ##   ##    ## ##            #
prompt  #    ##     ##  ##   ##     ##     ##   ##  ##     ##  ##   ##  ##       ##            #
prompt  #    ##     ## ##     ##    ##    ##     ## ########  ##     ##  ######  ######        #
prompt  #    ##     ## #########    ##    ######### ##     ## #########       ## ##            #
prompt  #    ##     ## ##     ##    ##    ##     ## ##     ## ##     ## ##    ## ##            #
prompt  #    ########  ##     ##    ##    ##     ## ########  ##     ##  ######  ########      #
prompt  #                                                                                      #
prompt  ########################################################################################
prompt 
prompt  ################################### A6  Environment ####################################
prompt  
prompt  A6NXTL01  A6NXTL03  A6NXTL05  A6NXTL07  A6NXTL08  A6NXTL8R  A6NXTL11  A6NXTL15  A6NXTL16
prompt  A6NXTL19  A6NXTL25  A6NXTL26  A6NXTL27  A6NXTL28  A6NXTL29  A6NXTL32  A6NXTL33
prompt  
prompt  ################################### A3  Environment ####################################
prompt  
prompt  A3NXTL01  A3NXTL03  A3NXTL05  A3NXTL07  A3NXTL08  A3NXTL8R  A3NXTL11  A3NXTL15  A3NXTL16
prompt  A3NXTL19  A3NXTL25  A3NXTL26  A3NXTL27  A3NXTL28  A3NXTL29  A3NXTL32  A3NXTL33
prompt  
prompt  ################################### H6  Environment ####################################
prompt  
prompt  H6NXTL01  H6NXTL03  H6NXTL05  H6NXTL07  H6NXTL08  H6NXTL8R  H6NXTL11  H6NXTL15  H6NXTL16
prompt  H6NXTL19  H6NXTL26  H6NXTL27  H6NXTL28  H6NXTL29  H6NXTL32  H6NXTL33  H6NXTL34  H6NXTL35
prompt  
prompt  ################################### T11 Environment ####################################
prompt  
prompt  T11NBR03  T11NBR05  T11NBR08  T11NBR8R
prompt  
prompt  ################################### T12 Environment ####################################
prompt  
prompt  T12NBR01  T12NBR03  T12NBR08  T12NBR8R  T12NBR28
prompt  
prompt  ################################### D12 Environment ####################################
prompt  
prompt  D12NBR01  D12NBR03  D12NBR07  D12NBR08  D12NBR8R  D12NBR19  D12NBR28
prompt  
prompt  ######################################## OTHERS ########################################
prompt  
prompt  D5NXTL01  D6NXTL01  D6NXTL03  D6NXTL26  D6NXTL28  DNXTL12
prompt  
prompt  ###################################     MY LAB      ####################################
prompt  LAB11021 or LAB
prompt  
prompt    
prompt  Type your option.:
accept OPTION
  
host title &OPTION - Database Administration 
conn IT_CTPRAND2@&&OPTION
undefine OPTION

@reset
@idb.sql
