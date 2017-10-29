require 'lib/papirus'
require 'pry'
require 'pry-nav'
YARD::Doctest.configure do |doctest|
    #skip tests that are just documentation
    doctest.skip 'PaPiRus::Display#initialize'
    #clear the tracks before each test
    doctest.before do
        clearscreen
    end
end

#default display of 8 by 3 pixels (1 byte x 3) used for the tests
def display
    @display ||= PaPiRus::Display.new(options: {epd_path: '/tmp/epd', width:8, height:3})
end

#returns the contents of the display
def testdisplaylookslike
    File.read(File.join([display.epd_path,'LE','display'])).unpack('b*').first
end
def clearscreen
    [0,0,0].pack('C*')
end
def imagewithline
    [0,255,0].pack('C*')
end
def lastcommand
    File.read(File.join([display.epd_path,'command']))
end
