/* 
 * File name      : count.v
 * Module name    : count
 * Author         : Higher Stark
 * 
 * Description  :
 * A clumsy stopwatch implemented by Higher Stark
 */
`timescale 1 ns/ 1 ns
module count(clk, key_reset, key_start_pause, key_display, 
                    hex0, hex1, hex2, hex3, hex4, hex5, 
                    led0, led1, led2, led3                  );

input          clk, key_reset, key_start_pause, key_display;

output  [6:0]  hex0, hex1, hex2, hex3, hex4, hex5;
output         led0, led1, led2, led3;

wire [6:0]  hex0, hex1, hex2, hex3, hex4, hex5;
// led0 - working
// led1 - counting
// led2 - display
reg         led0, led1, led2, led3;

// clock pluse counter
reg [31:0] cnt;
reg        pulse;
reg [3:0]  ms_counter_low, ms_counter_high, sec_counter_low, sec_counter_high, min_counter_low, min_counter_high; // count time
reg [3:0]  ms_display_low, ms_display_high, sec_display_low, sec_display_high, min_display_low, min_display_high; // show time

reg     working;
reg     counting;
reg     display;

wire     reset_set;
wire     start_set;
wire     display_set;

parameter   COUNTS=500000, DELAY=10000000;

sevenseg    led8_ms_display_low(.data(ms_display_low), .show(hex0));
sevenseg    led8_ms_display_high(.data(ms_display_high), .show(hex1));
sevenseg    led8_sec_display_low(.data(sec_display_low), .show(hex2));
sevenseg    led8_sec_display_high(.data(sec_display_high), .show(hex3));
sevenseg    led8_min_display_low(.data(min_display_low), .show(hex4));
sevenseg    led8_min_display_high(.data(min_display_high), .show(hex5));

debounce    rst(.clk(clk), .button(key_reset), .pressed(reset_set));
debounce    stt(.clk(clk), .button(key_start_pause), .pressed(start_set));
debounce    dsp(.clk(clk), .button(key_display), .pressed(display_set));

initial
begin
  cnt = 32'd0;
  pulse = 1'd0;
  ms_counter_low = 4'd0;
  ms_counter_high = 4'd0;
  sec_counter_low = 4'd0;
  sec_counter_high = 4'd0;
  min_counter_low = 4'd0;
  min_counter_high = 4'd0;
  working = 1'b0;
  counting = 1'b0;
  display = 1'b0;
end

always @ (posedge clk)
begin
  if (reset_set) 
  cnt = 32'd0;
  else 
  begin
    if (working & counting)
	 begin
		cnt = (cnt == COUNTS) ? 32'd0 : cnt + 1;
	 end
    else 
    begin
      cnt = cnt;
    end
  end
end

// reset
always @ (posedge clk)
begin
  if (reset_set)
  working = 1'b0;
  else if (start_set)
  working = 1'b1;
  else
  working = working;
  led0 = working;
end
// start/pause
always @ (posedge clk)
begin
  if (reset_set)
  counting = 1'b0;
  else if (start_set)
  counting = ~counting;
  else
  counting = counting;
  led1 = counting;
end
// display
always @ (posedge clk)
begin
  if (reset_set)
  display = 1'b0;
  else if (display_set)
  display = ~display;
  else 
  display = display;
  led2 = display;
end

always @ (posedge clk)
begin
    if (cnt == COUNTS) pulse = 1'b1;
    else pulse = 1'b0;
end
// 0.01s
always @ (posedge clk)
begin
  if (reset_set) ms_counter_low = 4'd0;
  else 
  begin
    if (ms_counter_low == 4'd10)
    ms_counter_low = 4'd0;
    else 
    ms_counter_low = ms_counter_low;

    if (pulse) 
    ms_counter_low = ms_counter_low + 4'd1;
    else 
    ms_counter_low = ms_counter_low;
  end
end
// 0.1s
always @ (posedge clk)
begin
  if (reset_set) ms_counter_high = 4'd0;
  else 
  begin
    if (ms_counter_high == 4'd10)
    ms_counter_high = 4'd0;
    else 
    ms_counter_high = ms_counter_high;

    if (ms_counter_low == 4'd10)
    ms_counter_high = ms_counter_high + 4'd1;
    else
    ms_counter_high = ms_counter_high;
  end
end
// 1s
always @ (posedge clk)
begin
  if (reset_set) sec_counter_low = 4'd0;
  else 
  begin
    if (sec_counter_low == 4'd10)
    sec_counter_low = 4'd0;
    else 
    sec_counter_low = sec_counter_low;

    if (ms_counter_high == 4'd10) 
    sec_counter_low = sec_counter_low + 4'd1;
    else 
    sec_counter_low = sec_counter_low;
  end
end
// 10s
always @ (posedge clk)
begin
  if (reset_set) sec_counter_high = 4'd0;
  else 
  begin
    if (sec_counter_high == 4'd6)
    sec_counter_high = 4'd0;
    else 
    sec_counter_high = sec_counter_high;

    if (sec_counter_low == 4'd10)
    sec_counter_high = sec_counter_high + 4'd1;
    else
    sec_counter_high = sec_counter_high;
  end
end
// 1min
always @ (posedge clk)
begin
  if (reset_set) min_counter_low = 4'd0;
  else 
  begin
    if (min_counter_low == 4'd10)
    min_counter_low = 4'd0;
    else 
    min_counter_low = min_counter_low;

    if (sec_counter_high == 4'd6) 
    min_counter_low = min_counter_low + 4'd1;
    else 
    min_counter_low = min_counter_low;
  end
end
// 10 min
always @ (posedge clk)
begin
  if (reset_set) min_counter_high = 4'd0;
  else 
  begin
    if (min_counter_high == 4'd6)
    min_counter_high = 4'd0;
    else 
    min_counter_high = min_counter_high;

    if (min_counter_low == 4'd10)
    min_counter_high = min_counter_high + 4'd1;
    else
    min_counter_high = min_counter_high;
  end
end
// display control
always @ (posedge clk)
begin
  if (~display) 
  begin
    ms_display_low = (ms_counter_low == 4'd10) ? 4'd0 : ms_counter_low;
    ms_display_high = (ms_counter_high == 4'd10) ? 4'd0 : ms_counter_high;
    sec_display_low = (sec_counter_low == 4'd10) ? 4'd0 : sec_counter_low;
    sec_display_high = (sec_counter_high == 4'd6) ? 4'd0 : sec_counter_high;
    min_display_low = (min_counter_low == 4'd10) ? 4'd0 : min_counter_low;
    min_display_high = (min_counter_high == 4'd6) ? 4'd0 : min_counter_high;
  end
end

endmodule