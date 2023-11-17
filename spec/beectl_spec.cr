require "./spec_helper"
require "../src/beedefs"

describe Beectl do
  it "simulates the browser extension" do
    File.exists?("./beectl").should eq(true)
    pipe = Process.new("./beectl",
		       input: Process::Redirect::Pipe,
		       output: Process::Redirect::Pipe)

    request = Hash(String, String | Array(String)){
              "editor" => "./editor.sh",
	        "args" => [] of String,
	        "ext" => "txt",
	        "text" => "This is a test.\n"}
    Beectl.write_hash(pipe.input, request)
    pipe.input.close

    values = Beectl.read_hash(pipe.output)
    text = values["text"].as(String)
    text.should eq("This is a test.\nThis is another test.\n")

    pipe.wait
  end
end
