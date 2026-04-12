cmake_minimum_required(VERSION 3.16)
project(QuickAccount VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Quick Sql QuickControls2)

add_executable(QuickAccountProbe probe.cpp)
target_link_libraries(QuickAccountProbe PRIVATE Qt6::Core)
# 与 QuickAccount.exe 分目录输出，避免两个 windeployqt 并行向 build/ 根目录写 Qt6Core.dll 导致损坏/入口错位
set_target_properties(QuickAccountProbe PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/probe"
)
if(MSVC)
    foreach(_cfg DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
        set_target_properties(QuickAccountProbe PROPERTIES
            "RUNTIME_OUTPUT_DIRECTORY_${_cfg}" "${CMAKE_BINARY_DIR}/probe")
    endforeach()
endif()
if(MINGW)
    target_link_options(QuickAccountProbe PRIVATE
        -static-libgcc
        -static-libstdc++
    )
endif()

qt_add_executable(QuickAccount
    early_env.cpp
    main.cpp
    core/dao/DatabaseManager.cpp
    core/dao/TransactionDAO.cpp
    core/service/TransactionService.cpp
)

target_include_directories(QuickAccount PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

qt_add_qml_module(QuickAccount
    URI QuickAccount
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/HomePage.qml
        qml/BookPage.qml
        qml/RecordsPage.qml
        qml/SettingsPage.qml
)

target_link_libraries(QuickAccount PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::QuickControls2
)

# 减少 PATH 上其他 MinGW 的 libgcc/libstdc++ 与 exe 混用导致的 0xc0000005
if(MINGW)
    target_link_options(QuickAccount PRIVATE
        -static-libgcc
        -static-libstdc++
    )
endif()

if(WIN32)
    find_program(QUICKACCOUNT_WINDEPLOYQT_EXECUTABLE
        NAMES windeployqt
        HINTS "${Qt6_DIR}/../../../bin"
    )
    if(QUICKACCOUNT_WINDEPLOYQT_EXECUTABLE)
        add_custom_command(
            TARGET QuickAccount
            POST_BUILD
            COMMAND "${QUICKACCOUNT_WINDEPLOYQT_EXECUTABLE}"
                --qmldir "${CMAKE_SOURCE_DIR}/qml"
                --compiler-runtime
                "$<TARGET_FILE:QuickAccount>"
            VERBATIM
        )
        add_custom_command(
            TARGET QuickAccountProbe
            POST_BUILD
            COMMAND "${QUICKACCOUNT_WINDEPLOYQT_EXECUTABLE}"
                --compiler-runtime
                "$<TARGET_FILE:QuickAccountProbe>"
            VERBATIM
        )
    endif()
endif()

if(WIN32)
    set_target_properties(QuickAccount QuickAccountProbe PROPERTIES WIN32_EXECUTABLE OFF)
endif()

include(GNUInstallDirs)
install(TARGETS QuickAccount
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
