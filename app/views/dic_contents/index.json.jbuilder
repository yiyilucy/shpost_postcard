json.array!(@dic_contents) do |dic_content|
  json.extract! dic_content, :id
  json.url dic_content_url(dic_content, format: :json)
end
