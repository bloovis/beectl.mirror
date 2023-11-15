# beectl - Crystal implementation of Browser's External Editor host program
# See source for the browser extension and host program in Python here:
#  https://github.com/rosmanov/chrome-bee
# See source for the C implementation of the host program here:
#  https://github.com/rosmanov/bee-host

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

def read_request
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
  return values
end

def write_length(len)
  buf = Bytes.new(4)
  [0,1,2,3].each do |i|
    buf[i] = len.to_u8
    len >>= 8
  end
  STDOUT.write(buf)
end

def write_response(content)
  response = JSON.build do |json|
    json.object do
      json.field "text", content
    end
  end

  dprint "response = #{response}"
  len = response.bytesize

  write_length(len)
  STDOUT << response
end

def main
  # Read the JSON requestion, convert it to a hash and extract
  # its values.
  values = read_request
  editor = values["editor"].as(String)
  args = values["args"].as(Array(String))
  ext = values["ext"].as(String)
  text = values["text"].as(String)

  # If a file suffix was specified, prepend it with a '.'; otherwise
  # don't use a suffix.
  if ext != ""
    suffix = "." + ext
  else
    suffix = nil
  end

  # Create a temporary file and write the specified text to it.
  tempfile = File.tempfile("beectl-", suffix)
  temppath = tempfile.path
  tempfile << text
  tempfile.close
  dprint "Created temp file #{temppath}"

  # Construct the editor command and run it.
  cmd = String.build do |cmd|
    cmd << editor
    args.each do |arg|
      cmd << " " + arg
    end
    cmd << " " + temppath
  end
  dprint "cmd = #{cmd}"
  system(cmd)

  # Read the contents of the temporary file and write it
  # out in JSON formation as the response.
  content = File.read(temppath)
  dprint "Contents of tempfile:"
  dprint content
  write_response(content)

  # Delete the temporary file.
  dprint "Deleting #{temppath}"
  tempfile.delete
end

main
