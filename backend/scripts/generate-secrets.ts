import crypto from "crypto";

async function maybeGenerateVapid() {
  try {
    // Dynamically import web-push if available; otherwise provide guidance
    const mod = await import("web-push").catch(() => null as any);
    if (!mod) {
      return {
        publicKey: "<GENERATE_WITH_NPX>",
        privateKey: "<GENERATE_WITH_NPX>",
        note: "Run: npx web-push generate-vapid-keys",
      };
    }
    const vapid = mod.generateVAPIDKeys();
    return { publicKey: vapid.publicKey, privateKey: vapid.privateKey };
  } catch {
    return {
      publicKey: "<GENERATE_WITH_NPX>",
      privateKey: "<GENERATE_WITH_NPX>",
      note: "Run: npx web-push generate-vapid-keys",
    };
  }
}

function hex(bytes: number) {
  return crypto.randomBytes(bytes).toString("hex");
}

async function main() {
  const jwtSecret = hex(32); // 64 hex chars
  const jwtRefreshSecret = hex(32);
  const sessionSecret = hex(32);
  const nextAuthSecret = hex(32);
  const otpSecret = hex(16); // 32 hex chars
  const walletEncryptionKey = hex(32); // AES-256 key (32 bytes)

  const vapid = await maybeGenerateVapid();

  // Backend .env snippet
  const backendEnv = `# --- Backend secrets ---
JWT_SECRET=${jwtSecret}
JWT_REFRESH_SECRET=${jwtRefreshSecret}
SESSION_SECRET=${sessionSecret}
OTP_SECRET=${otpSecret}
WALLET_ENCRYPTION_KEY=${walletEncryptionKey}
VAPID_PUBLIC_KEY=${(vapid as any).publicKey}
VAPID_PRIVATE_KEY=${(vapid as any).privateKey}
# WALLET_MASTER_SEED=<SET_SECURELY_OFFLINE>
`;

  // Frontend .env snippet
  const frontendEnv = `# --- Frontend secrets ---
NEXTAUTH_SECRET=${nextAuthSecret}
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
`;

  const guidance = `
Notes:
- Do NOT generate or store a real BIP39 wallet mnemonic in this repo. Use a hardware wallet or secure offline tool.
- If VAPID keys show <GENERATE_WITH_NPX>, run: npx web-push generate-vapid-keys
- Sentry DSN is provided by Sentry. Stripe webhook secret comes from the Stripe Dashboard after webhook creation.
`;

  // Output
  process.stdout.write("\n=== Backend .env values ===\n" + backendEnv);
  process.stdout.write("\n=== Frontend .env values ===\n" + frontendEnv);
  process.stdout.write("\n" + guidance + "\n");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
