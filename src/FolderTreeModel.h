#ifndef FOLDERTREEMODEL_H
#define FOLDERTREEMODEL_H

#include <QAbstractItemModel>
#include <QDir>
#include <QFileInfo>
#include <QList>
#include <QString>
#include <memory>

class FolderNode {
   public:
    FolderNode(const QString& name, const QString& path, FolderNode* parent = nullptr);
    ~FolderNode();

    void appendChild(std::unique_ptr<FolderNode> child);
    FolderNode* child(int row);
    int childCount() const;
    int columnCount() const;
    QVariant data(int column) const;
    int row() const;
    FolderNode* parentItem();
    QString path() const;
    QString name() const;

    void clearChildren();
    void removeChildAt(int index);
    bool hasPopulatedChildren() const;
    void setPopulatedChildren(bool populated);

   private:
    std::vector<std::unique_ptr<FolderNode>> m_children;
    QString m_name;
    QString m_path;
    FolderNode* m_parentItem;
    bool m_populated;
};

class FolderTreeModel : public QAbstractItemModel {
    Q_OBJECT
   public:
    enum FolderRoles { NameRole = Qt::UserRole + 1, PathRole, HasChildrenRole };

    explicit FolderTreeModel(QObject* parent = nullptr);
    ~FolderTreeModel() override;

    QVariant data(const QModelIndex& index, int role) const override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;
    QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex& index) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addRootPath(const QString& path);
    Q_INVOKABLE void removeNode(const QModelIndex& index);
    Q_INVOKABLE void refreshNode(const QModelIndex& index);
    Q_INVOKABLE void refreshAllPopulated();
    Q_INVOKABLE void clear();

    // For TreeView expansion
    Q_INVOKABLE bool hasChildren(const QModelIndex& parent = QModelIndex()) const override;
    Q_INVOKABLE void fetchMore(const QModelIndex& parent) override;
    Q_INVOKABLE bool canFetchMore(const QModelIndex& parent) const override;

   private:
    void setupModelData(FolderNode* parent, const QString& path);
    void refreshNodeRecursive(FolderNode* node, const QModelIndex& index);

    std::unique_ptr<FolderNode> rootItem;
};

#endif  // FOLDERTREEMODEL_H
