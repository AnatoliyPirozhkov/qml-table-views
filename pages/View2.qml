import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.qmlmodels 1.0
import "../modules"

Page {
    property int textSize: 20

    header: Rectangle {
        id: _header
        height: 30
        color: "#FF22A6F1"

        Text {
            id: _title
            text: qsTr("Table of cereals")
            font.pixelSize: textSize
            color: "white"
            anchors.centerIn: parent
        }
    }

    WarningDialog { id: _warningDialog }

    Item {
        // It's no visual object
        id:_data
        property var arr: []
        function clear() { arr = []; }
    }

    function fillIn() {
        _modelT.createModelRows()
        _dataView.isEdit = false;
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
            ListElement { name: ""; unit: "" }
            ListElement { name: "In Stock Mass"; unit: "[kg]" }
            ListElement { name: "Actual Mass"; unit: "[kg]" }
            ListElement { name: "Difference"; unit: "[kg]" }
            ListElement { name: "Temperature"; unit: "[°С]" }
            ListElement { name: "Humidity"; unit: "[%]" }
        }

        TableView {
            id: _dataView
            height: _tableRect.height - _rowSave.height - 20
            width: _tableRect.width
            clip: true
            topMargin: _columnsHeader.implicitHeight
            bottomMargin: _rowSave.height
            focus: true

            property int selectedRow: 0
            property int selectedColum: 1
            property bool isEdit: false

            onFocusChanged: isEdit = false

            Keys.onUpPressed: {if (selectedRow!=0) selectedRow = --selectedRow}
            Keys.onDownPressed: {if (selectedRow!=_dataView.rows-1) selectedRow = ++selectedRow}

            Keys.onLeftPressed: {
                if (selectedColum > 0) selectedColum = --selectedColum
                if (selectedColum === 0) { selectedColum = _dataView.columns-2; selectedRow = --selectedRow; }
                if (selectedRow < 0) { selectedColum = _dataView.columns-2; selectedRow = _dataView.rows-1; }
            }
            Keys.onRightPressed: {
                if (selectedColum < _dataView.columns+1) selectedColum = ++selectedColum
                if (selectedColum === _dataView.columns-1) { selectedColum = 1; selectedRow = ++selectedRow; }
                if (selectedRow >= _dataView.rows) { selectedColum = 1; selectedRow = 0; }
            }

            function keyTab()  {
                if (selectedColum < _dataView.columns+1) selectedColum = ++selectedColum
                if (selectedColum === _dataView.columns-1) { selectedColum = 1; selectedRow = ++selectedRow; }
                if (selectedRow >= _dataView.rows) { selectedColum = 1; selectedRow = 0; }
            }
            Keys.onTabPressed:keyTab()

            function fEnter() {
                isEdit = isEdit ? false : true;
            }

            Keys.onReturnPressed: fEnter()
            Keys.onEnterPressed:  fEnter()

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                  isEdit = false
                  event.accepted = true;
                }
            }

            ScrollBar.horizontal: ScrollBar{}
            ScrollBar.vertical: ScrollBar{}

            property var columnWidths: [width*0.20, width*0.16, width*0.16, width*0.16, width*0.16, width*0.16, 0]
            columnWidthProvider: function (column) { return columnWidths[column] }

            Timer {
                id: _timer
                running: true
                interval: 50
                onTriggered: _dataView.forceLayout();
            }
            onWidthChanged: _timer.restart()

            Row {
                id: _columnsHeader
                y: _dataView.contentY
                z: 2
                Repeater {
                    model: _modelHeader.count > 0 ? _modelHeader.count : 1
                    Item {
                        width: _dataView.columnWidthProvider(modelData)
                        height: 40
                        Label {
                            id: _topLabel
                            width: _dataView.columnWidthProvider(modelData)
                            height: 20
                            text: _modelHeader.get(modelData).name
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            background: Rectangle { border.color: "#C4C4C4"; color: "#F1F1F1" }
                        }
                        Label {
                            anchors.top: _topLabel.bottom
                            anchors.left: _topLabel.left
                            width: _dataView.columnWidthProvider(modelData)
                            height: 20
                            text: _modelHeader.get(modelData).unit
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            background: Rectangle { border.color: "#C4C4C4"; color: "#F1F1F1" }
                        }
                    }
                }
            }

            model:
                TableModel {
                    id: _modelT
                    TableModelColumn { display: "name"; }
                    TableModelColumn { display: "sMass"; }
                    TableModelColumn { display: "aMass"; }
                    TableModelColumn { display: "massDiff"; }
                    TableModelColumn { display: "temperature"; }
                    TableModelColumn { display: "humidity"; }
                    TableModelColumn { display: "isChanged"; }

                    rows: [
                        { name:"Rice",   sMass:parseFloat(10000), aMass:parseFloat(10000), massDiff:parseFloat(0), temperature:parseFloat(18), humidity:parseFloat(16.00), isChanged:0},
                        { name:"Wheat",  sMass:28901,   aMass:28901,    massDiff:0, temperature:19, humidity:14, isChanged:0},
                        { name:"Barley", sMass:32980,   aMass:32980,    massDiff:0, temperature:17, humidity:12, isChanged:0},
                        { name:"Rye",    sMass:21673.92,aMass:21673.92, massDiff:0, temperature:20, humidity:13, isChanged:0}
                    ]

                    function createModelRows() {
                        _data.clear()
                        for(var i = 0; i < _modelT.rowCount; i++) {
                            var c0 = _modelT.rows[i].name;
                            var c1 = _modelT.rows[i].sMass;
                            var c2 = _modelT.rows[i].aMass;
                            var c3 = _modelT.rows[i].massDiff;
                            var c4 = _modelT.rows[i].temperature;
                            var c5 = _modelT.rows[i].humidity;
                            //We create an array to compare the changes in the model (table) with the original data.
                            _data.arr[i] = [c0, c1, c2, c3, c4, c5];
                        }
                        cencelModelRows()
                    }

                    function cencelModelRows() {
                        _modelT.clear()
                        for (let i = 0; i < _data.arr.length; i++) {
                            var c0 = _data.arr[i][0];
                            var c1 = _data.arr[i][1];
                            var c2 = _data.arr[i][2];
                            var c3 = _data.arr[i][3];
                            var c4 = _data.arr[i][4];
                            var c5 = _data.arr[i][5];

                            _modelT.appendRow({name:        c0,
                                               sMass:       c1,
                                               aMass:       c2,
                                               massDiff:    c3,
                                               temperature: c4,
                                               humidity:    c5,
                                               isChanged: 0})
                        }
                    }
                }

                delegate: DelegateChooser {
                DelegateChoice {
                    // First column
                    column: 0
                    delegate: ItemDelegate {
                        id: _myItemDelegate
                        text: model.display

                        background: Rectangle {
                           anchors.fill: _myItemDelegate
                           color: "#F1F1F1"
                           border.color: "#FF536872"
                        }
                    }
                }

                DelegateChoice {
                    // Fourth column
                    column: 3
                    delegate: ItemDelegate {
                        id: _uneditableItemDelegate
                        highlighted: row === _dataView.selectedRow && column === _dataView.selectedColum
                        text: model.display

                        background: Rectangle {
                           anchors.fill: _uneditableItemDelegate
                           color: _uneditableItemDelegate.highlighted ? "#FFBEE5FF" : "#FFFFFAED"
                           border.color: "#FF536872"
                        }
                    }
                }

                DelegateChoice {
                    delegate: ItemDelegate {
                        id: _EditedDelegate
                        highlighted: row === _dataView.selectedRow && column === _dataView.selectedColum
                        onHighlightedChanged: _dataView.isEdit = false

                        TextField {
                            id: _tf
                            z: 4
                            anchors.fill: parent
                            text: model.display
                            focus: _dataView.isEdit && _EditedDelegate.highlighted
                            validator: RegExpValidator { regExp: /^[0-9]*([.][0-9]{0,3}|)$/ }
                            Keys.onTabPressed: {
                                _dataView.isEdit = false
                                event.accepted = true;
                                _dataView.keyTab()
                            }

                            property bool cLock : false

                            onTextEdited: {
                                model.display = _tf.text
                                var mIndex6 = _modelT.index(_dataView.selectedRow,6)

                                //Responding to changes in table values
                                if (_data.arr[_dataView.selectedRow][_dataView.selectedColum].toString() !== _tf.text)
                                {
                                    color = "#FFEB4C42"
                                    if (!cLock)
                                    {
                                        let changesCount = _modelT.rows[_dataView.selectedRow].isChanged
                                        _modelT.setData(mIndex6,"display",++changesCount)
                                        cLock = true;
                                    }
                                }
                                else
                                {
                                    color = "#353637"
                                    if (cLock)
                                    {
                                        let changesCount = _modelT.rows[_dataView.selectedRow].isChanged
                                        _modelT.setData(mIndex6,"display",--changesCount)
                                        cLock = false;
                                    }
                                }

                                //Computing differences
                                var mIndex1 = _modelT.index(_dataView.selectedRow,1)
                                var mIndex2 = _modelT.index(_dataView.selectedRow,2)
                                var mIndex3 = _modelT.index(_dataView.selectedRow,3)

                                _modelT.setData(mIndex3, "display", (_modelT.data(mIndex2, "display") - _modelT.data(mIndex1, "display")).toFixed(3))
                            }

                            background: Rectangle {
                                anchors.fill: parent
                                color: _EditedDelegate.highlighted ? _dataView.isEdit ? "#FFB4FFBD" : "#FFBEE5FF" : "transparent"
                                border.color: "#FF536872"
                            }

                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onClicked: {
                                    _dataView.focus = true
                                    mouse.accepted = false
                                    _dataView.selectedRow = row
                                    _dataView.selectedColum = column
                                }
                                onDoubleClicked: {
                                    mouse.accepted = false
                                    _dataView.isEdit = true
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            id: _rowSave
            Layout.fillWidth: true
            anchors.top: _dataView.bottom
            anchors.horizontalCenter: _dataView.horizontalCenter
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 10

            ToolButton {
                text: qsTr("  Save  ")
                icon.color: "transparent";
                icon.source: "/img/save.png";
                onClicked: _rowSave.saveTable();
            }

            ToolButton {
                text: qsTr(" Cancel ")
                icon.color: "transparent";
                icon.source: "/img/cancel.png";
                onClicked: _rowSave.cancelTable();
            }

            function saveTable() {
                let flag = false;
                for(var i = 0; i < _modelT.rowCount; i++)
                    if (_modelT.rows[i].isChanged) {
                        flag = true;
                        break;
                    }

                if (flag) {
                    _warningDialog.title = qsTr("Table of cereals")
                    _warningDialog.warningText = qsTr("Are you sure you want to update a data?")
                    _warningDialog.standardButtons = Dialog.Yes | Dialog.No
                    _warningDialog.acceptFunction = function(){ _modelT.createModelRows() }
                    _warningDialog.open();
                }
            }

            function cancelTable() { _modelT.cencelModelRows() }
        }
    }
}
