json.array!(@catalogs) do |product_catalog|
  json.extract! catalog, :id, :catalog_no, :catalog_name, :catalog_type, :is_show
  json.url catalog_url(catalog, format: :json)
end
