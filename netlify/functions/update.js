// netlify/functions/update.js
// ─────────────────────────────────────────────────────────────
// This file runs on Netlify's servers, never in the browser.
// The SUPABASE_SERVICE_KEY environment variable is set in the
// Netlify dashboard — it is never exposed to visitors.
// ─────────────────────────────────────────────────────────────

const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

const WRITE_TABLES = ['issue', 'alert', 'quick_links', 'deadlines', 'sections', 'stories'];

const headers = {
  'Content-Type':  'application/json',
  'apikey':        SUPABASE_SERVICE_KEY,
  'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
  'Prefer':        'resolution=merge-duplicates,return=representation',
};

exports.handler = async (event) => {
  // Only accept POST
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method not allowed' };
  }

  // Verify the request comes from a logged-in Netlify Identity user
  const userHeader = event.headers['x-netlify-identity-user'];
  if (!userHeader) {
    return { statusCode: 401, body: JSON.stringify({ error: 'Not authenticated' }) };
  }
  // Decode and confirm user is valid (Netlify injects this server-side)
  let user;
  try {
    user = JSON.parse(Buffer.from(userHeader, 'base64').toString('utf8'));
  } catch {
    return { statusCode: 401, body: JSON.stringify({ error: 'Invalid auth token' }) };
  }
  if (!user?.email) {
    return { statusCode: 401, body: JSON.stringify({ error: 'No user email found' }) };
  }

  // Parse request body
  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return { statusCode: 400, body: JSON.stringify({ error: 'Invalid JSON body' }) };
  }

  const { action, table, rows, id } = body;

  // Validate table name (prevent injection attacks)
  if (!WRITE_TABLES.includes(table)) {
    return { statusCode: 400, body: JSON.stringify({ error: `Unknown table: ${table}` }) };
  }

  try {
    let result;

    if (action === 'upsert') {
      // Upsert (insert or update) rows
      if (!Array.isArray(rows) || rows.length === 0) {
        return { statusCode: 400, body: JSON.stringify({ error: 'rows must be a non-empty array' }) };
      }
      const r = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
        method:  'POST',
        headers,
        body:    JSON.stringify(rows),
      });
      result = await r.json();

    } else if (action === 'delete') {
      // Delete a single row by id
      if (!id) {
        return { statusCode: 400, body: JSON.stringify({ error: 'id is required for delete' }) };
      }
      await fetch(`${SUPABASE_URL}/rest/v1/${table}?id=eq.${encodeURIComponent(id)}`, {
        method:  'DELETE',
        headers,
      });
      result = { deleted: true };

    } else {
      return { statusCode: 400, body: JSON.stringify({ error: `Unknown action: ${action}` }) };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result),
    };

  } catch (err) {
    console.error('Supabase error:', err);
    return { statusCode: 500, body: JSON.stringify({ error: 'Server error', detail: err.message }) };
  }
};