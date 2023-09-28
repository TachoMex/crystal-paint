require "./line"

module Tools
  class Heart < Line
    def draw(x, y)
      dx = (x - @last_x).abs
      dy = y - @last_y
      @canvas.heart(@last_x, @last_y, dx, dy)
    end
  end
end
