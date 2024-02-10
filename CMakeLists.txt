cmake_minimum_required(VERSION 3.20)
PROJECT(Oxygen C CXX)

#cmake_policy(SET CMP0003 NEW)

# Timestamp build
string(TIMESTAMP Oxygen_BUILD_TS UTC)

# Oxygen Version 1.0.0
set (Oxygen_VERSION_MAJOR 1)
set (Oxygen_VERSION_MINOR 0)
set (Oxygen_VERSION_PATCH 0)

set (Oxygen_SOVERSION "${Oxygen_VERSION_MAJOR}")
set (Oxygen_VERSION ${Oxygen_VERSION_MAJOR}.${Oxygen_VERSION_MINOR}.${Oxygen_VERSION_PATCH})
set (Oxygen_VERSION_STRING "${Oxygen_VERSION_MAJOR}.${Oxygen_VERSION_MINOR}.${Oxygen_VERSION_PATCH}")

# Exports
set(TARGET_EXPORT_NAME ${PROJECT_NAME}Targets)
set(TARGET_EXPORT_CONFIG ${PROJECT_NAME}Config)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/version.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

# set(CMAKE_AUTOMOC ON)
# set(CMAKE_AUTORCC ON)

if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)
endif(APPLE)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
include(GNUInstallDirs)

include_directories( "${CMAKE_CURRENT_BINARY_DIR}")
include_directories( "${CMAKE_CURRENT_SOURCE_DIR}")
# include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/tester")
include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src")
include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/include")
# include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/include")
# include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/include/astrometry")

set(config_SRCS
    # ${CMAKE_CURRENT_SOURCE_DIR}/src/util/os-features-test.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/os-features-test.c
    )

set(config_FN
    # "${CMAKE_CURRENT_SOURCE_DIR}/src/include/astrometry/os-features-config.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/os-features-config.h"
    )

file(REMOVE "${config_FN}")
if (WIN32)

    file(APPEND "${config_FN}" "#define NEED_DECLARE_QSORT_R 1\n")
    file(APPEND "${config_FN}" "#define NEED_QSORT_R 1\n")
    file(APPEND "${config_FN}" "#define NEED_SWAP_QSORT_R 0\n")

else(WIN32)

try_run(RUN_RESULT_2 COMPILE_SUCCESS_2 ${CMAKE_CURRENT_BINARY_DIR} ${config_SRCS} COMPILE_DEFINITIONS -DTEST_DECLARE_QSORT_R=ON)
if(COMPILE_SUCCESS_2 AND (RUN_RESULT_2 EQUAL 0))
    SET(VAR_2 0)
else()
    SET(VAR_2 1)
endif()
file(APPEND "${config_FN}" "#define NEED_DECLARE_QSORT_R ${VAR_2}\n")

try_run(RUN_RESULT_3 COMPILE_SUCCESS_3 ${CMAKE_CURRENT_BINARY_DIR} ${config_SRCS} COMPILE_DEFINITIONS -DTEST_QSORT_R=ON)
if(COMPILE_SUCCESS_3 AND (RUN_RESULT_3 EQUAL 0))
    SET(VAR_3 1)
else()
    SET(VAR_3 0)
endif()
file(APPEND "${config_FN}" "#define NEED_QSORT_R ${VAR_3}\n")

try_run(RUN_RESULT_4 COMPILE_SUCCESS_4 ${CMAKE_CURRENT_BINARY_DIR} ${config_SRCS} COMPILE_DEFINITIONS -DTEST_SWAP_QSORT_R=ON)
if(COMPILE_SUCCESS_4 AND (RUN_RESULT_4 EQUAL 0))
    SET(VAR_4 1)
else()
    SET(VAR_4 0)
endif()
file(APPEND "${config_FN}" "#define NEED_SWAP_QSORT_R ${VAR_4}\n")

endif(WIN32)

# We aren't using netpbm in this program, so set this to 0 no matter what
file(APPEND "${config_FN}" "#define HAVE_NETPBM 0")

option(BUILD_TESTER "Build oxygen tester program, instead of just the library" OFF)
option(BUILD_BATCH_SOLVER "Build oxygen batch solver program, instead of just the library" OFF)
option(BUILD_DEMOS "Build oxygen basic demonstration programs, instead of just the library" OFF)
option(BUILD_TESTS "Build oxygen tests, instead of just the library" OFF)

find_package(CFITSIO REQUIRED)
find_package(GSL REQUIRED)
# find_package(WCSLIB REQUIRED)
# find_package(Qt5 5.4 REQUIRED COMPONENTS Gui Widgets Core Concurrent Network)

# Max: No boost required, just use std::regex
# if(WIN32)
#    find_package(Boost 1.45.0 COMPONENTS regex)
# endif(WIN32)

if (NOT CFITSIO_FOUND OR CFITSIO_VERSION_MAJOR LESS 3)
  message(FATAL_ERROR "CFITSIO version too old, Please install cfitsio 3.x and try again. http://heasarc.gsfc.nasa.gov/fitsio/fitsio.html")
endif (NOT CFITSIO_FOUND OR CFITSIO_VERSION_MAJOR LESS 3)

if (CFITSIO_FOUND)
  include_directories(${CFITSIO_INCLUDE_DIR})
endif (CFITSIO_FOUND)

if (GSL_FOUND)
  include_directories(${GSL_INCLUDE_DIR})
endif (GSL_FOUND)

if(WCSLIB_FOUND)
    include_directories( ${WCSLIB_INCLUDE_DIR} )
endif(WCSLIB_FOUND)

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an")
set(qfits_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/anqfits.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_card.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_convert.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_error.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_header.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_image.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_table.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_time.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_tools.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_byteswap.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_memory.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_rw.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qfits-an/qfits_float.c
    )

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/libkd")
set(kd_SRCS
    #Internals
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_ddd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_fff.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_ddu.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_duu.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_dds.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdint_dss.c
    #kd
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdtree.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdtree_dim.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdtree_mem.c
    #kd fits
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libkd/kdtree_fits_io.c
    )

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/util")
set(anbase_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/starutil.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/mathutil.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/bl-sort.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/bl.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/healpix.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/permutedsort.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/ioutils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/os-features.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/errors.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/tic.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/log.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/datalog.c
    )

set(anutils_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/sip-utils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/fit-wcs.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/sip.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/gslutils.c

    #These get added if QFITS is to be included
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/fitsioutils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/fitstable.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/fitsbin.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/fitsfile.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/tic.c
    )

set(anfiles_SRCS
    #I think these only get added if QFITS is to be included
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/index.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/codekd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/starkd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/starxy.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/util/quadfile.c
        )

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}/src/blind")
set(engine_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/engine.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/blind.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/solver.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/quad-utils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/matchobj.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/tweak2.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/blind/verify.c
    )

set (sep_SRCS
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/analyse.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/aperture.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/background.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/convolve.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/deblend.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/extract.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/lutz.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/libs/sep/util.cpp
    )

# set(Oxygen_SRCS
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/parameters.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/extractorsolver.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/internalextractorsolver.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/externalextractorsolver.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/onlinesolver.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/oxygen.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/srclogger.cpp
#   ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/wcsdata.cpp
#   )

set(ALL_SRCS
#    ${Oxygen_SRCS}
    ${sep_SRCS}
    ${engine_SRCS}
    ${anfiles_SRCS}
    ${anutils_SRCS}
    ${anbase_SRCS}
    ${kd_SRCS}
    ${qfits_SRCS}
    )

if (WIN32)
    add_library(oxygen STATIC ${ALL_SRCS})
else(WIN32)
    add_library(oxygen SHARED ${ALL_SRCS})
endif(WIN32)

target_link_libraries(oxygen
    ${CFITSIO_LIBRARIES}
    ${GSL_LIBRARIES}
#    ${WCSLIB_LIBRARIES}
#    Qt5::Core
#    Qt5::Network
#    Qt5::Widgets
#    Qt5::Concurrent
    )

if(WIN32)
#    target_link_libraries(oxygen wsock32 ${Boost_LIBRARIES})
    target_link_libraries(oxygen wsock32)
else(WIN32)
    set_target_properties(oxygen PROPERTIES VERSION ${Oxygen_VERSION_STRING} SOVERSION ${Oxygen_SOVERSION} OUTPUT_NAME oxygen)
endif(WIN32)

if (MSVC) # We need to disable some warnings caused by using code designed for Unix on a Windows machine, otherwise astrometry code gives over 1500 warnings.
    # Use secure functions by default and suppress warnings about deprecated or POSIX functions
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_NONSTDC_NO_DEPRECATE=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_NONSTDC_NO_WARNINGS=1 /D _CRT_SECURE_NO_WARNINGS=1")
    # Disabling warnings caused by assigning values to types defined with typedef double <variable>
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4244")
    # Disbling warnings caused by size_t being assigned to int
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4267")
    # Disabling warning for comparing signed and unsigned variables
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4018")
    # Disabling the warning for redefined macros, because ERROR had a conflict and it is used A LOT in astrometry
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4005")
    # Disabling warning for unused local variables (This one is important because some variables only get used on Linux or MacOS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4101")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS}")
endif (MSVC)

install(TARGETS oxygen
    EXPORT ${TARGET_EXPORT_NAME}
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION include/liboxygen
    )

set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/include/liboxygen")
set(PKG_CONFIG_LIBDIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(PKGCONFIG_INSTALL_PREFIX "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/oxygen.h
    ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/structuredefinitions.h
    ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/extractorsolver.h
    ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/parameters.h
    ${CMAKE_CURRENT_SOURCE_DIR}/oxygen/wcsdata.h
    ${CMAKE_CURRENT_BINARY_DIR}/version.h
    DESTINATION "${INCLUDE_INSTALL_DIR}")
install(DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include/astrometry
    DESTINATION "${INCLUDE_INSTALL_DIR}")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/oxygen.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/oxygen.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/oxygen.pc DESTINATION ${PKGCONFIG_INSTALL_PREFIX})

if(BUILD_TESTER OR BUILD_BATCH_SOLVER OR BUILD_DEMOS OR BUILD_TESTS)
    set(SSolverUtilsLib_SRCS
        ${CMAKE_CURRENT_SOURCE_DIR}/ssolverutils/fileio.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ssolverutils/imagelabel.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ssolverutils/stretch.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ssolverutils/bayer.c
        ${CMAKE_CURRENT_SOURCE_DIR}/ssolverutils/dms.cpp
        )
    add_library(SSolverUtilsLib STATIC ${SSolverUtilsLib_SRCS})
    target_link_libraries(SSolverUtilsLib
        ${CFITSIO_LIBRARIES}
        ${GSL_LIBRARIES}
        ${WCSLIB_LIBRARIES}
        Qt5::Gui
        Qt5::Widgets
        Qt5::Core
        Qt5::Network
        Qt5::Concurrent
        )
endif(BUILD_TESTER OR BUILD_BATCH_SOLVER OR BUILD_DEMOS OR BUILD_TESTS)

#########################################################################################
## Stellar Solver Tester
#########################################################################################
if(BUILD_TESTER)

set(OxygenTester_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/tester/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tester/mainwindow.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tester/resources.qrc
    )

qt5_wrap_ui(Oxygenui_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/tester/mainwindow.ui
    )

if(APPLE)
set(MACOSX_BUNDLE_ICON_FILE OxygenIcon.icns)
set(OxygenTesterApp_ICON ${CMAKE_CURRENT_SOURCE_DIR}/tester/OxygenIcon.icns)
set_source_files_properties(${OxygenTesterApp_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
endif(APPLE)

if(WIN32)
set(OxygenTesterApp_ICON ${CMAKE_CURRENT_SOURCE_DIR}/tester/windowsicon.rc)
endif(WIN32)

add_executable(OxygenTester ${OxygenTester_SRCS} ${Oxygenui_SRCS} ${OxygenTesterApp_ICON})

if(APPLE)
    SET_TARGET_PROPERTIES(OxygenTester PROPERTIES MACOSX_BUNDLE TRUE)
endif(APPLE)


target_link_libraries(OxygenTester
    oxygen
    SSolverUtilsLib
    ${CFITSIO_LIBRARIES}
    ${GSL_LIBRARIES}
    ${WCSLIB_LIBRARIES}
    Qt5::Gui
    Qt5::Widgets
    Qt5::Core
    Qt5::Network
    Qt5::Concurrent
    )

if(WIN32)
    target_link_libraries(OxygenTester wsock32 ${Boost_LIBRARIES})
endif(WIN32)

if(APPLE)
install(TARGETS OxygenTester
    BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}
    )
else(APPLE)
        #installation for Linux and Windows
        install(TARGETS OxygenTester RUNTIME DESTINATION bin)
        install(DIRECTORY tester/icons
                DESTINATION ${CMAKE_INSTALL_PREFIX}/share)
    if(WIN32)
    else(WIN32)
        #Desktop file for Linux
        install(FILES tester/com.github.rlancaste.oxygen.desktop
                DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)
    endif(WIN32)
endif(APPLE)

endif(BUILD_TESTER)

#########################################################################################
## Stellar Solver Batch Solver Program
#########################################################################################
if(BUILD_BATCH_SOLVER)
    set(StellarBatchSolver_SRCS
         ${CMAKE_CURRENT_SOURCE_DIR}/stellarbatchsolver/stellarbatchsolver.cpp
         ${CMAKE_CURRENT_SOURCE_DIR}/stellarbatchsolver/resources.qrc
        )

    qt5_wrap_ui(StellarBatchSolverui_SRCS
        ${CMAKE_CURRENT_SOURCE_DIR}/stellarbatchsolver/stellarbatchsolver.ui
        )

    if(APPLE)
    set(MACOSX_BUNDLE_ICON_FILE StellarBatchSolverIcon.icns)
    set(StellarBatchSolver_ICON ${CMAKE_CURRENT_SOURCE_DIR}/stellarbatchsolver/StellarBatchSolverIcon.icns)
    set_source_files_properties(${StellarBatchSolver_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    endif(APPLE)

    if(WIN32)
    set(StellarBatchSolver_ICON ${CMAKE_CURRENT_SOURCE_DIR}/stellarbatchsolver/windowsicon.rc)
    endif(WIN32)

    add_executable(StellarBatchSolver ${StellarBatchSolver_SRCS} ${StellarBatchSolverui_SRCS} ${StellarBatchSolver_ICON})

    if(APPLE)
        SET_TARGET_PROPERTIES(StellarBatchSolver PROPERTIES MACOSX_BUNDLE TRUE)
    endif(APPLE)

    target_link_libraries(StellarBatchSolver
        oxygen
        SSolverUtilsLib
        ${CFITSIO_LIBRARIES}
        ${GSL_LIBRARIES}
        ${WCSLIB_LIBRARIES}
        Qt5::Widgets
        Qt5::Core
        Qt5::Network
        Qt5::Concurrent
        )

    if(WIN32)
        target_link_libraries(StellarBatchSolver wsock32 ${Boost_LIBRARIES})
    endif(WIN32)

    if(APPLE)
    install(TARGETS StellarBatchSolver
        BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}
        )
    else(APPLE)
            #installation for Linux and Windows
            install(TARGETS StellarBatchSolver RUNTIME DESTINATION bin)
            install(DIRECTORY stellarbatchsolver/icons
                    DESTINATION ${CMAKE_INSTALL_PREFIX}/share)
        if(WIN32)
        else(WIN32)
            #Desktop file for Linux
            install(FILES stellarbatchsolver/com.github.rlancaste.stellarbatchsolver.desktop
                    DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)
        endif(WIN32)
    endif(APPLE)
endif(BUILD_BATCH_SOLVER)

#########################################################################################
## Stellar Solver Basic Demonstration Programs
#########################################################################################
if(BUILD_DEMOS)
    add_library(OxygenDemosLib STATIC)
    target_link_libraries(OxygenDemosLib
        oxygen
        SSolverUtilsLib
        ${CFITSIO_LIBRARIES}
        ${GSL_LIBRARIES}
        ${WCSLIB_LIBRARIES}
        Qt5::Widgets
        Qt5::Core
        Qt5::Network
        Qt5::Concurrent
        )

    add_executable(DemoStarExtract ${CMAKE_CURRENT_SOURCE_DIR}/demos/demostarextract.cpp)
    target_link_libraries(DemoStarExtract OxygenDemosLib)
    add_executable(DemoPlateSolve ${CMAKE_CURRENT_SOURCE_DIR}/demos/demoplatesolve.cpp)
    target_link_libraries(DemoPlateSolve OxygenDemosLib)
    add_executable(DemoExtractSolve ${CMAKE_CURRENT_SOURCE_DIR}/demos/demoextractsolve.cpp)
    target_link_libraries(DemoExtractSolve OxygenDemosLib)
    add_executable(DemoFITSStarExtract ${CMAKE_CURRENT_SOURCE_DIR}/demos/demofitsstarextract.cpp)
    target_link_libraries(DemoFITSStarExtract OxygenDemosLib)
    add_executable(DemoFITSPlateSolve ${CMAKE_CURRENT_SOURCE_DIR}/demos/demofitsplatesolve.cpp)
    target_link_libraries(DemoFITSPlateSolve OxygenDemosLib)
    add_executable(DemoFITSExtractSolve ${CMAKE_CURRENT_SOURCE_DIR}/demos/demofitsextractsolve.cpp)
    target_link_libraries(DemoFITSExtractSolve OxygenDemosLib)
    add_executable(DemoSignalsSlots ${CMAKE_CURRENT_SOURCE_DIR}/demos/demosignalsslots.cpp)
    target_link_libraries(DemoSignalsSlots OxygenDemosLib)
    add_executable(DemoMultipleSolves ${CMAKE_CURRENT_SOURCE_DIR}/demos/demomultiplesolves.cpp)
    target_link_libraries(DemoMultipleSolves OxygenDemosLib)

    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/demos/pleiades.jpg" DESTINATION "${CMAKE_BINARY_DIR}/")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/demos/randomsky.fits" DESTINATION "${CMAKE_BINARY_DIR}/")
    # Note: These are the index files that solve the above images best.
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/astrometry/")
        message(STATUS "Downloading two index files for solving demos/tests. . .")
        make_directory("${CMAKE_BINARY_DIR}/astrometry/")
        file(DOWNLOAD "http://data.astrometry.net/4100/index-4107.fits" "${CMAKE_BINARY_DIR}/astrometry/index-4107.fits")
        file(DOWNLOAD "http://data.astrometry.net/4100/index-4110.fits" "${CMAKE_BINARY_DIR}/astrometry/index-4110.fits")
    endif(NOT EXISTS "${CMAKE_BINARY_DIR}/astrometry/")

endif(BUILD_DEMOS)

#########################################################################################
## Stellar Solver Testing
#########################################################################################
if(BUILD_TESTS)
    add_library(OxygenTestsLib STATIC)
    target_link_libraries(OxygenTestsLib
        oxygen
        SSolverUtilsLib
        ${CFITSIO_LIBRARIES}
        ${GSL_LIBRARIES}
        ${WCSLIB_LIBRARIES}
        Qt5::Widgets
        Qt5::Core
        Qt5::Network
        Qt5::Concurrent
        )

    add_executable(TestTwoOxygens ${CMAKE_CURRENT_SOURCE_DIR}/tests/testtwooxygens.cpp)
    target_link_libraries(TestTwoOxygens OxygenTestsLib)
    add_executable(TestDeleteSolver ${CMAKE_CURRENT_SOURCE_DIR}/tests/testdeletesolver.cpp)
    target_link_libraries(TestDeleteSolver OxygenTestsLib)
    add_executable(TestMultipleSyncSolvers ${CMAKE_CURRENT_SOURCE_DIR}/tests/testmultiplesyncsolvers.cpp)
    target_link_libraries(TestMultipleSyncSolvers OxygenTestsLib)

    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/demos/pleiades.jpg" DESTINATION "${CMAKE_BINARY_DIR}/")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/demos/randomsky.fits" DESTINATION "${CMAKE_BINARY_DIR}/")
    # Note: These are the index files that solve the above images best.
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/astrometry/")
        message(STATUS "Downloading two index files for solving demos/tests. . .")
        make_directory("${CMAKE_BINARY_DIR}/astrometry/")
        file(DOWNLOAD "http://data.astrometry.net/4100/index-4107.fits" "${CMAKE_BINARY_DIR}/astrometry/index-4107.fits")
        file(DOWNLOAD "http://data.astrometry.net/4100/index-4110.fits" "${CMAKE_BINARY_DIR}/astrometry/index-4110.fits")
    endif(NOT EXISTS "${CMAKE_BINARY_DIR}/astrometry/")

endif(BUILD_TESTS)

#########################################################################################
# Generate Package Config Files
#########################################################################################
# Set destination directory
set(ConfigPackageLocation ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# 1. Generate the OxygenConfigVersion.cmake
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_EXPORT_CONFIG}Version.cmake"
    VERSION ${${PROJECT_NAME}_VERSION}
    COMPATIBILITY SameMajorVersion
    )

# 2. Configure the Exports and namespace
export(TARGETS oxygen
    NAMESPACE ${PROJECT_NAME}::
    FILE ${TARGET_EXPORT_NAME}.cmake)
# 3. Configure the Include Directories
target_include_directories(oxygen PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include/liboxygen>)

# 4. Install Oxygen Config
install(EXPORT ${TARGET_EXPORT_NAME}
        FILE ${TARGET_EXPORT_CONFIG}.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${ConfigPackageLocation})

# 5. Install Oxygen Config Version
install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_EXPORT_CONFIG}Version.cmake"
        DESTINATION ${ConfigPackageLocation})
