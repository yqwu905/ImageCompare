cmake_minimum_required(VERSION 3.16)
project(ImageComparator VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Core5Compat)
# Optional: find Test if we're building tests
if(BUILD_TESTING OR NOT DEFINED BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)
endif()

# We enable testing by default
include(CTest)
enable_testing()

add_subdirectory(src)

if(BUILD_TESTING OR NOT DEFINED BUILD_TESTING)
    add_subdirectory(tests)
endif()
