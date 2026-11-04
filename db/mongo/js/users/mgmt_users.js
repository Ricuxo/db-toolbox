/*drop user*/

db.dropUser("carlosfabri")


/*create user*/
db.createUser({
  user: "cassianogazzo",
  pwd: "jQZ2FyqBtLvTk4Tx",
  roles: [
    { role: "read", db: "tpz-core-people" }
  ]
})


/* reset user password */

db.getSiblingDB("admin").changeUserPassword("nome_do_usuario", passwordPrompt())


/* grant roles */

db.grantRolesToUser(
  "NOME_USUARIO",
  [
      { role: "read", db: "termica" }
  ]
)

/* Comando	          Comportamento
grantRolesToUser()	  Adiciona uma role sem remover as existentes.
updateUser()	        Substitui a lista de roles pelas informadas. */

db.updateUser("nome_do_usuario", {
  roles: [
      { role: "read", db: "termica" }
  ]
})