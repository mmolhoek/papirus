module Papirus
    class Edp
        attr_accessor :epd_path, :width, :height, :panel, :cog, :film, :auto, :rotation, :inverse, :image

        def initialize(args={})
            self.epd_path = args[:epd_path]|| '/dev/epd'
            self.width = args[:width] || 200
            self.height = args[:height] || 96
            self.panel = args[:panel] || 'EPD 2.0'
            self.cog = args[:cog] || 0
            self.film = args[:film] || 0
            self.auto = args[:auto] || false
            self.inverse = args[:auto] || true
            self.rotation = args[:rotation] || 0
        end


        def display(image)
            File.open(File.join(self.epd_path, "LE", "display_inverse"), 'wb') do |io|
                io.write image.to_bytes(self.inverse)
            end
            self.fast_update
        end

        def displayfile(pngfile)
            #does not work yet, as pixel not white will turn black, giving a black image
            self.png = ChunkyPNG::Image.from_file(pngfile)

            File.open(File.join(self.epd_path, "LE", "display"), 'wb') do |io|
                io.write self.png.to_bit_stream(self.inverse)
            end

            # Call the update
            self.update
        end

        def fast_update()
            self._command('F')
        end

        def partial_update()
            self._command('P')
        end

        def update()
            self._command('U')
        end

        def clear()
            self._command('C')
        end

        def _command(c)
            f = File.new(File.join(self.epd_path, "command"), "wb")
            f.write(c)
        end
    end
end
