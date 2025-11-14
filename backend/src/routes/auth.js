import bcrypt from "bcrypt";
import { Router } from "express";
import jwt from "jsonwebtoken";
import { query } from "../db.js";

const router = Router();

router.post("/signup", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Email and password required" });

  const existing = await query("SELECT id FROM users WHERE email=$1", [email]);
  if (existing.rowCount > 0)
    return res.status(409).json({ error: "Email already registered" });

  const hash = await bcrypt.hash(password, 12);
  const result = await query(
    "INSERT INTO users (email, password_hash) VALUES ($1, $2) RETURNING id, email, role",
    [email, hash],
  );

  const user = result.rows[0];
  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" },
  );
  res.status(201).json({ token, user });
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Email and password required" });

  const result = await query(
    "SELECT id, email, role, password_hash FROM users WHERE email=$1",
    [email],
  );
  if (result.rowCount === 0)
    return res.status(401).json({ error: "Invalid credentials" });

  const user = result.rows[0];
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(401).json({ error: "Invalid credentials" });

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" },
  );
  res.json({
    token,
    user: { id: user.id, email: user.email, role: user.role },
  });
});

export default router;
