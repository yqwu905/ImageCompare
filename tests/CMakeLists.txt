add_executable(DummyTest dummy_test.cpp)
target_link_libraries(DummyTest PRIVATE Qt6::Test Qt6::Core)
add_test(NAME DummyTest COMMAND DummyTest)
