add_executable(DummyTest dummy_test.cpp)
target_link_libraries(DummyTest PRIVATE Qt6::Test Qt6::Core)
add_test(NAME DummyTest COMMAND DummyTest)

add_executable(FolderTreeModelTest foldertreemodel_test.cpp ../src/FolderTreeModel.cpp)
target_include_directories(FolderTreeModelTest PRIVATE ../src)
target_link_libraries(FolderTreeModelTest PRIVATE Qt6::Test Qt6::Core)
add_test(NAME FolderTreeModelTest COMMAND FolderTreeModelTest)
