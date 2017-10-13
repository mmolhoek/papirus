require 'chunky_png'

module ChunkyPNG::Canvas::StreamExporting
    # Creates a simple map of the image of '0's and '1's to STDERR
    # this way you can view your image from the terminal
    # set your terminals font very small, so the image will fit on your screen
    # @param width[integer] The width of the image to inspect
    # @param height[integer] The height of the image to inspect
    def inspect_bitstream(width, height)
        STDERR.puts to_1_bit_2_color_bw_image(width, height).each_slice(width).map{|row| row.each_slice(8).map{|pixels|pixels.map{|pixel| pixel < 128 ? '0' : '1'}.join}.join(' ')}.join("\n")
    end

    # Creates a rescaled image of whatever image is loaded
    # image is rescaled to fit the width/height and is placed in the middle
    # @param width[integer] width the image should be scaled to
    # @param height[integer] height the image should be scaled to
    def to_1_bit_2_color_bw_image(width, height)
        resize(width, height).pixels.map{|pixel| ChunkyPNG::Color.grayscale_teint(pixel)}
    end
    # As the EPD display needs 1-bit per pixel, which get written as a string to the fuse-fs display file
    # and the ChunkyPNG library works with 4 bytes data per pixel (1 byte for R, G, B and transparancy)
    # we need to load all the bits together in bytes, and packed those bytes into a string
    # @param width[integer] width the image should be scaled to
    # @param height[integer] height the image should be scaled to
    # @param inverse[boolean] wether the image should be made negative
    # @param mingray{intergeri (0-255)] what grayscale value or higher is needed, to turn a bit on
    def to_bit_stream(width, height, inverse = false, mingray = 128)
        bytes = []
        #for each 8 pixels (the ChunkyPNG library keeps an array of all pixels used, containing ChunkyPNG::Color elements)
        to_1_bit_2_color_bw_image(width, height).each_slice(8).map do |pixels|
            #we create a byte with its bits set to 00000000
            byte = 0
            0.upto(7) do |bit|
                #and switch the bit to 1 (or 0 if not inverse) for each pixel if it was white
                #we have to check pixels[7-bit] as the order is right to left
                byte |= 1 << bit if (inverse && pixels[7-bit] > mingray) || (!inverse && pixels[7-bit] < mingray)
            end
            #and add it to the output byte stream
            bytes.push(byte)
        end
        #now we just need to pack all bytes into a file writable string
        bytes.pack('C*')
    end
end
