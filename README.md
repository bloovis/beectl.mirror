# beectl - Crystal implementation of host program for Browser's External Editor

(*Note*: If you are reading this on Github, you can find the
original Fossil repository [here](https://www.bloovis.com/fossil/home/marka/fossils/beectl/home)).

[Browser's External Editor](https://github.com/rosmanov/chrome-bee),
aka chrome-bee, is a browser extension by Ruslan Osmanov that allows you to use an external
editor to edit text areas in browser forms.  It communicates with a
host program called beectl that runs the editor and returns the edited
text.  The chrome-bee repository linked to above provides a Python
implementation of the host program, and there is also a separate [C
implementation](https://github.com/rosmanov/bee-host).

This Crystal implementation of beectl requires only an installation of
the [Crystal compiler](https://crystal-lang.org/), and has no other dependencies.

## Installation

To clone this repository:

```
fossil clone https://www.bloovis.com/fossil/home/marka/fossils/beectl
```

Build the program with either:

```
make
```

or:

```
crystal build --no-color src/beectl.cr
```

To make browser configuration a little simpler, I chose to copy
the resulting binary file `beectl` to `/usr/local/bin`:

    sudo cp beectl /usr/local/bin

## Install the browser extension

Install the "Browser's External Editor" extension in Chrome or
Firefox, using the normal sources for extensions.  Then
in the settings page for the extension, make the following
changes:

* Set the full path to your editor.
* Optionally, set some regular expressions and file extensions for specific
sites.  This isn't strictly necessary; I suspect it is only useful for
editors that change their behavior based on file
extensions (e.g., EMACS modes).

Now you have to create a native messaging manifest file for
your browser, and also set a shortcut key.

### Ungoogled Chromium and Brave

For Ungoogled Chromium, the directory where the manifest file will be located is:

```
$HOME/.config/chromium/NativeMessagingHosts
```

For Brave, the full path of the manifest file directory is:

```
$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts
```

Create this directory it does not already exist.  Then in that directory, create the file
`com.ruslan_osmanov.bee.json` with the following contents:

```
{
   "allowed_origins" : [
      "chrome-extension://haenebhcepllcpneciadjchacagagfkc/",
      "chrome-extension://moakhilhbeednkjahjmomncgigcoemoi/",
      "chrome-extension://hpjfedijojbkggipmcnoadekibdpcjde/"
   ],
   "description" : "Bee - Browser's external editor",
   "name" : "com.ruslan_osmanov.bee",
   "path" : "/usr/local/bin/beectl",
   "type" : "stdio"
}
```

The ID in the third `chrome-extension` setting is the one I had to use for ungoogled-chromium.
You can find the exact ID for your installation of the chrome-bee extension
by going to your browser's extension settings and copying the ID you see there.

Only the second `chrome-extension` line is necessary for Brave; the
ID is identical to the ID in beectl's URL in the Chrome Web Store.
The first and third lines aren't necessary, but leaving them in does no harm.


Replace the value for the `path` setting with the correct
path to `beectl`.

Finally, you will need to set the keyboard shortcut that will invoke the external
editor.  Visit `chrome://extensions/shortcuts` in chromium/chrome, or
`brave://extensions/shortcuts` in Brave.  Then
set the shorcut for Browser's External Editor.  I used `Alt-E` to avoid conflict
with `Ctrl-E`, which is used for editing in entry fields.

### Firefox

The full path of the manifest file is:

```
$HOME/.mozilla/native-messaging-hosts/com.ruslan_osmanov.bee.json
```

Create the directory `$HOME/.mozilla/native-messaging-hosts` if
it does not already exist.  Then in that directory, create the file
`com.ruslan_osmanov.bee.json` with the following contents:

```
{
  "name": "com.ruslan_osmanov.bee",
  "description": "Bee - Browser's external editor",
  "path": "/usr/local/bin/beectl",
  "type": "stdio",
  "allowed_extensions": [
     "bee@ruslan_osmanov.com"
  ]
}
```

Replace the value for the `path` setting with the correct
path to `beectl`.

Finally, you will need to set the keyboard shortcut that will invoke the external
editor.  In the settings page for the extension, click on the gear icon
at the upper right corner of the settings, and select Manage Extension Shortcuts.
I used `Ctrl-7` to avoid conflict with the numerous existing shortcuts
for Firefox and the other extensions I use.

## Testing

There is a simple spec test that simulates how the browser runs
beectl.  Run the test using:

```
make test
```

or

```
crystal spec --no-color
```
