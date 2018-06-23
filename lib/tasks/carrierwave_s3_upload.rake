desc "Build colllection/album/photo tables and Carrierwave AWS S3 storage."
task "carrierwave_to_s3" => :environment do
  main_resource_s3_location = 'resource.json'
  main_resource_data = S3Wrapper.get(main_resource_s3_location)

  main_resource_data.each_with_index do |collection_data, i|
    collection_name = collection_data.first.to_s
    album_paths     = collection_data.last

    if (collection = Collection.find_by(name: collection_name))
      puts "** Updating Collection: #{collection.name} (#{collection.order_index})"
    else
      puts "** Creating Collection: #{collection_name} (#{i + 1})"
      collection = Collection.create!(name: collection_name, order_index: i + 1)
    end

    album_paths.each_with_index do |album_path, j|
      album_resource_data =
        S3Wrapper.get("#{album_path}/resource.json")

      if (album = collection.albums.find_by(path: album_path))
        puts "  ** Updating Album: #{album.path} (ID=#{album.id}, #{album.order_index})"
      else
        puts "  ** Creating Album: #{album_path} (#{j + 1})"
        album =
          Album.create!(path:        album_path,
                        title:       album_resource_data[:title],
                        description: album_resource_data[:description],
                        order_index: j + 1,
                        collection:  collection
          )
      end

      photo_resource_data =  album_resource_data[:photos]

      photo_resource_data.each_with_index do |photo_data, k|
        begin
          photo = nil
          photo_basename = photo_data.keys.first.to_s
          photos = album.photos.where("UPPER(image) = ?", photo_basename.upcase.gsub(/[^[:word:]\.\-\+]/, '_'))
          if photos.present? && photos.last.image&.url
            # puts "    ** Skipping Photo: #{photo_basename} (already exists) #{photos.count} times"
            print 'S'
            photo = photos.order(:created_at).last
            if photos.length > 1
              # puts "    ** Photo: #{photo_basename} (has #{photos.count} records, deleting extras..."
              print 'D'
              photos.where.not(id: photo.id).each(&:delete)
            end

            next if photo.image&.url
          end

          photo ||= Photo.new(album: album, order_index: k + 1)
          full_photo_location = "#{album_path}/images/full/#{photo_basename}"
          print '.'
          # puts "    ** Getting Photo at: #{full_photo_location} (#{k + 1})"
          temp_file     = File.open(File.join(Rails.root, photo_basename), 'wb')
          photo_content = S3Wrapper.get(full_photo_location)
          puts "    ** --> NO PHOTO CONTENT RETRIEVED" unless photo_content
          temp_file.write(photo_content)
          temp_file.rewind
          photo.image = temp_file
          photo.save!
          temp_file.close
          File.delete(temp_file.path)
        rescue => e
          Log.error("#{self.class}: For photo at '#{full_photo_location}' - #{e.message}")
        end
      end
      puts " "
    end
  end

end
