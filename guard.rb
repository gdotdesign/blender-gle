require 'rubygems'
require 'rb-inotify'
notifier = INotify::Notifier.new
notifier.watch("Specs/Buttons", :modify) do |event|
  puts event.inspect
  puts "foo.txt was modified!"
end
notifier.run
