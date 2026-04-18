const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const client = new Client({
  connectionString: 'postgresql://neondb_owner:npg_YqaB2OGc7ASe@ep-holy-cell-anifnolg.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require',
  ssl: { rejectUnauthorized: false }
});

// Split SQL into individual statements, respecting dollar-quoted blocks ($$...$$)
function splitStatements(sql) {
  const statements = [];
  let current = '';
  let inDollarQuote = false;

  for (let i = 0; i < sql.length; i++) {
    const ch = sql[i];

    if (!inDollarQuote && sql.slice(i, i + 2) === '$$') {
      inDollarQuote = true;
      current += '$$';
      i++;
      continue;
    }
    if (inDollarQuote && sql.slice(i, i + 2) === '$$') {
      inDollarQuote = false;
      current += '$$';
      i++;
      continue;
    }

    if (!inDollarQuote && ch === ';') {
      const trimmed = current.trim();
      if (trimmed) statements.push(trimmed);
      current = '';
    } else {
      current += ch;
    }
  }
  const trimmed = current.trim();
  if (trimmed) statements.push(trimmed);
  return statements;
}

async function run() {
  await client.connect();
  console.log('Connected to Neon!');

  const files = [
    '../moodrobe_database.sql',
    '../moodrobe_admin.sql',
    '../moodrobe_payment_table_constraints.sql'
  ];

  for (const file of files) {
    const filePath = path.join(__dirname, file);
    console.log(`\nRunning ${path.basename(filePath)}...`);
    const sql = fs.readFileSync(filePath, 'utf8');
    const statements = splitStatements(sql);

    for (const stmt of statements) {
      try {
        await client.query(stmt);
      } catch (err) {
        const msg = err.message || '';
        if (msg.includes('already exists') || msg.includes('duplicate')) {
          // skip silently
        } else {
          console.error(`  Error in statement: ${stmt.slice(0, 80)}...`);
          console.error(`  -> ${msg}`);
        }
      }
    }
    console.log(`  Done (${statements.length} statements).`);
  }

  await client.end();
  console.log('\nSchema import complete!');
}

run().catch(err => {
  console.error('Fatal:', err.message);
  process.exit(1);
});
