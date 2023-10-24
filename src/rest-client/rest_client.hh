#ifndef REST_CLIENT_H_
#define REST_CLIENT_H_

#include <stdio.h>
#include <curl/curl.h>

#include <string>
using string = std::string;
#include <memory>
#include <variant>
#include <iostream>
#include <stdexcept>
#include <string_view>

#define NON_USED_PORT 0

namespace rest
{
namespace inet
{
  typedef struct http_server_url_t
  {
    std::string_view server_url;
  } http_server_url_t;

  typedef struct http_server_address_t
  {
    std::string_view server_ip;
    long             server_port{NON_USED_PORT};
  } http_server_address_t;
}
}

/**
 * Get REST client instance via rest::inet::sync::client()
 */
namespace rest
{
namespace inet
{
namespace sync
{
  class rest_client;

  /**
   * The interface allow user get rest::inet::sync::client instance.
   *
   * @param[in] server_ip IPv4 address of target HTTP server
   * @param[in] server_port Port number of target HTTP server
   *
   * @return Unique pointer to REST client if succeeded
   * @return nullptr If failed
   * 
   * @exception Interface might throw std::runtime_error
   */
  std::unique_ptr<rest_client>
  client(const std::string_view& server_ip, const long server_port);

  /**
   * The interface allow user get rest::inet::sync::client instance.
   *
   * @param[in] url URL to target HTTP server
   *
   * @return Unique pointer to REST client if succeeded
   * @return nullptr If failed
   * 
   * @exception Interface might throw std::runtime_error
   */
  std::unique_ptr<rest_client>
  client(const std::string_view& url);

  class rest_client
  {
  public:
    using endpoint_t = const std::string&;
    using postdata_t = const std::string_view&;

    ~rest_client();

    rest_client() = delete;
    rest_client(rest_client&&) = delete;
    rest_client(const rest_client&) = delete;
    rest_client& operator=(rest_client&&) = delete;
    rest_client& operator=(const rest_client&) = delete;

    /**
     * Set timeout (in seconds) for maximum time
     * the transfer is allowed to complete.
     *
     * @param[in] in_seconds Set timeout in seconds.
     *            Default value: 0, means never times out during transfer.
     */
    void set_timeout(const long in_seconds);

    /**
     * HTTP GET
     *
     * @param[in] endpoint Set target endpoint for GET, e.g. "/version"
     * 
     * @return Empty string if failed.
     * @return Result from GET request in string format if succeeded.
     */
    std::string GET(endpoint_t endpoint);

    /**
     * HTTP POST
     *
     * @param[in] endpoint Set target endpoint for GET, e.g. "/version"
     * @param[in] postdata Set POST data to send to server, e.g. "{"Json String"}" 
     * 
     * @return Empty string if failed.
     * @return Result from GET request in string format if succeeded.
     */    
    std::string POST(endpoint_t endpoint, postdata_t postdata);

    void just_test() {
      try {
        auto url = std::get<0>(m_server_id).server_url;
        fprintf(stdout, "== Info: rest::inet::sync::client connects to %s\n",
                            string(url).c_str());
        return;
      } catch (const std::bad_variant_access& e) {
        std::cerr << "== Error: caugth exception: " << e.what() << "\n";
      }

      try {
        auto ip = std::get<1>(m_server_id).server_ip;
        auto port = std::get<1>(m_server_id).server_port;
        fprintf(stdout, "== Info: rest::inet::sync::client connects to %s:%ld\n",
                            string(ip).c_str(), port);
        return;
      } catch (const std::bad_variant_access& e) {
        std::cerr << "Caugth exception: " << e.what() << "\n";
      }
    }

  private:
    friend std::unique_ptr<rest_client>
    client(const std::string_view& url);

    friend std::unique_ptr<rest_client>
    client(const std::string_view& server_ip, const long server_port);

    /**
     * REST client constructor with target HTTP server's URL setting
     * @exception Interface might throw std::runtime_error
     */
    rest_client(const std::string_view& server_url);

    /**
     * REST client constructor with target HTTP server's IP and port settings
     * @exception Interface might throw std::runtime_error
     */
    rest_client(const std::string_view& server_ip, const long server_port);

    long                m_timeout = 0;
    CURL*               m_curl = NULL;
    string              m_curl_data{""};
    struct curl_slist*  m_headers = NULL;

    using server_identity_t = std::variant<http_server_url_t, http_server_address_t>;
    server_identity_t m_server_id;

    inline const string form_url() const noexcept
    {
      try {
        auto url = string(std::get<0>(m_server_id).server_url);
        return url;
      } catch (const std::bad_variant_access& e) { ; }
      try {
        auto ip = string(std::get<1>(m_server_id).server_ip);
        auto port = std::to_string(std::get<1>(m_server_id).server_port);
        return (ip + ":" + port);
      } catch (const std::bad_variant_access& e) { ; }

      return "";
    }
  };
} // namespace sync
} // namespace inet
} // namespace rest

namespace rest
{
  // static
  size_t rread(void* _data, size_t _size, size_t _nmemb, string* buffer);
  // static
  size_t rwrite(void* _data, size_t _size, size_t _nmemb, string* buffer);
}

namespace rest
{
namespace client
{
  class core
  {
  public:
    static core& init()
    {
      static core c;
      return c;
    }

    ~core() { curl_global_cleanup(); }

    core(core&&) = delete;
    core(const core&) = delete;
    core& operator=(core&&) = delete;
    core& operator=(const core&) = delete;

  private:
    core()
    {
      CURLcode res = curl_global_init(CURL_GLOBAL_NOTHING);
      if (CURLE_OK != res) {
        throw std::runtime_error("Failed to perform curl_global_init()");
      }
    }
  };
} // namespace client
} // namespace rest

#endif /* REST_CLIENT_H_ */
