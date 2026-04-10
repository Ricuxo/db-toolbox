/* Listar roles atribuidas aos usuários do MongoDB */
/* Para executar: 
   mongosh list_roles.js
   mongosh list_roles.js */

/* Listar as roles existentes no MongoDB */

use admin

db.getRoles({ showPrivileges: true }).map(r => ({ role: r.role, db: r.db, privileges: r.privileges }))
db.system.roles.find({}, { role: 1, db: 1, privileges: 1, _id: 0 })

db.system.roles.aggregate([
    {
        $project: {
            role: "$role",
            db: "$db"
        }
    },
    { $sort: { role: 1 } }
])