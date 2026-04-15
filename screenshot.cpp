#include <QDebug>
#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

int main(int argc, char *argv[]) {
    qputenv("QT_QPA_PLATFORM", "offscreen");
    qputenv("QSG_RENDER_LOOP", "basic");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QUrl::fromLocalFile(QDir::currentPath() + "/src/Main.qml"));

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Failed to load root objects";
        return -1;
    }

    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window) {
        qWarning() << "Root object is not a QQuickWindow";
        return -1;
    }

    QTimer::singleShot(2000, [&]() {
        QImage image = window->grabWindow();
        if (image.isNull()) {
            qWarning() << "Failed to grab window.";
        } else {
            image.save("screenshot.png");
            qDebug() << "Screenshot saved";
        }
        QCoreApplication::exit(0);
    });

    return app.exec();
}
