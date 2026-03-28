----CRIAR RESTORE POINT CHAMADO CLEAN_DB
create restore point CLEAN_DB guarantee flashback database;

----VOLTAR O BANCO PARA O RESTORE POINT CRIADO
flashback database to restore point CLEAN_DB;


-----REMOVE O RESTORE POINT
drop restore point CLEAN_DB


link para nota https://share.evernote.com/note/324ef0ba-2baa-4254-9f51-01f7a9314ff5