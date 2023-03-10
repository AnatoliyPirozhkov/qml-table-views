import QtQuick 2.12
import QtQuick.Controls 2.12
import "./pages"

Item {
    readonly property alias newWidth:  _view1.newWidth
    readonly property alias newHeight: _view1.newHeight

    anchors.fill: parent

    function pop() {
        _stack.pop();
    }

    function showView2() {
        if (_stack.currentItem !== _view2)
        {
            if (_stack.depth === 2)
            {
                _stack.replace(_view2);
            } else _stack.push(_view2);

            _view2.fillIn()
        }
    }

    StackView {
        id: _stack
        focus: true
        initialItem: _view1
        anchors.fill: parent
    }

    View1 {
        id: _view1
        visible: true
    }

    View2 {
        id: _view2
        visible: false
    }
}
