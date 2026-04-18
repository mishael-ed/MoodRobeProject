const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://neondb_owner:npg_YqaB2OGc7ASe@ep-holy-cell-anifnolg.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require',
  ssl: { rejectUnauthorized: false }
});

const statements = [
  `CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
  )`,
  `CREATE TABLE IF NOT EXISTS collection_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, product_id)
  )`,
  `CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id)`,
  `CREATE INDEX IF NOT EXISTS idx_user_favorites_product_id ON user_favorites(product_id)`,
  `CREATE INDEX IF NOT EXISTS idx_collection_items_collection_id ON collection_items(collection_id)`,
  `CREATE INDEX IF NOT EXISTS idx_collection_items_product_id ON collection_items(product_id)`
];

async function run() {
  await client.connect();
  console.log('Connected!');
  for (const stmt of statements) {
    try {
      await client.query(stmt);
      console.log('OK:', stmt.slice(0, 60));
    } catch (err) {
      console.error('ERR:', err.message, '->', stmt.slice(0, 60));
    }
  }
  await client.end();
  console.log('Done!');
}

run().catch(err => { console.error(err.message); process.exit(1); });
