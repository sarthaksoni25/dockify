json.extract! image, :id, :name, :postgres, :nginx, :redis, :ruby_version, :created_at, :updated_at
json.url image_url(image, format: :json)
