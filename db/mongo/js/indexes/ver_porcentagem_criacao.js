db.currentOp({ "command.createIndexes": { $exists: true }, ns: "transfer.pixtransactions" })
  .inprog
  .filter(o => o.progress)
  .forEach(o => {
    const p = (o.progress.done / o.progress.total * 100).toFixed(2);
    print(`${p}% — ${o.progress.done}/${o.progress.total} — ${o.secs_running}s`);
  });