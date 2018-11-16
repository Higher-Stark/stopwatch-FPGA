/*
 * File name      : debounce.v
 * Module name    : debounce
 * Author         : Higher Stark
 * 
 * Description :
 * Debounce module
 * debounce key press only after DELAY cycles
 */
module debounce(clk, button, pressed);
input   clk, button;
output  pressed;

reg         pressed;
reg [31:0]  last;

parameter   DELAY=10000000;

always @ (posedge clk)
begin
  if (button)
  last = 32'd0;
  else 
  last = (last == DELAY) ? 32'd0 : last + 32'd1;
end

always @ (posedge clk)
begin
    if (button | last != DELAY)
    pressed = 1'b0;
    else 
    pressed = 1'b1;
end
endmodule