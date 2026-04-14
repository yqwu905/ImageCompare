add_executable(ImageComparator
    main.cpp
)

target_link_libraries(ImageComparator PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

# Add QML resources
qt_add_qml_module(ImageComparator
    URI ImageComparator
    VERSION 1.0
    QML_FILES
        Main.qml
)

# Install rules (Basic)
install(TARGETS ImageComparator
    RUNTIME DESTINATION bin
)
