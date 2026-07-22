# TrailPoint (iOS)

This package is the iOS coding exercise starter: app shell, unit tests, and a
local mock HTTP server.

## Project Structure

```
zoleo-trailpoint-ios-interview-coding-challenge/
├── README.md          # Package overview
├── TrailPoint/        # SwiftUI app — see TrailPoint/README.md
└── mock-server/       # Local API — see mock-server/README.md
```

- App setup: [TrailPoint/README.md](TrailPoint/README.md)
- Mock server and API: [mock-server/README.md](mock-server/README.md)

## Quick Start

```bash
cd mock-server && npm ci && npm start
```

In another terminal: `curl http://localhost:4747/devices`

Then build and test the app per [TrailPoint/README.md](TrailPoint/README.md).
The simulator uses `http://localhost:4747` (see mock-server Base URLs).

## Scope

Editable: Swift source, tests, and resources under `TrailPoint/`.

Out of scope: Any changes to `mock-server/`, release/CI/distribution tasks, or work unrelated to the iOS mobile app.

## Tech Stack

- **iOS:** Swift, SwiftUI
- **Testing:** XCTest
- **Mock server:** Node.js, Express, TypeScript
