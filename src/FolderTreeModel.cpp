#include "FolderTreeModel.h"

#include <QUrl>

FolderNode::FolderNode(const QString& name, const QString& path, FolderNode* parent)
    : m_name(name), m_path(path), m_parentItem(parent), m_populated(false) {}

FolderNode::~FolderNode() {}

void FolderNode::appendChild(std::unique_ptr<FolderNode> child) { m_children.push_back(std::move(child)); }

FolderNode* FolderNode::child(int row) {
    if (row < 0 || row >= static_cast<int>(m_children.size())) return nullptr;
    return m_children[row].get();
}

int FolderNode::childCount() const { return static_cast<int>(m_children.size()); }

int FolderNode::columnCount() const { return 1; }

QVariant FolderNode::data(int column) const {
    if (column == 0) return m_name;
    return QVariant();
}

FolderNode* FolderNode::parentItem() { return m_parentItem; }

int FolderNode::row() const {
    if (m_parentItem) {
        for (size_t i = 0; i < m_parentItem->m_children.size(); ++i) {
            if (m_parentItem->m_children[i].get() == this) {
                return static_cast<int>(i);
            }
        }
    }
    return 0;
}

QString FolderNode::path() const { return m_path; }

QString FolderNode::name() const { return m_name; }

void FolderNode::clearChildren() {
    m_children.clear();
    m_populated = false;
}

void FolderNode::removeChildAt(int index) {
    if (index >= 0 && index < static_cast<int>(m_children.size())) {
        m_children.erase(m_children.begin() + index);
    }
}

bool FolderNode::hasPopulatedChildren() const { return m_populated; }

void FolderNode::setPopulatedChildren(bool populated) { m_populated = populated; }

FolderTreeModel::FolderTreeModel(QObject* parent) : QAbstractItemModel(parent) {
    rootItem = std::make_unique<FolderNode>("Root", "");
}

FolderTreeModel::~FolderTreeModel() {}

QModelIndex FolderTreeModel::index(int row, int column, const QModelIndex& parent) const {
    if (!hasIndex(row, column, parent)) return QModelIndex();

    FolderNode* parentItem;

    if (!parent.isValid())
        parentItem = rootItem.get();
    else
        parentItem = static_cast<FolderNode*>(parent.internalPointer());

    FolderNode* childItem = parentItem->child(row);
    if (childItem) return createIndex(row, column, childItem);
    return QModelIndex();
}

QModelIndex FolderTreeModel::parent(const QModelIndex& index) const {
    if (!index.isValid()) return QModelIndex();

    FolderNode* childItem = static_cast<FolderNode*>(index.internalPointer());
    FolderNode* parentItem = childItem->parentItem();

    if (parentItem == rootItem.get()) return QModelIndex();

    return createIndex(parentItem->row(), 0, parentItem);
}

int FolderTreeModel::rowCount(const QModelIndex& parent) const {
    if (parent.column() > 0) return 0;

    FolderNode* parentItem;
    if (!parent.isValid())
        parentItem = rootItem.get();
    else
        parentItem = static_cast<FolderNode*>(parent.internalPointer());

    return parentItem->childCount();
}

int FolderTreeModel::columnCount(const QModelIndex& parent) const {
    if (parent.isValid()) return static_cast<FolderNode*>(parent.internalPointer())->columnCount();
    return rootItem->columnCount();
}

QVariant FolderTreeModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) return QVariant();

    FolderNode* item = static_cast<FolderNode*>(index.internalPointer());

    switch (role) {
        case Qt::DisplayRole:
        case NameRole:
            return item->name();
        case PathRole:
            return item->path();
        case HasChildrenRole: {
            QDir dir(item->path());
            dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
            return !dir.isEmpty();
        }
        default:
            return QVariant();
    }
}

Qt::ItemFlags FolderTreeModel::flags(const QModelIndex& index) const {
    if (!index.isValid()) return Qt::NoItemFlags;

    return QAbstractItemModel::flags(index);
}

QHash<int, QByteArray> FolderTreeModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[HasChildrenRole] = "hasChildren";
    return roles;
}

void FolderTreeModel::addRootPath(const QString& pathUrl) {
    QUrl url(pathUrl);
    QString path = url.isLocalFile() ? url.toLocalFile() : pathUrl;

    QFileInfo fileInfo(path);
    if (!fileInfo.exists() || !fileInfo.isDir()) {
        return;
    }

    // Check if it already exists as a root
    for (int i = 0; i < rootItem->childCount(); ++i) {
        if (rootItem->child(i)->path() == path) {
            return;
        }
    }

    beginInsertRows(QModelIndex(), rootItem->childCount(), rootItem->childCount());
    rootItem->appendChild(std::make_unique<FolderNode>(fileInfo.fileName(), path, rootItem.get()));
    endInsertRows();
}

void FolderTreeModel::removeNode(const QModelIndex& index) {
    if (!index.isValid()) return;

    FolderNode* item = static_cast<FolderNode*>(index.internalPointer());
    FolderNode* parentItem = item->parentItem();
    if (!parentItem) return;

    int row = item->row();
    QModelIndex parentIndex = parent(index);

    beginRemoveRows(parentIndex, row, row);
    parentItem->removeChildAt(row);
    endRemoveRows();
}

void FolderTreeModel::refreshNode(const QModelIndex& index) {
    if (!index.isValid()) return;

    FolderNode* item = static_cast<FolderNode*>(index.internalPointer());
    if (item->hasPopulatedChildren()) {
        refreshNodeRecursive(item, index);
    }
}

void FolderTreeModel::refreshNodeRecursive(FolderNode* node, const QModelIndex& index) {
    if (!node->hasPopulatedChildren()) return;

    QDir dir(node->path());
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    dir.setSorting(QDir::Name);
    QFileInfoList list = dir.entryInfoList();

    // Naive refresh: remove all and re-add.
    if (node->childCount() > 0) {
        beginRemoveRows(index, 0, node->childCount() - 1);
        node->clearChildren();
        endRemoveRows();
    }

    if (list.size() > 0) {
        beginInsertRows(index, 0, list.size() - 1);
        for (const QFileInfo& fileInfo : list) {
            node->appendChild(std::make_unique<FolderNode>(fileInfo.fileName(), fileInfo.filePath(), node));
        }
        endInsertRows();
    }
    node->setPopulatedChildren(true);

    // Recursive refresh for expanded children not needed as lazy loading will fetch when expanded
    // Oh wait, if they were expanded, we should probably keep them expanded or just let the tree view re-fetch
    // Actually, tree views will collapse if we clear children. Let's just keep it simple: clearing children collapses
    // them.
}

void FolderTreeModel::refreshAllPopulated() {
    // For every root node, refresh it.
    for (int i = 0; i < rootItem->childCount(); ++i) {
        QModelIndex rootIndex = index(i, 0, QModelIndex());
        refreshNodeRecursive(rootItem->child(i), rootIndex);
    }
}

void FolderTreeModel::clear() {
    if (rootItem->childCount() > 0) {
        beginRemoveRows(QModelIndex(), 0, rootItem->childCount() - 1);
        rootItem->clearChildren();
        endRemoveRows();
    }
}

bool FolderTreeModel::hasChildren(const QModelIndex& parent) const {
    if (!parent.isValid()) {
        return rootItem->childCount() > 0;
    }

    FolderNode* item = static_cast<FolderNode*>(parent.internalPointer());
    if (item->hasPopulatedChildren()) {
        return item->childCount() > 0;
    }

    // Check if it physically has directories inside
    QDir dir(item->path());
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    return !dir.isEmpty();
}

bool FolderTreeModel::canFetchMore(const QModelIndex& parent) const {
    if (!parent.isValid()) return false;

    FolderNode* item = static_cast<FolderNode*>(parent.internalPointer());
    return !item->hasPopulatedChildren() && hasChildren(parent);
}

void FolderTreeModel::fetchMore(const QModelIndex& parent) {
    if (!parent.isValid()) return;

    FolderNode* item = static_cast<FolderNode*>(parent.internalPointer());
    if (item->hasPopulatedChildren()) return;

    QDir dir(item->path());
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    dir.setSorting(QDir::Name);
    QFileInfoList list = dir.entryInfoList();

    if (list.isEmpty()) {
        item->setPopulatedChildren(true);
        return;
    }

    beginInsertRows(parent, 0, list.size() - 1);
    for (const QFileInfo& fileInfo : list) {
        item->appendChild(std::make_unique<FolderNode>(fileInfo.fileName(), fileInfo.filePath(), item));
    }
    item->setPopulatedChildren(true);
    endInsertRows();
}
