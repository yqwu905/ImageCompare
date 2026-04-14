#include <QtTest>

class DummyTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        // Called before the first test function is executed
    }

    void cleanupTestCase()
    {
        // Called after the last test function was executed
    }

    void testBasicMath()
    {
        QCOMPARE(1 + 1, 2);
    }
};

QTEST_MAIN(DummyTest)
#include "dummy_test.moc"
