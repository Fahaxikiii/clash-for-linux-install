<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>clashctl KernelSU</title>
  <style>
    body { margin:0; font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif; background:#0b1020; color:#e7edf8; }
    .wrap { max-width:920px; margin:32px auto; padding:24px; }
    .card { background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08); border-radius:16px; padding:18px; margin-bottom:18px; }
    .row { display:flex; gap:12px; flex-wrap:wrap; }
    button { background:#2b6ef5; color:white; border:none; border-radius:10px; padding:10px 16px; cursor:pointer; }
    button.secondary { background:#1d2b45; }
    button.warn { background:#d84b4b; }
    input { padding:10px; border-radius:8px; border:1px solid #334c76; background:#0f172a; color:white; width:100%; box-sizing:border-box; }
    pre { white-space:pre-wrap; background:#0d1320; border-radius:10px; padding:14px; overflow:auto; }
    .pill { display:inline-block; padding:6px 10px; border-radius:999px; background:#123f3a; color:#8ef5da; font-size:12px; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h2>clashctl KernelSU</h2>
      <div class="row" style="margin-top:16px;">
        <button id="btnStart">启动</button>
        <button id="btnStop" class="warn">停止</button>
        <button id="btnRefresh" class="secondary">刷新状态</button>
      </div>
      <p style="margin-top:16px;">状态： <span id="statusPill" class="pill">loading...</span></p>
    </div>

    <div class="card">
      <h3>订阅管理</h3>
      <div class="row" style="align-items:flex-end;">
        <div style="flex:1; min-width:240px;">
          <input id="subUrl" placeholder="https://example.com/subscription.yaml" />
        </div>
        <button id="btnAddSub">添加订阅</button>
      </div>
      <pre id="subsOutput">加载中…</pre>
    </div>

    <div class="card">
      <h3>配置 / 日志</h3>
      <pre id="logsOutput">加载中…</pre>
    </div>
  </div>

  <script>
    async function api(path, method='GET', body=null) {
      const res = await fetch(path, {
        method,
        headers: body ? {'Content-Type':'application/json'} : {},
        body: body ? JSON.stringify(body) : null
      });
      return await res.json();
    }

    async function loadStatus() {
      const resp = await api('/api/status');
      const state = resp.status || {};
      const out = state.stdout || '';
      const running = /running:|started:/.test(out) || /running/.test(out);
      document.getElementById('statusPill').textContent = running ? 'running' : 'stopped';
      document.getElementById('statusPill').style.background = running ? '#123f3a' : '#3b2a2a';
      document.getElementById('statusPill').style.color = running ? '#8ef5da' : '#ffb0b0';
    }

    async function loadSubscriptions() {
      const resp = await api('/api/subscriptions');
      const out = resp.subscriptions && resp.subscriptions.stdout ? resp.subscriptions.stdout : 'No subscriptions';
      document.getElementById('subsOutput').textContent = out;
    }

    async function loadLogs() {
      const resp = await api('/api/logs');
      const out = resp.logs && resp.logs.stdout ? resp.logs.stdout : 'No logs';
      document.getElementById('logsOutput').textContent = out;
    }

    document.getElementById('btnStart').addEventListener('click', async () => {
      await api('/api/start', 'POST');
      await loadStatus();
      await loadLogs();
    });

    document.getElementById('btnStop').addEventListener('click', async () => {
      await api('/api/stop', 'POST');
      await loadStatus();
      await loadLogs();
    });

    document.getElementById('btnRefresh').addEventListener('click', async () => {
      await loadStatus();
      await loadSubscriptions();
      await loadLogs();
    });

    document.getElementById('btnAddSub').addEventListener('click', async () => {
      const url = document.getElementById('subUrl').value.trim();
      if (!url) return;
      await api('/api/subscriptions', 'POST', { url });
      document.getElementById('subUrl').value = '';
      await loadSubscriptions();
    });

    (async function onLoad() {
      await loadStatus();
      await loadSubscriptions();
      await loadLogs();
    })();
  </script>
</body>
</html>
