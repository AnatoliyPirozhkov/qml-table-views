import QtQuick.Controls 2.14

ApplicationWindow  {
  id: mainWindow
  visible: true
  width:  ps.newWidth+12
  height: ps.newHeight
  title:  qsTr("QML table views")

  menuBar: MenuBar {
    Menu {
      title: qsTr("&Table views")
      MenuItem {
        text: qsTr("View &1");
        icon {
            color: "transparent";
            source: "/img/table1.png";
        }
        onTriggered: ps.pop();
      }
      MenuItem {
        text: qsTr("&View &2");
        icon {
            color: "transparent";
            source: "/img/table2.png";
        }
        onTriggered: ps.showView2();
      }
    }
  }

  PageStack {
      id: ps
  }
}
