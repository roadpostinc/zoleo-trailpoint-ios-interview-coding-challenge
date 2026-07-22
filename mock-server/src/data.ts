import type { Device, LocationPing, Message, MessageType } from "./types.js";
import { MESSAGE_TYPES } from "./types.js";

const ms = (iso: string): number => new Date(iso).getTime();
const pad = (n: number, width: number): string => String(n).padStart(width, "0");

const DEVICE_COUNT = 20;

const DEVICE_NAMES = [
  "Ridge Runner", "Basecamp Rover", "Trailhead Scout", "Summit Seeker",
  "Canyon Drifter", "Alpine Wanderer", "Switchback Scout", "Timberline Tracker",
  "Glacier Pathfinder", "Boulder Voyager", "Meadow Rambler", "Cascade Explorer",
  "Highline Nomad", "Granite Pioneer", "Backcountry Beacon", "Thicket Tracer",
  "Overlook Sentinel", "Valley Voyager", "Pinnacle Wayfarer", "Foothill Ranger",
];

const LOCATION_COUNTS = [0, 9, 3, 12, 0, 15, 6, 1, 10, 4, 13, 7, 2, 11, 5, 14, 8, 0, 15, 3];
const SOS_FLAGS = [
  true, false, false, true, false, false, true, false, false, true,
  false, false, true, false, false, true, false, false, true, false,
];

function deviceId(seq: number): string {
  return `b3f1a2c4-${pad(seq, 4)}-4a6d-8b2e-${pad(seq, 12)}`;
}

function locationId(globalSeq: number): string {
  return `c7d2b3e5-${pad(globalSeq, 4)}-4a6d-8b2e-${pad(globalSeq, 12)}`;
}

function messageId(seq: number): string {
  return `d8e3c4f6-${pad(seq, 4)}-4a6d-8b2e-${pad(seq, 12)}`;
}

let locationSeq = 0;

function buildLocationHistory(deviceSeq: number, count: number): LocationPing[] {
  const baseLat = 45.4 + (deviceSeq % 10) * 0.01;
  const baseLon = -75.7 - (deviceSeq % 10) * 0.015;
  const baseTimestamp = ms("2026-07-15T08:00:00Z") + deviceSeq * 60 * 60 * 1000;
  return Array.from({ length: count }, (_, i) => {
    locationSeq += 1;
    return {
      id: locationId(locationSeq),
      latitude: baseLat + i * 0.003,
      longitude: baseLon - i * 0.004,
      timestamp: baseTimestamp + i * 30 * 60 * 1000,
    };
  });
}

export const devices: Device[] = Array.from({ length: DEVICE_COUNT }, (_, i) => {
  const seq = i + 1;
  return {
    id: deviceId(seq),
    name: DEVICE_NAMES[i],
    hasActiveSosAlert: SOS_FLAGS[i],
    lastSeen: ms("2026-07-16T06:00:00Z") + i * 45 * 60 * 1000,
    locationHistory: buildLocationHistory(seq, LOCATION_COUNTS[i]),
  };
});

const MESSAGE_COUNT = 50;

const MESSAGE_BODIES: Record<MessageType, string[]> = {
  sos: [
    "SOS triggered — requesting immediate assistance.",
    "SOS re-armed after brief signal loss.",
    "Accidental SOS trigger — false alarm, resolved on call-back.",
  ],
  checkIn: [
    "Checked in at base camp, all clear.",
    "Checked in at waypoint, on schedule.",
    "Checked in for the night, settling at camp.",
  ],
  text: [
    "Battery holding steady, all systems normal.",
    "Heading to the next checkpoint, ETA 45 minutes.",
    "Good signal here, clear skies.",
  ],
};

export const messages: Message[] = Array.from({ length: MESSAGE_COUNT }, (_, i) => {
  const seq = i + 1;
  const device = devices[i % DEVICE_COUNT];
  const type = MESSAGE_TYPES[i % MESSAGE_TYPES.length];
  const bodies = MESSAGE_BODIES[type];
  return {
    id: messageId(seq),
    deviceId: device.id,
    type,
    body: bodies[i % bodies.length],
    timestamp: String(ms("2026-07-14T12:00:00Z") + i * 20 * 60 * 1000),
  };
});
