'use strict';

function set(id, ok, text) {
  var row = document.getElementById(id);
  row.classList.remove('ok', 'fail');
  row.classList.add(ok ? 'ok' : 'fail');
  row.querySelector('.val').textContent = text;
}

async function run() {
  // 1. WebView engine
  set('t-ua', true, navigator.userAgent.replace(/^Mozilla\/5\.0 /, '').slice(0, 90));

  // 2. Bridge ping roundtrip
  try {
    var t0 = performance.now();
    var pong = await window.NativeBridge.call('ping');
    var ms = Math.max(1, Math.round(performance.now() - t0));
    set('t-bridge', pong && pong.pong === true, pong && pong.pong ? '通，往返 ' + ms + 'ms' : '响应异常');
  } catch (e) {
    set('t-bridge', false, '失败：' + e.message);
  }

  // 3. Device info through the bridge
  try {
    var info = await window.NativeBridge.call('getInfo');
    set('t-info', true, info.systemName + ' ' + info.systemVersion + ' · ' +
      info.screenWidthPt + '×' + info.screenHeightPt + ' @' + info.screenScale + 'x · v' + info.appVersion);
  } catch (e) {
    set('t-info', false, '失败：' + e.message);
  }

  // 4. localStorage
  try {
    localStorage.setItem('hg-shell-test', 'ok-1');
    var v = localStorage.getItem('hg-shell-test');
    set('t-storage', v === 'ok-1', v === 'ok-1' ? '可读写' : '读回不一致');
  } catch (e) {
    set('t-storage', false, '失败：' + e.message);
  }

  // 5/6. Media support
  var video = document.createElement('video');
  var h264 = video.canPlayType('video/mp4; codecs="avc1.640028, mp4a.40.2"');
  set('t-h264', !!h264, h264 || '不支持');
  var hevc = video.canPlayType('video/mp4; codecs="hvc1.1.6.L123, mp4a.40.2"');
  set('t-hevc', !!hevc, hevc || '不支持');

  // 7. Network reachability (opaque response still proves reachability)
  try {
    await fetch('https://hongguoduanju.com/', { mode: 'no-cors', cache: 'no-store' });
    set('t-net', true, '可达');
  } catch (e) {
    set('t-net', false, '失败：' + e.message);
  }
}

document.getElementById('rerun').addEventListener('click', run);
window.addEventListener('load', run);
