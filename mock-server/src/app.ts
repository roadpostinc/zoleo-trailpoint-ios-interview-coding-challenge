import cors from "cors";
import express, { type Express } from "express";
import { devicesRouter } from "./routes/devices.js";
import { messagesRouter } from "./routes/messages.js";

/**
 * Builds the Express app without binding a port — used directly by tests
 * (supertest) and by `server.ts` for the real listening process.
 */
export function createApp(): Express {
  const app = express();

  // Local dev-only mock: allow every origin, no auth.
  app.use(cors());
  app.use(express.json());

  app.use(devicesRouter);
  app.use(messagesRouter);

  app.use((_req, res) => {
    res.status(404).json({ error: "Not found" });
  });

  return app;
}
