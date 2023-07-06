local plugin = {
    PRIORITY = 1010, -- set the plugin priority, which determines plugin execution order
    VERSION = "0.9",
  }
  
function plugin:access(plugin_conf)
  -- >>>>>> checking if we got a token at all
  local token = kong.request.get_header("Authorization")
  if token == nil then
    kong.log.info("No token found")
    kong.response.exit(401, 'Authentication required')
    return
  end

  if token:find("^Bearer ") ~= nil then
    kong.log.info("Opaque token includes Bearer - removing it")
    token = token:sub(8)
  end

  local token_cache_key = "token_exchange_" .. token
  local opts = { ttl = plugin_conf.cache_ttl }

  local decoded_token, err = kong.cache:get(token_cache_key, opts, exchange_token, plugin_conf, token)
  if err then
    kong.log.info(err)
    return kong.response.exit(401, 'Invalid credentials')
  end

  kong.service.request.set_header("Authorization", "Bearer " .. decoded_token)

end

function exchange_token(plugin_conf, token)
  local http = require "resty.http"
  local httpc = http.new()

  local res, err = httpc:request_uri(plugin_conf.exchange_endpoint_url, {
    method = "POST",
      headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
      },
      body = "grant_type=" .. plugin_conf.grant_type .. "&subject_token_type=" .. plugin_conf.subject_token_type .. "&client_id=" .. plugin_conf.client_id .. "&client_secret=" .. plugin_conf.client_secret .. "&subject_token=" .. token,
      query = {
      },
      keepalive_timeout = 60,
      keepalive_pool = 10
    })
  if err then
    return nil, err
  end
  if not res.status == 200 then
    return nil, "Invalid exchange status code received: " .. res.status
  end

  local cjson = require("cjson.safe").new()
  local serialized_content, err = cjson.decode(res.body)
  if not serialized_content then
    return nil,"Exchange endpoint has not returned parsable JSON"
  end

  if not serialized_content.access_token then
    return nil, "We have not gotten an exchanged token"
  end

  return serialized_content.access_token, nil
end

return plugin
