/*
// === 2026-10-09T21:12:09.249Z | fila lock -> readers: 0 writers: 0
[BUILD] opid=1659886592 Index Build: scanning collection Index Build: scanning collection: 5651104/65340819 8% 5651104/65340819
[ESPERANDO LOCK] opid=1659869189 op=command ns=pix.pixtransactions 153s app=mongosh 2.8.3 client=127.0.0.1:51790

=== 2026-10-09T21:12:14.268Z | fila lock -> readers: 0 writers: 0
[BUILD] opid=1659886592 Index Build: scanning collection Index Build: scanning collection: 5827974/65340822 8% 5827974/65340822
[ESPERANDO LOCK] opid=1659869189 op=command ns=pix.pixtransactions 158s app=mongosh 2.8.3 client=127.0.0.1:51790*/

const NS = "pix.pixtransactions";
while (true) {
  const ops = db.getSiblingDB("admin").aggregate([
    { $currentOp: { allUsers: true, idleConnections: false } },
    { $match: { $or: [
        { "command.createIndexes": { $exists: true } },
        { ns: NS, waitingForLock: true },
        { waitingForLock: true, secs_running: { $gte: 1 } }
    ]}},
    { $project: {
        opid: 1, op: 1, ns: 1, secs_running: 1, waitingForLock: 1,
        msg: 1, progress: 1, client: 1, appName: 1
    }}
  ]).toArray();

  const q = db.serverStatus().globalLock.currentQueue;

  print(`\n=== ${new Date().toISOString()} | fila lock -> readers: ${q.readers} writers: ${q.writers}`);
  ops.forEach(o => {
    if (o.msg) print(`[BUILD] opid=${o.opid} ${o.msg} ${o.progress ? (o.progress.done + "/" + o.progress.total) : ""}`);
    else print(`[ESPERANDO LOCK] opid=${o.opid} op=${o.op} ns=${o.ns} ${o.secs_running}s app=${o.appName || "-"} client=${o.client || "-"}`);
  });
  sleep(5000);
}

