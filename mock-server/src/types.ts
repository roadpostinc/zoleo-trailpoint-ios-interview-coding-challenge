/** TrailPoint HTTP wire contract. */

export type MessageType = "sos" | "checkIn" | "text";

export const MESSAGE_TYPES: readonly MessageType[] = ["sos", "checkIn", "text"];

export function isMessageType(value: string): value is MessageType {
  return (MESSAGE_TYPES as readonly string[]).includes(value);
}

export interface LocationPing {
  id: string;
  latitude: number;
  longitude: number;
  timestamp: number;
}

export interface Device {
  id: string;
  name: string;
  hasActiveSosAlert: boolean;
  lastSeen: number;
  locationHistory: LocationPing[];
}

export interface Message {
  id: string;
  deviceId: string;
  type: MessageType;
  body: string;
  timestamp: string;
}
