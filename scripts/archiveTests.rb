require 'net/http'
require 'json'

# url = 'https://archive.org/advancedsearch.php?q="title:"moby dick" mediatype:"texts""&fl[]=downloads,format,identifier,title&output="json"&sort[]=downloads desc&rows=50&page=1'
# uri = URI(url)
# response = Net::HTTP.get(uri)
# @json = JSON.parse(response)
#
# res =  @json['response']

require '../app/helpers/archive_helper'
include ArchiveHelper

# download_file_async('http://www.jamieglowacki.com/wp-content/uploads/2015/01/LYw4POpF.jpeg', 'poop/poop_test.jpeg')

ungzip '../data/books/manhattanarmyato00jone/manhattanarmyato00jone.abbyy.gz', ""