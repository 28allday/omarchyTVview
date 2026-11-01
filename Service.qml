import QtQuick
import Quickshell
import Quickshell.Io

// One instance per shell. The bar mounts a widget per monitor, so the window's
// process lives here and every icon shows the same state.
//
//   omarchy-shell omarchytvview toggle | start | stop | status
Item {
  id: root

  // ---- injected by shell.qml (ensureService) ----
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null
  property var pluginRegistry: null

  readonly property string helper: {
    var url = String(Qt.resolvedUrl("bin/omarchytvview"))
    return decodeURIComponent(url.replace(/^file:\/\//, ""))
  }

  readonly property bool running: proc.running
  property string error: ""

  property bool _stopping: false
  property string _lastError: ""

  function start() {
    if (proc.running) return
    error = ""
    _lastError = ""
    _stopping = false
    proc.running = true
  }

  function stop() {
    if (!proc.running) return
    _stopping = true
    proc.running = false
  }

  function toggle() {
    if (proc.running) stop()
    else start()
  }

  function _notify(text) {
    Quickshell.execDetached(["notify-send", "--app-name=omarchyTVview", "--", "omarchyTVview",
                             text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")])
  }

  Process {
    id: proc
    command: [root.helper]

    stderr: SplitParser {
      onRead: function(line) {
        var text = String(line || "")
        if (text.indexOf("omarchytvview: ") === 0) root._lastError = text.slice(15, 300)
        else if (text.indexOf("ERROR: ") === 0 && root._lastError === "") root._lastError = text.slice(7, 300)
      }
    }

    onExited: function(exitCode) {
      var stopping = root._stopping
      root._stopping = false
      if (stopping || exitCode === 0) return
      root.error = root._lastError !== "" ? root._lastError : "The connection to the TV ended."
      root._notify(root.error)
    }
  }

  IpcHandler {
    target: "omarchytvview"
    function toggle(): void { root.toggle() }
    function start(): void { root.start() }
    function stop(): void { root.stop() }
    function status(): string { return root.running ? "running" : (root.error !== "" ? "error" : "stopped") }
  }
}
