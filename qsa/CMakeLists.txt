# CMakeList.txt : CMake project for qsa, include source and define
# project specific logic here.
#
set(PROJ_NAME "qsa")
set(PROJ_INCLUDES "")
set(PROJ_LIBRARIES "")

# Spinnaker SDK
if(WIN32)
  set(Spinnaker_LIBS debug "Spinnakerd_v140.lib" optimized "Spinnaker_v140.lib")
  set(Spinnaker_INCLUDE_DIR
      "C:/Program Files/Teledyne/Spinnaker/include")
  link_directories(
    "C:/Program Files/Teledyne/Spinnaker/lib64/vs2015")
endif(WIN32)
if(UNIX)
  add_definitions(-DLINUX)
  find_path(Spinnaker_INCLUDE_DIR Spinnaker.h 
    PATHS /opt/spinnaker /usr /usr/local
    PATH_SUFFIXES include)
  find_library(Spinnaker_LIBS NAMES Spinnaker 
    PATHS /opt/spinnaker /usr /usr/local
    PATH_SUFFIXES lib
  )
endif(UNIX)

# Add source to this project's executable.
add_executable (qsa "main.cpp")

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET qsa PROPERTY CXX_STANDARD 20)
  endif()

# TODO: Add tests and install targets if needed.
target_link_libraries(${PROJ_NAME} ${Spinnaker_LIBS})
target_include_directories(${PROJ_NAME} PUBLIC ${PROJECT_SOURCE_DIR} ${Spinnaker_INCLUDE_DIR})


