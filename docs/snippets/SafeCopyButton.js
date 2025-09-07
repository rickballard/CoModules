/
  SafeCopyButton: attaches a below-block "Copy (verified)" button that only
  activates once the block finishes rendering and stays stable for N ms.
 /
export function attachSafeCopy(blockEl, opts = {}) {
  const stableMs = opts.stableMs ?? 600;
  const label    = opts.label ?? "Copy (verified)";
  const footer   = document.createElement("div");
  footer.style.marginTop = "8px";

  const btn = document.createElement("button");
  btn.textContent = label;
  btn.disabled = true;
  footer.appendChild(btn);
  blockEl.after(footer);

  let timer = null, lastText = "", lastLen = 0;

  function currentText() {
    const src = blockEl.getAttribute("data-source-text");
    return src ?? blockEl.innerText ?? "";
  }

  function maybeEnable() {
    const complete = blockEl.getAttribute("data-render-complete") === "true";
    if (!complete) { btn.disabled = true; return; }
    const nowText = currentText();
    btn.disabled = !(nowText === lastText && nowText.length === lastLen);
  }

  const mo = new MutationObserver(() => {
    lastText = currentText();
    lastLen  = lastText.length;
    btn.disabled = true;
    if (timer) clearTimeout(timer);
    timer = setTimeout(maybeEnable, stableMs);
  });
  mo.observe(blockEl, { characterData: true, subtree: true, childList: true });

  blockEl.addEventListener("block:complete", () => {
    blockEl.setAttribute("data-render-complete","true");
    mo.takeRecords();
    if (timer) clearTimeout(timer);
    timer = setTimeout(maybeEnable, stableMs);
  }, { once: true });

  btn.addEventListener("click", async () => {
    const text = currentText();
    try { await navigator.clipboard.writeText(text);
      btn.textContent = "Copied ✓";
      setTimeout(()=> btn.textContent = label, 1200);
    } catch(e) {
      btn.textContent = "Copy failed";
      setTimeout(()=> btn.textContent = label, 1500);
    }
  });
}