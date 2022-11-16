ShopifyAPI::Context.setup(
  api_key: "e66194343b7a521549c3dde66eef0358",
  api_secret_key: "270aae7dda139b1405f3b87a998afd1f",
  host: "https://5df5-177-222-37-83.ngrok.io",
  scope: "read_orders,read_products,read_inventory",
  session_storage: ShopifyAPI::Auth::FileSessionStorage.new, # See more details below
  is_embedded: false, # Set to true if you are building an embedded app
  is_private: false, # Set to true if you are building a private app
  api_version: "2022-10" # The version of the API you would like to use
)