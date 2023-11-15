require "json"

buf = Bytes.new(4)
STDIN.read(buf)
buf.each do |c|
  puts "c = #{c}"
end
len : Int32 = 0
[3,2,1,0].each do |i|
  x : Int32 = buf[i].to_i32
  len = (len << 8) + x
end
printf("%x\n", len)
slice = Bytes.new(len)
STDIN.read(slice)
jsonbuf = String.new(slice)
puts "jsonbuf = #{jsonbuf}"
values = Hash(String, String | Array(String)).from_json(jsonbuf)
#values = JSON.parse(jsonbuf)
values.each do |k,v|
  puts "key = #{k}, value = #{v}, value type = #{typeof(v)}"
  if k == "args"
    a = v.as(Array(String))
    puts "v is an array of strings"
    a.each {|s| puts "arg: #{s}"}
  else
    puts "v is a string"
  end
end

editor = values["editor"].as(String)
args = values["args"].as(Array(String))
ext = values["ext"].as(String)
if ext != ""
  suffix = "." + ext
else
  suffix = nil
end
tempfile = File.tempfile("beectl-", suffix)
temppath = tempfile.path
puts "Created temp file #{temppath}"

cmd = String.build do |cmd|
  cmd << editor
  args.each do |arg|
    cmd << " " + arg
  end
  cmd << " " + temppath
end

puts "cmd = #{cmd}"
system(cmd)

content = File.read(temppath)
puts "Contents of tempfile:"
puts content

puts "Deleting #{temppath}"
tempfile.delete

#values["args"].each do |arg|
#  cmd << " " + arg
#end
#if values["ext"]
#  cmd << " ." + values["ext"]
#end
#puts "cmd = #{cmd}"
