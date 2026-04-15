#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "FolderTreeModel.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    qmlRegisterType<FolderTreeModel>("ImageComparator", 1, 0, "FolderTreeModel");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/ImageComparator/Main.qml"_qs);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
