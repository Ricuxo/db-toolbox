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