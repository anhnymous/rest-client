/*
 * file   main.cc
 * brief
 *
 *  Created on: Tue 09 May 2023 04:06:39 PM UTC
 *    Author: anhthd
 */

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
   * SIMPLE TEST
   ************************************************************************/
  // auto rest_client = rest::inet::sync::client("127.0.0.1", 8888);
  // rest_client->just_test();
  // rest_client->GET("version");
  // rest_client->POST("version", "some data");

  /*************************************************************************
   * SIMPLE TEST
   ************************************************************************/  
  // auto rest_client2 = rest::inet::sync::client("https://www.google.com");
  // rest_client2->just_test();
  // rest_client2->GET("version2");
  // rest_client2->POST("version2", "some data 2");

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
