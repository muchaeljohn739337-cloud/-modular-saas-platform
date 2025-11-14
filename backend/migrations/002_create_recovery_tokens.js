export async function up(pool) {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS recovery_tokens (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) NOT NULL,
      token VARCHAR(255) UNIQUE NOT NULL,
      expires_at TIMESTAMP NOT NULL,
      used BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);
}
