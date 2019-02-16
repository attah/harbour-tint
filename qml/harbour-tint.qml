import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import org.nemomobile.notifications 1.0
import "pages"
import "jshue.js" as Jshue

ApplicationWindow
{
    id: appWin
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.Portrait

    property var current_global_group
    property var current_bridge

    Item {
        id: hue_holder
        property var hue

        Component.onCompleted: {
            hue = Jshue.jsHue();
            console.log(Jshue);
        }
    }

    Notification {
        id: notifier

        expireTimeout: 4000

        function notifyMessage(data) {
            console.log("notifyMessage", data)
            body = data.message
            previewBody = data.message
            publish()
        }
    }

    Item {
        id: db
        property var db_conn
        property ListModel favourites_model : ListModel { id: favouritesModel }

        Component.onCompleted: {
            db_conn = LocalStorage.openDatabaseSync("TintDB", "1.0", "Tint storage", 100000)
            db_conn.transaction(function (tx) {
//                tx.executeSql('DROP TABLE IF EXISTS Bridges');
                tx.executeSql('CREATE TABLE IF NOT EXISTS Bridges (id STRING UNIQUE, username STRING)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS LastBridge (id STRING UNIQUE)');

            });
//            addHub("001788fffe4aa93c", "7tVeLUun9M-7CKznKMLEhY8n2fE9G3pKtnOCQBUk");
        }

        function addHub(id, username) {
            db_conn.transaction(function (tx) {
                tx.executeSql('INSERT INTO Bridges VALUES(?, ?)', [id, username] );
            });
        }
        function removeHub(id) {
            db_conn.transaction(function (tx) {
                tx.executeSql('DELETE FROM Bridges WHERE id=?', [id] );
            });
        }
        function getUsername(id) {
            var username = "";
            db_conn.transaction(function (tx) {
                var res = tx.executeSql('SELECT username FROM Bridges WHERE id=?', [id] );
                if (res.rows.length !== 0) {
                    console.log(res.rows.item(0).username)
                    username = res.rows.item(0).username;
                }
            });
            return username
        }
        function setFavourite(id) {
            db_conn.transaction(function (tx) {
                console.log("fav!!!",id);
                tx.executeSql('REPLACE INTO LastBridge VALUES(?)', [id] );
            });
        }
        function isFavourite(id) {
            var isFav = false;
            db_conn.transaction(function (tx) {
                console.log("isfav?");
                var res = tx.executeSql('SELECT * FROM LastBridge WHERE id=?', [id] );
                if (res.rows.length !== 0) {
                    console.log("isfav!");
                    isFav = true;
                }
            });
            return isFav
        }

    }

}
