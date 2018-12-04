json.array!(@coins) do |coin|
  json.extract! coin, :id
  json.url coin_url(coin, format: :json)
end
