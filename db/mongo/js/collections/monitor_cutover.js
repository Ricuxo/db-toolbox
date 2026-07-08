// monitor_cutover.js
// Monitora apenas as collections PIX que estão sendo cortadas no cutover

var COLLECTIONS_MONITORADAS = [
  "accountblockrefunds", "localholidays", "pixaccounts",
  "pixclaims", "pixdictentries", "pixdictentriestimes",
  "pixdictremoveds", "pixdicts", "pixfraudmarks",
  "pixfundsrecoveries", "pixinfractions", "pixliquidationperdates",
  "pixqrcodeblockeds", "pixqrcodejwks", "pixqrcodes",
  "pixrecurringauthorizations",  // ← adicionar
  "pixrecurringqrcodes",
  "pixrecurringschedulings",     // ← adicionar
  "pixrefunds", "pixtimespertransactions",
  "pixtransactionbatches", "pixtransactions"
];

var NODES = [
  { host: "10.100.97.80", port: 27017 },
  { host: "10.100.97.81", port: 27017 },
  { host: "10.100.97.82", port: 27017 },
  { host: "10.100.97.199", port: 27017 }
];

function checkNode(node) {
  var connStr = "mongodb://admin:topazprd@" + node.host + ":" + node.port + "/admin?authSource=admin";
  var conn;
  try {
    conn = Mongo(connStr);
  } catch (e) {
    print("  [ERRO conectando " + node.host + "]: " + e);
    return;
  }

  var adminDb = conn.getDB("admin");
  var ops = adminDb.currentOp({ "active": true }).inprog;

  ops.forEach(op => {
    if (!op.ns) return;

    var parts = op.ns.split(".");
    if (parts[0] !== "transfer") return;

    var collName = parts.slice(1).join(".");
    if (COLLECTIONS_MONITORADAS.indexOf(collName) === -1) return;

    var user = op.effectiveUsers ? op.effectiveUsers[0].user : "n/a";
    if (user === "shake_user") return; // ignora o MongoShake

    print("  [" + node.host + "] client=" + op.client +
          " | ns=" + op.ns +
          " | op=" + op.op +
          " | user=" + user +
          " | secs_running=" + op.secs_running);
  });
}

while (true) {
  print(new Date().toISOString() + " - Verificando " + NODES.length + " nós...");
  NODES.forEach(checkNode);
  print("---");
  sleep(5000);
}



/*
Forma de usar
mongosh --host 10.100.97.82 --port 27017 -u admin -p 'SENHA_RS0' --authenticationDatabase admin  --eval 'load("/root/migracao/monitor_cutover.js")'
*/