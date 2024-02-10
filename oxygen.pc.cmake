prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=@CMAKE_INSTALL_PREFIX@
libdir=@PKG_CONFIG_LIBDIR@
includedir=@INCLUDE_INSTALL_DIR@

Name: oxygen
Description: Oxygen Internal Plate Solving Library (Migrated from Stellarsolver)
URL: https://github.com/ElementAstro/Oxygen
Version: @Oxygen_VERSION@
Libs: -L${libdir} -loxygen
Libs.private: -lcfitsio -lwcslib -lpthread
Cflags: -I${includedir} -I${includedir}/liboxygen

