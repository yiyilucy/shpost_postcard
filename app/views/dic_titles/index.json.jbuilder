json.array!(@dic_titles) do |dic_title|
  json.extract! dic_title, :id
  json.url dic_title_url(dic_title, format: :json)
end
