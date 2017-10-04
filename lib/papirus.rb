require_relative "edp"
require_relative "image"

module Papirus
    def create_canvas_from_image(filename)
        Papirus::Canvas.new({filename:filename})
    end
    def create_canvas(params)
        if !params[:type]
            params[:type] = :chunky
        end
        Papirus::Canvas.new(params)
    end
end

#basic test of drawing some circles
canvas = Papirus::create_canvas({epd_path: 'test'})
canvas.clear()
10.step(70, 5) do |radius|
    canvas.circle(canvas.width/2, canvas.height/2, radius)
    canvas.display()
end
