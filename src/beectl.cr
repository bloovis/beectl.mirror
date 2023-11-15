require "json"

DEBUG = false

def dprint(s)
  puts s if DEBUG
end

def read_length
  buf = Bytes.new(4)
  STDIN.read(buf)
  buf.each do |c|
    dprint "c = #{c}"
  end
  len : Int32 = 0
  [3,2,1,0].each do |i|
    x : Int32 = buf[i].to_i32
    len = (len << 8) + x
  end
  dprint(sprintf("%x\n", len))
  return len
end

def write_length(len)
  buf = Bytes.new(4)
  [0,1,2,3].each do |i|
    buf[i] = len.to_u8
    len >>= 8
  end
  STDOUT.write(buf)
end

len = read_length
slice = Bytes.new(len)
STDIN.read(slice)
jsonbuf = String.new(slice)
dprint "jsonbuf = #{jsonbuf}"
values = Hash(String, String | Array(String)).from_json(jsonbuf)
values.each do |k,v|
  dprint "key = #{k}, value = #{v}, value type = #{typeof(v)}"
  if k == "args"
    a = v.as(Array(String))
    dprint "v is an array of strings"
    a.each {|s| dprint "arg: #{s}"}
  else
    dprint "v is a string"
  end
end

editor = values["editor"].as(String)
args = values["args"].as(Array(String))
ext = values["ext"].as(String)
text = values["text"].as(String)

if ext != ""
  suffix = "." + ext
else
  suffix = nil
end
tempfile = File.tempfile("beectl-", suffix)
temppath = tempfile.path
tempfile << text
tempfile.close
dprint "Created temp file #{temppath}"

cmd = String.build do |cmd|
  cmd << editor
  args.each do |arg|
    cmd << " " + arg
  end
  cmd << " " + temppath
end

dprint "cmd = #{cmd}"
system(cmd)

content = File.read(temppath)
dprint "Contents of tempfile:"
dprint content

response = JSON.build do |json|
  json.object do
    json.field "text", content
  end
end

dprint "response = #{response}"
len = response.bytesize

write_length(len)
STDOUT << response

dprint "Deleting #{temppath}"
tempfile.delete

#values["args"].each do |arg|
#  cmd << " " + arg
#end
#if values["ext"]
#  cmd << " ." + values["ext"]
#end
#puts "cmd = #{cmd}"
