=begin

Copyright 2010-2019, Alexander C. Schreyer
All rights reserved

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.

License:        GPL (http://www.gnu.org/licenses/gpl.html)

Author :        Alexander Schreyer, www.alexschreyer.net, mail@alexschreyer.net
Website:        http://www.alexschreyer.net/projects/sketchup-ruby-code-editor

Name :          Ruby Code Editor
Version:        4.2
Date :          9/5/2019

Description :   Adds a Ruby code editor to the SketchUp WINDOWS menu. This code editor allows
                writing and modifying Ruby (and other) scripts within SketchUp.
                These scripts can be used to create geometry, add functionality or add
                data within the SketchUp 3D modeling environment.

Usage :         Just click on the menu item and edit away. See website for details.

History:        1.0 (2/3/2010):
                    - first version
                1.1 (2/22/2010):
                    - Changed webdialog internal name for compatibility
                    - Better looking dropdowns under IE Win
                    - Fixed save filename preselect problem
                    - Better code execution and error catching (thanks to Dan Rathbun)
                    - Faster file loading for large files
                    - Added cookie-based saving of preferences (expires after 365 days)
                    - Added changeable user interface
                    - Modified some references
                1.1.1 (2/25/2010):
                    - Safari-related fixes (cookies, text insert, removed back button)
                1.1.2 (3/8/2010)
                    - Removed nav buttons also for IE because they disabled execution after a while
                    - Renamed some code elements
                    - Added wrapper module
                1.2 (4/13/2010)
                    - Updated jQuery UI to v. 1.8
                    - Added object explorer button to show current selection details
                    - Added attribute explorer button for selection attributes
                    - Added button to show Ruby console
                    - Modified code a bit
                    - Changed buttons to images for space reasons
                    - Fixed keyboard access (Alt+...)
                    - Added pages to browser: Edges to Rubies, Ruby core and Google search
                    - Added basic update checking
                    - Enabled browser buttons again - except for Safari
                    - Waiting icon shown while code executes
                2.0 (4/12/2011)
                    - Switched editor to use CodeMirror - sooo much better!
                    - Added code coloring for several languages (Ruby, HTML, CSS, JavaScript, XML, C/Java)
                    - Can handle large files easily
                    - Added bracket matching
                    - Added coloring changer
                    - Disabling run button if code is not Ruby
                    - Added some more options
                    - Added option to disable single undo
                    - Added color coding for SU classes
                    - Fixed problem with loading/saving slashes in files
                    - Updated jQuery and jQuery UI
                    - Results window is now continuous and scrolls
                    - Added some more code snippets to dropdown
                    - Added toolbar item
                    - Moved menu item to "Windows" menu
                    - Added settings file for modifications
                    - Added code printing
                 2.1 (2/26/2013)
                    - Uses most recently used directory for file loading and saving
                    - Fixed the outdated URLs in the browser
                    - Update checking now uses www.sketchupplugins.com
                 3.0 (3/4/2013):
                    - Got rid of settings file
                    - Results feedback now wrapped in Paragraph
                    - Improved feedback scrolling
                    - Some CSS changes, separated CSS by theme
                    - Two editor themes now: ambiance and eclipse
                    - Updated Codemirror to 3.1
                    - Updated jQuery
                    - Updated jQuery UI
                    - Improved editor stability, smoother scrolling
                    - Set IE version number to 9 (allows for more features and better display)
                    - Fixed SU class highlighting and added SU method highlighting
                    - Added syntax highlighting for SketchUp classes and methods
                    - Better editor closing handling
                    - Changed some options for newer Codemirror
                    - Fixed theme color options
                    - Better error display
                    - Fixed Mac rendering of results window
                    - Fixed Mac default folder issue
                  3.1 (3/6/2013)
                    - Fixed default file bug
                    - Updated jQuery cookie plugin
                    - Fixed Tab problem
                    - Minor fix: results window text wrap and editor refresh
                    - Proper markClean handling
                  3.2 (4/25/2013)
                    - Reorganized files and folders
                  4.0 (7/10/2017)
                    - Code cleanup
                    - Updated jQuery, jQueryUI, codemirror
                    - Updated styles
                    - Updated code snippets
                    - New menu and tab UI
                    - Ref browser and help windows use HtmlDialog now, also separate windows
                    - Fixed loading code
                    - Fixed recent file bug. Opens in current folder now
                    - Fixed printing
                    - Fixed preferences
                    - Fixed eval binding to be top level (like the Ruby Console)
                    - Made line wrapping default
                    - Added preloading of optional $LIBRARY_PATH items from preferences
                    - Added MRU file list
                    - Added quick save option
                    - Added undo/redo
                    - Added find/replace
                    - Added code folding
                    - Added ability to edit default code
                    - Added help window (link to website)
                    - Improved keyboard shortcuts
                    - Improved reference browser, updated links
                  4.1 (7/18/2017)
                    - Resubmission to fix EW signing issue
                    - Minor fixes and edits
                    - Fixed selection reporting
                    - Separated selection menu
                    - Created new SVG icons
                    - Added definition attribute reporting
                    - Added inserting of IDs
                    - Added more menu tooltips
                  4.2 (9/5/2019)
                    - Fixed .to_l nil comparison issue
                    - Added some backcomp fixes (works down to SU8)
                    - Error handling for invalid filetypes
                    - Fixes $LOAD_PATH inclusion, now at execution
                    - Adds proper filetype selectors to open dialog
                  4.3 (TBD)
                    - Ruby working dir changes on load/save know
                    - Menu item to open plugin folder



To-Do List:       - Add line wrapping as option
                  - Improve SketchUp autocomplete
                  - Move settings into SU defaults instead of cookies
                  - Multi-document environment


Isues:


=================================================================

This plugin was originally based on Jim Foz's Web Console:

Copyright (C) 2006 jim.foltz@gmail.com

This software is free to use, copy, modify and disribute, but
if you do, I'd like to know about it. This software comes with no warranty.

=================================================================

This plugin uses CodeMirror 5.27.4:
http://codemirror.net/

MIT License

Copyright (C) 2017 by Marijn Haverbeke <marijnh@gmail.com> and others

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=================================================================

This plugin uses the jQuery cookie plugin:
https://github.com/carhartl/jquery-cookie

Copyright 2013 Klaus Hartl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=================================================================

This plugin uses the jQuery and jQuery UI:
https://jqueryui.com/

Copyright jQuery Foundation and other contributors, https://jquery.org/

This software consists of voluntary contributions made by many
individuals. For exact contribution history, see the revision history
available at https://github.com/jquery/jquery-ui

The following license applies to all parts of this software except as
documented below:

====

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

====

Copyright and related rights for sample code are waived via CC0. Sample
code is defined as all source code contained within the demos directory.

CC0: http://creativecommons.org/publicdomain/zero/1.0/


=end


# ========================


require 'sketchup.rb'
require 'extensions.rb'


# ========================


module AS_Extensions

  module AS_RubyEditor

    EXTVERSION            = "4.2"
    EXTTITLE              = "Ruby Code Editor"
    EXTNAME               = "as_rubyeditor"
    EXTDESCRIPTION        = "This code editor simplifies writing and modifying Ruby (and other) scripts within SketchUp. These scripts can be used to create geometry, add functionality or add data within the SketchUp 3D modeling environment."

    @extdir = File.dirname(__FILE__).gsub(%r{//}) { "/" }
    @extdir.force_encoding('UTF-8') if @extdir.respond_to?(:force_encoding)
    EXTDIR = @extdir

    loader = File.join( EXTDIR , EXTNAME , "as_rubyeditor.rb" )

    extension             = SketchupExtension.new( EXTTITLE , loader )
    extension.copyright   = "Copyright 2010-#{Time.now.year} Alexander C. Schreyer"
    extension.creator     = "Alexander C. Schreyer, www.alexschreyer.net"
    extension.version     = EXTVERSION
    extension.description = EXTDESCRIPTION

    Sketchup.register_extension( extension , true )

  end  # module AS_RubyEditor

end  # module AS_Extensions


# ========================
