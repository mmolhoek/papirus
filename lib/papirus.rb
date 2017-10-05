require_relative "chunky"

module PaPiRus
    class Display
        attr_reader :epd_path, :width, :height, :panel, :cog, :film, :auto
        attr_accessor :rotation, :inverse, :image

        def initialize(epd_path: '/dev/epd', width: 200, height: 96, panel: 'EPD 2.0', cog: 0, film: 0, auto: false, inverse: false, rotation: 0)
            #transver all vars to attr's
            method(__method__).parameters.each do |type, k|
                next unless type == :key
                v = eval(k.to_s)
                instance_variable_set("@#{k}", v) unless v.nil?
            end
            get_display_info_from_edp
        end

        def show(*args)
            raise 'you need to al least provide raw imagedata' if args.length == 0
            data = args[0]
            updatemethod = args[1] || 'U'
            File.open(File.join(@epd_path, "LE", "display#{@inverse ? '_inverse': ''}"), 'wb') do |io|
                io.write data
            end
            command(updatemethod)
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

    private
        def get_display_info_from_edp
            if File.exists?(File.join(@epd_path, 'panel'))
                info = File.read(File.join(@epd_path, 'panel'))
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

        def command(c)
            f = File.new(File.join(@epd_path, "command"), "wb")
            f.write(c)
        end
    end
end
