import { Application } from "https://deno.land/x/oak@v17.1.3/mod.ts";
import { proxy } from "https://deno.land/x/oak_http_proxy@2.3.0/mod.ts";

const app = new Application();

// Proxy all requests to Google
app.use(proxy("https://www.google.com", {
  // Optional: Rewrite path if needed (e.g., remove root)
  rewritePath: (path) => path.replace(/^\/$/, "/"),
  memoizeUrl: true, // Improve efficiency by reusing parsed URLs
}));

const PORT = 8080;
console.log(`HTTP server running on http://localhost:${PORT}`);
await app.listen({ port: PORT });
