cmake_minimum_required(VERSION 3.16)
project(QuickAccount VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Quick Sql QuickControls2)

option(QUICKACCOUNT_BUILD_PROBE "Build QuickAccountProbe diagnostic tool" OFF)

# 桌面诊断小程序，不参与 Android APK
if(NOT ANDROID AND QUICKACCOUNT_BUILD_PROBE)
    add_executable(QuickAccountProbe EXCLUDE_FROM_ALL probe.cpp)
    target_link_libraries(QuickAccountProbe PRIVATE Qt6::Core)
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
endif()

qt_add_executable(QuickAccount
    early_env.cpp
    main.cpp
    resources.qrc
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

if(ANDROID)
    # 与 android/ 下的 AndroidManifest.xml、res/ 合并进 Qt 默认 Android 包
    set_target_properties(QuickAccount PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
endif()

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
        if(TARGET QuickAccountProbe)
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
endif()

if(WIN32)
    # 主程序始终使用 GUI 子系统，避免启动时弹出终端窗口
    set_target_properties(QuickAccount PROPERTIES
        WIN32_EXECUTABLE ON
    )
    if(TARGET QuickAccountProbe)
        # 诊断小工具保持控制台子系统，避免发布态 GUI 子系统下的额外入口/构建兼容问题
        set_target_properties(QuickAccountProbe PROPERTIES
            WIN32_EXECUTABLE OFF
        )
    endif()
endif()

include(GNUInstallDirs)
if(NOT ANDROID)
    install(TARGETS QuickAccount
        BUNDLE DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()
