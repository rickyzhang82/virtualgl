include(CheckCSourceCompiles)

set(DEFAULT_TJPEG_INCLUDE_DIR /opt/libjpeg-turbo/include)
if(NOT TJPEG_INCLUDE_DIR)
	set(TJPEG_INCLUDE_DIR_HINTS ${DEFAULT_TJPEG_INCLUDE_DIR})
else()
	set(TJPEG_INCLUDE_DIR_HINTS ${TJPEG_INCLUDE_DIR})
	unset(TJPEG_INCLUDE_DIR)
	unset(TJPEG_INCLUDE_DIR CACHE)
endif()

find_path(TJPEG_INCLUDE_DIR turbojpeg.h
	DOC "TurboJPEG include directory (default: ${DEFAULT_TJPEG_INCLUDE_DIR})"
	HINTS ${TJPEG_INCLUDE_DIR_HINTS})
if(TJPEG_INCLUDE_DIR STREQUAL "TJPEG_INCLUDE_DIR-NOTFOUND")
	message(FATAL_ERROR "Could not find turbojpeg.h in ${TJPEG_INCLUDE_DIR_HINTS}.  If it is installed in a different place, then set TJPEG_INCLUDE_DIR accordingly.")
else()
	message(STATUS "TJPEG_INCLUDE_DIR = ${TJPEG_INCLUDE_DIR}")
endif()
include_directories(${TJPEG_INCLUDE_DIR})

set(DEFAULT_TJPEG_LIBRARY /opt/libjpeg-turbo/lib/libturbojpeg.a)

set(TJPEG_LIBRARY_OVERRIDE 0)
if(TJPEG_LIBRARY)
	set(TJPEG_LIBRARY_OVERRIDE 1)
endif()

set(TJPEG_LIBRARY ${DEFAULT_TJPEG_LIBRARY} CACHE STRING
	"Path to TurboJPEG library or flags necessary to link with it (default: ${DEFAULT_TJPEG_LIBRARY})")

set(CMAKE_REQUIRED_INCLUDES ${TJPEG_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${TJPEG_LIBRARY})
check_c_source_compiles("#include <turbojpeg.h>\nint main(void) { tjhandle h=tjInitCompress(); return 0; }" TURBOJPEG_WORKS)
if(NOT TURBOJPEG_WORKS AND NOT TJPEG_LIBRARY_OVERRIDE AND UNIX)
	message(STATUS "Could not link with official TurboJPEG library ${TJPEG_LIBRARY}.  Checking whether the operating system supplies it ...")
	set(CMAKE_REQUIRED_LIBRARIES turbojpeg)
	check_c_source_compiles("#include <turbojpeg.h>\nint main(void) { tjhandle h=tjInitCompress(); return 0; }" SYSTEM_TURBOJPEG_WORKS)
	if(SYSTEM_TURBOJPEG_WORKS)
		set(TJPEG_LIBRARY turbojpeg CACHE STRING
			"Path to TurboJPEG library or flags necessary to link with it (default: ${DEFAULT_TJPEG_LIBRARY})"
			FORCE)
	endif()
endif()
set(CMAKE_REQUIRED_DEFINITIONS)
set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_REQUIRED_LIBRARIES)
if(NOT TURBOJPEG_WORKS AND NOT SYSTEM_TURBOJPEG_WORKS)
	message(FATAL_ERROR "Could not link with TurboJPEG library ${TJPEG_LIBRARY}.  If it is installed in a different place, then set TJPEG_LIBRARY accordingly.")
endif()

message(STATUS "TJPEG_LIBRARY = ${TJPEG_LIBRARY}")
