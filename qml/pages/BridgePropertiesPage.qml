import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge
    property var config

    function populate() {
        bridge.getConfig(
            function(cfg) {
                console.log("cfg", JSON.stringify(cfg));
                config = cfg;
            },
            notifier.notifyMessage
        );
    }

    Timer {
        id: repopulate_timer
        running: false
        interval: 1000
        onTriggered: populate()
    }

    onConfigChanged: {
        if(repopulate_timer.running) {
            // Cancel criterias
            if(config.swupdate2.checkforupdate === false &&
               (config.swupdate2.state === "unknown" ||
                config.swupdate2.state === "noupdates"||
                config.swupdate2.state === "allreadytoinstall")) {
                repopulate_timer.stop();
            }
        }
        else {
            // Poll criterias
            if(config.swupdate2.state === "transferring" ||
               config.swupdate2.state === "installing" ||
               config.swupdate2.checkforupdate === true) {
                repopulate_timer.start();
            }
        }
    }


    onVisibleChanged: {
        if (visible) {
            console.log("pop");
            populate();
            repopulate_timer.start();
        }
        else {
            repopulate_timer.stop();
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            busy: config.swupdate2.checkforupdate === true || config.swupdate2.state === "transferring" || config.swupdate2.state === "installing"

            MenuItem {
                text: qsTr("Check for updates")
                visible: config.swupdate2.checkforupdate === false  && (config.swupdate2.state === "unknown" ||  config.swupdate2.state === "noupdates")
                onClicked: {bridge.setConfig({swupdate2: {checkforupdate: true}},
                                             function(success) {
                                                 console.log("up succ!",  JSON.stringify(success));
                                                 page.populate();
                                             },
                                             notifier.notifyMessage);
                }
            }
            MenuItem {
                text: qsTr("Install updates")
                visible: config.swupdate2.state === "anyreadytoinstall" ||  config.swupdate2.state === "allreadytoinstall"
                onClicked: { Remorse.popupAction(page, qsTr("Installing updates"),
                                                 function() {bridge.setConfig({swupdate2: {install: true}},
                                                                             function(success) {
                                                                                 console.log("up succ!",  JSON.stringify(success));
                                                                                 page.populate();
                                                                             },
                                                                             notifier.notifyMessage);})
                }
            }
        }

        Column {
            //TODO: consider another model for this
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: qsTr("Bridge properties")
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.name
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("Name")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.modelid
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("Model")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin

                        function humanify(updStr) {
                            switch (updStr) {
                                case "noupdates":
                                    return qsTr("No updates available");
                                case "transferring":
                                    return qsTr("Transferring");
                                case "anyreadytoinstall":
                                    return qsTr("All ready to install");
                                case "allreadytoinstall":
                                    return qsTr("Some ready to install");
                                case "installing":
                                    return qsTr("Installing");
                                default:
                                    return qsTr("Unknown");
                            }
                        }


                        text:  humanify(config.swupdate2.state)
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("Updates")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.swversion + " (api: "+ config.apiversion+")"
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("Software version")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.ipaddress
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("IP address")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.mac
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("MAC address")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
            Row {
                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text:  config.bridgeid
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("Bridge id")
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
        }
    }


}
