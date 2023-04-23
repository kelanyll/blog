---
title: "How to integrate an external library that doesn't support CMake"
date: 2023-04-16T10:57:25+01:00
tags: ["cmake","c++"]
---

If you're trying to integrate an external library into your project, most of the time you should be able to make use of CMake's `FetchContent`. Although, if the external library isn't compatible with CMake that won't work. Here are two alternative methods for doing this:

# Use `ExternalProject_Add`

If you're using a CMake version >3.2 then you should be able to take advantage of `ExternalProject_Add`. You can point it at a git repository which makes it very easy to use. It should look something like this:

```cmake
include(ExternalProject)

ExternalProject_Add(
    lib
    GIT_REPOSITORY https://github.com/lib.git
    GIT_TAG main
    CONFIGURE_COMMAND ...
    BUILD_COMMAND ...
    INSTALL_COMMAND ...
)
```

`ExternalProject_Add` is super configurable - see the [API documentation](https://cmake.org/cmake/help/latest/module/ExternalProject.html) for a full list of parameters - so you likely won't have to write anything custom. 

You still need to add the library's header files to your include path and tell the linker where it is - this will be `.a` file on Unix if it's a static library. If the library has all of its header files in a single folder that's easy enough but if not you may have to specify each header file (or subdirectory) as `target_include_directories` isn't recursive. Another solution could be to search the library for all header files like [this](https://cmake.org/pipermail/cmake/2012-June/050674.html), but you have to consider whether the utility of this is worth maintaining your own code and including all the library's header files in your build.
```cmake
target_include_directories(my-exe PRIVATE ${PATH_TO_INCLUDE})

target_link_libraries(my-exe ${PATH_TO_LIB})
```

See [here](https://github.com/kelanyll/poisson/blob/main/CMakeLists.txt) for a full example of this method with a library that's built with Bazel.

# Using git submodules and custom commands

If you're not on a CMake version that supports `ExternalProject_Add`, this is still doable but we have to manage a bit more of the build process. 

We can make use of git submodules which allow you to clone the source code of the library into your project. Run `git submodule add [REPOSITORY-URL]`, ideally in a dedicated folder for cleanliness. From here we should be able to run all commands with CMake so that the rest of the build is automated and repeatable.

```cmake
set(MYLIB_SOURCE_DIR ${CMAKE_SOURCE_DIR}/lib/mylib/BOOM)

function(find_mylib)
    find_library(MY_LIB mylib.a PATHS ${MYLIB_SOURCE_DIR}/build)
endfunction()

function(find_mylib)

if(NOT MY_LIB)
    execute_process(COMMAND [BUILD_COMMAND] WORKING_DIRECTORY ${MYLIB_SOURCE_DIR})
    find_mylib()
    if(NOT MY_LIB)
        message(FATAL_ERROR "Unable to build MY_LIB")
    endif()
endif()

add_executable(my_exe ...)

target_include_directories(my_exe PRIVATE ${MYLIB_SOURCE_DIR}/include)

target_link_libraries(my_exe ${MY_LIB})
```

[An example of this in practice.](https://github.com/kelanyll/poisson/blob/0cd1c7bb6274ddd8a4a1543fd00b330756fe6b38/CMakeLists.txt)

I'd note that things get a bit more complicated if you're writing a library yourself as you have to think about how to make this external library available to your users. If you're building your own executable, there's likely more you can do as far as best practices, but this should be enough to get you started!