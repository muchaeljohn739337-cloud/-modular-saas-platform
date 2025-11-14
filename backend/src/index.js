import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import helmet from "helmet";
import { runMigrations } from "./db.js";
import authRoutes from "./routes/auth.js";
import healthRoutes from "./routes/health.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(helmet());
app.use(cors({ origin: "*" }));
app.use(express.json());

app.use("/api", healthRoutes);
app.use("/api/auth", authRoutes);

app.get("/api/me", (req, res) =>
  res.json({ service: "advvancia-backend", version: "1.0.0" }),
);

// Run migrations at startup
runMigrations()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Backend listening on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Migration error:", err);
    process.exit(1);
  });
