/* Listar roles atribuidas aos usuários do MongoDB */
/* Para executar: 
   mongosh list_roles.js
   mongosh list_roles.js */

/* Encontrar roles atribuídas mas que não existem */

use admin

var rolesCriadas = db.system.roles.find().toArray().map(r => r.role + "@" + r.db)

db.system.users.aggregate([
    { $unwind: "$roles" },
    {
        $project: {
            role: { $concat: ["$roles.role", "@", "$roles.db"] }
        }
    }
]).forEach(function (r) {
    if (!rolesCriadas.includes(r.role)) {
        print("ROLE NÃO EXISTE: " + r.role)
    }
})