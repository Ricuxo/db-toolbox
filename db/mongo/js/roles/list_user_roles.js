/* Listar roles atribuidas aos usuários do MongoDB */
/* Para executar: 
   mongosh list_roles.js
   mongosh list_roles.js */
   
use admin

db.system.users.aggregate([
    { $unwind: "$roles" },
    {
        $group: {
            _id: { role: "$roles.role", db: "$roles.db" }
        }
    },
    { $sort: { "_id.role": 1 } }
])
