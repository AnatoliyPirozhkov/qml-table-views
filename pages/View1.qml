import QtQuick 2.14
import QtQuick.Controls 2.12
import Qt.labs.qmlmodels 1.0

Page {
    property int textSize: 20
    readonly property int newWidth: 800
    readonly property int newHeight: 576

    header: Rectangle {
        id: _header
        height: 30
        color: "#FF22A6F1"

        Text {
            id: _title
            text: qsTr("Condition of tanks")
            font.pixelSize: textSize
            color: "white"
            anchors.centerIn: parent
        }
    }

    Rectangle {
        id: _tableRect
        border.color: "#065999"
        border.width: 1
        radius: 6
        anchors.fill: parent
        anchors.margins: 4
        clip: true

        ListModel {
            id: _modelHeader
            ListElement { fluid: ""; name: "№" }
            ListElement { fluid: ""; name: "Brand" }
            ListElement { fluid: "Oil"; name: "volume, l" }
            ListElement { fluid: "Oil"; name: "level, mm" }
            ListElement { fluid: "Oil"; name: "temperature, °С" }
            ListElement { fluid: "Oil"; name: "density, g/m³" }
            ListElement { fluid: "Oil"; name: "mass, kg" }
        }

    TableView {
        id: _tankCondition
        anchors.fill: _tableRect
        clip: true
        topMargin: columnsHeader.implicitHeight
        focus: true

        property int selectedRow: 0

        Keys.onUpPressed: {if (selectedRow!=0) selectedRow = --selectedRow}
        Keys.onDownPressed: {if (selectedRow!=_tankCondition.rows-1) selectedRow = ++selectedRow}

        ScrollBar.horizontal: ScrollBar{}
        ScrollBar.vertical: ScrollBar{}

        property var columnWidths: [width*0.04, width*0.14, width*0.22, width*0.15, width*0.15, width*0.15, width*0.15]
        columnWidthProvider: function (column) { return columnWidths[column] }

        Timer {
            id: _timer
            running: true
            interval: 50
            onTriggered: _tankCondition.forceLayout()
        }

        onWidthChanged: _timer.restart()

        Row {
            id: columnsHeader
            y: _tankCondition.contentY
            z: 2
            Repeater {
                model: _modelHeader.count > 0 ? _modelHeader.count : 1
                Label {
                    width: _tankCondition.columnWidthProvider(modelData)
                    height: 45
                    text: _modelHeader.get(modelData).fluid +"\n"+ _modelHeader.get(modelData).name
                    color: '#FFE1E1E1'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter

                    background: Rectangle { border.color: "#FF000000"; color: "#FF5B5F68" }
                }
            }
        }

        model:
            TableModel {
                id: _modelT
                TableModelColumn { display: "number"; decoration: function() { return "";} }
                TableModelColumn { display: "name"; decoration: function() { return "";}}
                TableModelColumn { display: "fvolume"; decoration: "type"}
                TableModelColumn { display: "flevel"; decoration: function() { return "";}}
                TableModelColumn { display: "ftemp"; decoration: function() { return "";} }
                TableModelColumn { display: "fdensity"; decoration: function() { return "";}}
                TableModelColumn { display: "fmass"; decoration:function() { return "";}}

                rows: [
                    {number:1, name:"Valvoline", type: "bp", fvolume:"800 (50%)",  flevel:552,  ftemp:18, fdensity:910, fmass:10000},
                    {number:2, name:"Mobil 1",   type: "bp", fvolume:"533 (30%)",  flevel:333,  ftemp:22, fdensity:922, fmass:3000},
                    {number:3, name:"Liqui Moly",type: "bp", fvolume:"160 (10%)",  flevel:110,  ftemp:16, fdensity:935, fmass:1200},
                    {number:4, name:"Castrol",   type: "bp", fvolume:"1440 (90%)", flevel:1070, ftemp:19, fdensity:892, fmass:14500}
                ]
            }

            delegate: DelegateChooser {
                role: "decoration"

                DelegateChoice {
                    roleValue: "bp"
                    delegate: ItemDelegate {
                        id: _pbDelegate
                        property alias valueText: _text.text
                        highlighted: row === _tankCondition.selectedRow
                        onValueTextChanged: {
                            let regexp = /\d{1,2}(?:\.\d{1,2})?%/;
                            _pbControl.value = Number(model.display.match(regexp)[0].slice(0, -1)) / 100
                        }

                        ProgressBar {
                            id: _pbControl
                            property real yellow_level  : 0.45
                            property real red_level     : 0.13

                            anchors.fill: parent
                            padding: 2
                            onValueChanged: {
                                // Color depending on the percentage of filling
                                if (value <= red_level)
                                   {_bar.color = "#FFD5382C"; _bbar.border.color = "#FFCD3232"}
                                else if (value <= yellow_level)
                                        {_bar.color = "#FFD5B92C"; _bbar.border.color = "#FFCDB332"}
                                      else  {_bar.color = "#FF41D52C"; _bbar.border.color = "#FF32CD32"}
                            }

                            Text {
                                id: _text
                                anchors.centerIn: parent
                                text: model.display
                            }

                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 6
                                border.color: "#FF536872"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: _tankCondition.selectedRow = row
                                }

                                Rectangle {
                                    id: _bbar
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    radius: 3
                                    border.width: 1.4
                                    color: _pbDelegate.highlighted ? "#FFD0ECFF" : "transparent"
                                }
                            }

                            contentItem: Item {
                                implicitWidth: 200
                                implicitHeight: 4

                                Rectangle {
                                    id: _bar
                                    width: _pbControl.visualPosition * parent.width
                                    height: parent.height
                                    radius: 3
                                }
                            }
                        }
                    }
                }

                DelegateChoice {
                    delegate: ItemDelegate {
                        id: _textDelegate
                        highlighted: row === _tankCondition.selectedRow
                        onClicked: _tankCondition.selectedRow = row
                        text: model.display

                        background: Rectangle {
                            anchors.fill: _textDelegate
                            color: _textDelegate.highlighted ? "#FFD0ECFF" : "transparent"
                            border.color: "#FF536872"
                        }
                    }
                }
            }
        }
    }
}
