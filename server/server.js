const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';
const DATA_FILE = path.join(__dirname, 'data.json');

function loadTasks() {
  try {
    return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  } catch {
    return [];
  }
}

function saveTasks(tasks) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(tasks, null, 2));
}

let tasks = loadTasks();

function send(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  });
  res.end(body === undefined ? '' : JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (chunk) => (raw += chunk));
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch {
        reject(new Error('Invalid JSON'));
      }
    });
    req.on('error', reject);
  });
}

function validateTitle(title) {
  return typeof title === 'string' && title.trim().length > 0;
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const parts = url.pathname.split('/').filter(Boolean);
  const method = req.method;

  console.log(`${new Date().toISOString()} ${method} ${url.pathname}`);

  if (method === 'OPTIONS') return send(res, 204);

  try {
    if (parts.length === 1 && parts[0] === 'health' && method === 'GET') {
      return send(res, 200, { status: 'ok', time: new Date().toISOString() });
    }

    if (parts[0] !== 'tasks') {
      return send(res, 404, { error: 'Not found' });
    }

    if (parts.length === 1) {
      if (method === 'GET') {
        const sorted = [...tasks].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
        return send(res, 200, sorted);
      }

      if (method === 'POST') {
        const body = await readBody(req);
        if (!validateTitle(body.title)) {
          return send(res, 400, { error: 'Title is required' });
        }
        const task = {
          id: crypto.randomUUID(),
          title: body.title.trim(),
          description: typeof body.description === 'string' ? body.description.trim() : '',
          completed: false,
          createdAt: new Date().toISOString(),
        };
        tasks.push(task);
        saveTasks(tasks);
        return send(res, 201, task);
      }

      return send(res, 405, { error: 'Method not allowed' });
    }

    if (parts.length === 2) {
      const index = tasks.findIndex((t) => t.id === parts[1]);
      if (index === -1) return send(res, 404, { error: 'Task not found' });

      if (method === 'GET') return send(res, 200, tasks[index]);

      if (method === 'PUT') {
        const body = await readBody(req);
        if (body.title !== undefined && !validateTitle(body.title)) {
          return send(res, 400, { error: 'Title cannot be empty' });
        }
        const current = tasks[index];
        const updated = {
          ...current,
          title: body.title !== undefined ? body.title.trim() : current.title,
          description:
            typeof body.description === 'string' ? body.description.trim() : current.description,
          completed: typeof body.completed === 'boolean' ? body.completed : current.completed,
        };
        tasks[index] = updated;
        saveTasks(tasks);
        return send(res, 200, updated);
      }

      if (method === 'DELETE') {
        tasks.splice(index, 1);
        saveTasks(tasks);
        return send(res, 204);
      }

      return send(res, 405, { error: 'Method not allowed' });
    }

    return send(res, 404, { error: 'Not found' });
  } catch (e) {
    return send(res, 400, { error: e.message });
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
