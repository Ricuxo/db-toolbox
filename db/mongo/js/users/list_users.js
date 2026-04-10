use admin

// Método 1 (API)
db.getUsers().users.map(u => u.user)

// Método 2 (coleção interna)
db.system.users.find({}, { user: 1, _id: 0 })