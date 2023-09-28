require "./pen"

module Tools
  class Eraser < Pen
    def draw(x, y)
      @canvas.line(@last_x, @last_y, x, y) do
        @canvas.erase(x, y)
      end
    end
  end
end
