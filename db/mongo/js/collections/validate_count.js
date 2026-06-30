/*# Salva o script*/
cat > /tmp/validate_count.js << 'EOF'
var collections = [
  "accountblockrefunds", "localholidays", "pixaccounts",
  "pixclaims", "pixdictentries", "pixdictentriestimes",
  "pixdictremoveds", "pixdicts", "pixfraudmarks",
  "pixfundsrecoveries", "pixinfractions", "pixliquidationperdates",
  "pixqrcodeblockeds", "pixqrcodejwks", "pixqrcodes",
  "pixrecurringqrcodes", "pixrefunds", "pixtimespertransactions",
  "pixtransactionbatches", "pixtransactions"
];

var origem = connect("mongodb://admin:SENHA_RS0@10.100.97.82:27017/admin?authSource=admin");
var destino = connect("mongodb://admin:yhz2mtk0vcx7YAG1mbd@10.100.106.86:27017/admin?authSource=admin");

print("=== VALIDAÇÃO DE CONTAGEM ===");
print("Collection                          | Origem    | Destino   | Status");
print("-".repeat(75));

var divergencias = 0;

collections.forEach(c => {
  var countOrigem  = origem.getDB("transfer")[c].countDocuments({});
  var countDestino = destino.getDB("pix")[c].countDocuments({});
  var status = (countOrigem === countDestino) ? "OK" : "DIVERGÊNCIA";
  if (status === "DIVERGÊNCIA") divergencias++;
  print(
    c.padEnd(35) + " | " +
    String(countOrigem).padStart(9) + " | " +
    String(countDestino).padStart(9) + " | " +
    status
  );
});

print("-".repeat(75));
print("Divergências: " + divergencias + "/" + collections.length);
print("Concluído: " + new Date().toISOString());
EOF

/*mongosh --host 10.100.97.82 --port 27017 -u admin -p 'SENHA_RS0' --authenticationDatabase admin /tmp/validate_count.js*/