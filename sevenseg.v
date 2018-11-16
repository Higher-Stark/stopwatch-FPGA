/*
 * File name    : sevenseg.v
 * Module name  : sevenseg
 * Author       : Higher Stark
 * Date         : 2018/11/09
 * 
 * Description:
 * This is a module to show decimal number
 */
module sevenseg(data, show);
input   [3:0]  data;
output  [6:0]  show;

reg     [6:0]  show;

always @ (*)
begin
  case (data)
  4'd0: show = 7'b100_0000;
  4'd1: show = 7'b111_1001;
  4'd2: show = 7'b010_0100;
  4'd3: show = 7'b011_0000;
  4'd4: show = 7'b001_1001;
  4'd5: show = 7'b001_0010;
  4'd6: show = 7'b000_0010;
  4'd7: show = 7'b111_1000;
  4'd8: show = 7'b000_0000;
  4'd9: show = 7'b001_0000;
  default: show = 7'b111_1111;
  endcase
end
endmodule