import { createReadStream, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize, resolve } from 'node:path';

const port = Number(process.env.PORT || 55222);
const host = process.env.HOST || '127.0.0.1';
const root = resolve('build/web');

const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
};

createServer((req, res) => {
  const url = new URL(req.url ?? '/', `http://${host}:${port}`);
  const requested = normalize(decodeURIComponent(url.pathname)).replace(/^[/\\]+/, '');
  let file = resolve(join(root, requested));

  if (!file.startsWith(root) || !existsSync(file) || statSync(file).isDirectory()) {
    file = join(root, 'index.html');
  }

  res.setHeader('Content-Type', types[extname(file)] ?? 'application/octet-stream');
  res.setHeader('Cache-Control', 'no-store');
  createReadStream(file).pipe(res);
}).listen(port, host, () => {
  console.log(`Serving ${root} at http://${host}:${port}`);
});
