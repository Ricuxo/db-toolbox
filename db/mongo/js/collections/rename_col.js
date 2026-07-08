// Roda no primary da ORIGEM (rs0)
// Roda no database admin

var DB = "transfer";
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

collections.forEach(c => {
  var result = db.adminCommand({
    renameCollection: DB + "." + c,
    to: DB + "." + c + "_migrated",
    dropTarget: false
  });
  print(c + " -> " + (result.ok === 1 ? "OK" : JSON.stringify(result)));
});