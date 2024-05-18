# REST Client
`rest-client` is a lightweight and simple REST client library which implemented in C++.

A quick glance at code example:
```cpp
#include "rest_client.hh"

auto restclient = rest::inet::sync::client("127.0.0.1", 6789);
auto version = rest_client->GET("/endpoint");

auto another_client = rest::inet::sync::client("https:://www.backend.com");
another_client->POST("/user_name", "{\"user_id\":\"123\",\"name\":\"SomeOne\"}")
```

# Third-party Dependencies
The `rest-client` employs these open-source libraries:
- [libcurl](https://github.com/curl/curl)
- [nlohmann-json](https://github.com/nlohmann/json)

In case you installed above libraries to your system, then you just need to build
`rest-client` alone. Otherwise, we support third-party dependencies build-on-fly
before building `rest-client`, using CMake.

# Build rest-client library
`rest-client` build process requires

  * C/C++ compiler (most commonly GCC on Linux) support C17.
  * CMake version 3.21 or later.

## Build it as a static library and install to your system
```bash
cd rest-client
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX="install_path" -DTESTING=ON ..
make
sudo make install
```

## Build it as a shared library and install to your system
```bash
cd rest-client
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX="install_path" -DDEBUG=ON -DSHARED_LIB=ON -DTESTING=ON ..
make
sudo make install
```

## Core CMake build options
  * CMAKE_INSTALL_PREFIX: specify your desired installation path for `rest-client`
  * DEBUG: ON | OFF (default), enable DEBUG build
  * SHARED_LIB: ON | OFF (default), build as shared or static library
  * TESTING: ON | OFF (default), build testings
