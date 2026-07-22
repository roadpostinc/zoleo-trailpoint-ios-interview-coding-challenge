import { createApp } from "./app.js";

// Fixed port + bind-all so both the iOS Simulator (localhost) and the
// Android Emulator (10.0.2.2) can reach this process. See README.md.
const PORT = 4747;
const HOST = "0.0.0.0";

const app = createApp();

const server = app.listen(PORT, HOST, () => {
  console.log(`TrailPoint mock server listening on http://${HOST}:${PORT}`);
  console.log(`  iOS Simulator      -> http://localhost:${PORT}`);
  console.log(`  Android Emulator   -> http://10.0.2.2:${PORT}`);
});

function shutdown(signal: string): void {
  console.log(`\nReceived ${signal}, shutting down TrailPoint mock server...`);
  server.close(() => process.exit(0));
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));
