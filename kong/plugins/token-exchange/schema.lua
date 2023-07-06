local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "token-exchange"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { exchange_endpoint_url = typedefs.url({ 
              required = true,
              }) },
          { grant_type = {
              type = "string",
              default = "urn:ietf:params:oauth:grant-type:token-exchange",
	      required = true,
               }}, 
          { subject_token_type = {
              type = "string",
              default = "urn:ietf:params:oauth:token-type:access_token",
	      required = true,
               }}, 
          { client_id = {
              type = "string",
	      required = true,
	      referenceable = true,
               }}, 
          { client_secret = {
              type = "string",
	      required = true,
	      referenceable = true,
               }}, 
          { response_body_access_token_parameter = {
              type = "string",
              default = "access_token",
	      required = true,
               }},
	  { cache_ttl = {
              type = "integer",
              default = 300,
              required = true
            }},
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema
