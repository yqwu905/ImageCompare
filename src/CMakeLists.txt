add_executable(ImageComparatorApp
    main.cpp
    FolderTreeModel.cpp
    FolderTreeModel.h
)

target_link_libraries(ImageComparatorApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

# Add QML resources
qt_add_qml_module(ImageComparatorApp
    URI ImageComparator
    VERSION 1.0
    QML_FILES
        GlassCard.qml
        GlassButton.qml
        Main.qml
)

# Install rules (Basic)
install(TARGETS ImageComparatorApp
    RUNTIME DESTINATION bin
)
