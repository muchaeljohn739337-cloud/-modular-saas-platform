import dotenv from "dotenv";
dotenv.config();

// List critical env variables for startup
const critical = [
  "DATABASE_URL",
  "JWT_SECRET",
  "JWT_SECRET_ENCRYPTED",
  "JWT_ENCRYPTION_KEY",
  "JWT_ENCRYPTION_IV",
  "JWT_SECRET_BASE64",
  "FRONTEND_URL",
  "ALLOWED_ORIGINS",
  "STRIPE_SECRET_KEY",
  "STRIPE_WEBHOOK_SECRET",
];

interface VarStatus {
  name: string;
  present: boolean;
  length?: number;
  note?: string;
}

function status(): VarStatus[] {
  return critical.map((name) => {
    const value = process.env[name];
    return {
      name,
      present: !!value,
      length: value ? value.length : 0,
      note: !value ? "MISSING" : value.length < 8 ? "Too short?" : undefined,
    };
  });
}

const results = status();

const missing = results.filter((r) => !r.present);

console.table(results);

if (missing.length) {
  console.error(`\n❌ Missing ${missing.length} critical env variable(s):`);
  missing.forEach((m) => console.error(` - ${m.name}`));
  process.exitCode = 1;
} else {
  console.log("\n✅ All critical env variables present (some optional).");
}
