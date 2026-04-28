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
    user: "psdbconmarcos",
    pwd: "zsd9N183c##6KjKqC2m",
    roles: [
        { role: "IPsPermitidos_users", db: "admin" },
        { role: "read", db: "transfer" }
    ],
    mechanisms: ["SCRAM-SHA-256"],
    passwordDigestor: "server"
})
