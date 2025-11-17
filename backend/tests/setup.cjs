// Register ts-node and dynamically import TS setup (ESM-aware)
(async () => {
  const tsnode = await import("ts-node");
  tsnode.register({ transpileOnly: true, files: true });
  await import("./setup.ts");
})();
// (loaded dynamically)
