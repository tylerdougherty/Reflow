require 'net/http'
require 'json'

url = 'https://archive.org/advancedsearch.php?q="title:"moby dick" mediatype:"texts""&fl[]=downloads,format,identifier,title&output="json"&sort[]=downloads desc&rows=50&page=1'
uri = URI(url)
response = Net::HTTP.get(uri)
@json = JSON.parse(response)

res =  @json['response']
