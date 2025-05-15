# This the main program for beeectl.

require "./beedefs"

begin
  Beectl.main
rescue ex
  Beectl.dprint "Oh crap!  An exception occurred!"
  Beectl.dprint ex.inspect_with_backtrace
end

