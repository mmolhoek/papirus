# The PaPiRus::Display can be use to send image data to the
# epd fuse driver
#
# Example usage
#    require 'papirus'
#    require 'papirus/rmagick'
#    display = PaPiRus::Display.new()
#    image = Magick::Image::read('/path/to/img/file.[png|jpg|etc]').first
#    display.show(image.to_bit_stream(display.width, display.height))
module PaPiRus
    # Default epd driver path
    EPDPATH = '/dev/epd'

    class Display
        attr_reader :epd_path, :width, :height, :panel, :cog, :film, :auto, :allowed_commands, :display_path
        attr_accessor :rotation, :inverse, :image
        # The possible commands to send to the display with {PaPiRus::Display.command}
        # can be either
        #  'U' for update
        #  'F' for fast update
        #  'P' for partial update
        #  or 'C' for clearing the display
        # @return [Array<String>] All allowed command strings
        attr_reader :allowed_commands
        # By default, no parameters need to be passed to initialize. It will read all display settings
        # from the panel info file that is created by the fuse driver. However, if you want to test
        # without the display being available, you can pass a fake epd_path set to a folder in /tmp
        # in that case initialize will use all other params to create a fake fuse structure
        #  PaPiRus display sizes:
        #  1.44"     128 x 96
        #  1.9"      144 x 128
        #  2.0"      200 x 96
        #  2.6"      232 x 128
        #  2.7"      264 x 176
        # All the examples used in the documentation are also used to unit testing the code with
        # yard:doctest[https://github.com/p0deje/yard-doctest],
        # so we have duomentation and testing in one go, great!
        # * the display that is used for the examples is a 8x3 mini display for the sake of simplicity.
        # * imagewithline is a test helper that create an image of 8x3 pixels
        # * testdisplaylookslike is a test helper that shows the bit content of the display
        # * lastcommand is a test helper that will show the last command send to the display
        # @example Initializing the real display
        #   display = PaPiRus::Display.new()
        # @example Initializing the display for testing the 2.7 display
        #   display = PaPiRus::Display.new(options:{epd_path: '/tmp/epd', width: 264, height: 176, panel: 'EPD 2.7'})
        # @param [Hash] options The options setup options when using a fake display file structure for testing.
        # @option options [String] :epd_path ('/tmp/epd') The path to the fake display fuse folder
        # @option options [Integer] :width (200) The width of the fake display (defaults to the 2.0 display size)
        # @option options [Integer] :height (96) The height of the fake display
        # @option options [String] :panel ('EPD 2.0') The panel type
        # @option options [String] :cog (2)
        # @option options [String] :film (231)
        # @option options [Boolean] :auto (false)
        # @option options [Boolean] :inverse (false)
        # @option options [Integer] :rotation (0)
        def initialize(options: {})
            initializeOptions(options: options)
            createFakeEpdFileStructure(epd_path: @epd_path) if @epd_path != EPDPATH
            updateOptionsFromPanel
        end

        # Show can be used to send raw image data to the display.
        # @param data [raw image data file] The file containing the raw 1-bits 2 color image bitmap without any header/footer/imageinfo
        # @param command ['U'|'F'|'P']
        # @example Show simpel image
        #  display.show(data: imagewithline)
        #  testdisplaylookslike #=> '000000001111111100000000'
        #  lastcommand #=> 'U'
        # @see #initialize if you are wondering what display type is used for the tests and what imagewithline  and lastcommand is all about
        def show(data:, command: 'U')
            File.open(File.join(@epd_path, "LE", "display#{@inverse ? '_inverse': ''}"), 'wb') do |io|
                io.write data
            end
            command(@allowed_commands.include?(command) ? command : 'U')
        end

        # Send the fast update command to the display
        # @example Fast Update example
        #  display.fast_update
        #  lastcommand #=> 'F'
        def fast_update()
            command('F')
        end

        # Send the partial update command to the display
        # @example Partial Update example
        #  display.partial_update
        #  lastcommand #=> 'P'
        def partial_update()
            command('P')
        end

        # Send the full update command to the display
        # @example Full Update example
        #  display.update
        #  lastcommand #=> 'U'
        def update()
            command('U')
        end

        # Send the clear command to the display
        # @example Clear the display
        #  display.clear
        #  lastcommand #=> 'C'
        def clear()
            command('C')
        end

        # Send's the display command to the driver
        # available commands are
        #   * 'U' => update the display
        #   * 'F' => fast update the display
        #   * 'P' => Partial update the display
        #   * 'C' => Clear the display
        # @param c [String] command to execute
        #
        # @example Clear the display
        #   display.command('C')
        #   lastcommand #=> 'C'
        # @example Update the display
        #   display.command('U')
        #   lastcommand #=> 'U'
        # @example Fast update the display
        #   display.command('F')
        #   lastcommand #=> 'F'
        # @example Partial update the display
        #   display.command('P')
        #   lastcommand #=> 'P'
        def command(c)
            raise "command #{c} does not exist" unless @allowed_commands.include?(c)
            File.open(File.join(@epd_path, "command"), "wb") do |io|
                io.write(c)
            end
        end

    private
        # Creates a fake test structure of the display fuse driver
        def createFakeEpdFileStructure(epd_path:)
            # assuming we use a test dir and it is not created yet
            # test dirs can only be subdir of /tmp/
            raise 'epd test path should be located somewhere in /tmp/' unless epd_path =~ /\/tmp\/\w+/
            require 'fileutils'
            #remove old test dir as it may be a different display size/type
            if File.exists?(epd_path)
                FileUtils.rm_f(epd_path)
            end
            #create all folders and files
            FileUtils.mkdir_p(File.join([epd_path, 'LE']))
            %w{command LE/display, LE/display_inverse}.each do |file|
                FileUtils.touch File.join([epd_path, file])
            end
            #create the panel info file
            File.open(File.join([epd_path, 'panel']), 'w+') do |file|
                file.write %{#{@panel} #{@width}x#{@height} COG #{@cog} FILM #{@film}\n}
            end
        end

        # Reads all panel info from /dev/epd/panel and updates the according attributes
        def initializeOptions(options:)
            @allowed_commands = ['F', 'P', 'U', 'C']
            @epd_path = options[:epd_path] || EPDPATH
            @width = options[:width] || 200
            @height = options[:height] || 96
            @panel = options[:panel] || "EPD 2.0"
            @cog = options[:cog] || 2
            @film = options[:film] || 231
            @auto = options[:auto] || false
            @inverse = options[:inverse] || false
            @rotation = options[:rotation] || 0
        end

        def updateOptionsFromPanel
            if File.exists?(File.join(@epd_path, 'panel'))
                info = File.read(File.join(@epd_path, 'panel'))
                @display_path = File.join([@epd_path, 'LE', 'display'])
                if match = info.match(/^([A-Za-z]+\s+\d+\.\d+)\s+(\d+)x(\d+)\s+COG\s+(\d+)\s+FILM\s+(\d+)\s*$/)
                    @panel, @width, @height, @cog, @film = match.captures.each_with_index.map{|val, index| index > 0 ? val.to_i : val}
                else
                    STDERR.puts "did not recognize display info: #{info}, is the epd driver properly installed? have a look at the README.md to see how to install the epaper driver"
                    exit 1
                end
            else
                STDERR.puts "could not find the epd driver at #{@epd_path}, is the epd driver properly installed? have a look at the README.md to see how to install the epaper driver"
                exit 1
            end
        end
    end
end
