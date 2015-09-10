Wordnik.configure do |config|
  config.api_key = 'effc8492139608ff233c81d1ee507090d9d8bea27f994736c'               # required
  config.username = 'Simplarity'                    # optional, but needed for user-related functions
  config.password = '12345678'               # optional, but needed for user-related functions
  config.response_format = 'json'             # defaults to json, but xml is also supported
  config.logger = Logger.new(RUBY_PLATFORM != 'i386-mingw32' ? '/dev/null' : 'NUL')    # defaults to Rails.logger or Logger.new(STDOUT). Set to Logger.new('/dev/null') to disable logging.
end