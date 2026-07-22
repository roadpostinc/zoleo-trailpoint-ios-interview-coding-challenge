import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";
import type { Server } from "node:http";
import supertest from "supertest";
import { createApp } from "../src/app.js";
import { devices, messages } from "../src/data.js";

let server: Server;
let request: ReturnType<typeof supertest>;

before(() => {
  const app = createApp();
  server = app.listen(0); // ephemeral port for the test process
  request = supertest(server);
});

after(() => {
  server.close();
});

describe("GET /devices", () => {
  test("lists all seeded devices", async () => {
    const res = await request.get("/devices");
    assert.equal(res.status, 200);
    assert.equal(res.body.length, devices.length);
    assert.equal(res.body[0].id, devices[0].id);
  });

  test("?empty=true returns an empty array", async () => {
    const res = await request.get("/devices?empty=true");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, []);
  });

  test("?fail=true returns a 500 with an error body", async () => {
    const res = await request.get("/devices?fail=true");
    assert.equal(res.status, 500);
    assert.ok(res.body.error);
  });

  test("?delayMs=200 delays the response by roughly that long", async () => {
    const start = Date.now();
    const res = await request.get("/devices?delayMs=200");
    const elapsed = Date.now() - start;
    assert.equal(res.status, 200);
    assert.ok(elapsed >= 190, `expected >=190ms elapsed, got ${elapsed}ms`);
  });

  test("delayMs composes with fail (waits, then still fails)", async () => {
    const start = Date.now();
    const res = await request.get("/devices?delayMs=150&fail=true");
    const elapsed = Date.now() - start;
    assert.equal(res.status, 500);
    assert.ok(elapsed >= 140, `expected >=140ms elapsed, got ${elapsed}ms`);
  });

  test("?limit=5 returns only the first 5 devices", async () => {
    const res = await request.get("/devices?limit=5");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, devices.slice(0, 5));
  });

  test("?limit=5&offset=5 returns the next page", async () => {
    const res = await request.get("/devices?limit=5&offset=5");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, devices.slice(5, 10));
  });

  test("?offset=<n> with no limit returns the remaining tail", async () => {
    const res = await request.get("/devices?offset=18");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, devices.slice(18));
  });

  test("?offset=-5 is clamped to 0", async () => {
    const res = await request.get("/devices?offset=-5&limit=3");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, devices.slice(0, 3));
  });

  test("non-numeric offset and limit values are clamped to 0", async () => {
    const offsetRes = await request.get("/devices?offset=invalid&limit=3");
    assert.equal(offsetRes.status, 200);
    assert.deepEqual(offsetRes.body, devices.slice(0, 3));

    const limitRes = await request.get("/devices?limit=invalid");
    assert.equal(limitRes.status, 200);
    assert.deepEqual(limitRes.body, []);
  });

  test("no limit/offset returns every device (unchanged)", async () => {
    const res = await request.get("/devices");
    assert.equal(res.status, 200);
    assert.equal(res.body.length, devices.length);
  });
});

describe("GET /devices/:id", () => {
  test("returns the matching device", async () => {
    const target = devices[0];
    const res = await request.get(`/devices/${target.id}`);
    assert.equal(res.status, 200);
    assert.equal(res.body.id, target.id);
    assert.equal(res.body.name, target.name);
    assert.equal(res.body.hasActiveSosAlert, target.hasActiveSosAlert);
  });

  test("404s for an unknown id", async () => {
    const res = await request.get("/devices/does-not-exist");
    assert.equal(res.status, 404);
    assert.ok(res.body.error);
  });
});

describe("GET /devices/:id/locations", () => {
  test("returns location history for a device that has some", async () => {
    const target = devices[1];
    const res = await request.get(`/devices/${target.id}/locations`);
    assert.equal(res.status, 200);
    assert.equal(res.body.length, target.locationHistory.length);
    assert.ok(res.body.length > 0);
  });

  test("returns an empty array for a device with no location history", async () => {
    const target = devices[0];
    const res = await request.get(`/devices/${target.id}/locations`);
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, []);
  });
});

describe("GET /messages", () => {
  test("lists all seeded messages", async () => {
    const res = await request.get("/messages");
    assert.equal(res.status, 200);
    assert.equal(res.body.length, messages.length);
    for (const message of res.body) {
      assert.equal(typeof message.timestamp, "string");
      assert.match(message.timestamp, /^\d+$/);
    }
  });

  test("?type=sos filters across all devices", async () => {
    const res = await request.get("/messages?type=sos");
    assert.equal(res.status, 200);
    assert.ok(res.body.length > 0);
    for (const m of res.body) {
      assert.equal(m.type, "sos");
    }
  });

  test("invalid ?type= returns a 400", async () => {
    const res = await request.get("/messages?type=bogus");
    assert.equal(res.status, 400);
  });

  test("?empty=true returns an empty array", async () => {
    const res = await request.get("/messages?empty=true");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, []);
  });

  test("?fail=true returns a 500", async () => {
    const res = await request.get("/messages?fail=true");
    assert.equal(res.status, 500);
  });

  test("?limit=3 returns only the first 3 messages", async () => {
    const res = await request.get("/messages?limit=3");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, messages.slice(0, 3));
  });

  test("?type filter and ?limit compose together", async () => {
    const sos = messages.filter((m) => m.type === "sos");
    const res = await request.get("/messages?type=sos&limit=2");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, sos.slice(0, 2));
  });

  test("?type filter composes with ?limit and ?offset", async () => {
    const sos = messages.filter((m) => m.type === "sos");
    const res = await request.get("/messages?type=sos&limit=1&offset=1");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, sos.slice(1, 2));
  });

  test("no limit/offset returns every message (unchanged)", async () => {
    const res = await request.get("/messages");
    assert.equal(res.status, 200);
    assert.equal(res.body.length, messages.length);
  });
});

describe("unknown route", () => {
  test("404s with a JSON error body", async () => {
    const res = await request.get("/not-a-real-route");
    assert.equal(res.status, 404);
    assert.ok(res.body.error);
  });
});
