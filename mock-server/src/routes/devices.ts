import { Router } from "express";
import { devices } from "../data.js";
import {
  applyDelay,
  respondEmptyIfRequested,
  respondFailIfRequested,
} from "../inject.js";

export const devicesRouter = Router();

function findDevice(id: string) {
  return devices.find((d) => d.id.toLowerCase() === id.toLowerCase());
}

// GET /devices
devicesRouter.get("/devices", async (req, res) => {
  await applyDelay(req);
  if (respondFailIfRequested(req, res)) return;
  if (respondEmptyIfRequested(req, res)) return;

  let result = devices;
  const { limit, offset } = req.query;
  if (limit !== undefined || offset !== undefined) {
    const start = Math.max(Number(offset) || 0, 0);
    const end = limit !== undefined ? start + Math.max(Number(limit) || 0, 0) : undefined;
    result = result.slice(start, end);
  }

  res.status(200).json(result);
});

// GET /devices/:id
devicesRouter.get("/devices/:id", async (req, res) => {
  await applyDelay(req);
  if (respondFailIfRequested(req, res)) return;

  const device = findDevice(req.params.id);
  if (!device) {
    res.status(404).json({ error: `Device '${req.params.id}' not found` });
    return;
  }
  res.status(200).json(device);
});

// GET /devices/:id/locations
devicesRouter.get("/devices/:id/locations", async (req, res) => {
  await applyDelay(req);
  if (respondFailIfRequested(req, res)) return;

  const device = findDevice(req.params.id);
  if (!device) {
    res.status(404).json({ error: `Device '${req.params.id}' not found` });
    return;
  }
  if (respondEmptyIfRequested(req, res)) return;

  res.status(200).json(device.locationHistory);
});
