import axios from "axios";

const client = axios.create({
  baseURL: "/api",
  timeout: 600000
});

export async function fetchHealth() {
  const { data } = await client.get("/health");
  return data;
}
const PNG_SIG = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];

function matchPngAt(u8, offset) {
  if (offset < 0 || offset + 8 > u8.byteLength) return false;
  for (let j = 0; j < 8; j++) {
    if (u8[offset + j] !== PNG_SIG[j]) return false;
  }
  return true;
}

/** 从缓冲区开头识别 PNG（无前置杂字节时） */
function isPngBuffer(u8) {
  return matchPngAt(u8, 0);
}

/**
 * 在响应前若干字节内查找 PNG 头（应对 UTF-8 BOM、代理前置空白等）。
 */
function firstPngOffset(u8, searchLimit = 65536) {
  const max = Math.min(u8.byteLength - 8, Math.max(0, searchLimit));
  for (let i = 0; i <= max; i++) {
    if (matchPngAt(u8, i)) return i;
  }
  return -1;
}

/**
 * 若 Plumber 把 raw 误序列化成 { value: [byte,...], filename }，尝试还原为 PNG。
 */
/**
 * jsonlite 对 R raw 向量会序列成 JSON 数组包一段 Base64 字符串，如 ["iVBORw0K..."]。
 * 若后端误走 JSON 序列化，在此还原为 PNG Blob。
 */
function blobFromJsonArrayBase64Png(data) {
  if (!Array.isArray(data) || data.length !== 1) return null;
  const s = data[0];
  if (typeof s !== "string" || s.length < 32) return null;
  try {
    const bin = atob(s.replace(/\s/g, ""));
    const len = bin.length;
    const u8 = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      u8[i] = bin.charCodeAt(i);
    }
    if (!isPngBuffer(u8)) return null;
    return new Blob([u8], { type: "image/png" });
  } catch {
    return null;
  }
}

function blobFromPlumberStyleJson(data) {
  if (!data || typeof data !== "object") return null;
  const v = data.value;
  if (!Array.isArray(v) || v.length < 8) return null;
  const bytes = new Uint8Array(v.length);
  for (let i = 0; i < v.length; i++) {
    const n = v[i];
    if (typeof n !== "number" || n < 0 || n > 255) return null;
    bytes[i] = n;
  }
  if (!isPngBuffer(bytes)) return null;
  return new Blob([bytes], { type: "image/png" });
}

/**
 * 提交绘图：multipart/form-data，字段名 `file`。
 * 使用 fetch + arrayBuffer：先按 PNG 魔数识别二进制（不依赖 Content-Type，避免代理/Plumber 标错类型）。
 * 成功体为 PNG 二进制；JSON 仅用于业务/HTTP 错误（{ ok:false, error }）。
 */
function responseContentType(res) {
  const h = res.headers.get("content-type");
  return h ? h.split(";")[0].trim().toLowerCase() : "";
}

/** Plumber/jsonlite 常把标量序列化成单元素数组，如 "ok":[true]、"error":["msg"] */
function rJsonScalar(x) {
  if (Array.isArray(x) && x.length === 1) {
    return x[0];
  }
  return x;
}

export async function requestBubblePlot(formData) {
  if (!(formData instanceof FormData)) {
    throw new TypeError("requestBubblePlot: 参数必须是 FormData");
  }
  let res;
  try {
    /* 不传 Content-Type：浏览器为 FormData 自动带 multipart boundary */
    res = await fetch("/api/plot", {
      method: "POST",
      body: formData,
      cache: "no-store"
    });
  } catch (e) {
    const msg = e && e.message ? String(e.message) : "";
    const isConn = /ECONNREFUSED|Failed to fetch|NetworkError|Load failed/i.test(msg);
    throw new Error(
      isConn
        ? "无法连接绘图服务（127.0.0.1:8787）。请先在 enrichment-bubble-tool/backend 目录运行 Rscript run_api.R，并保持该窗口开启后再刷新页面重试。"
        : msg || "绘图请求失败"
    );
  }
  const buf = await res.arrayBuffer();
  const u8 = new Uint8Array(buf);
  const ct = responseContentType(res);
  const jsonByHeader = ct === "application/json" || ct.endsWith("+json");

  const tryParseJsonBody = () => {
    const text = new TextDecoder("utf-8", { fatal: false }).decode(buf);
    const trimmed = text.trimStart().replace(/^\uFEFF/, "");
    try {
      const data = JSON.parse(trimmed);
      return { trimmed, data };
    } catch {
      const hint = trimmed.length > 160 ? `${trimmed.slice(0, 160)}…` : trimmed;
      throw new Error(
        res.ok
          ? `无法解析响应（既不是 PNG 也不是 JSON）。片段：${hint}`
          : `请求失败 HTTP ${res.status}：${hint}`
      );
    }
  };

  const attachStatsFields = (target, data) => {
    if (!target || !data || typeof data !== "object") return;
    if (typeof data.raw_enrichment_csv === "string") {
      target.raw_enrichment_csv = data.raw_enrichment_csv;
    }
    if (typeof data.display_results_csv === "string") {
      target.display_results_csv = data.display_results_csv;
    }
    if (Array.isArray(data.display_results)) {
      target.display_results = data.display_results;
    }
    if (Array.isArray(data.raw_enrichment)) {
      target.raw_enrichment = data.raw_enrichment;
    }
    if (data.meta && typeof data.meta === "object") {
      target.meta = data.meta;
    }
    const pdfB64Raw = data.pdf_base64;
    const pdfB64 =
      typeof pdfB64Raw === "string"
        ? pdfB64Raw.replace(/\s+/g, "")
        : Array.isArray(pdfB64Raw)
          ? pdfB64Raw.join("").replace(/\s+/g, "")
          : "";
    if (pdfB64.length > 0) {
      try {
        target.pdf_blob = b64ToBlob(pdfB64, "application/pdf");
      } catch {
        target.pdf_blob = null;
      }
    } else {
      target.pdf_blob = null;
    }
  };

  const b64ToBlob = (b64, mime) => {
    const clean = String(b64).replace(/\s+/g, "");
    const bin = atob(clean);
    const bytes = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) {
      bytes[i] = bin.charCodeAt(i);
    }
    return new Blob([bytes], { type: mime || "image/png" });
  };

  const handleJsonValue = (data) => {
    const fromB64Arr = blobFromJsonArrayBase64Png(data);
    if (fromB64Arr) {
      const out = { ok: true, mime: "image/png", blob: fromB64Arr };
      attachStatsFields(out, data);
      return out;
    }
    const recovered = blobFromPlumberStyleJson(data);
    if (recovered) {
      const out = { ok: true, mime: "image/png", blob: recovered };
      attachStatsFields(out, data);
      return out;
    }
    const okFlag = rJsonScalar(data && data.ok);
    if (data && (okFlag === true || okFlag === 1)) {
      let b64 = data.image;
      if (Array.isArray(b64)) b64 = b64.join("");
      if (typeof b64 === "string" && b64.length > 0) {
        const mimeRaw = rJsonScalar(data.mime);
        const mime = typeof mimeRaw === "string" && mimeRaw ? mimeRaw : "image/png";
        let blob;
        try {
          blob = b64ToBlob(b64, mime);
        } catch {
          blob = null;
        }
        const out = {
          ok: true,
          mime,
          image: b64,
          ...(blob ? { blob } : {})
        };
        attachStatsFields(out, data);
        return out;
      }
      throw new Error(
        "后端返回 JSON 且 ok=true，但无有效图片字段（image 为空）。请确认已保存并重启 backend/plumber.R（成功时应直接返回 PNG 二进制而非 JSON）。"
      );
    }
    if (data && typeof data === "object") {
      const errRaw = rJsonScalar(data.error);
      return {
        ok: okFlag === true || okFlag === 1,
        error: typeof errRaw === "string" ? errRaw : undefined
      };
    }
    return { ok: false, error: "未知响应结构" };
  };

  if (res.ok && jsonByHeader) {
    const { data } = tryParseJsonBody();
    return handleJsonValue(data);
  }

  if (res.ok && !jsonByHeader) {
    try {
      const head = new TextDecoder("utf-8", { fatal: false })
        .decode(u8.slice(0, Math.min(4096, u8.byteLength)))
        .trimStart()
        .replace(/^\uFEFF/, "");
      if (head.startsWith("{") || head.startsWith("[")) {
        const { data } = tryParseJsonBody();
        return handleJsonValue(data);
      }
    } catch {
      /* 非 JSON，继续走 PNG / 错误分支 */
    }
  }

  if (res.ok) {
    if (isPngBuffer(u8)) {
      return {
        ok: true,
        mime: "image/png",
        blob: new Blob([buf], { type: "image/png" })
      };
    }
    const off = firstPngOffset(u8);
    if (off >= 0) {
      const slice = buf.slice(off);
      return {
        ok: true,
        mime: "image/png",
        blob: new Blob([slice], { type: "image/png" })
      };
    }
  }

  let trimmed;
  let data;
  try {
    const parsed = tryParseJsonBody();
    trimmed = parsed.trimmed;
    data = parsed.data;
  } catch (e) {
    throw e;
  }

  if (res.ok) {
    return handleJsonValue(data);
  }

  /* HTTP 非 2xx：优先返回结构化错误，便于 generate() 与 200+{ok:false} 同一套分支 */
  const errHttp = data && rJsonScalar(data.error);
  const msg =
    (typeof errHttp === "string" && errHttp) ||
    trimmed ||
    `HTTP ${res.status}`;
  return { ok: false, error: msg };
}
