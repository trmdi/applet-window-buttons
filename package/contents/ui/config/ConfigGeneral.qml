/*
*  Copyright 2018  Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of Latte-Dock
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.appletdecoration 0.1 as AppletDecoration

Item {
    id: root

    property alias cfg_useCurrentDecoration: root.useCurrent
    property alias cfg_selectedPlugin: root.selectedPlugin
    property alias cfg_selectedTheme: root.selectedTheme
    property alias cfg_buttons: root.currentButtons
    property alias cfg_showOnlyForActiveAndMaximized: onlyOnMaximizedChk.checked
    property alias cfg_slideAnimation: slideChk.checked
    property alias cfg_useDecorationMetrics: decorationMetricsChk.checked
    property alias cfg_spacing: spacingSpn.value
    property alias cfg_thicknessMargin: thickSpn.value
    property alias cfg_lengthMargin: lengthSpn.value

    // used as bridge to communicate properly between configuration and ui
    property bool useCurrent
    property string selectedPlugin
    property string selectedTheme
    property string currentButtons

    // used from the ui
    readonly property real centerFactor: 0.35
    property string currentPlugin: root.useCurrent ? decorations.currentPlugin : root.selectedPlugin
    property string currentTheme: root.useCurrent ? decorations.currentTheme : root.selectedTheme

    ///START Decoration Items
    AppletDecoration.Bridge {
        id: bridgeItem
        plugin: currentPlugin
        theme: currentTheme
    }

    AppletDecoration.Settings {
        id: settingsItem
        bridge: bridgeItem.bridge
        borderSizesIndex: 0
    }

    AppletDecoration.AuroraeTheme {
        id: auroraeThemeEngine
        theme: isEnabled ? currentTheme : ""

        readonly property bool isEnabled: decorations.isAurorae(root.currentPlugin, root.currentTheme);
    }

    AppletDecoration.DecorationsModel {
        id: decorations
    }

    // sort decorations based on display name
    PlasmaCore.SortFilterModel {
        id: sortedDecorations
        sourceModel: decorations
        sortRole: 'display'
        sortOrder: Qt.AscendingOrder
    }

    ///END Decoration Items

    ColumnLayout {
        id:mainColumn
        spacing: units.largeSpacing
        Layout.fillWidth: true

        RowLayout{
            Label {
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Decoration:")
                horizontalAlignment: Text.AlignRight
            }
            ComboBox{
                id: decorationCmb
                Layout.minimumWidth: 100
                Layout.preferredWidth: 0.2 * root.width
                Layout.maximumWidth: 250

                model: decs

                property var decs: []

                function feedDecorations() {
                    for (var i=0; i<sortedDecorations.count; ++i) {
                        var d = sortedDecorations.get(i);
                        decs.push(d.display);
                    }

                    decorationCmb.model = decs;
                }

                function indexFor(plugin, theme) {
                    for (var i=0; i<sortedDecorations.count; ++i) {
                        var d = sortedDecorations.get(i);
                        if (d.plugin === plugin && d.theme === theme) {
                            return i+1;
                        }
                    }

                    return 0;
                }

                function initDecorations() {
                    decs.push("Current");
                }

                onActivated: {
                    if (index===0) {
                        root.useCurrent = true;
                        root.selectedPlugin = "";
                        root.selectedTheme = "";
                    } else {
                        root.useCurrent = false;
                        var d = sortedDecorations.get(index-1);
                        root.selectedPlugin = d.plugin;
                        root.selectedTheme = d.theme;
                    }
                }

                Component.onCompleted: {
                    initDecorations();
                    feedDecorations();
                    if (!root.useCurrent) {
                        currentIndex = indexFor(root.currentPlugin, root.currentTheme);
                    }
                }
            }
        }

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Buttons:")
                horizontalAlignment: Text.AlignRight
            }

            OrderableListView{
                id: activeButtons
                itemWidth: 36
                itemHeight: 36
                buttonsStr: root.currentButtons
                orientation: ListView.Horizontal
            }
        }

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Visual behavior:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: onlyOnMaximizedChk
                text: i18n("Show only when active window is maximized")
            }

            Label{
            }

            CheckBox{
                id: slideChk
                text: i18n("Slide animation in order to show or hide")
                enabled: onlyOnMaximizedChk.checked
            }
        }

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Metrics:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: decorationMetricsChk
                text: i18n("Use from decoration if any are found")
            }

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Icons spacing:")
                horizontalAlignment: Text.AlignRight
                enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            }

            SpinBox{
                id: spacingSpn
                minimumValue: 0
                maximumValue: 24
                suffix: " " + i18nc("pixels","px.")
                enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            }

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Thickness margin:")
                horizontalAlignment: Text.AlignRight
                enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            }

            SpinBox{
                id: thickSpn
                minimumValue: 0
                maximumValue: 24
                suffix: " " + i18nc("pixels","px.")
                enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            }

            Label{
                Layout.minimumWidth: centerFactor * root.width
                text: i18n("Length margin:")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox{
                id: lengthSpn
                minimumValue: 0
                maximumValue: 24
                suffix: " " + i18nc("pixels","px.")
            }

        }
    }
}