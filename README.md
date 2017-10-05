# papirus

ruby gem to talk to the PAPiRus display (wip)

* it is not working yet. please wait until I finished the first release and update the readme with instructions :)

## epaper fuse driver installation instructions (if you have not done that already ::)
```bash
sudo apt-get install libfuse-dev -y

mkdir /tmp/papirus
cd /tmp/papirus
git clone https://github.com/repaper/gratis.git

cd gratis
make rpi EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
make rpi-install EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
systemctl enable epd-fuse.service
systemctl start epd-fuse
```
## gem installation

```bash
$ gem install papirus
```
## usage

```ruby
require 'papirus'

# first we get ourself a display
display = PaPiRus::Display.new()

#lets get a clean clean png of the size of the display to play with using chunky_png
image = ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE)
#and we draw a circle on it which is about the size of the screen
image.circle(display.width/2, display.height/2, display.height/2-2)
# have a look at https://github.com/wvanbergen/chunky_png for more examples

#and last we dump the image as bitsteam to the display
display.show(image.to_bit_stream)

# now we could also change the circle and fast update the screen
image.replace!(ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE))
image.circle(display.width/2, display.height/2, display.height/4)
display.show(image.to_bit_stream, 'F')

## from here WIP
#or load a png
image = ChunkyPNG::Image.from_file(pngfile)
display.show(image.to_bit_stream)

# more control
display = PaPiRus::Display.new()
display.load(imagefile)

display.update #or
display.fast_update #or
display.partial_update

#or when testing to a temp file (run createtestepd.sh to create paths in /tmp)
display = PaPiRus::Display.new(epd_path: '/tmp/epd')

