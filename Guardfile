guard 'shell' do
 watch('^Source/(.*).coffee') {|m| `./build` }
end
guard 'shell' do
 watch(/^Specs\/(.*).coffee/) do |m|
   puts m
   puts File.read(m)
   ``
 end
end
