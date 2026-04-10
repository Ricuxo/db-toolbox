/* Listar roles atribuidas aos usuários do MongoDB */
/* Para executar: 
   mongosh list_roles.js
   mongosh list_roles.js */
/* Validar roles se está criada no banco correto */

use admin
var builtins = [
    "read", "readWrite", "dbAdmin", "dbOwner", "userAdmin",
    "clusterAdmin", "clusterManager", "clusterMonitor",
    "hostManager", "backup", "restore", "readAnyDatabase",
    "readWriteAnyDatabase", "userAdminAnyDatabase",
    "dbAdminAnyDatabase", "root", "__system"
];

["db_termica_admin", "opnagios"].forEach(nome => {
    print("\n╔══════════════════════════════════════════╗");
    print("║  Usuário: " + nome);
    print("╚══════════════════════════════════════════╝");

    var u = db.system.users.findOne({ user: nome }, { user: 1, roles: 1, _id: 0 });

    u.roles.forEach(r => {
        if (builtins.includes(r.role)) return;

        var existe = db.system.roles.findOne({ role: r.role, db: r.db });
        if (!existe) {
            print("   ❌ Role mal atribuída:");
            print("      role : " + r.role);
            print("      db   : " + r.db + " ← role não existe neste banco");

            // Buscar onde a role realmente existe
            var roleReal = db.system.roles.findOne({ role: r.role });
            if (roleReal) {
                print("      fix  : db deveria ser '" + roleReal.db + "'");
            }
        } else {
            print("   ✅ " + r.role + " (db: " + r.db + ")");
        }
    });
});