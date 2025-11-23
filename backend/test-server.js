import express from "express";

const app = express();
const PORT = 3001;

app.get("/test", (req, res) => {
  res.json({ message: "Test server working!" });
});

const server = app.listen(PORT, () => {
  console.log(`Test server listening on port ${PORT}`);
  console.log(`Try: http://localhost:${PORT}/test`);
});

// Log all process events
process.on("SIGINT", (signal) => {
  console.log("\nReceived SIGINT, shutting down...");
  server.close(() => process.exit(0));
});

process.on("SIGTERM", (signal) => {
  console.log("\nReceived SIGTERM, shutting down...");
  server.close(() => process.exit(0));
});

process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
});
