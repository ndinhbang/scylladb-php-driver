include(CheckIPOSupported)
include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)

function(scylladb_php_library target enable_sanitizers native_arch lto)
    scylladb_php_find_php_config("${CUSTOM_PHP_CONFIG}" "${PHP_VERSION_FOR_PHP_CONFIG}" ${PHP_DEBUG_FOR_PHP_CONFIG} ${PHP_THREAD_SAFE_FOR_PHP_CONFIG})
    scylladb_php_find_php(${PHP_CONFIG_EXECUTABLE})

    target_include_directories(
            ${target}
            PUBLIC
            ${PHP_INCLUDES}
            ${PROJECT_SOURCE_DIR}/include
            ${PROJECT_BINARY_DIR}
            ${libscylladb_SOURCE_DIR}/include
            ${PROJECT_SOURCE_DIR}
    )

    target_compile_features(
            ${target}
            PUBLIC
            cxx_std_20
            c_std_17
    )
    target_compile_options(
            ${target} PRIVATE
            -fPIC -Wall -Wextra -Wno-long-long -Wno-deprecated-declarations -Wchanges-meaning -Wno-unused-parameter -Wno-unused-result -Wno-variadic-macros -Wno-extra-semi -pthread
    )

    if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        target_compile_definitions(${target} PRIVATE -DDEBUG)
    elseif (${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo" OR ${CMAKE_BUILD_TYPE} STREQUAL "Release")
        target_compile_definitions(${target} PRIVATE -DRELEASE)
    endif ()

    if (enable_sanitizers)
        target_compile_options(${target} PRIVATE -fno-inline -fno-omit-frame-pointer)
        add_sanitize_undefined(${target})
        add_sanitize_address(${target})
    endif ()

    scylladb_php_target_optimize(${target} ${native_arch} ${lto})
endfunction()