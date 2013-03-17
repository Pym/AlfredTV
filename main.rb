require 'json'
require 'net/http'
require 'rexml/document'
require 'ostruct'

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

is_prime = true

uri = URI('http://api.programme-tv.net/1326279455-10/getPrime/?date=2013-03-17&periode=prime1&bouquetId=2')
json = JSON.parse(Net::HTTP.get(uri))

doc = REXML::Document.new('<items/>')
doc << REXML::XMLDecl.new

items = OpenStruct.new(json)

channel_id = 19

results = []

items.data.each { |data|
  item = OpenStruct.new(data['list'][0])

  results << {
    'attr' => {
      'uid' => 'tv-' + data['idChaine'],
      'arg' => 'tv-' + data['idChaine'],
      'valid' => 'yes'
    },
    'title' => item.titre,
    'subtitle' => '(' + data['name'] + ' / ' + item.type + ' / ' + item.heure + ')',
    'icon' => item.image_vignette_small,
  }
}

results.each { |result|
  item = doc.root.add_element('item', result['attr'])
  item.add_element('title').add_text(result['title'])
  item.add_element('subtitle').add_text(result['subtitle'])
  item.add_element('icon').add_text(result['icon'])
}

puts doc

#ARGV.each do|a|
#  puts "Argument: #{a}"
#end
