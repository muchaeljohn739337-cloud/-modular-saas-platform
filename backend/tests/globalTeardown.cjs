// CommonJS wrapper to run TypeScript globalTeardown
// ESM-aware globalTeardown wrapper: import ts-node and call the TS default export
module.exports = async () => {
  const tsnode = await import("ts-node");
  tsnode.register({ transpileOnly: true, files: true });
  const g = await import("./globalTeardown.ts");
  if (g && typeof g.default === "function") {
    return g.default();
  }
  return undefined;
};
