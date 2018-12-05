json.array!(@stamps) do |stamp|
  json.extract! stamp, :id
  json.url stamp_url(stamp, format: :json)
end
