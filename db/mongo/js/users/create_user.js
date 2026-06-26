db.createUser({
    user: "psinsotavio",
    pwd: "wqx9znj#FTV1haj#zfu",
    roles: [
        { role: "IPsPermitidos_users", db: "admin" },
        { role: "read", db: "transfer" }
    ],
    mechanisms: ["SCRAM-SHA-256"],
    passwordDigestor: "server"
})


db.createUser({
    user: "psaginichollas",
    pwd: "zsd9N183c326KjKqC2m",
    roles: [
        { role: "IPsPermitidos_users", db: "admin" },
        { role: "read", db: "transfer" }
    ],
    mechanisms: ["SCRAM-SHA-256"],
    passwordDigestor: "server"
})



// Executar no mongosh - Mais proximo de um DDL
var u = db.getUser("db_app_admin", {
    showPrivileges: false,
    showCredentials: false,
    showAuthenticationRestrictions: true
})

print("db.createUser({")
print('  user: "' + u.user + '",')
print('  pwd: passwordPrompt(),')
print('  roles: ' + JSON.stringify(u.roles, null, 4) + ',')

if (u.authenticationRestrictions && u.authenticationRestrictions.length > 0) {
    print('  authenticationRestrictions: ' + JSON.stringify(u.authenticationRestrictions, null, 4) + ',')
}

print('  mechanisms: ["SCRAM-SHA-256"],')
print('  passwordDigestor: "server"')
print("})")