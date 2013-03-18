require 'json'
require 'net/http'
require 'rexml/document'

def console_log(msg)
  escape = proc{ |m| m.gsub("'", "'\\\\''") }
  `logger -t 'Alfred Workflow' '#{escape[msg]}'`
end

now  = Time.now

case ARGV[0].to_s.downcase
when 'demain'
  now += 86400
end

channels = {
  1 => 19,
  2 => 6,
  3 => 7,
  4 => 2,
  5 => 9,
  6 => 12,
  7 => 1,
  8 => 4,
  9 => 24,
  10 => 21,
  11 => 14,
  12 => 13,
  13 => 11,
  14 => 8,
  15 => 25,
  16 => 30,
  17 => 28,
  18 => 29,
  19 => 69
}

is_prime = ARGV.length < 2

xml = REXML::Document.new('<items/>')
xml << REXML::XMLDecl.new

channel_id = ARGV[1].nil? ? 19 : channels[ARGV[1].to_i]

time_begin = Time.new(now.year, now.month, now.day, 20, 00).to_i
time_end = Time.new(now.year, now.month, now.day, 22, 00).to_i

if is_prime then
  uri = URI("http://api.programme-tv.net/1326279455-10/getPrime/?date=#{ now.strftime('%Y-%m-%d') }&periode=prime1&bouquetId=2")
else
  uri = URI("http://api.programme-tv.net/1326279455-10/getBroadcastInfo/?timeBegin=#{ time_begin.to_s }&timeEnd=#{ time_end.to_s }&channelList=#{ channel_id.to_s }")
end

json = JSON.parse(Net::HTTP.get(uri), :symbolize_names => true)

results = []

json[:data].each { |data|

  item = data[:list][0]

  results << {
    'attr' => {
      'uid' => 'tv-' << data[:idChaine],
      'arg' => 'tv-' << data[:idChaine],
      'valid' => 'yes'
    },
    'title' => item[:titre],
    'subtitle' => "(#{data[:name]} / #{item[:type]} / #{item[:heure]})",
    'icon' => item[:image_vignette_small],
  }

}

results.each { |result|
  item = xml.root.add_element('item', result['attr'])
  item.add_element('title').add_text(result['title'])
  item.add_element('subtitle').add_text(result['subtitle'])
  item.add_element('icon').add_text(result['icon'])
}

puts xml
