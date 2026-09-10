/*reset de senha de usuário*/
db.getSiblingDB("admin").changeUserPassword("nome_do_usuario", passwordPrompt());
db.getSiblingDB("admin").(changeUserPassword("user", "senha123"));

/*O passwordPrompt() faz o mongosh pedir a senha interativamente, sem gravar em texto claro no histórico do shell nem no .dbshell. 
/*Em produção, especialmente PIX, não passe a senha inline (changeUserPassword("user", "senha123")) — ela fica no history do shell 
e pode cair no log de auditoria/system.profile.*/
