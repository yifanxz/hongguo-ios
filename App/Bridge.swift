import Foundation
import UIKit
import WebKit

/// Native bridge for the WebView shell (v0.1, shell verification).
///
/// JS side contract (injected at document start by ViewController):
///   window.NativeBridge.call(method, params) -> Promise<response>
/// Messages arrive as { method: String, id: Int, params: [String: Any] }.
/// Responses go back through window.__nativeResponse(id, jsonString).
///
/// This mirrors the contract shape planned for the full bridge
/// (private storage / crypto / media), so the JS shim will not change.
final class Bridge: NSObject, WKScriptMessageHandler {
    private weak var webView: WKWebView?

    func attach(to webView: WKWebView) {
        self.webView = webView
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "native",
              let body = message.body as? [String: Any],
              let method = body["method"] as? String,
              let id = body["id"] as? Int else {
            return
        }
        let params = body["params"] as? [String: Any] ?? [:]
        let result = handle(method: method, params: params)
        respond(id: id, payload: result)
    }

    private func handle(method: String, params: [String: Any]) -> [String: Any] {
        switch method {
        case "ping":
            return ["pong": true, "ts": Date().timeIntervalSince1970]
        case "echo":
            return ["echo": params]
        case "getInfo":
            let screen = UIScreen.main
            return [
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?",
                "buildNumber": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?",
                "bundleId": Bundle.main.bundleIdentifier ?? "?",
                "systemName": UIDevice.current.systemName,
                "systemVersion": UIDevice.current.systemVersion,
                "model": UIDevice.current.model,
                "screenWidthPt": Double(screen.bounds.width),
                "screenHeightPt": Double(screen.bounds.height),
                "screenScale": Double(screen.scale),
            ]
        default:
            return ["error": "UNKNOWN_METHOD", "method": method]
        }
    }

    private func respond(id: Int, payload: [String: Any]) {
        guard let webView,
              let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8),
              let literalData = try? JSONSerialization.data(withJSONObject: [json]),
              var literal = String(data: literalData, encoding: .utf8) else {
            return
        }
        // literal is a JSON array string like ["{...}"]; unwrap to a quoted string.
        literal.removeFirst()
        literal.removeLast()
        let js = "window.__nativeResponse && window.__nativeResponse(\(id), \(literal))"
        DispatchQueue.main.async {
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    /// JS shim injected at document start. Defines the promise-based
    /// NativeBridge.call used by all bundled web content.
    static var shimScript: String {
        """
        (function () {
          if (window.NativeBridge) return;
          var callbacks = {};
          var seq = 0;
          window.__nativeResponse = function (id, jsonString) {
            var entry = callbacks[id];
            if (!entry) return;
            delete callbacks[id];
            try { entry.resolve(JSON.parse(jsonString)); }
            catch (e) { entry.reject(e); }
          };
          window.NativeBridge = {
            call: function (method, params) {
              return new Promise(function (resolve, reject) {
                var id = ++seq;
                callbacks[id] = { resolve: resolve, reject: reject };
                window.webkit.messageHandlers.native.postMessage({
                  method: method, id: id, params: params || {}
                });
              });
            }
          };
        })();
        """
    }
}
