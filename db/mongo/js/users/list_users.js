use admin

// Método 1 (API)
db.getUsers().users.map(u => u.user)

// Método 2 (coleção interna)
db.system.users.find({}, { user: 1, _id: 0 })

db.system.users.find({ user: "psdbcluciele" }, { user: 1, db: 1, roles: 1 })

// trazer todos os usuários do banco de dados
db.system.users.find({}, { user: 1, _id: 0 }).toArray()