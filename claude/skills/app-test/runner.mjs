/**
 * Universal app smoke-test runner (app-test skill).
 *
 *   node runner.mjs <appDir>
 *
 * Launches the app described by <appDir>/tests/smoke.mjs, opens it in a
 * real (visible) browser, runs the app's test steps, screenshots each one,
 * and prints a pass/fail report. The runner never changes per app — each
 * app ships its own tests/smoke.mjs.
 */

import { chromium } from "playwright";
import { spawn } from "node:child_process";
import path from "node:path";
import url from "node:url";
import fs from "node:fs";

const appDir = path.resolve(process.argv[2] || process.cwd());
const smokePath = path.join(appDir, "tests", "smoke.mjs");

if (!fs.existsSync(smokePath)) {
  console.error(`NO_TESTS: ${smokePath} not found`);
  console.error("Scaffold one from template-smoke.mjs, then re-run.");
  process.exit(3);
}

const mod = await import(url.pathToFileURL(smokePath).href);
const config = mod.config || {};
// Pace can be overridden per run via env vars, without editing smoke.mjs.
const slowMo = Number(process.env.APP_TEST_SLOWMO) || config.slowMo || 350;
const stepPause = Number(process.env.APP_TEST_PAUSE) || config.stepPauseMs || 900;
if (typeof mod.run !== "function") {
  console.error("smoke.mjs must export a `run` function");
  process.exit(3);
}

async function isUp(target) {
  try {
    const res = await fetch(target);
    return res.status < 500;
  } catch {
    return false;
  }
}

function stopServer(proc) {
  if (!proc) return;
  try {
    if (process.platform === "win32") {
      spawn("taskkill", ["/F", "/T", "/PID", String(proc.pid)], {
        stdio: "ignore",
      });
    } else {
      proc.kill("SIGTERM");
    }
  } catch {
    /* best effort */
  }
}

let serverProc = null;
let browser = null;
const results = [];

try {
  if (mod.setup) {
    await mod.setup({ appDir });
  }

  // --- launch the app ----------------------------------------------------
  const alreadyUp = config.url ? await isUp(config.url) : false;
  if (config.start && !alreadyUp) {
    const parts = config.start.split(" ");
    serverProc = spawn(parts[0], parts.slice(1), {
      cwd: path.join(appDir, config.cwd || "."),
      env: { ...process.env, ...(config.env || {}) },
      stdio: "ignore",
    });
    const deadline = Date.now() + (config.readyTimeoutMs || 20000);
    while (Date.now() < deadline && !(await isUp(config.url))) {
      await new Promise((r) => setTimeout(r, 300));
    }
    if (!(await isUp(config.url))) {
      throw new Error(`app did not become ready at ${config.url}`);
    }
  }

  // --- browser -----------------------------------------------------------
  // Headed + slowed down so a person can watch it like a live demo.
  browser = await chromium.launch({
    headless: false,
    slowMo,
  });
  const page = await browser.newPage({
    viewport: config.viewport || { width: 1280, height: 860 },
  });

  if (Array.isArray(config.permissions) && config.permissions.length) {
    try {
      await page
        .context()
        .grantPermissions(config.permissions, { origin: config.url });
    } catch {
      /* permissions are best effort */
    }
  }

  const shotsDir = path.join(appDir, "tests", "screenshots");
  fs.rmSync(shotsDir, { recursive: true, force: true });
  fs.mkdirSync(shotsDir, { recursive: true });

  // A caption pinned to the bottom of the page, so a watcher can follow
  // along — what step is running and whether it passed.
  async function showCaption(text) {
    try {
      await page.evaluate((label) => {
        let el = document.getElementById("__app_test_caption");
        if (!el) {
          el = document.createElement("div");
          el.id = "__app_test_caption";
          el.style.cssText =
            "position:fixed;left:0;right:0;bottom:0;z-index:2147483647;" +
            "padding:14px 22px;background:#0f2742;color:#fff;text-align:center;" +
            "font:600 16px/1.45 'Segoe UI',system-ui,sans-serif;" +
            "box-shadow:0 -2px 16px rgba(0,0,0,.5);pointer-events:none;";
          document.body.appendChild(el);
        }
        el.textContent = label;
      }, text);
    } catch {
      /* the page may be mid-navigation */
    }
  }

  async function step(name, fn) {
    const n = results.length + 1;
    await showCaption(`Step ${n}:  ${name}`);
    const started = Date.now();
    let ok = true;
    let error = "";
    try {
      await fn();
    } catch (err) {
      ok = false;
      error = err.message;
    }
    results.push({ name, ok, ms: Date.now() - started, error });
    console.log(`  ${ok ? "PASS" : "FAIL"}  ${name}${error ? "  — " + error : ""}`);
    await showCaption(`Step ${n}:  ${name}   ${ok ? "PASS" : "FAILED"}`);
    await page.waitForTimeout(stepPause);
    const slug =
      String(n).padStart(2, "0") +
      "-" + name.replace(/[^a-z0-9]+/gi, "-").toLowerCase().slice(0, 50);
    try {
      await page.screenshot({ path: path.join(shotsDir, `${slug}.png`) });
    } catch {
      /* ignore screenshot failures */
    }
  }

  function expect(condition, message) {
    if (!condition) {
      throw new Error(message || "assertion failed");
    }
  }

  console.log(`\napp-test — ${appDir}\n`);
  await mod.run({ page, step, expect, appDir, config });

  const okSoFar = results.filter((r) => r.ok).length;
  await showCaption(`Smoke test complete — ${okSoFar}/${results.length} passed`);
  await page.waitForTimeout(2500);
} catch (err) {
  console.log(`  FATAL  ${err.message}`);
  results.push({ name: "runner", ok: false, error: err.message });
} finally {
  if (browser) {
    await browser.close().catch(() => {});
  }
  stopServer(serverProc);
  if (mod.teardown) {
    try {
      await mod.teardown({ appDir });
    } catch {
      /* teardown is best effort */
    }
  }
}

const passed = results.filter((r) => r.ok).length;
const failed = results.length - passed;
console.log(`\n${"=".repeat(48)}`);
console.log(`${passed} passed, ${failed} failed`);
console.log(`screenshots: ${path.join(appDir, "tests", "screenshots")}`);
process.exit(failed ? 1 : 0);
