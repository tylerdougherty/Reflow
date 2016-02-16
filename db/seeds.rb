# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Book.create!( :title => 'Moby Dick' , :author => 'Herman Melville' )
Book.create!( :title => 'Harry Potter and the Chamber of Secrets' , :author => 'JK Rowling' )
Book.create!( :title => 'The Lord of the Rings: The Fellowship of the Ring' , :author => 'J.R.R. Tolkien' )