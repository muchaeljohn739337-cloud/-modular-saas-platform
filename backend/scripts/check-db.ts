import prisma from "../src/prismaClient";

async function main() {
  try {
    const now = await prisma.$queryRaw`SELECT NOW()`;
    console.log("✅ DB time:", now);
    const users = await prisma.user.count();
    console.log("✅ User count:", users);
  } catch (e) {
    console.error("❌ Database check failed:", e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
}

main();
