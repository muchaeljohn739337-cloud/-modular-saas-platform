import bcrypt from "bcrypt";
import { Router } from "express";
import jwt from "jsonwebtoken";
import speakeasy from "speakeasy";
import { query } from "../db.js";
import {
    loginLimiter,
    sanitizeUser,
    userSchema,
} from "../middleware/protection.js";
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
  res.status(201).json({ token, user: sanitizeUser(user) });
});

router.post("/login", loginLimiter, async (req, res) => {
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
    user: userSchema.parse(sanitizeUser(user)),
  });
});

router.post("/admin-login", loginLimiter, async (req, res) => {
  const { email, password, token, backupCode } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Email and password required" });

  const result = await query(
    "SELECT id, email, role, password_hash, totp_secret, totp_enabled, backup_codes FROM users WHERE email=$1 AND role=$2",
    [email, "admin"],
  );
  if (result.rowCount === 0)
    return res.status(403).json({ error: "Forbidden" });

  const user = result.rows[0];
  const passwordValid = await bcrypt.compare(password, user.password_hash);
  if (!passwordValid)
    return res.status(401).json({ error: "Invalid credentials" });

  let authenticated = false;

  if (user.totp_enabled) {
    if (token) {
      // Verify TOTP
      const tokenValid = speakeasy.totp.verify({
        secret: user.totp_secret,
        encoding: "base32",
        token,
      });
      if (tokenValid) authenticated = true;
    } else if (backupCode) {
      // Check backup code
      const hashedCodes = JSON.parse(user.backup_codes || "[]");
      for (let i = 0; i < hashedCodes.length; i++) {
        if (await bcrypt.compare(backupCode, hashedCodes[i])) {
          // Remove used code
          hashedCodes.splice(i, 1);
          await query("UPDATE users SET backup_codes = $1 WHERE id = $2", [
            JSON.stringify(hashedCodes),
            user.id,
          ]);
          authenticated = true;
          break;
        }
      }
    }
  } else {
    // If 2FA not enabled, just password
    authenticated = true;
  }

  if (!authenticated)
    return res.status(401).json({ error: "Invalid 2FA token or backup code" });

  const jwtToken = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" },
  );
  res.json({
    token: jwtToken,
    user: userSchema.parse(sanitizeUser(user)),
  });
});

router.post("/admin-recovery", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Email required" });

  const userResult = await query(
    "SELECT id FROM users WHERE email=$1 AND role=$2",
    [email, "admin"],
  );
  if (userResult.rowCount === 0)
    return res.status(404).json({ error: "Admin not found" });

  // Generate recovery token
  const token = crypto.randomBytes(32).toString("hex");
  await query(
    "INSERT INTO recovery_tokens (email, token, expires_at) VALUES ($1, $2, NOW() + interval '15 minutes')",
    [email, token],
  );

  // Send email (using Gmail SMTP as per instructions)
  const transporter = nodemailer.createTransporter({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD,
    },
  });

  const recoveryUrl = `${process.env.FRONTEND_URL || "http://localhost:3000"}/admin-recover?token=${token}`;
  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Admin 2FA Recovery",
    text: `Click to recover access: ${recoveryUrl}. Expires in 15 minutes.`,
  });

  res.json({ message: "Recovery email sent" });
});

router.post("/admin-recover", async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: "Token required" });

  const tokenResult = await query(
    "SELECT email FROM recovery_tokens WHERE token=$1 AND expires_at > NOW() AND used=FALSE",
    [token],
  );
  if (tokenResult.rowCount === 0)
    return res.status(401).json({ error: "Invalid or expired token" });

  const email = tokenResult.rows[0].email;

  // Mark token as used
  await query("UPDATE recovery_tokens SET used=TRUE WHERE token=$1", [token]);

  // Get user
  const userResult = await query(
    "SELECT id, email, role FROM users WHERE email=$1",
    [email],
  );
  const user = userResult.rows[0];

  // Issue JWT
  const jwtToken = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "1h" }, // Short expiry for recovery
  );
  res.json({
    token: jwtToken,
    user: userSchema.parse(sanitizeUser(user)),
    message: "Logged in via recovery. Please reset 2FA.",
  });
});

export default router;
