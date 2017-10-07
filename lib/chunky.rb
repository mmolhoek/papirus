require 'chunky_png'

module ChunkyPNG::Canvas::StreamExporting
    def inspect_bitstream
        #create a simple map of the image of '0's and '1's
        #for debugging purpuses
        pixels.each_slice(@width).map{|row| row.each_slice(8).map{|pixels|pixels.map{|pixel| pixel == ChunkyPNG::Color::WHITE ? '0' : '1'}.join}.join(' ')}
    end

    def to_bit_stream(inverse = false)
        #as the ChunkyPNG library works with 4 bytes data per pixel (1 byte for R, G, B and transparancy)
        #and the EDP needs 1 bit per pixel (on or off), we need some way to traverse over all pixels
        #and add a bit to a byte stream for each pixel. so
        bytes = []
        #for each 8 pixels (the ChunkyPNG library keeps an array of all pixels used, containing ChunkyPNG::Color elements)
        pixels.each_slice(8).map do |pixels|
            #we create a byte with its bits set to 00000000
            byte = 0
            0.upto(7) do |bit|
                #and switch the bit to 1 (or 0 if not inverse) for each pixel if it was white
                #we have to check pixels[7-bit] as the order is right to left
                byte |= 1 << bit if (inverse && pixels[7-bit] == ChunkyPNG::Color::WHITE) || (!inverse && pixels[7-bit] != ChunkyPNG::Color::WHITE)
            end
            #and add it to the output byte stream
            bytes.push(byte)
        end
        #now we just need to pack all bytes into a file writable string
        bytes.pack('C*')
    end
end
