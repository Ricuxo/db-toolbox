cat > /tmp/validate_count.js << 'EOF'
var collections = [
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

var connOrigem  = new Mongo("mongodb://admin:topazprd@10.100.97.82:27017/?authSource=admin");
var connDestino = new Mongo("mongodb://admin:yhz2mtk0vcx7YAG1mbd@10.100.106.86:27017/?authSource=admin");

var dbOrigem  = connOrigem.getDB("transfer");
var dbDestino = connDestino.getDB("pix");

print("=== VALIDAÇÃO DE CONTAGEM ===");
print("Collection                          | Origem    | Destino   | Status");
print("---------------------------------------------------------------------------");

var divergencias = 0;

collections.forEach(c => {
  var countOrigem  = dbOrigem[c].countDocuments({});
  var countDestino = dbDestino[c].countDocuments({});
  var status = (countOrigem === countDestino) ? "OK" : "DIVERGENCIA";
  if (status === "DIVERGENCIA") divergencias++;
  print(
    c.padEnd(35) + " | " +
    String(countOrigem).padStart(9) + " | " +
    String(countDestino).padStart(9) + " | " +
    status
  );
});

print("---------------------------------------------------------------------------");
print("Divergencias: " + divergencias + "/" + collections.length);
print("Concluido: " + new Date().toISOString());
EOF

mongosh --host 10.100.97.82 --port 27017 -u admin -p 'topazprd' --authenticationDatabase admin /tmp/validate_count.js