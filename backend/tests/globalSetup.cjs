// ESM-aware globalSetup wrapper: import ts-node and call the TS default export
module.exports = async () => {
  const tsnode = await import("ts-node");
  tsnode.register({ transpileOnly: true, files: true });
  const g = await import("./globalSetup.ts");
  if (g && typeof g.default === "function") {
    return g.default();
  }
  return undefined;
};
