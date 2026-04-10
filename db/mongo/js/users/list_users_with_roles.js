use admin

// Método 1 (API)
db.getUsers().users.map(u => ({ user: u.user, roles: u.roles }))

// Método 2 (coleção interna)
db.system.users.find({}, { user: 1, roles: 1, _id: 0 })