// monitor_novo_cluster.js
// Monitora conexões e operações ativas no rs-pix-prd após cutover

var NODES = [
  { host: "10.100.106.86", port: 27017 },
  { host: "10.100.106.87", port: 27017 },
  { host: "10.100.106.88", port: 27017 },
  { host: "10.100.106.89", port: 27017 }
];

var COLLECTIONS_MONITORADAS = [
    "accountblockrefunds", "localholidays", "pixaccounts",
    "pixclaims", "pixdictentries", "pixdictentriestimes",
    "pixdictremoveds", "pixdicts", "pixfraudmarks",
    "pixfundsrecoveries", "pixinfractions", "pixliquidationperdates",
    "pixqrcodeblockeds", "pixqrcodejwks", "pixqrcodes",
    "pixrecurringauthorizations",
    "pixrecurringqrcodes",
    "pixrecurringschedulings",
    "pixrefunds", "pixtimespertransactions",
    "pixtransactionbatches", "pixtransactions"
];

function checkNode(node) {
  var connStr = "mongodb://admin:yhz2mtk0vcx7YAG1mbd@" + node.host + ":" + node.port + "/admin?authSource=admin";
  var conn;
  try {
    conn = Mongo(connStr);
  } catch (e) {
    print("  [ERRO conectando " + node.host + "]: " + e);
    return;
  }

  var adminDb = conn.getDB("admin");

  // Conexões ativas por usuário
  var result = adminDb.runCommand({ currentOp: 1, active: true });
  var ops = result.inprog;

  var atividadePix = [];

  ops.forEach(op => {
    if (!op.ns) return;
    var parts = op.ns.split(".");
    if (parts[0] !== "pix") return;
    var collName = parts.slice(1).join(".");
    if (COLLECTIONS_MONITORADAS.indexOf(collName) === -1) return;

    var user = op.effectiveUsers ? op.effectiveUsers[0].user : "n/a";
    atividadePix.push({
      client: op.client,
      ns: op.ns,
      op: op.op,
      user: user,
      secs: op.secs_running
    });
  });

  if (atividadePix.length > 0) {
    print("  [" + node.host + "] " + atividadePix.length + " operação(ões) ativa(s):");
    atividadePix.forEach(op => {
      print("    client=" + op.client +
            " | ns=" + op.ns +
            " | op=" + op.op +
            " | user=" + op.user +
            " | secs=" + op.secs);
    });
  } else {
    print("  [" + node.host + "] Nenhuma operação ativa em pix.*");
  }
}

while (true) {
  print(new Date().toISOString() + " - Monitorando rs-pix-prd...");
  NODES.forEach(checkNode);
  print("---");
  sleep(5000);
}