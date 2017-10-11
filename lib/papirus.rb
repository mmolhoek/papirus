module PaPiRus
    # The {PaPiRus::Display} can be use to send image data to the
    # epd fuse driver
    class Display
        attr_reader :epd_path, :width, :height, :panel, :cog, :film, :auto, :allowed_commands, :display_path
        attr_accessor :rotation, :inverse, :image
        # The possible commands to send to the display with {PaPiRus::Display.command}
        # can be eitheri
        # 'U' for update
        # 'F' for fast update
        # 'P' for partial update
        # or 'C' for clearing the screen
        attr_reader :allowed_commands

        def initialize(epd_path: '/dev/epd', width: 200, height: 96, panel: 'EPD 2.0', cog: 0, film: 0, auto: false, inverse: false, rotation: 0)
            #transver all vars to attr's
            method(__method__).parameters.each do |type, k|
                next unless type == :key
                v = eval(k.to_s)
                instance_variable_set("@#{k}", v) unless v.nil?
            end
            @allowed_commands = ['F', 'P', 'U', 'C']
            get_display_info_from_edp
        end

        def show(*args)
            raise 'you need to al least provide raw imagedata' if args.length == 0
            data = args[0]
            updatemethod = args[1] || 'U'
            File.open(File.join(@epd_path, "LE", "display#{@inverse ? '_inverse': ''}"), 'wb') do |io|
                io.write data
            end
            command(@allowed_commands.include?(updatemethod) ? updatemethod : 'U')
        end

        def fast_update()
            command('F')
        end

        def partial_update()
            command('P')
        end

        def update()
            command('U')
        end

        def clear()
            command('C')
        end

        # send's the display command to the driver
        # @param c [string] command to execute, have a look at {}
        def command(c)
            raise "command #{c} does not exist" unless @allowed_commands.include?(c)
            File.open(File.join(@epd_path, "command"), "wb") do |io|
                io.write(c)
            end
        end

    private
        # Reads all panel info and updates the according attributes
        def get_display_info_from_edp
            if File.exists?(File.join(@epd_path, 'panel'))
                info = File.read(File.join(@epd_path, 'panel'))
                @display_path = File.join([@epd_path, 'LE', 'display'])
                if match = info.match(/^([A-Za-z]+\s+\d+\.\d+)\s+(\d+)x(\d+)\s+COG\s+(\d+)\s+FILM\s+(\d+)\s*$/)
                    @panel, @width, @height, @cog, @film = match.captures.each_with_index.map{|val, index| index > 0 ? val.to_i : val}
                else
                    STDERR.puts "did not recognize screen info: #{info}, is the epd driver properly installed? have a look at the README.md to see how to install the epaper driver"
                    exit 1
                end
            else
                STDERR.puts "could not find the epd driver at #{@epd_path}, is the epd driver properly installed? have a look at the README.md to see how to install the epaper driver"
                exit 1
            end
        end

    end
end
