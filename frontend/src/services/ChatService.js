import { apiRequest } from "../JS/APi.js";
export function askBookAdviser(message, history = []) {
  return apiRequest("/chat/recommendations", { method: "POST", body: { message, history } });
}
