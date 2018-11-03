/*
*  Copyright 2018  Michail Vourlakos <mvourlakos@gmail.com>
*
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

#include "auroraetheme.h"

#include <QDir>
#include <QFileInfo>

#include <KConfigGroup>
#include <KSharedConfig>

#include <QDebug>

namespace Decoration {
namespace Applet {

static const QString s_auroraeSvgTheme = QStringLiteral("__aurorae__svg__");

AuroraeTheme::AuroraeTheme(QObject *parent) :
    QObject(parent)
{
    connect(this, &AuroraeTheme::themeChanged, this, &AuroraeTheme::loadSettings);
}

AuroraeTheme::~AuroraeTheme()
{
}

int AuroraeTheme::duration() const
{
    return m_duration;
}

QString AuroraeTheme::theme() const
{
    return m_theme;
}

void AuroraeTheme::setTheme(QString theme)
{
    if (m_theme == theme || theme.isEmpty()) {
        return;
    }

    m_theme = theme;
    m_themePath = auroraeThemePath(theme);

    emit themeChanged();
}

QString AuroraeTheme::auroraeThemePath(QString themeName)
{
    m_themeName = themeName.replace(s_auroraeSvgTheme, "");

    QString localThemePath = QDir::homePath() + "/.local/share/aurorae/themes/" + m_themeName;
    QString globalThemePath = "/usr/share/aurorae/themes/" + m_themeName;

    if (QDir(localThemePath).exists()) {
        return localThemePath;
    }

    if (QDir(globalThemePath).exists()) {
        return globalThemePath;
    }

    return "";
}

void AuroraeTheme::loadSettings()
{
    const QString rc(m_themePath + "/" + m_themeName + "rc");

    if (!QFileInfo(rc).exists()) {
        return;
    }

    KSharedConfigPtr rcPtr = KSharedConfig::openConfig(rc);

    const KConfigGroup generalGroup = KConfigGroup(rcPtr, "General");
    m_duration = generalGroup.readEntry("Animation", 0);

    emit settingsChanged();
}

}
}