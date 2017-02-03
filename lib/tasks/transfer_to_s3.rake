
desc "Transfer image files from file structure to AWS S3 storage."
task "transfer_to_s3" => :environment do
  collection_names = Collection.names
  albums = collection_names.map { |name| Collection.find(name).albums }.flatten

  main_resource_s3_location = "resource.json"
  main_resource_data = S3Wrapper.get(main_resource_s3_location)

  main_resource_data = {} unless main_resource_data

  main_resource_data.merge!(
    albums.map do |album|
      [album.collection_name, album.path]
    end.group_by(&:first).map do |k, v|
      { k => v.map(&:last) }
    end.reduce({}) do |m, v|
      m.merge(v)
    end
  )
  S3Wrapper.put(main_resource_s3_location, main_resource_data)

  albums.each do |album|
    resource_s3_location = File.join(album.path, 'resource.json')
    puts "Starting to upload album resource data for #{album.title} to AWS S3 #{resource_s3_location}"

    existing_resource = S3Wrapper.get(resource_s3_location)
    if existing_resource
      puts "Album resource already exists --> skipping..."
      next
    end
    album.assemble_album_metadata

    puts "Finishing uploading album resource data for #{album.title} to AWS S3 #{resource_s3_location}"

    # photo_paths_all_res.values.flatten.each do |photo_path|
    #   s3_path = photo_path.sub(Rails.application.secrets.base_photo_path + '/', "")
    #   puts "Uploading #{photo_path} to AWS S3 #{s3_path}"
    #   S3Wrapper.put(s3_path, IO.read("#{Rails.root}/#{photo_path}"))
    # end
  end

end
