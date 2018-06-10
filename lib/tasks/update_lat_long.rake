desc "Get photo EXIF data and update photos table lat/long."
task "update_lat_long" => :environment do

  Album.all.each do |album|
    photos = album.photos.where.not(longitude: nil).where.not(latitude: nil)
    puts "  ** Updating Album: #{album.path} with #{photos.count} photos (ID=#{album.id}, #{album.order_index})"
    photos.each do |photo|
      print '.'
      photo.send(:save_exif_info)
    end
    puts " "
  end
  puts "Done."
  end

desc "Set photos table lat/long to nil when lat/long = 0.0/0.0."
task "nil_out_lat_long" => :environment do

  Album.all.each do |album|
    photos = album.photos.where.not(longitude: nil).where.not(latitude: nil)
    puts "  ** Updating Album: #{album.path} with #{photos.count} photos (ID=#{album.id}, #{album.order_index})"
    photos.each do |photo|
      if photo.latitude == 0.0 && photo.longitude == 0.0
        print '0'
        photo.update(latitude: nil, longitude: nil)
      else
        print '.'
      end
    end
    puts " "
  end
  puts "Done."
end
