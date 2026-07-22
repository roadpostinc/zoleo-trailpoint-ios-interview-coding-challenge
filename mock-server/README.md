# TrailPoint mock server

Local Express and TypeScript HTTP server for TrailPoint device, location, and
message data. No authentication; no external calls.

Package overview: [../README.md](../README.md)

## Setup

```bash
npm ci
npm start
```

Listens on `0.0.0.0:4747`. `npm run dev` reloads on source changes.

## Base URLs

| Runtime | Base URL |
|---|---|
| Host / iOS Simulator | `http://localhost:4747` |
| Android Emulator | `http://10.0.2.2:4747` |
| Physical device (same network) | `http://<host-LAN-IP>:4747` |

## API

Read-only endpoints:

| Method | Path | Success | Other |
|---|---|---|---|
| `GET` | `/devices` | `200` `Device[]` | Injectable controls below |
| `GET` | `/devices/:id` | `200` `Device` | `404` unknown id; injectable controls |
| `GET` | `/devices/:id/locations` | `200` `LocationPing[]` | `404` unknown id; injectable controls |
| `GET` | `/messages` | `200` `Message[]` | `400` invalid `type`; injectable controls |

`GET /messages` optional `type`: `sos`, `checkIn`, or `text`.

`GET /devices` and `GET /messages` optional `limit` and `offset` (pagination).
`offset` defaults to `0`; omit `limit` to return from `offset` onward. Negative
or non-numeric values clamp to `0`. Omit both for the full array.

## Deterministic response controls

Composable query parameters on any endpoint:

| Parameter | Behavior |
|---|---|
| `delayMs=<n>` | Delay `n` ms (non-positive/non-numeric → 0; cap `30000`) |
| `fail=true` | `500` error body |
| `empty=true` | `200 []` on list endpoints only |

Order: delay → failure → route lookup → empty list → normal payload. On
`/messages`, type validation/filtering runs after shared controls.

## Wire fields

IDs are UUID strings. Device/location timestamps are integer epoch ms (UTC).
Message timestamps are decimal epoch-ms strings (UTC).

| Object | Field | Type or values |
|---|---|---|
| `Device` | `id` | UUID string |
| `Device` | `name` | string |
| `Device` | `hasActiveSosAlert` | boolean |
| `Device` | `lastSeen` | integer epoch ms |
| `Device` | `locationHistory` | `LocationPing[]` |
| `LocationPing` | `id` | UUID string |
| `LocationPing` | `latitude` | number |
| `LocationPing` | `longitude` | number |
| `LocationPing` | `timestamp` | integer epoch ms |
| `Message` | `id` | UUID string |
| `Message` | `deviceId` | UUID string |
| `Message` | `type` | `sos`, `checkIn`, or `text` |
| `Message` | `body` | string |
| `Message` | `timestamp` | decimal epoch-ms string |

## Verification

```bash
curl http://localhost:4747/devices
npm test
npm run typecheck
```
