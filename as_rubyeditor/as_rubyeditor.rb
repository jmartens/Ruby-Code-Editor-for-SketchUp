# =========================
# Main file for Ruby Code Editor
#
# by Alexander Schreyer, www.alexschreyer.net, mail@alexschreyer.net
#
# DO NOT EDIT THIS FILE IN THE RUBY CODE EDITOR, IT WILL STRIP SOME OF THE CODE!!!
# =========================


require 'sketchup.rb'


## =====================


module AS_Extensions

  module AS_RubyEditor


    # Creates new class
    class RubyEditor < UI::WebDialog


        # Initialize class and callbacks
        def initialize


          ## =====================

          ## Set some variables

          # Get this file's directory w/ backcomp for "//" in file path
          @base_dir = File.dirname(__FILE__).gsub(%r{//}) { "/" }

          # Get user directory
          @user_dir = (ENV['USERPROFILE'] != nil) ? ENV['USERPROFILE'] :
            ((ENV['HOME'] != nil) ? ENV['HOME'] : @base_dir )

          # Get working directory from last file - set to user directory otherwise
          @last_file = Sketchup.read_default "as_RubyCodeEditor", "last_file"
          @last_file != nil ? @snip_dir = File.dirname(@last_file) : @snip_dir = @user_dir


          ## =====================

          ## Set up the WebDialog interface

          # Dialog parameters
          super "Ruby Code Editor", false, "RubyCodeEditor", 750, 600, 100, 100, true

          # Set HTML UI file for WebDialog
          ui_loc = File.join( @base_dir , "ui.html" )
          set_file( ui_loc )
          navigation_buttons_enabled = false
          min_width = 500
          min_height = 500


          ## =====================

          ## Show the dialog and run the new routine

          show do

            # Set version number in about dlg
            execute_script("var rceVersion = #{AS_RubyEditor::EXTVERSION.to_s}")
            execute_script("$('#version').text( rceVersion )")

            Sketchup.status_text = "#{AS_RubyEditor::EXTTITLE} | Welcome!"

          end  # show


          ## =====================

          ## Offer a save when dialog closes

          set_on_close do

            # Some feedback
            execute_script("addResults('Closing editor...')")

            # Handling closing confirmation in RB rather than JS
            r = UI.messagebox "Save this file before quitting?", MB_YESNO

            if r == 6 then

              execute_script("cb_save()")

            end

            Sketchup.status_text = "#{AS_RubyEditor::EXTTITLE} | Bye!"

          end  # set_on_close


          ## =====================

          ## Callback to CLEAR (NEW) editor

          add_action_callback("new") do |dlg, params|

            # Get initial code snippet - load from file
            loadcode = File.readlines(File.join( AS_RubyEditor::EXTDIR , 'as_rubyeditor' , 'templates' , 'default.rb' ))
            # Fix newlines so that they are preserved
            loadcode.each{ |i| i.gsub!(/\n/, '') }
            @initCode = loadcode.join('\n')

            # Send initial code to editor. Use only single quotes here to preserve newlines!
            script = 'editor.getDoc().setValue(\''+@initCode+'\')'
            dlg.execute_script(script)

            # Update new file names in editor
            dlg.execute_script("$('#save_name').val('untitled.rb')")
            dlg.execute_script("$('#file_name').text('untitled.rb')")
            dlg.execute_script("$('#save_filepath').val('')")

            # Reset the editor after loading
            dlg.execute_script("editor.scrollTo(0,0)")
            dlg.execute_script("addResults('Cleared the editor')")
            dlg.execute_script("editor.markClean()")
            dlg.execute_script("editor.getDoc().clearHistory()")

            # Update the MRU list (from SU prefs)
            # ... Load current MRU
            mru = []
            (1..5).each { |i|
               mru.push Sketchup.read_default("as_RubyCodeEditor", "mru#{i}", "" )
            }
            dlg.execute_script("updateMRU( '#{mru[0]}' , '#{mru[1]}' , '#{mru[2]}' , '#{mru[3]}' , '#{mru[4]}' )")

          end  # add_action_callback("new")


          ## =====================

          ## Callback to LOAD (OPEN) a file into the editor

          add_action_callback("load") do |dlg, params|

            # Get filename (dialog, parameter, default)
            case params
              when 'undefined'  # No parameter supplied
                file = UI.openpanel("Open File", @snip_dir, "Ruby Files|*.rb|All Files|*.*||")
              when 'default'  # Parameter "default" opens default file
                file = File.join( AS_RubyEditor::EXTDIR , 'as_rubyeditor' , 'templates' , 'default.rb' )
              else  # File and path has been supplied by parameter
                file = params
            end

            if not File.exist?(file)
              UI.messagebox "Cannot load #{File.basename(file).to_s}. This file doesn't exist (here)."
              return
            elsif not file
              UI.messagebox "No valid file selected."
              return
            end

            begin

              # Fix slashes for Windows
              file.tr!("\\","/")

              # Set file directory as current and get file details
              @snip_dir = File.dirname(file)
              Dir.chdir( @snip_dir )
              name = File.basename(file)
              extension = File.extname(file)

              # Read text from file
              f = File.new(file,"r")
              text = f.readlines.join

              # Load text into editor by encoding some parts in RB and unencoding in JS:
              # ... Encode backward slashes and single quotes in Ruby
              text.gsub!('\\', "<84JSed>")
              text.gsub!('\'', "<25SKxw>")
              text.gsub!(/\n/, "\\n")
              text.gsub!(/\r/, "\\r")
              text.gsub!(/'\'/, '\\')
              # ... Load text into variable in JS and unencode the slashes and quotes
              dlg.execute_script("tmp = '#{text}'")
              dlg.execute_script("tmp = tmp.replace(/<84JSed>/g,'\\\\')")
              dlg.execute_script("tmp = tmp.replace(/<25SKxw>/g,'\\'')")
              script = 'editor.setValue(tmp)'
              dlg.execute_script(script)

              # Reset the editor after loading
              dlg.execute_script("editor.scrollTo(0,0)")
              dlg.execute_script("addResults('File loaded: #{name}')")
              dlg.execute_script("editor.markClean()")
              dlg.execute_script("editor.getDoc().clearHistory()")

              # Update new file names in editor
              dlg.execute_script("$('#save_name').val('#{name}')")
              dlg.execute_script("$('#file_name').text('#{name}')")
              dlg.execute_script("$('#save_filepath').val('#{file}')")

              # Update the MRU list (from SU prefs)
              # ... Load current MRU
              mru = []
              (1..5).each { |i|
                 mru.push Sketchup.read_default("as_RubyCodeEditor", "mru#{i}", "" )
              }
              # ... Don't update if file is already in there
              if not mru.include?(file)
                (5).downto(2) { |i|
                  Sketchup.write_default("as_RubyCodeEditor", "mru#{i}", mru[i-2].to_s )
                }
                Sketchup.write_default("as_RubyCodeEditor", "mru1", file )
              end
              # ... Write new MRU to editor menu
              dlg.execute_script("updateMRU( '#{mru[0]}' , '#{mru[1]}' , '#{mru[2]}' , '#{mru[3]}' , '#{mru[4]}' )")
              # ... Make a note of the last file (not necessarily mru1)
              Sketchup.write_default "as_RubyCodeEditor", "last_file", file

            rescue Exception => e

              UI.messagebox "Cannot open #{File.basename(file).to_s}. \n\nError: #{e}"

            end

          end  # add_action_callback("load")


          ## =====================

          ## Callback to SAVE / SAVE AS a file (and create a backup)

          add_action_callback("save") do |dlg, params|

            # Extract all parameters
            params = params.split(',')

            # Get current filename from hidden inputs
            filename = dlg.get_element_value("save_name")

            # Get filename
            if params[1] == 'true' or dlg.get_element_value("save_filepath") == ""
              file = UI.savepanel("Save File", @snip_dir, filename)  # Allow to change save file in dialog
            else
              file = dlg.get_element_value("save_filepath")  # Get existing filename from hidden field
            end
            return if file.nil?
            file.tr!("\\","/")  # Fix slashes for Windows

            # Set file directory as current and get file details
            @snip_dir = File.dirname(file)
            Dir.chdir( @snip_dir )
            extension = File.extname(file)
            # Add RB extension if nothing is there
            file = file+".rb" if extension == ""
            name = File.basename(file)

            # Get text from editor and clean it up
            str = dlg.get_element_value("console")
            str.gsub!(/\r\n/, "\n")

            # Copy current file to backup if file already exists
            if File.exist?(file) and params[0] == 'true'
              f = File.new(file,"r")
              oldfile = f.readlines
              File.open(file+".bak", "w") { |f| f.puts oldfile }
            end

            # Write text to file
            File.open(file, "w") { |f| f.puts str }

            # Update new file names in editor
            dlg.execute_script("$('#save_name').text('#{name}')")
            dlg.execute_script("$('#file_name').text('#{name}')")
            dlg.execute_script("$('#save_filepath').val('#{file}')")

            # Reset the editor
            dlg.execute_script("editor.markClean()")
            dlg.execute_script("addResults('File saved: #{name}')")

            # Update the MRU list (from SU prefs)
            # ... Load current MRU
            mru = []
            (1..5).each { |i|
               mru.push Sketchup.read_default("as_RubyCodeEditor", "mru#{i}", "" )
            }
            # ... Don't update if file is already in there
            if not mru.include?(file)
              (5).downto(2) { |i|
                Sketchup.write_default("as_RubyCodeEditor", "mru#{i}", mru[i-2].to_s )
              }
              Sketchup.write_default("as_RubyCodeEditor", "mru1", file )
            end
            # ... Write new MRU to editor menu
            dlg.execute_script("updateMRU( '#{mru[0]}' , '#{mru[1]}' , '#{mru[2]}' , '#{mru[3]}' , '#{mru[4]}' )")
            # ... Make a note of the last file (not necessarily mru1)
            Sketchup.write_default "as_RubyCodeEditor", "last_file", file

          end  # add_action_callback("save")


          ## =====================

          ## Callback to EXECUTE Ruby code in SketchUp

          add_action_callback("exec") do |dlg, params|

            # Provide some status text
            dlg.execute_script( "addResults('Running the code...')" )
            Sketchup.status_text = "#{AS_RubyEditor::EXTTITLE} | Running the code..."

            # Add some paths to loadpath variable (if those are supplied)
            lp1 = get_element_value("loadpath1")
            lp2 = get_element_value("loadpath2")
            if not lp1.empty?
              lp1 = File.expand_path(lp1)
              $LOAD_PATH << lp1 unless $LOAD_PATH.include? lp1
            end
            if not lp2.empty?
              lp2 = File.expand_path(lp2)
              $LOAD_PATH << lp2 unless $LOAD_PATH.include? lp2
            end

            # Get the code from the editor and encode it
            v = dlg.get_element_value('console').strip
            # ... Force encoding for non-UTF text (e.g. in China) w/ backcomp
            v.force_encoding('UTF-8') if v.respond_to?(:force_encoding)

            # Execute the code with eval and rescue if error
            reason = nil
            begin
              # ... Wrap everything in single undo if desired
              Sketchup.active_model.start_operation "RCE Code Run" if params == 'true'
              eval( v , TOPLEVEL_BINDING )
            rescue ScriptError, StandardError => e# ... If error
              Sketchup.active_model.abort_operation
              reason = 'Run aborted. Error: ' + e.to_s
            else  # ... Commit process if no errors
              Sketchup.active_model.commit_operation if params == 'true'
            ensure  # ... Always do this
              unless reason.nil?
                p reason  # ... Also return result to console
                # ... Format for HTML box
                reason.gsub!(/ /, "&nbsp;")
                reason.gsub!(/'/, "&rsquo;")
                reason.gsub!(/`/, "&lsquo;")
                reason.gsub!(/</, "&lt;")
                reason.gsub!(/\\n/, "<br>")

                # Provide some status text and return result
                dlg.execute_script("addResults('Done running code. Ruby says: <span class=\\'hl\\'>#{reason}</span>')")
              end
                Sketchup.status_text = "#{AS_RubyEditor::EXTTITLE} | Done running code"

            end

          end  # add_action_callback("exec")


          ## =====================

          ## Callback to CLOSE the dialog

          add_action_callback("quit") do |dlg, params|

            dlg.close

          end  # add_action_callback("quit")


          ## =====================

          ## Callback to UNDO the last grouped code execution

          add_action_callback("undo") do |dlg, params|

            Sketchup.undo

            dlg.execute_script("addResults('Last step undone')")
            Sketchup.status_text = "#{AS_RubyEditor::EXTTITLE} | Last step undone"

          end  # add_action_callback("undo")


          ## =====================

          ## Callback to EXPLORE current SELECTION

          add_action_callback("sel_explore") do |dlg, params|

            sel = Sketchup.active_model.selection

            mes = ""
            mes += "#{sel.length} "
            mes += sel.length == 1 ? "entity" : "entities"
            mes += " selected\n\n"

            sel.each { |e|

              # Show useful properties
              mes += "Entity: #{e.to_s}\n"
              mes += "Type: #{e.typename}\n"
              mes += "ID: #{e.entityID}\n"
              mes += "Persistent ID: #{e.persistent_id}\n" if Sketchup.version.to_f >= 17
              mes += "Layer: #{e.layer.name}\n"
              mes += "Center location (x,y,z): #{e.bounds.center}\n"
              size = e.bounds.max - e.bounds.min
              mes += "Size (x,y,z): #{size}\n"
              mes += "Definition name: #{e.definition.name}\n" if e.is_a? Sketchup::ComponentInstance
              mes += "Parent: #{e.parent}\n"

              mes += "\n"

            }

            UI.messagebox mes , MB_MULTILINE, "List Current Selection's Properties"

          end  # add_action_callback("sel_explore")


          ## =====================

          ## Callback to EXPLORE current selection's ATTRIBUTES

          add_action_callback("att_explore") do |dlg, params|

            sel = Sketchup.active_model.selection

            mes = ""
            mes += "#{sel.length} "
            mes += sel.length == 1 ? "entity" : "entities"
            mes += " selected\n\n"

            sel.each { |e|

              mes += "Entity: #{e.to_s}\n"
              mes += "ID: #{e.entityID}\n"
              mes += "Persistent ID: #{e.persistent_id}\n" if Sketchup.version.to_f >= 17

              # Check for entity attributes
              if e.attribute_dictionaries
                mes += "Entity attribute dictionaries:\n"
                names = ""
                e.attribute_dictionaries.each {|dic|
                  mes += "  Dictionary name: #{dic.name}\n"
                  dic.each { | key, value |
                    mes += "    " + key.to_s + '=' + value.to_s + "\n"
                  }
                }
              else
                mes += "No entity attributes defined.\n"
              end

              # Check for component attributes
              if e.is_a? Sketchup::ComponentInstance and e.definition.attribute_dictionaries
                mes += "Definition attribute dictionaries:\n"
                names = ""
                e.definition.attribute_dictionaries.each {|dic|
                  mes += "   Dictionary name: #{dic.name}\n"
                  dic.each { | key, value |
                    mes += "      " + key.to_s + '=' + value.to_s + "\n"
                  }
                }
              else
                mes += "No definition attributes defined.\n"
              end

              mes += "\n"

            }

            UI.messagebox mes , MB_MULTILINE, "List Current Selection's Attributes"

          end  # add_action_callback("att_explore")


          ## =====================

          ## Callback to INSERT the selection reference

          add_action_callback("insert_ref") do |dlg, params|

            ents = []
            Sketchup.active_model.selection.each { | e |
              # Use persistent ID when available
              Sketchup.version.to_f < 17 ? ents << e.entityID : ents << e.persistent_id
            }
            dlg.execute_script("editor.replaceSelection('#{ents}')")

          end  # add_action_callback("insert_ref")


          ## =====================

          ## Callback to show RUBY CONSOLE

          add_action_callback("show_console") do |dlg, params|

            Sketchup.send_action "showRubyPanel:"

          end  # add_action_callback("show_console")


          ## =====================

          ## Callback to show PLUGIN FOLDER

          add_action_callback("plugin_folder") do |dlg, params|

            UI.openURL("file:///#{Sketchup.find_support_file('Plugins')}")

          end  # add_action_callback("plugin_folder")          


          ## =====================

          ## Callback to show HELP dialog in browser

          add_action_callback("help") do |dlg, params|

            AS_RubyEditor::browser( "#{AS_RubyEditor::EXTTITLE} - Help" , "https://alexschreyer.net/projects/sketchup-ruby-code-editor/" )

          end  # add_action_callback("help")


          ## =====================

          ## Callback to show REFERENCE BROWSER dialog

          add_action_callback("browser") do |dlg, params|

            AS_RubyEditor::browser( "#{AS_RubyEditor::EXTTITLE} - Reference Browser" , File.join( AS_RubyEditor::EXTDIR , 'as_rubyeditor' , 'ui-browser.html' ) , true )

          end  # add_action_callback("browser")


       end # initialize


    end # class RubyEditor


    ## =====================

    ## Show local or remote website either as a WebDialog or HtmlDialog

    def self.browser( title , loc , isfile = false )

      if Sketchup.version.to_f < 17 then  # Use old WebDialog method
        d = UI::WebDialog.new( title , true ,
          title.gsub(/\s+/, "_") , 1000 , 600 , 100 , 100 , true);
        d.navigation_buttons_enabled = false
        isfile ? d.set_file( loc ) : d.set_url( loc )
        d.show
      else  # Use new HtmlDialog
        d = UI::HtmlDialog.new( { :dialog_title => title, :width => 1000, :height => 600,
          :style => UI::HtmlDialog::STYLE_DIALOG, :preferences_key => title.gsub(/\s+/, "_") } )
        isfile ? d.set_file( loc ) : d.set_url( loc )
        d.show
        d.center
      end

    end  # def self.browser


    ## =====================

    ## Add menu items

    unless file_loaded?(__FILE__)

      # Add main menu items
      sub = UI.menu("Window").add_submenu( "Ruby Code Editor" )
      sub.add_item("Ruby Code Editor") { editordlg = AS_RubyEditor::RubyEditor.new }
      sub.add_item("Reference Browser") { self.browser( "#{AS_RubyEditor::EXTTITLE} - Reference Browser" , File.join( AS_RubyEditor::EXTDIR , 'as_rubyeditor' , 'ui-browser.html' ) , true ) }
      sub.add_item("Help") { self.browser( "#{AS_RubyEditor::EXTTITLE} - Help" , "https://alexschreyer.net/projects/sketchup-ruby-code-editor/" ) }

      # Add toolbar
      as_rce_tb = UI::Toolbar.new "Ruby Code Editor"
      as_rce_cmd = UI::Command.new("Ruby Code Editor") { editordlg = AS_RubyEditor::RubyEditor.new }
      # One instance only version:
      # as_rce_cmd = UI::Command.new("Ruby Code Editor") { editordlg = AS_RubyEditor::RubyEditor.new unless editordlg }
      if Sketchup.version.to_i >= 16
        if RUBY_PLATFORM =~ /darwin/
          as_rce_cmd.small_icon = "img/tb_rubyeditor.pdf"
          as_rce_cmd.large_icon = "img/tb_rubyeditor.pdf"
        else
          as_rce_cmd.small_icon = "img/tb_rubyeditor.svg"
          as_rce_cmd.large_icon = "img/tb_rubyeditor.svg"
        end
      else
        as_rce_cmd.small_icon = "img/tb_rubyeditor_16.png"
        as_rce_cmd.large_icon = "img/tb_rubyeditor_24.png"
      end
      as_rce_cmd.tooltip = "Ruby Code Editor"
      as_rce_cmd.status_bar_text = "Edit and run Ruby scripts in a nice-looking dialog"
      as_rce_cmd.menu_text = "Ruby Code Editor"
      as_rce_tb = as_rce_tb.add_item as_rce_cmd
      as_rce_tb.show

      # Tell SU that we loaded this file
      file_loaded(__FILE__)

    end  # unless


    ## =====================


  end  # module AS_RubyEditor

end  # module AS_Extensions


## =====================
