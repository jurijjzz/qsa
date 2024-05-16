cmake_minimum_required(VERSION 3.24)
project(camera_bind)

set(CMAKE_CXX_STANDARD 20)

find_package(pybind11 CONFIG)

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
add_executable (camera_test "main.cpp")

target_link_libraries(camera_test PUBLIC ${Spinnaker_LIBS})
target_include_directories(camera_test PUBLIC ${PROJECT_SOURCE_DIR} ${Spinnaker_INCLUDE_DIR})


pybind11_add_module(camera camera_bind.cpp)
target_link_libraries(camera PUBLIC ${Spinnaker_LIBS})
target_include_directories(camera PUBLIC ${PROJECT_SOURCE_DIR} ${Spinnaker_INCLUDE_DIR})
