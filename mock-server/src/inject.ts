import type { Request, Response } from "express";

/**
 * Deterministic delay, failure, and empty-list controls supplied through
 * `?delayMs=<n>`, `?fail=true`, and `?empty=true` query parameters.
 *
 * Composition order on every route:
 *   1. delayMs
 *   2. fail
 *   3. route-specific lookup and 404 handling
 *   4. empty on list routes
 *   5. normal payload
 */

/** Upper bound so a mistyped `delayMs` can't hang a request/test forever. */
export const MAX_DELAY_MS = 30_000;

export function parseDelayMs(req: Request): number {
  const raw = req.query.delayMs;
  if (typeof raw !== "string") return 0;
  const parsed = Number(raw);
  if (!Number.isFinite(parsed) || parsed <= 0) return 0;
  return Math.min(parsed, MAX_DELAY_MS);
}

export async function applyDelay(req: Request): Promise<void> {
  const delayMs = parseDelayMs(req);
  if (delayMs > 0) {
    await new Promise<void>((resolve) => setTimeout(resolve, delayMs));
  }
}

/** Returns true (and has already written the 500 response) if `?fail=true`. */
export function respondFailIfRequested(req: Request, res: Response): boolean {
  if (req.query.fail === "true") {
    res.status(500).json({ error: "Injected failure (fail=true)" });
    return true;
  }
  return false;
}

/** List routes only. Returns true (and has already written `[]`) if `?empty=true`. */
export function respondEmptyIfRequested(req: Request, res: Response): boolean {
  if (req.query.empty === "true") {
    res.status(200).json([]);
    return true;
  }
  return false;
}
