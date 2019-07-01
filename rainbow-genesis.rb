require 'json'

# A function to determine if a string contains only numbers (is an integer?)
class String
  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end

# The bible translation to parse
argument = ARGV[0]

if argument == 'niv' || argument == 'esv' || argument == 'nlt'
  translation = argument
  file = File.open("./translations/#{translation}.json")
else
  # Help message if an invalid argument
  puts "\n\nRainbow Genesis\n\nPlease specify the bible translation to generate passwords from (niv, esv, nlt).\n\n"
end


if translation && File.exist?("./translations/#{translation}.json")

# Read the file
json = file.read

# Remove hyphens and replace with spaces - some words in the files are delimited with these instead of spaces
json.gsub! '-', ' '

# Parse the entire json text into ruby hashes and arrays
json = JSON.parse json

# Will hold words
words = []

# Will contain all the passwords that will be written to a file
passwords = []

# Passwords will be written here
passwords_file = File.open("passwords-#{translation}.txt", 'a+')

# Extract every word from the bible (exclude numbers)
json.keys.each do |book|
  words.push(book.downcase.strip.gsub(/[^a-z0-9\s]/i, ''))
  json[book].keys.each do |chapter|
    json[book][chapter].keys.each do |verse|
      json[book][chapter][verse].split(' ').each do |word|
        sanitised_word = word.downcase.strip.gsub(/[^a-z0-9\s]/i, '')
        words.push(sanitised_word) unless sanitised_word.is_i?
      end
    end
  end
end

# Eliminate duplicate words
unique_words = words.uniq

# Eliminate words less than seven characters long
length_words = unique_words.select { |word| word.length >= 7 }

passwords += length_words

# Passwords based of words with one or two numbers appended on the end
#length_words.each do |word|
#  word.capitalize!
#  (0..9).to_a.each do |n1|
#    passwords.push("#{word}#{n1}")
#    (0..9).to_a.each do |n2|
#      passwords.push("#{word}#{n1}#{n2}")
#    end
#  end
#end

# Passwords based on books, chapters, and verses (with and without colons)
json.keys.each do |book|
  json[book].keys.each do |chapter|
    json[book][chapter].keys.each do |verse|
      # With colon
      passwords.push("#{book}#{chapter}:#{verse}")
      # Without colon
      passwords.push("#{book}#{chapter}#{verse}")
    end
  end
end

# Format the array into a string list - one word per line - and write the passwords to a file in that format
# Also ensure there are no duplicates which would have been created
passwords = passwords.uniq
passwords = passwords.join("\n")
passwords_file.write(passwords)
passwords_file.close

end
