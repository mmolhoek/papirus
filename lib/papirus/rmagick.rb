require 'rmagick'

class Magick::Image
    # Creates a simple map of the image of '0's and '1's to STDERR
    # this way you can view your image from the terminal
    # set your terminals font very small, so the image will fit on your screen
    # @param width[integer] The width of the image to inspect
    # @param height[integer] The height of the image to inspect
    def inspect_bitstream(width, height)
        STDERR.puts to_1_bit_2_color_bw_image(width, height).get_pixels(0, 0, width, height).each_slice(width).map{|row| row.each_slice(8).map{|pixels|pixels.map{|pixel| pixel.blue == 0 ? '1' : '0'}.join}.join(' ')}.join("\n")
    end

    # Creates a 1-bit 2-color image of whatever image is loaded
    # image is rescaled to fit the width/height and is placed in the middle
    # @param width[integer] width the image should be scaled to
    # @param height[integer] height the image should be scaled to
    def to_1_bit_2_color_bw_image(width, height)
        # Resize to fit the screen
        resized = resize_to_fit(width, height)
        # Reduce the image to a limited number of colors for a "poster" effect, brings it donw to 4-bit 16 colors
        posterized = resized.posterize(2)
        #now, as the display expects a file with all pixels set, we need to extend the image to the display size
        #if it is smaller in either width or height or both
        if (posterize.columns != width or posterize.rows != height)
            # extent fill color
            posterized.background_color = "#FFFFFF"
            # calculate necessary translation to center image on background
            x = (posterized.columns - width) / 2
            y = (posterized.rows - height) / 2
            # now, 'extent' the image to the correct size with the image centered
            posterized = posterized.extent(width, height, x, y)
        end
        # Now, make grayscale with only 2 colors, b/w, brings it down to 1-bit 2 colors
        return posterized.quantize(2, Magick::GRAYColorspace)
    end

    # As the EPD display needs 1-bit per pixel, which get written as a string to the fuse-fs display file
    # we need to load all the bits together in bytes, and packed those bytes into a string
    # @param width[integer] width the image should be scaled to
    # @param height[integer] height the image should be scaled to
    # @param inverse[boolean] wether the image should be made negative
    def to_bit_stream(width, height, inverse = false)
        bytes =[]
        # First, we convert whatever image we got to a 1-bit 2-color image,
        # then we traverse over the pixels in byte (8 bits) chucks to create our output bytes
        to_1_bit_2_color_bw_image(width, height).get_pixels(0, 0, width, height).each_slice(8).map do |pixels|
            #we create a byte with its bits set to 00000000
            byte = 0
            0.upto(7) do |bit|
                #and switch the bit to 1 (or 0 if not inverse) for each pixel if it was white
                #we have to check pixels[7-bit] as the order is right to left
                byte |= 1 << bit if (inverse && pixels[7-bit].blue == 65535) || (!inverse && pixels[7-bit].blue == 0)
            end
            #and add it to the output byte stream
            bytes.push(byte)
        end
        #now we just need to pack all bytes into a file writable string
        bytes.pack('C*')
    end
end
