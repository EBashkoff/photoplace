#!/usr/bin/env ruby

ENVIRONMENTS = %w(production).freeze

environment = ARGV[0]

unless environment && ENVIRONMENTS.include?(environment.to_s.downcase)
  puts "You must specify an environment: #{ENVIRONMENTS.map(&:upcase).join(", ")}"
  puts "Exiting..."
  exit(0)
end

environment = ARGV[0].dup

puts "Getting Configuration Variables for #{environment.upcase}..."

environment.downcase!

heroku_config_lines =
  if environment == "production"
    `heroku config -a photoplace`.lines
  else
    `heroku config -a photoplace-#{environment}`.lines
  end
heroku_config_lines.shift

heroku_config = heroku_config_lines.reduce({}) do |m, line|
  /\A([^:]+):\s+(.*)/.match(line) do |match|
    m.merge({ match[1] => match[2].strip })
  end
end

native_config =
  IO.read(".env.#{environment}")
    .lines
    .map(&:strip)
    .reject(&:empty?)
    .reduce({}) do |m, line|
    /\A([^=]+)="([^"]*)"/.match(line) do |match|
      m.merge({ match[1] => match[2] })
    end
  end

on_heroku_not_in_env = heroku_config.keys - native_config.keys
in_env_not_on_heroku = native_config.keys - heroku_config.keys
common_keys          = heroku_config.keys & native_config.keys
differences          = common_keys.reject do |key|
  heroku_config[key] == native_config[key]
end.reduce({}) do |m, key|
  m.merge(
    {
      key =>
        {
          heroku_config: heroku_config[key],
          native_config: native_config[key]
        }
    }
  )
end

unless on_heroku_not_in_env.empty?
  puts "=== Environment variables on Heroku #{environment} but not in your .env.#{environment} file:"
  on_heroku_not_in_env.each do |one_var|
    puts "--- > #{one_var}='#{heroku_config[one_var]}'"
  end
  puts "\n"
end

unless in_env_not_on_heroku.empty?
  puts "=== Environment variables in your .env.#{environment} file but not on Heroku #{environment}:"
  in_env_not_on_heroku.each do |one_var|
    puts "--- > #{one_var}='#{native_config[one_var]}'"
  end
  puts "\n"
end

unless differences.empty?
  puts "=== Environment variables in your .env.#{environment} file and Heroku #{environment} that differ:"
  differences.keys.each do |one_var|
    puts "--- > #{one_var} - (.env.#{environment}: '#{differences[one_var][:native_config]}', Heroku #{environment}: '#{differences[one_var][:heroku_config]}')"
  end
  puts "\n"
end

if on_heroku_not_in_env.empty? && in_env_not_on_heroku.empty? && differences.empty?
  puts "No need to pull config!! Everything is already the same."
  exit(0)
end

puts "Do you want to continue with updating your .env.#{environment} file [Y/n]?"
if STDIN.gets.chomp == "Y"
  File.open(".env.#{environment}", "w+") do |f|
    f.puts(heroku_config.map { |key, value| "#{key}=\"#{value}\"" })
  end

  puts "Done!  The config variables are in file '.env.#{environment}'."
else
  puts "Nothing done."
  exit(0)
end


