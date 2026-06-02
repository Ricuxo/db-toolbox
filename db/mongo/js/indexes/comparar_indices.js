mongosh 'mongodb://admin:topazhmg@10.100.98.241:27017/?authSource=admin&replicaSet=rs-pix' \
  --eval "
    db = db.getSiblingDB('pix');
    var cols = ['accountblockrefunds','localholidays','originacao_proxy_routes',
                'pixaccounts','pixclaims','pixdicts','pixdictentries',
                'pixdictentriestimes','pixdictremoveds','pixfraudmarks',
                'pixinfractions','pixfundsrecoveries','pixliquidationperdates',
                'pixqrcodes','pixqrcodeblockeds','pixqrcodejwks',
                'pixrecurringauthorizations','pixrecurringqrcodes',
                'pixrecurringschedulings','pixrefunds','pixtimespertransactions',
                'pixtransactions','pixtransactionbatches','receivablesoptins',
                'receivablesoptouts','ursimulations'];
    cols.forEach(function(c) {
      var indexes = db[c].getIndexes();
      print(c + ': ' + indexes.length + ' índices');
    });
  "