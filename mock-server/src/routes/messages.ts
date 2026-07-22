import { Router } from "express";
import { messages } from "../data.js";
import {
  applyDelay,
  respondEmptyIfRequested,
  respondFailIfRequested,
} from "../inject.js";
import { isMessageType } from "../types.js";

export const messagesRouter = Router();

// GET /messages?type=sos|checkIn|text
messagesRouter.get("/messages", async (req, res) => {
  await applyDelay(req);
  if (respondFailIfRequested(req, res)) return;
  if (respondEmptyIfRequested(req, res)) return;

  const typeParam = req.query.type;
  let result = messages;
  if (typeof typeParam === "string") {
    if (!isMessageType(typeParam)) {
      res.status(400).json({ error: `Invalid type '${typeParam}'` });
      return;
    }
    result = result.filter((m) => m.type === typeParam);
  }

  const { limit, offset } = req.query;
  if (limit !== undefined || offset !== undefined) {
    const start = Math.max(Number(offset) || 0, 0);
    const end = limit !== undefined ? start + Math.max(Number(limit) || 0, 0) : undefined;
    result = result.slice(start, end);
  }

  res.status(200).json(result);
});
