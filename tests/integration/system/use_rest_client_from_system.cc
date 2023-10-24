#include <string>
#include <cstdio>
#include <cstdlib>
#include <iostream>

#include "rest_client.hh"

int main(int argc, char** argv)
{
  (void)argc;
  (void)argv;

  /*************************************************************************
   * HTTP GET TEST
   ************************************************************************/  
  auto rest_client = rest::inet::sync::client("127.0.0.1", 9999);
  std::cout << "GET requesting to LSV ...\n";
  auto version = rest_client->GET("/version");
  std::cout << "GET response: " << version << std::endl;

  /*************************************************************************
   * HTTP POST TEST
   ************************************************************************/
  auto another_client = rest::inet::sync::client("localhost:9999");
  std::string_view post_data = 
    "{\"ctx\":\"lsv\",\"level\":\"kInfo\",\"msg\":\"Hello World\"}";
  std::cout << "POST requesting to LSV ...\n";
  auto result = rest_client->POST("/logging", post_data);
  std::cout << "POST response: " << result << std::endl;

  return 0;
}















