# beectl - Crystal implementation of Browser's External Editor host program
# See source for the browser extension and host program in Python here:
#  https://github.com/rosmanov/chrome-bee
# See source for the C implementation of the host program here:
#  https://github.com/rosmanov/bee-host

require "json"

DEBUG = false

module Beectl

  extend self

  def dprint(s)
    puts s if DEBUG
  end

  # Read a 32-bit little-endian integer from the file.
  # In perl or python we could do this with an unpack one-liner.

  def read_length(file : IO)
    buf = Bytes.new(4)
    file.read(buf)
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

  # Read a message consisting of a 32-bit little-endian length,
  # followed by a JSON string of that length.  Convert the JSON
  # string to Hash and return it.

  def read_hash(file : IO)
    len = read_length(file)
    if len > 1000
      jsonbuf = %({"error":"length #{len}"})
    else
      slice = Bytes.new(len)
      file.read(slice)
      jsonbuf = String.new(slice)
    end
    dprint "jsonbuf = #{jsonbuf}"
    return JSON.parse(jsonbuf)
  end

  # Write a 32-bit little-endian integer to the file.
  # In perl or python we could do this with a pack one-liner.

  def write_length(file : IO, len)
    buf = Bytes.new(4)
    [0,1,2,3].each do |i|
      buf[i] = len.to_u8
      len >>= 8
    end
    file.write(buf)
  end

  # Convert a hash of values to a JSON string, and write the length
  # of the JSON string as a 32-bit little-endian integer, followed
  # by the JSON string itself.

  def write_hash(file : IO, values)
    response = values.to_json
    dprint "response = #{response}"
    len = response.bytesize
    write_length(file, len)
    file << response
  end

  def main
    # Read the JSON request, convert it to a hash and extract
    # its values.
    values = read_hash(STDIN)
    editor = values["editor"].as_s
    args = values["args"].as_a
    ext = values["ext"].as_s
    text = values["text"].as_s

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
	cmd << " " + arg.as_s
      end
      cmd << " " + temppath
    end
    dprint "cmd = #{cmd}"
    system(cmd)

    # Read the contents of the temporary file and write it
    # out in JSON form as the response.
    content = File.read(temppath)
    dprint "Contents of tempfile:"
    dprint content
    response = {"text" => content}
    write_hash(STDOUT, response)

    # Delete the temporary file.
    dprint "Deleting #{temppath}"
    tempfile.delete
  end
end	# module Beectl
