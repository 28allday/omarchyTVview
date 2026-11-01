import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Bar icon: click to open or close the window showing the TV's screen. It takes
// the accent colour while the window is open. State lives in Service.qml.
BarWidget {
  id: root
  moduleName: "nosignal.omarchytvview"

  readonly property string pluginId: "nosignal.omarchytvview"
  readonly property var service: (bar && bar.shell) ? bar.shell.serviceFor(pluginId) : null
  readonly property bool running: service ? service.running : false
  readonly property string error: service ? service.error : ""

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰔂"
    tooltipText: root.running ? "omarchyTVview: close the TV window"
               : root.error !== "" ? root.error
               : "omarchyTVview: show the TV here"
    useActiveColor: false
    // Theme colours come through the Commons alias: in a plugin, a bare `Color`
    // resolves to a different object whose fields are all undefined.
    foreground: root.running ? Commons.Color.accent
              : root.bar ? root.bar.foreground
              : Commons.Color.foreground
    onPressed: function(b) { if (root.service) root.service.toggle() }
  }
}
