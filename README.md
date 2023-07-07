# Kong plugin for token exchange

## About

This Kong 🦍 plugin receives and opaque / encrypted token and will exchange it based on [RFC-8693](https://www.rfc-editor.org/rfc/rfc8693) with a JWT from the IdP.

Exchanged tokens will be cached for a configurable amount of time and the cache can be invalidated per token at any time.

This plugin is only focussing on the token exchange - for validating the token and enforcing claims have the OpenID Connect plugin also configured on the same call (this plugin injects the JWT into the request authorization header).

## Configuration parameters token exchange

|FORM PARAMETER|DEFAULT|DESCRIPTION|
|:----|:------|:------|
|config.cache_ttl|300|Time in seconds we cache the client token|
|config.client_id||Client ID used by Kong to authenticate against the IdP token-endpoint (*referencable*)|
|config.client_secret||Client secret used by Kong to authenticate against the IdP token-endpoint (*referencable*)|
|config.exchange_endpoint_url||The token exchange endpoint of the IdP|
|config.grant_type|urn:ietf:params:oauth:grant-type:token-exchange|The grant type to be used (should normally be the default one)|
|config.response_body_access_token_parameter|access_token|The JSON parameter name where the access token is provided in the response from the IdP|
|config.subject_token_type|urn:ietf:params:oauth:token-type:access_token|The subject token type to be used (should normally be the default one)|

# Cache invalidation

This plugin provides an API to invalidate the cache for a given token. The API is protected by a secret that can be configured in the plugin. It is a `DELETE` request with parameters sent as headers.

IMPORTANT: this API should not be enabled on public facing endpoints. It is protected by a shared secrets.

Example call to invalidate the cache for a given token:

```bash
curl --request DELETE \
  --url https://KONG_GATEWAY/YOUR_PATH \
  --header 'Invalidate-Cache: ORIGINAL_OPAQUE_TOKEN' \
  --header 'invalidation-secret: SHARED_SECRET_SEE_BELOW'
  ```

## Configuration parameters cache invalidation

|FORM PARAMETER|DEFAULT|DESCRIPTION|
|:----|:------|:------|
|config.cache_invalidation_enabled|false|Cache invalidation enabled on this instance|
|config.cache_invalidation_secret||The secret which needs to be also sent (see above example) in order to authenticate against the plugin as trusted source (*referencable*)|