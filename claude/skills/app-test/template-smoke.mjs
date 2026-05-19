/**
 * tests/smoke.mjs — smoke test for THIS app (template).
 *
 * Copy into <appRepo>/tests/smoke.mjs and tailor it. No dependencies: the
 * app-test runner supplies the Playwright `page`. Run a throwaway data
 * directory and a spare port so tests never touch real data.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const PORT = 4399; // a spare port, not the app's normal one

export const config = {
  start: "node server.js", // command that launches the app
  cwd: ".", // relative to the app repo root
  url: `http://127.0.0.1:${PORT}`,
  env: { PORT: String(PORT) }, // env vars for the launch (test port, temp data dir, ...)
  slowMo: 250, // ms between actions, so a human can watch
  readyTimeoutMs: 20000,
};

export function setup() {
  // e.g. wipe a temp data directory before the run
}

export function teardown() {
  // e.g. wipe the temp data directory after the run
}

export async function run({ page, step, expect, config }) {
  await step("app loads", async () => {
    await page.goto(config.url);
    await page.waitForSelector("body");
  });

  // Add more steps — each wrapped in step(), each asserting with expect():
  //
  // await step("does the thing", async () => {
  //   await page.click("#some-button");
  //   expect(await page.locator(".result").count() === 1, "no result shown");
  // });
}
