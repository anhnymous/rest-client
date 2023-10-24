#include <algorithm>

#include "rest_client.hh"

namespace rest
{
namespace inet
{
namespace sync
{
  std::unique_ptr<rest_client>
  client(const std::string_view& url)
  {
    std::unique_ptr<rest_client> client{new rest_client(url)};
    return client;
  }

  std::unique_ptr<rest_client>
  client(const std::string_view& server_ip, const long server_port)
  {
    std::unique_ptr<rest_client> client{new rest_client(server_ip, server_port)};
    return client;
  }

  rest_client::~rest_client()
  {
    fprintf(stdout, "== Info: rest_client::~rest_client\n");
    if (m_curl) {
      curl_easy_cleanup(m_curl);
      m_curl = NULL;
    }

    if (m_headers) {
      curl_slist_free_all(m_headers);
      m_headers = NULL;
    }
  }

  void rest_client::set_timeout(const long in_seconds)
  {
    m_timeout = in_seconds;
    if (m_curl) {
      curl_easy_setopt(m_curl, CURLOPT_TIMEOUT, m_timeout);
      fprintf(stdout, "== Info: rest_client set_timeout: %ld\n", m_timeout);
    }
  }

  std::string rest_client::GET(endpoint_t endpoint)
  {
    if (m_curl) {
      curl_easy_setopt(m_curl, CURLOPT_HTTPGET, 1L);
    } else {
      std::cout << "== Warn: GET request but has not curl_easy_init() yet" << std::endl;
      return "";
    }

    auto url = form_url() + endpoint;
    curl_easy_setopt(m_curl, CURLOPT_URL, string(url).c_str());
    fprintf(stdout, "== Info: GET request: %s\n", string(url).c_str());

    m_curl_data.clear();
    CURLcode res = curl_easy_perform(m_curl);
    if (CURLE_OK != res) {
      std::cout << "== Error: GET failed to perform curl_easy_perform()" << std::endl;
      return "";
    }

    auto response_code = 0l;
    curl_easy_getinfo(m_curl, CURLINFO_RESPONSE_CODE, &response_code);
    if (200 != response_code) {
      fprintf(stderr, "== Error: GET failed, response_code %ld\n", response_code);
      return "";
    }
  
    return m_curl_data;
  }

  std::string rest_client::POST(endpoint_t endpoint, postdata_t postdata)
  { 
    auto postdata_s = string(postdata);

    if (m_curl) {
      curl_easy_setopt(m_curl, CURLOPT_HTTPGET, 1L);
      curl_easy_setopt(m_curl, CURLOPT_POSTFIELDS, postdata_s.c_str());
      curl_easy_setopt(m_curl, CURLOPT_POSTFIELDSIZE, postdata_s.size());
      curl_easy_setopt(m_curl, CURLOPT_POST, 1L);                          
    } else {
      std::cout << "== Warn: POST request but has not curl_easy_init() yet" << std::endl;
      return "";
    }

    auto url = form_url() + endpoint;
    curl_easy_setopt(m_curl, CURLOPT_URL, string(url).c_str());
    fprintf(stdout, "== Info: POST request: %s\n",
                     string(url + " -d " + postdata_s).c_str());

    m_curl_data.clear();
    CURLcode res = curl_easy_perform(m_curl);
    if (CURLE_OK != res) {
      std::cout << "== Info: POST failed to perform curl_easy_perform()" << std::endl;
      return "";
    }

    auto response_code = 0l;
    curl_easy_getinfo(m_curl, CURLINFO_RESPONSE_CODE, &response_code);
    if (200 != response_code) {
      fprintf(stderr, "== Error: GET failed, response_code %ld\n", response_code);
      return "";
    }
  
    return m_curl_data;
  }

  rest_client::rest_client(const std::string_view& server_url)
  { 
    (void)rest::client::core::init();
    m_server_id = http_server_url_t{server_url};
    
    m_curl = curl_easy_init();
    if (NULL == m_curl) {
      throw std::runtime_error("Cannot perform curl_easy_init()");
    }

    m_headers = curl_slist_append(m_headers, "Content-Type: plain/text");
    if (NULL == m_headers) {
      curl_easy_cleanup(m_curl);
      throw std::runtime_error("Cannot set Content-Type");
    }

    curl_easy_setopt(m_curl, CURLOPT_TIMEOUT, m_timeout);
    curl_easy_setopt(m_curl, CURLOPT_WRITEFUNCTION, rwrite);
    curl_easy_setopt(m_curl, CURLOPT_WRITEDATA, &m_curl_data);
    curl_easy_setopt(m_curl, CURLOPT_HTTPHEADER, m_headers);
  }

  rest_client::rest_client(const std::string_view& server_ip, const long server_port)
  {
    (void)rest::client::core::init();
    m_server_id = http_server_address_t{server_ip, server_port};

    m_curl = curl_easy_init();
    if (NULL == m_curl) {
      throw std::runtime_error("Cannot perform curl_easy_init()");
    }

    m_headers = curl_slist_append(m_headers, "Content-Type: plain/text");
    if (NULL == m_headers) {
      curl_easy_cleanup(m_curl);
      throw std::runtime_error("Cannot set Content-Type");
    }

    curl_easy_setopt(m_curl, CURLOPT_TIMEOUT, m_timeout);
    curl_easy_setopt(m_curl, CURLOPT_WRITEFUNCTION, rwrite);
    curl_easy_setopt(m_curl, CURLOPT_WRITEDATA, &m_curl_data);
    curl_easy_setopt(m_curl, CURLOPT_HTTPHEADER, m_headers);
  }
} // namespace sync
} // namespace inet
} // namespace rest


namespace rest
{
  /**
   * REST read function
   *
   * @param[in] _data Libcurl's memory contains data from libcurl
   * @param[in] _size Size of each data element. This value is always 1
   * @param[in] _nmemb Number of items we want to read from user and send
   * @param[in] _buffer User's memory area contains user's data to be read
   *
   */
  size_t rread(void* _data, size_t _size, size_t _nmemb, string* _buffer)
  {
    auto len = _size * _nmemb;
    if (_buffer->length() < len) {
      len = _buffer->length();
    }
    std::copy((char*)_buffer->data(), (char*)_buffer->data() + len, (char*)_data);
    *_buffer = _buffer->substr(len);
    return len;
  }

  /**
   * CURLOPT_WRITEFUNCTION
   *
   * @param[in] _data Libcurl's memory contains data from libcurl
   * @param[in] _size Size of each data element. This value is always 1
   * @param[in] _nmemb Number of items we want to read from user and send
   * @param[in] _buffer User's memory area contains user's data to be read
   */
  size_t rwrite(void* _data, size_t _size, size_t _nmemb, string* _buffer)
  {
    auto new_len = _size * _nmemb;
    auto old_len = _buffer->size();
    try {
      _buffer->resize(old_len + new_len);
    } catch (const std::bad_alloc& e) {
      fprintf(stderr, "[ERROR] rwrite() caught exception: %s\n", e.what());
      return 0;
    }
    std::copy((char*)_data, (char*)_data + new_len, _buffer->begin() + old_len);
    return new_len;
  }

  /**
   * This callback is gets called by libcurl as soon as it needs read
   * user's data in order to send to peer host. Like, if you ask to upload/post
   * data to server.
   *
   * @param[in] _buffer Memory area contains data to be sent (after read)
   * @param[in] _size This value is always 1
   * @param[in] _nitems Number of items we want to read and send
   * @param[in] _userdata Memory area contains user's data to be read
   *            _userdata is set with
   *             curl_easy_setopt(curl, CURLOPT_READDATA, (void*)_userdata);
   *
   * @return Actual number of bytes that stored in the data area pointed at _buffer
   * @return 0 Means libcurl read all data need to be sent, so libcurl will stop
   */
  size_t read_callback(char* _buffer, size_t _size, size_t _nitems, void* _userdata)
  {
    FILE* readhere = (FILE*)_userdata;
    curl_off_t nread;
  
    /* copy as much data as possible into the 'ptr' buffer, but no more than
       'size' * 'nmemb' bytes! */
    size_t retcode = fread(_buffer, _size, _nitems, readhere);
  
    nread = (curl_off_t)retcode;
  
    fprintf(stderr, "*** We read %" CURL_FORMAT_CURL_OFF_T
                    " bytes from file\n", nread);
    return retcode;
  }
}
