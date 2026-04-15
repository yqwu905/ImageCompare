#include "../src/FolderTreeModel.h"

#include <QDir>
#include <QTemporaryDir>
#include <QTest>

class FolderTreeModelTest : public QObject {
    Q_OBJECT

   private slots:
    void testInitialState() {
        FolderTreeModel model;
        QCOMPARE(model.rowCount(), 0);
    }

    void testAddRootPath() {
        FolderTreeModel model;
        QTemporaryDir tempDir;
        QVERIFY(tempDir.isValid());

        model.addRootPath(tempDir.path());
        QCOMPARE(model.rowCount(), 1);

        QModelIndex rootIndex = model.index(0, 0);
        QVERIFY(rootIndex.isValid());
        QCOMPARE(model.data(rootIndex, FolderTreeModel::PathRole).toString(), tempDir.path());
    }

    void testLazyLoading() {
        FolderTreeModel model;
        QTemporaryDir tempDir;
        QVERIFY(tempDir.isValid());

        // Create a sub-directory
        QDir dir(tempDir.path());
        QVERIFY(dir.mkdir("SubDir"));

        model.addRootPath(tempDir.path());
        QModelIndex rootIndex = model.index(0, 0);
        QVERIFY(rootIndex.isValid());

        // Initial fetch check
        QCOMPARE(model.rowCount(rootIndex), 0);  // Before fetching
        QVERIFY(model.canFetchMore(rootIndex));

        model.fetchMore(rootIndex);
        QCOMPARE(model.rowCount(rootIndex), 1);  // After fetching

        QModelIndex childIndex = model.index(0, 0, rootIndex);
        QVERIFY(childIndex.isValid());
        QCOMPARE(model.data(childIndex, FolderTreeModel::NameRole).toString(), QString("SubDir"));
    }

    void testClear() {
        FolderTreeModel model;
        QTemporaryDir tempDir;
        QVERIFY(tempDir.isValid());

        model.addRootPath(tempDir.path());
        QCOMPARE(model.rowCount(), 1);

        model.clear();
        QCOMPARE(model.rowCount(), 0);
    }

    void testRemoveNode() {
        FolderTreeModel model;
        QTemporaryDir tempDir;
        QVERIFY(tempDir.isValid());

        model.addRootPath(tempDir.path());
        QCOMPARE(model.rowCount(), 1);

        QModelIndex rootIndex = model.index(0, 0);
        model.removeNode(rootIndex);
        QCOMPARE(model.rowCount(), 0);
    }

    void testRefreshNode() {
        FolderTreeModel model;
        QTemporaryDir tempDir;
        QVERIFY(tempDir.isValid());

        model.addRootPath(tempDir.path());
        QModelIndex rootIndex = model.index(0, 0);
        model.fetchMore(rootIndex);
        QCOMPARE(model.rowCount(rootIndex), 0);

        // Add a directory externally
        QDir dir(tempDir.path());
        QVERIFY(dir.mkdir("NewSubDir"));

        model.refreshNode(rootIndex);
        QCOMPARE(model.rowCount(rootIndex), 1);
        QCOMPARE(model.data(model.index(0, 0, rootIndex), FolderTreeModel::NameRole).toString(), QString("NewSubDir"));
    }
};

QTEST_MAIN(FolderTreeModelTest)
#include "foldertreemodel_test.moc"
