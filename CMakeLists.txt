cmake_minimum_required(VERSION 3.16)

project(SmartLockerSystem LANGUAGES CXX)

# 启用自动化工具
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找所需的包
find_package(Qt6 COMPONENTS Core Quick Sql REQUIRED)

# 添加源文件和头文件
set(SOURCES
        main.cpp

        src/DatabaseManager.cpp
        src/UserManager.cpp
        src/LockerManager.cpp
        src/PackageManager.cpp
        src/LoginManager.cpp
        src/LogManager.cpp

        src/DatabaseManager.h
        src/UserManager.h
        src/LockerManager.h
        src/PackageManager.h
        src/LoginManager.h
        src/LogManager.h
)

# 添加资源文件
qt_add_resources(RESOURCES qml/qml.qrc)

# 添加可执行文件
add_executable(SmartLockerSystem ${SOURCES} ${RESOURCES})

# 链接 Qt 库
target_link_libraries(SmartLockerSystem Qt6::Core Qt6::Quick Qt6::Sql)