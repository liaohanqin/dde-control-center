import QtQuick 2.1
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0
import Deepin.Locale 1.0
import Deepin.Widgets 1.0
import DBus.Com.Deepin.Daemon.Display 1.0
import DBus.Com.Deepin.SessionManager 1.0
import DBus.Com.Deepin.Daemon.Accounts 1.0
import DBus.Com.Deepin.Daemon.InputDevices 1.0

Rectangle {
    id: panelContent
    color: dconstants.bgColor

    property var inputDevicesId: InputDevices {}
    property var inputDevices: {
        var devices = new Object()
        for(var i in inputDevicesId.devInfoList){
            var path = inputDevicesId.devInfoList[i][0]
            var type = inputDevicesId.devInfoList[i][1]
            if(typeof(devices[type]) == "undefined"){
                var paths = new Array()
                devices[type] = paths
            }
            devices[type].push(path)
        }
        return devices
    }
    property bool isTouchpadExist: typeof(inputDevices["touchpad"]) != "undefined"

    property bool isSiderNavigate: false
    property string currentContentId: ""

    property alias moduleLoaderItem: rightBoxLoaderItem
    property alias moduleBox: rightBox
    property alias moduleIconList: moduleIconList

    property var iconIdToIndex
    property color tuhaoColor: "#faca57"

    property var sessionManager: SessionManager {}
    property var modulesId: ModulesData {}
    property var accountId: Accounts {}
    property var currentUserObj: User { path: accountId.userList[0] }

    property bool inExpandHideTrayIcon: false
    property bool inDssHome: true
    property var navigateIconModel: ListModel {}
    property real trayIconHeight: {
        if(navigateIconModel.count==0){
            return trayWidth
        }
        else{
            var new_tray_height = iconsArea.height/(navigateIconModel.count)
            return new_tray_height < trayWidth ? new_tray_height : trayWidth
        }
    }

    function initTrayIcon() {
        print("==> [info] initTrayIcon emit")
        avatarImage.imageSource = currentUserObj.iconFile
        userName.text = currentUserObj.userName.substring(0, 1).toUpperCase()
            +currentUserObj.userName.substring(1)
        var modules_id_array = modulesId.allIds
        moduleIconList.currentIndex = -1
        navigateIconModel.clear()
        for (var i in modules_id_array){
            var module_id = modules_id_array[i]
            if(module_id == "mouse_touchpad" && !isTouchpadExist){
                var localeName = modulesId.moduleLocaleNames["mouse"]
            }
            else{
                var localeName = modulesId.moduleLocaleNames[module_id]
            }
            navigateIconModel.append({
                "moduleId": module_id,
                "moduleLocaleName": localeName
            })
        }
        iconIdToIndex = new Object()
        for(var i=0; i<navigateIconModel.count; i++){
            iconIdToIndex[navigateIconModel.get(i).moduleId] = i
        }
    }

    function addHomeShutdownButton() {
        panelContent.isSiderNavigate = true

        var item = navigateIconModel.get(0)
        if(item.moduleId != "home"){
            navigateIconModel.insert(0, {
                "moduleId": "home",
                "moduleLocaleName": modulesId.moduleLocaleNames["home"]
            })
        }

        var item = navigateIconModel.get(navigateIconModel.count-1)
        if(item.moduleId != "shutdown"){
            navigateIconModel.append({
                "moduleId": "shutdown",
                "moduleLocaleName": modulesId.moduleLocaleNames["shutdown"]
            })
        }
    }

    function removeHomeShutdownButton() {
        panelContent.isSiderNavigate = false

        var item = navigateIconModel.get(0)
        if(item.moduleId == "home"){
            navigateIconModel.remove(0)
        }
        var item = navigateIconModel.get(navigateIconModel.count-1)
        if(item.moduleId == "shutdown"){
            navigateIconModel.remove(navigateIconModel.count - 1)
        }
    }

    function shutdownButtonClicked(){
        rootWindow.width = 0
        rootWindow.displayWidth = 0
        rootWindow.hide()
        sessionManager.PowerOffChoose()
    }

    function trayIconHoverHandler(module_id, index) {
        var tipDisplayHeight
        tipDisplayHeight = Math.abs(trayIconHeight - trayIconTip.height)/2 
            + trayIconHeight * index
        if (trayIconHeight == trayWidth) {
        }
        trayIconTip.y = tipDisplayHeight
        trayIconTip.text = modulesId.moduleLocaleNames[module_id]
        if(!inDssHome){
            trayIconTip.visible = true
        }
    }

    NumberAnimation {
        id: expandHideTrayIconAnimation
        duration: 300
        target: moduleIconList
        properties: "height"
        to: navigateIconModel.count * trayIconHeight

        onStopped: {
            inExpandHideTrayIcon = false
        }
    }

    Binding {
        target: moduleIconList
        property: "height"
        value: navigateIconModel.count * trayIconHeight
        when: !inExpandHideTrayIcon
    }

    Timer {
        running: true
        repeat: false
        interval: 100
        onTriggered: {
            initTrayIcon()
        }
    }

    ParallelAnimation {
        id: toSiderNavigateAnimation
        PropertyAnimation {
            target: headerArea
            property: "y"
            to: 0 - headerArea.height
            duration: 200
        }

        PropertyAnimation {
            target: footerArea
            property: "anchors.bottomMargin"
            to: -80
            duration: 200
        }
        PropertyAnimation {
            target: iconsArea
            property: "opacity"
            to: 0
            duration: 200
        }

        onStopped: {
            iconsArea.width = 48
            iconsArea.anchors.topMargin = 0
            listBox.width = 48
            moduleIconList.itemSize = 48
            addHomeShutdownButton()
            rightBoxLoaderItem.iconId = currentContentId
            moduleIconList.iconLabelOpacity = 0
            rightBox.x = 48
            showContentPanel.start()
        }
    }

    ParallelAnimation {
        id: showContentPanel
        PropertyAnimation {
            target: iconsArea
            property: "opacity"
            to: 1
            duration: 200
        }
    }

    ParallelAnimation {
        id: toGridNavigateAnimation
        PropertyAnimation {
            target: iconsArea
            property: "opacity"
            to: 0
            duration: 200
        }

        onStopped: {
            iconsArea.width = panelContent.width
            iconsArea.anchors.topMargin = headerArea.height
            listBox.width = 96 * 3
            moduleIconList.itemSize = 96
            removeHomeShutdownButton()
            rightBoxLoaderItem.iconId = ""
            moduleIconList.iconLabelOpacity = 1
            rightBox.x = panelContent.width
            showHomePanel.start()
        }
    }

    ParallelAnimation {
        id: showHomePanel
        PropertyAnimation {
            target: headerArea
            property: "y"
            to: 0
            duration: 200
        }

        PropertyAnimation {
            target: footerArea
            property: "anchors.bottomMargin"
            to: 0
            duration: 200
        }
        
        PropertyAnimation {
            target: iconsArea
            property: "opacity"
            to: 1
            duration: 200
        }
    }

    Column {
        id: headerArea
        height: childrenRect.height
        width: parent.width

        property bool headerClicked: false

        Rectangle {
            width: parent.width
            height: 150
            color: dconstants.contentBgColor

            DRoundImage {
                id: avatarImage
                roundRadius: 40
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    moduleIconList.iconClickAction("account")
                    headerArea.headerClicked = true
                }
            }

            DLabel {
                id: userName
                anchors.top: avatarImage.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 18
                color: tuhaoColor
            }
        }

        DSeparatorHorizontal{}

        DBaseLine {}
    }

    Item {
        id: iconsArea
        anchors.top: parent.top
        anchors.topMargin: headerArea.height
        anchors.left: parent.left
        width: parent.width
        height: childrenRect.height

        Rectangle {
            id: listBox
            width: 96 * 3
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(1, 0, 0, 0)

            GridView {
                id: moduleIconList
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                property int itemSize: 96
                cellHeight: itemSize
                cellWidth: itemSize
                property real iconLabelOpacity: 1

                function iconClickAction(iconId) {
                    currentContentId = iconId
                    if (iconId == 'shutdown'){
                        shutdownButtonClicked()
                    }
                    else if(iconId == "home"){
                        inDssHome = true
                        trayIconTip.visible = false
                        toGridNavigateAnimation.start()
                        if (frame.x != rootWindow.width - panelWidth){
                            showAll.restart()
                        }
                    }
                    else{
                        if (frame.x != rootWindow.width - panelWidth){
                            showAll.restart()
                        }
                        inDssHome = false
                        if(!panelContent.isSiderNavigate){
                            toSiderNavigateAnimation.start()
                        }
                        else{
                            rightBoxLoaderItem.iconId = currentContentId
                        }
                    }
                }

                function hightLightSelected(id){
                    for(var i=0; i<navigateIconModel.count; i++){
                        if(navigateIconModel.get(i).moduleId == id){
                            moduleIconList.currentIndex = i
                        }
                    }
                }

                delegate: ModuleIconItem {
                    isSiderNavigate: panelContent.isSiderNavigate
                }
                model: navigateIconModel
                currentIndex: -1
                maximumFlickVelocity: 0
            }
        }
    }

    Item {
        id: footerArea
        width: parent.width
        anchors.bottom: parent.bottom

        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 300 }
        }

        Image {
            anchors.bottom: parent.bottom
            source: "images/shutdown_bg.png"
        }

        DImageButton {
            id: shutdownButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 36
            normal_image: "images/shutdown_normal.png"
            hover_image: "images/shutdown_hover.png"
            press_image: hover_image

            onStateChanged: {
                if(state == ""){
                    shutdownText.color = dconstants.fgColor
                } else {
                    shutdownText.color = tuhaoColor
                }
            }

            onClicked: {
                shutdownButtonClicked()
            }
        }

        DLabel {
            id: shutdownText
            text: dsTr("Shutdown")
            anchors.top: shutdownButton.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 12
        }
    }

    Rectangle {
        id: rightBox
        width: parent.width - trayWidth
        height: parent.height
        color: dconstants.bgColor
        x: panelContent.width
        clip: true

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            //Eats mouse events
        }

        Row {
            id: rightBoxLoaderItem
            width: parent.width
            height: parent.height
            clip: true

            property string iconId
            onIconIdChanged: {
                rightBoxLoaderItem.visible = iconId != ''
                rightBoxLoader.iconId = iconId
                rightBoxLoader.source = (iconId == ''? '' : '../../modules/' + iconId + '/main.qml')
            }

            DSeparatorVertical {}

            Loader{
                id: rightBoxLoader
                property string iconId
                focus: true
                clip: true
                source: ''
                width: parent.width - 2
                height: parent.height

                onLoaded: {
                    if(iconId == "account" && headerArea.headerClicked){
                        timeoutShowCurrentUserDetail.start()
                    }
                }

                Timer {
                    id: timeoutShowCurrentUserDetail
                    interval: 200
                    running: false
                    repeat: false
                    onTriggered: {
                        rightBoxLoader.item.showCurrentUserDetail()
                        headerArea.headerClicked = false
                    }
                }
            }
        }
    }
}
