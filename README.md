# beectl - Crystal implementation of host program for Browser's External Editor

[Browser's External Editor](https://github.com/rosmanov/chrome-bee),
aka chrome-bee, is a browser extension by Ruslan Osmanov that allows you to use an external
editor to edit text areas in browser forms.  It communicates with a
host program called beectl that runs the editor and returns the edited
text.  The chrome-bee repository linked to above provides a Python
implementation of the host program, and there is a also separate [C
implementation](https://github.com/rosmanov/bee-host).

This Crystal implementation of beectl requires only an installation of
the [Crystal compiler](https://crystal-lang.org/), and has no other dependencies.

## Installation

Build the program with either:

    make

or:

    crystal build --no-color src/beectl.cr

Once this is built, resulting in a `beectl` binary, you must do some additional
configuration for Chrome-based browsers,
as described in the [BEE Wiki](https://github.com/rosmanov/chrome-bee/wiki/Configuration-in-Chrome).
Note that the procedure described there installs a file `com.ruslan_osmanov.bee.json`
in the `NativeMessageHosts` configuration directory for your browser, and that
only Chrome and Firefox are supported.  I use the
[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) browser,
and I had to create a modified file
`$HOME/.config/chromium/NativeMessagingHosts/com.ruslan_osmanov.bee.json`
that looks like this:

    {
       "allowed_origins" : [
          "chrome-extension://haenebhcepllcpneciadjchacagagfkc/",
          "chrome-extension://moakhilhbeednkjahjmomncgigcoemoi/",
          "chrome-extension://hpjfedijojbkggipmcnoadekibdpcjde/"
       ],
       "description" : "Bee - Browser's external editor",
       "name" : "com.ruslan_osmanov.bee",
       "path" : "/home/path-to-beectl/beectl",
       "type" : "stdio"
}

The ID in third `chrome-extension` setting is the one I had to use for ungoogled-chromium.
You can find the exact ID for your installation of the chrome-bee extension
by going to your browser's extension settings and copying the ID you see there.

You will also need to change the `path` setting to point to the actual location
of the compiled `beectl` program.

Finally, you will need to set the keyboard shortcut that will invoke the external
editor.  Visit this URL in chromium/Chrome: <chrome://extensions/shortcuts>.  Then
set the shorcut for Browser's External Editor.  I used Alt-E to avoid conflict
with Ctrl-E, which is used for editing in entry fields.

I have not tried to use chrome-bee or beectl in any browser other than
ungoogled-chromium.

## Testing.

There is a simple spec test that simulates how the browser runs
beectl.  Run the test using:

    make test

or

    crystal spec --no-color
